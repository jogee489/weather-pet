"""Turn per-state pose + loop descriptions into one timeline of Lottie tracks.

Every state gets three marked segments: `<state>.enter` (neutral -> pose,
with anticipation and overshoot), `<state>.loop` (seamless) and
`<state>.exit` (pose -> neutral). Neutral is the hub, so any state can
follow any other. Face swaps are hidden behind a blink.
"""
from rig import G, bake

EYES = ['open', 'half', 'happy', 'sleep', 'squint', 'scared', 'big']
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


def full_rig(pet):
    """The rig with every eye and mouth variant present as its own group."""
    base = pet.build(brow_a=1e-9)
    for side in 'LR':
        slot = find(base, 'eye' + side)
        brows = [c for c in slot['children'] if c['name'].startswith('brow')]
        slot['children'] = [
            G(f'eye{side}_{k}', [c for c in find(pet.build(eyes=k), 'eye' + side)['children']])
            for k in EYES] + brows
    find(base, 'mouth')['children'] = [
        G(f'mouth_{k}', find(pet.build(mouth_k=k), 'mouth')['children']) for k in MOUTHS]
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


def face_channels(face):
    out = {}
    for k in EYES:
        out[f'eyeL_{k}.o'] = out[f'eyeR_{k}.o'] = 1 if k == face.get('eyes', 'open') else 0
    for k in MOUTHS:
        out[f'mouth_{k}.o'] = 1 if k == face.get('mouth', 'w') else 0
    b = face.get('brow')
    out['browL.o'] = out['browR.o'] = 1 if b else 0
    out['browL.rot'], out['browR.rot'] = -(b or 0), (b or 0)
    return out


def _is_face(ch):
    return ch.endswith('.o') and ch.split('.')[0].split('_')[0] in (
        'eyeL', 'eyeR', 'mouth', 'browL', 'browR')


def wave(base, amp, period, length, phase=0.0):
    """Sine-like keys around base. length must be a whole number of periods."""
    vec = isinstance(base, tuple)
    add = (lambda k: tuple(b + a * k for b, a in zip(base, amp))) if vec else (
        lambda k: base + amp * k)
    import math
    keys, n = [], round(length / period * 4)
    for i in range(n + 1):
        f = round(i * period / 4)
        k = math.sin(2 * math.pi * (i / 4 + phase))
        keys.append((f, add(round(k, 6)), 'io' if abs(k) > .5 else 'io'))
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


def chain(length, *parts):
    """Merge key dicts and close every channel at the loop end with its first value."""
    out = {}
    for p in parts:
        for ch, keys in p.items():
            out.setdefault(ch, []).extend(keys)
    for ch, keys in out.items():
        keys.sort(key=lambda k: k[0])
        if keys[0][0] != 0:
            keys.insert(0, (0, keys[0][1], 'lin'))
        if keys[-1][0] != length:
            keys.append((length, keys[0][1], 'io'))
    return out


def timeline(states, neutral_face=None):
    """states: [(name, dict(face=, pose=, loop=, length=))] -> tracks, markers, frames"""
    nf = dict(eyes='open', mouth='w', **(neutral_face or {}))
    chans = set(face_channels(nf)) | {'root.scale', 'eyeL.scale', 'eyeR.scale'}
    for _, s in states:
        chans |= set(s.get('pose', {})) | set(s.get('loop', {}))
    neutral = {ch: default(ch, nf) for ch in chans}
    tracks = {ch: [] for ch in chans}
    markers, t = [], 0
    for name, s in states:
        pose = dict(neutral)
        pose.update(face_channels(s.get('face', nf)))
        pose.update(s.get('pose', {}))
        loop = s.get('loop', {})
        for ch, keys in loop.items():  # a loop may define its own frame-0 value
            if keys and keys[0][0] == 0:
                pose[ch] = keys[0][1]
        L, a, b, c = s['length'], t, t + ENTER, t + ENTER + s['length']
        end = c + EXIT
        for ch in chans:
            tr, n, p = tracks[ch], neutral[ch], pose[ch]
            if _is_face(ch):
                tr += [(a, n, 'hold'), (a + 6, p, 'hold'), (c + 4, n, 'hold')]
            elif ch in ('eyeL.scale', 'eyeR.scale'):
                shut = (1, .08)
                tr += [(a, n, 'lin'), (a + 3, n, 'lin'), (a + 5, shut, 'in'),
                       (a + 7, shut, 'lin'), (a + 10, p, 'out'), (b, p, 'lin')]
                tr += [(c, p, 'lin'), (c + 2, shut, 'in'), (c + 5, shut, 'lin'),
                       (c + 8, n, 'out'), (end, n, 'lin')]
            elif ch == 'root.scale':
                tr += [(a, n, 'lin'), (a + 4, (n[0] * 1.05, n[1] * .93), 'out'),
                       (b - 2, p, 'back'), (b, p, 'lin'),
                       (c, p, 'lin'), (end - 3, (n[0] * .97, n[1] * 1.04), 'io'),
                       (end, n, 'io')]
            else:
                ease = 'io' if ch.endswith('.o') else 'back'
                tr += [(a, n, 'lin'), (a + 3, n, 'lin'), (b - 2, p, ease), (b, p, 'lin'),
                       (c, p, 'lin'), (end, n, 'io')]
            for f, v, e in loop.get(ch, []):
                if 0 < f < L:
                    tr.append((b + f, v, e))
        markers += [(f'{name}.enter', a, ENTER), (f'{name}.loop', b, L),
                    (f'{name}.exit', c, EXIT)]
        t = end + 1
    return tracks, markers, t
