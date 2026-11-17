"""Turn per-state pose + loop descriptions into one timeline of Lottie tracks.

Every state gets three marked segments: `<state>.enter` (neutral -> pose,
with anticipation and overshoot), `<state>.loop` (seamless) and
`<state>.exit` (pose -> neutral). Neutral is the hub, so any state can
follow any other. Face swaps are hidden behind a blink.
"""
import math

from rig import G, bake

EYES = ['open', 'half', 'happy', 'sleep', 'squint', 'scared', 'big']
CLOSED_EYES = {'happy', 'sleep', 'squint'}  # line-art eyes: nothing to blink
MOUTHS = ['w', 'open', 'o', 'frown', 'wail', 'pant']
ENTER, EXIT = 14, 10


def find(node, name):
    if node['name'] == name:
        return node
    for c in node.get('children', []):
        hit = find(c, name) if c['t'] == 'g' or c['name'] == name else None
        if hit:
            return hit
    return None


def names(node):
    out = {node['name']}
    for c in node.get('children', []):
        out |= names(c)
    return out


def used_variants(states):
    """Eye and mouth variants the states show; the rest never need exporting."""
    eyes, mouths = {'open'}, {'w'}
    for _, s in states:
        eyes.add(s.get('face', {}).get('eyes', 'open'))
        mouths.add(s.get('face', {}).get('mouth', 'w'))
        for ch in list(s.get('pose', {})) + list(s.get('loop', {})):
            if ch.startswith('mouth_'):
                mouths.add(ch[6:].split('.')[0])
            elif ch[:5] in ('eyeL_', 'eyeR_'):
                eyes.add(ch[5:].split('.')[0])
    return [k for k in EYES if k in eyes], [k for k in MOUTHS if k in mouths]


def full_rig(pet, states):
    """The rig with every eye and mouth variant the states use as its own group.

    Each eye is  eyeSlot<S> > [ eye<S> > [ eye<S>Blink > open variants,
    closed variants ], brow<S> ].  Baked blinks scale eye<S>; the app's random
    blink scales eye<S>Blink, so brows and line-art eyes are never squashed.
    """
    eyes, mouths = used_variants(states)
    base = pet.build(brow_a=1e-9)
    for side in 'LR':
        slot = find(base, 'eye' + side)
        brows = [c for c in slot['children'] if c['name'].startswith('brow')]
        variant = {k: G(f'eye{side}_{k}', find(pet.build(eyes=k), 'eye' + side)['children'])
                   for k in eyes}
        live = G(f'eye{side}Blink', [variant[k] for k in eyes if k not in CLOSED_EYES])
        shut = [variant[k] for k in eyes if k in CLOSED_EYES]
        slot['name'] = f'eyeSlot{side}'
        slot['children'] = [G('eye' + side, [live] + shut)] + brows
    find(base, 'mouth')['children'] = [
        G(f'mouth_{k}', find(pet.build(mouth_k=k), 'mouth')['children']) for k in mouths]
    return bake(base)


def default(ch, face):
    if ch.endswith('.pos'):
        return (0, 0)
    if ch.endswith('.scale'):
        return (1, 1)
    if ch.endswith('.rot'):
        return 0
    name = ch[:-2]
    if name[:5] in ('eyeL_', 'eyeR_'):
        return 1 if name[5:] == face['eyes'] else 0
    if name.startswith('mouth_'):
        return 1 if name[6:] == face['mouth'] else 0
    if name.startswith('brow') or name.startswith('fx'):
        return 0
    return 1


def face_channels(face, eyes=EYES, mouths=MOUTHS):
    out = {}
    for k in eyes:
        out[f'eyeL_{k}.o'] = out[f'eyeR_{k}.o'] = 1 if k == face.get('eyes', 'open') else 0
    for k in mouths:
        out[f'mouth_{k}.o'] = 1 if k == face.get('mouth', 'w') else 0
    b = face.get('brow')
    out['browL.o'] = out['browR.o'] = 1 if b else 0
    out['browL.rot'], out['browR.rot'] = -(b or 0), (b or 0)
    return out


def _is_face(ch):
    return ch.endswith('.o') and ch.split('.')[0].split('_')[0] in (
        'eyeL', 'eyeR', 'mouth', 'browL', 'browR')


