"""Export a rig tree plus animation tracks as a Lottie JSON document.

The whole pet is one shape layer; every rig group becomes a nested Lottie
shape group whose transform carries the animation. Only features every
Lottie player renders are emitted: paths, ellipses, solid and gradient
fills, strokes, group transforms and markers.
"""
import re

FPS = 30
EASE = {  # name -> (out handle of previous key, in handle of this key)
    'lin': ((0, 0), (1, 1)),
    'io': ((.42, 0), (.58, 1)),
    'out': ((.1, .1), (.3, 1)),
    'in': ((.5, 0), (.9, .9)),
    'back': ((.34, 1.56), (.64, 1)),
}
_TOK = re.compile(r'([MCLZ])|(-?\d+(?:\.\d+)?)')


def _rgb(h):
    return [round(int(h[i:i + 2], 16) / 255, 4) for i in (1, 3, 5)]


def _k(v):
    return {'a': 0, 'k': v}


def _r(v):
    return [round(x, 2) for x in v] if isinstance(v, (list, tuple)) else round(v, 2)


def _bezier(d):
    verts, ins, outs, closed, cmd, nums = [], [], [], False, None, []

    def flush():
        if cmd in ('M', 'L'):
            for i in range(0, len(nums), 2):
                verts.append(nums[i:i + 2]); ins.append([0, 0]); outs.append([0, 0])
        elif cmd == 'C':
            for i in range(0, len(nums), 6):
                c1, c2, p = nums[i:i + 2], nums[i + 2:i + 4], nums[i + 4:i + 6]
                outs[-1] = [c1[0] - verts[-1][0], c1[1] - verts[-1][1]]
                verts.append(p); ins.append([c2[0] - p[0], c2[1] - p[1]])
                outs.append([0, 0])

    for c, n in _TOK.findall(d):
        if c:
            flush()
            cmd, nums = c, []
            closed = closed or c == 'Z'
        else:
            nums.append(float(n))
    flush()
    if closed and len(verts) > 1 and all(abs(a - b) < .01 for a, b in zip(verts[0], verts[-1])):
        ins[0] = ins[-1]
        verts.pop(); ins.pop(); outs.pop()
    return {'c': closed, 'v': [_r(v) for v in verts], 'i': [_r(v) for v in ins],
            'o': [_r(v) for v in outs]}


def _fill(f, opacity=100):
    if not isinstance(f, dict):  # gradients render black in Flutter's HTML renderer
        return {'ty': 'fl', 'c': _k(_rgb(f) + [1]), 'o': _k(opacity), 'r': 1}
    raise ValueError('gradient fills are not exported; run rig.bake() first')


def _stroke(n):
    return {'ty': 'st', 'c': _k(_rgb(n['stroke']) + [1]), 'o': _k(100),
            'w': _k(n['sw']), 'lc': 2, 'lj': 2, 'ml': 4}


def _prop(keys, conv, dims, spatial=False):
    """keys: [(frame, value, ease)] where ease describes the move INTO that key."""
    keys = sorted({t: (t, v, e) for t, v, e in keys}.values())
    vals = [conv(v) for _, v, _ in keys]
    # Drop keys that sit between two identical neighbours: nothing moves there.
    keep = [i for i in range(len(keys))
            if i in (0, len(keys) - 1) or not vals[i - 1] == vals[i] == vals[i + 1]]
    keys, vals = [keys[i] for i in keep], [vals[i] for i in keep]
    if all(v == vals[0] for v in vals):
        return _k(vals[0] if dims > 1 else vals[0][0])
    out = []
    for i, (t, _, _) in enumerate(keys):
        kf = {'t': t, 's': vals[i]}
        if i + 1 < len(keys):
            ease = keys[i + 1][2]
            if ease == 'hold':
                kf['h'] = 1
            else:
                (ox, oy), (ix, iy) = EASE[ease]
                if spatial:
                    kf['o'], kf['i'] = {'x': ox, 'y': oy}, {'x': ix, 'y': iy}
                else:
                    kf['o'] = {'x': [ox] * dims, 'y': [oy] * dims}
                    kf['i'] = {'x': [ix] * dims, 'y': [iy] * dims}
        out.append(kf)
    return {'a': 1, 'k': out}


def _transform(n, tracks):
    px, py = n['pivot']
    nm = n['name']

    def tr(prop, default):
        return tracks.get(f'{nm}.{prop}') or [(0, default, 'lin')]

    return {
        'ty': 'tr', 'a': _k(_r([px, py])),
        'p': _prop(tr('pos', (0, 0)),
                   lambda v: _r([px + n['tx'] + v[0], py + n['ty'] + v[1]]), 2, True),
        's': _prop(tr('scale', (1, 1)),
                   lambda v: _r([n['sx'] * v[0] * 100, n['sy'] * v[1] * 100]), 2),
        'r': _prop(tr('rot', 0), lambda v: [_r(n['rot'] + v)], 1),
        'o': _prop(tr('o', 1), lambda v: [_r(n['opacity'] * v * 100)], 1),
        'sk': _k(0), 'sa': _k(0),
    }


def _node(n, tracks):
    if n['t'] == 'g':
        # Lottie paints the first item on top, so reverse the paint order.
        items = [_node(c, tracks) for c in reversed(n['children'])]
        return {'ty': 'gr', 'nm': n['name'], 'it': items + [_transform(n, tracks)]}
    if n['t'] == 'e':
        geo = {'ty': 'el', 'd': 1, 'p': _k(_r([n['cx'], n['cy']])),
               's': _k(_r([n['rx'] * 2, n['ry'] * 2]))}
    else:
        geo = {'ty': 'sh', 'ks': _k(_bezier(n['d']))}
    paint = []
    if n['stroke']:
        paint.append(_stroke(n))
    if n['fill']:
        paint.append(_fill(n['fill']))
    if n.get('behind'):
        paint.reverse()  # fill listed first, so the stroke sits underneath
    ident = {'ty': 'tr', 'a': _k([0, 0]), 'p': _k([0, 0]),
             's': _k([100, 100]), 'r': _k(0), 'o': _k(_r(n['opacity'] * 100)),
             'sk': _k(0), 'sa': _k(0)}
    return {'ty': 'gr', 'nm': n['name'], 'it': [geo] + paint + [ident]}


def export(root, tracks, frames, markers, size=512):
    """markers: [(name, start_frame, duration_frames)]"""
    layer = {
        'ty': 4, 'nm': root['name'], 'ind': 1, 'ddd': 0, 'ip': 0, 'op': frames,
        'st': 0, 'sr': 1, 'ao': 0, 'bm': 0,
        'ks': {'o': _k(100), 'r': _k(0), 'p': _k([0, 0, 0]), 'a': _k([0, 0, 0]),
               's': _k([100, 100, 100])},
        'shapes': [_node(root, tracks)],
    }
    return {
        'v': '5.7.4', 'nm': root['name'], 'fr': FPS, 'ip': 0, 'op': frames,
        'w': size, 'h': size, 'ddd': 0, 'assets': [], 'layers': [layer],
        'markers': [{'cm': n, 'tm': t, 'dr': d} for n, t, d in markers],
    }