def wave(base, amp, period, length, phase=0.0):
    """A sine around base. length must be a whole number of periods.

    Keys sit on each peak and zero crossing. Every key
    carries its own ease, fitted to the sine's slope at both ends, so the
    motion between keys is a true sine and not a row of stop-start swings.
    """
    if abs(length / period - round(length / period)) > 1e-9:
        raise ValueError(f'wave: {length} frames is not a whole number of {period}s')
    vec = isinstance(base, tuple)
    add = (lambda k: tuple(b + a * k for b, a in zip(base, amp))) if vec else (
        lambda k: base + amp * k)
    w = 2 * math.pi / period
    k = lambda f: math.sin(w * f + 2 * math.pi * phase)
    slope = lambda f: w * math.cos(w * f + 2 * math.pi * phase)
    frames = {0, length}  # peaks and zero crossings, which may fall between frames
    for m in range(math.ceil(4 * phase), math.ceil(4 * (length / period + phase)) + 1):
        f = round((m / 4 - phase) * period, 3)
        if 0 < f < length:
            frames.add(int(f) if f == int(f) else f)
    frames = sorted(frames)
    keys = [(0, add(round(k(0), 6)), 'lin')]
    for f0, f1 in zip(frames, frames[1:]):
        rise, third = k(f1) - k(f0), (f1 - f0) / 3
        ease = 'lin' if abs(rise) < 1e-9 else (
            (1 / 3, slope(f0) * third / rise), (2 / 3, 1 - slope(f1) * third / rise))
        value = keys[0][1] if f1 == length else add(round(k(f1), 6))
        keys.append((f1, value, ease))
    return keys


def jitter(base, amp, step, start, end):
    """Fast alternating shake between start and end frames (linear)."""
    keys, sign = [(start, base, 'lin')], 1
    for f in range(start + step, end, step):
        keys.append((f, tuple(b + a * sign for b, a in zip(base, amp)), 'lin'))
        sign = -sign
    keys.append((end, base, 'lin'))
    return keys


def blink(at):
    keys = [(at, (1, 1), 'lin'), (at + 2, (1, .08), 'in'), (at + 3, (1, .08), 'lin'),
            (at + 6, (1, 1), 'out')]
    return {'eyeL.scale': keys, 'eyeR.scale': keys}


def zs(length):
    """Sleeping Zs drift up and fade, staggered."""
    out = {}
    for i in range(3):
        s = i * length // 3
        e = min(s + 50, length - 1)
        out[f'fxZ{i}.o'] = [(0, 0, 'lin'), (s, 0, 'lin'), (s + 12, 1, 'io'), (e, 0, 'io'),
                            (length, 0, 'lin')]
        out[f'fxZ{i}.pos'] = [(0, (0, 0), 'lin'), (s, (0, 0), 'hold'), (e, (10, -26), 'out'),
                              (length, (0, 0), 'hold')]
    return out


def hop(at, height, length=14, squash=.1):
    """One hop with anticipation squash, airborne stretch and landing squash."""
    a, top, land = at + 4, at + 4 + (length - 4) // 2, at + length
    return {
        'root.pos': [(at, (0, 0), 'lin'), (a, (0, 0), 'lin'), (top, (0, -height), 'out'),
                     (land, (0, 0), 'in')],
        'root.scale': [(at, (1, 1), 'lin'), (a, (1 + squash, 1 - squash * 1.2), 'io'),
                       (top, (1 - squash * .6, 1 + squash * .8), 'out'),
                       (land, (1, 1), 'in'), (land + 3, (1 + squash * .8, 1 - squash), 'out'),
                       (land + 8, (1, 1), 'back')],
    }


def _same(a, b):
    a, b = (a, b) if isinstance(a, tuple) else ((a,), (b,))
    return all(abs(x - y) < 1e-6 for x, y in zip(a, b))


def chain(length, *parts):
    """Merge key dicts and close every channel at the loop end with its first value.

    Moves on one channel must follow each other: a move that starts before
    the previous one has settled would silently overwrite its keys.
    """
    runs = {}
    for p in parts:
        for ch, keys in p.items():
            runs.setdefault(ch, []).append(sorted(keys, key=lambda k: k[0]))
    out = {}
    for ch, moves in runs.items():
        moves.sort(key=lambda m: m[0][0])
        keys = list(moves[0])
        for move in moves[1:]:
            if move[0][0] < keys[-1][0] or (
                    move[0][0] == keys[-1][0] and not _same(move[0][1], keys[-1][1])):
                raise ValueError(
                    f'chain: {ch} move starting on frame {move[0][0]} overlaps the one '
                    f'ending on frame {keys[-1][0]}')
            keys += move[1:] if move[0][0] == keys[-1][0] else move
        out[ch] = keys
    for ch, keys in out.items():
        if keys[0][0] != 0:
            keys.insert(0, (0, keys[0][1], 'lin'))
        if keys[-1][0] != length:
            keys.append((length, keys[0][1], 'io'))
    return out


def timeline(states, neutral_face=None):
    """states: [(name, dict(face=, pose=, loop=, length=))] -> tracks, markers, frames"""
    nf = dict(eyes='open', mouth='w', **(neutral_face or {}))
    used = used_variants(states)
    chans = set(face_channels(nf, *used)) | {'root.scale', 'eyeL.scale', 'eyeR.scale'}
    for _, s in states:
        chans |= set(s.get('pose', {})) | set(s.get('loop', {}))
    neutral = {ch: default(ch, nf) for ch in chans}
    tracks = {ch: [] for ch in chans}
    markers, t = [], 0
    for name, s in states:
        pose = dict(neutral)
        pose.update(face_channels(s.get('face', nf), *used))
        pose.update(s.get('pose', {}))
        loop = s.get('loop', {})
        for ch, keys in loop.items():  # a loop may define its own frame-0 value
            if keys and keys[0][0] == 0:
                pose[ch] = keys[0][1]
        L, a, b, c = s['length'], t, t + ENTER, t + ENTER + s['length']
        end = c + EXIT
        if s.get('face', nf).get('eyes', 'open') in CLOSED_EYES and (
                'eyeL.scale' in loop or 'eyeR.scale' in loop):
            raise ValueError(f'{name}: blink on closed eyes')
        closing = {}  # ease of each channel's last move, back onto the start pose
        for ch, keys in loop.items():
            for f, v, e in keys:
                if f > L:
                    raise ValueError(f'{name}: {ch} has a key on frame {f}, past the '
                                     f'{L}-frame loop')
                if f == L:
                    if not _same(v, pose[ch]):
                        raise ValueError(f'{name}: {ch} ends on {v} but starts on '
                                         f'{pose[ch]}; the loop would jump')
                    closing[ch] = e
        for ch in chans:
            tr, n, p, ce = tracks[ch], neutral[ch], pose[ch], closing.get(ch, 'lin')
            if _is_face(ch):
                tr += [(a, n, 'hold'), (a + 6, p, 'hold'), (c + 4, n, 'hold')]
            elif ch in ('eyeL.scale', 'eyeR.scale'):
                shut = (1, .08)
                tr += [(a, n, 'lin'), (a + 3, n, 'lin'), (a + 5, shut, 'in'),
                       (a + 7, shut, 'lin'), (a + 10, p, 'out'), (b, p, 'lin')]
                tr += [(c, p, ce), (c + 2, shut, 'in'), (c + 5, shut, 'lin'),
                       (c + 8, n, 'out'), (end, n, 'lin')]
            elif ch == 'root.scale':
                tr += [(a, n, 'lin'), (a + 4, (n[0] * 1.05, n[1] * .93), 'out'),
                       (b - 2, p, 'back'), (b, p, 'lin'),
                       (c, p, ce), (end - 3, (n[0] * .97, n[1] * 1.04), 'io'),
                       (end, n, 'io')]
            else:
                ease = 'io' if ch.endswith('.o') else 'back'
                tr += [(a, n, 'lin'), (a + 3, n, 'lin'), (b - 2, p, ease), (b, p, 'lin'),
                       (c, p, ce), (end, n, 'io')]
            for f, v, e in loop.get(ch, []):
                if 0 < f < L:
                    tr.append((b + f, v, e))
        markers += [(f'{name}.enter', a, ENTER), (f'{name}.loop', b, L),
                    (f'{name}.exit', c, EXIT)]
        t = end + 1
    return tracks, markers, t
