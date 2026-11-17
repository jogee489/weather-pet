"""Tiny vector scene model shared by the SVG (model sheet) and Lottie emitters.

Nodes are plain dicts. Paths use an absolute M/C/L/Z subset so they map
one-to-one onto Lottie bezier shapes.
"""
import re

W = 512  # artboard is W x W, character centred on x = W/2


def G(name, children, pivot=(0, 0), tx=0, ty=0, rot=0, sx=1, sy=1, opacity=1):
    return dict(t='g', name=name, children=[c for c in children if c],
                pivot=pivot, tx=tx, ty=ty, rot=rot, sx=sx, sy=sy,
                opacity=opacity)


def P(name, d, fill=None, stroke=None, sw=0, opacity=1, behind=False):
    """Path. behind=True paints the stroke under the fill (outer half shows)."""
    return dict(t='p', name=name, d=d, fill=fill, stroke=stroke, sw=sw,
                opacity=opacity, behind=behind)


def E(name, cx, cy, rx, ry, fill=None, stroke=None, sw=0, opacity=1,
      behind=False):
    return dict(t='e', name=name, cx=cx, cy=cy, rx=rx, ry=ry, fill=fill,
                stroke=stroke, sw=sw, opacity=opacity, behind=behind)


def radial(cx, cy, r, *stops):
    """Radial gradient fill; stops are (offset, '#hex') pairs."""
    return dict(g='radial', c=(cx, cy), r=r, stops=stops)


def linear(x1, y1, x2, y2, *stops):
    return dict(g='linear', p1=(x1, y1), p2=(x2, y2), stops=stops)


def num(v, places=4):
    """A number as plain decimals: never an exponent, never '-0'."""
    s = f'{round(float(v), places):.{places}f}'.rstrip('0').rstrip('.')
    return '0' if s in ('-0', '') else s


def commands(d):
    """Split a path string into [(command, [numbers])]; rejects anything else."""
    bad = re.search(r'[^MCLZ\d\s.\-]', d)
    if bad:
        raise ValueError(f'unsupported character {bad.group()!r} in path: {d[:60]}')
    return [(cmd, [float(n) for n in _NUM.findall(body)])
            for cmd, body in re.findall(r'([MCLZ])([^MCLZ]*)', d)]


def ell_d(cx, cy, rx, ry):
    """Ellipse as a four-cubic path string (so it can join a union outline)."""
    k = 0.5523
    pts = [(cx, cy - ry),
           (cx + rx * k, cy - ry), (cx + rx, cy - ry * k), (cx + rx, cy),
           (cx + rx, cy + ry * k), (cx + rx * k, cy + ry), (cx, cy + ry),
           (cx - rx * k, cy + ry), (cx - rx, cy + ry * k), (cx - rx, cy),
           (cx - rx, cy - ry * k), (cx - rx * k, cy - ry), (cx, cy - ry)]
    xy = [f'{num(x)} {num(y)}' for x, y in pts]
    return f'M {xy[0]} ' + ' '.join(
        'C ' + ' '.join(xy[i:i + 3]) for i in (1, 4, 7, 10)) + ' Z'


def split(p0, p1, p2, p3, t):
    """De Casteljau: return the control points of the t..1 part of a cubic."""
    def lerp(a, b):
        return (a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t)
    a, b, c = lerp(p0, p1), lerp(p1, p2), lerp(p2, p3)
    d, e = lerp(a, b), lerp(b, c)
    return lerp(d, e), e, c, p3


_NUM = re.compile(r'-?\d+(?:\.\d+)?')


def mirror_d(d, axis=W / 2):
    """Mirror a path string about the vertical line x = axis."""
    out = []
    for cmd, nums in commands(d):
        for i in range(0, len(nums), 2):
            nums[i] = 2 * axis - nums[i]
        out.append(' '.join([cmd] + [num(n) for n in nums]))
    return ' '.join(out)


def mirror(node, axis=W / 2, suffix='R'):
    """Mirror a node (and children) left-to-right."""
    n = dict(node)
    n['name'] = re.sub(r'L$', suffix, node['name'])
    f = n.get('fill')
    if isinstance(f, dict):
        f = dict(f)
        for k in ('c', 'p1', 'p2'):
            if k in f:
                f[k] = (2 * axis - f[k][0], f[k][1])
        n['fill'] = f
    if n['t'] == 'p':
        n['d'] = mirror_d(node['d'], axis)
    elif n['t'] == 'e':
        n['cx'] = 2 * axis - node['cx']
    else:
        n['pivot'] = (2 * axis - node['pivot'][0], node['pivot'][1])
        n['tx'] = -node['tx']
        n['rot'] = -node['rot']
        n['children'] = [mirror(c, axis, suffix) for c in node['children']]
    return n


_gid = [0]


def _paint(f, defs):
    if not isinstance(f, dict):
        return f or 'none'
    _gid[0] += 1
    gid = f'g{_gid[0]}'
    stops = ''.join(f'<stop offset="{o}" stop-color="{c}"/>' for o, c in f['stops'])
    if f['g'] == 'radial':
        defs.append(f'<radialGradient id="{gid}" gradientUnits="userSpaceOnUse" '
                    f'cx="{f["c"][0]:g}" cy="{f["c"][1]:g}" r="{f["r"]:g}">{stops}'
                    '</radialGradient>')
    else:
        defs.append(f'<linearGradient id="{gid}" gradientUnits="userSpaceOnUse" '
                    f'x1="{f["p1"][0]:g}" y1="{f["p1"][1]:g}" x2="{f["p2"][0]:g}" '
                    f'y2="{f["p2"][1]:g}">{stops}</linearGradient>')
    return f'url(#{gid})'


def _style(n):
    defs = []
    s = f'fill="{_paint(n["fill"], defs)}"'
    if n.get('behind'):
        s += ' paint-order="stroke"'
    n['_defs'] = ''.join(defs)
    if n['stroke']:
        s += (f' stroke="{n["stroke"]}" stroke-width="{n["sw"]}"'
              ' stroke-linecap="round" stroke-linejoin="round"')
    if n['opacity'] != 1:
        s += f' opacity="{n["opacity"]}"'
    return s


def to_svg(n):
    if n['t'] == 'p':
        st = _style(n)
        return f'{n["_defs"]}<path d="{n["d"]}" {st}/>'
    if n['t'] == 'e':
        st = _style(n)
        return (f'{n["_defs"]}<ellipse cx="{n["cx"]}" cy="{n["cy"]}" '
                f'rx="{n["rx"]}" ry="{n["ry"]}" {st}/>')
    px, py = n['pivot']
    tf = (f'translate({n["tx"] + px:g} {n["ty"] + py:g}) rotate({n["rot"]:g}) '
          f'scale({n["sx"]:g} {n["sy"]:g}) translate({-px:g} {-py:g})')
    op = f' opacity="{n["opacity"]}"' if n['opacity'] != 1 else ''
    return (f'<g data-part="{n["name"]}" transform="{tf}"{op}>'
            + ''.join(to_svg(c) for c in n['children']) + '</g>')


# ─── Gradient baking ──────────────────────────────────────────────────────────
# Flutter's HTML web renderer paints Lottie gradient fills black, so gradients
# never reach the exported file. bake() swaps each one for flat tones: a radial
# gradient becomes shrinking copies of the shape stepped from rim colour to
# centre colour; a linear gradient becomes its midpoint colour.

def _hex(rgb):
    return '#' + ''.join(f'{round(v):02X}' for v in rgb)


def _sample(f, t):
    stops = [(o, [int(c[i:i + 2], 16) for i in (1, 3, 5)]) for o, c in f['stops']]
    t = max(stops[0][0], min(stops[-1][0], t))
    for (o0, c0), (o1, c1) in zip(stops, stops[1:]):
        if o0 <= t <= o1:
            k = (t - o0) / (o1 - o0) if o1 > o0 else 0
            return _hex([a + (b - a) * k for a, b in zip(c0, c1)])
    return _hex(stops[-1][1])


def _points(n):
    if n['t'] == 'e':
        return [(n['cx'] - n['rx'], n['cy'] - n['ry']), (n['cx'] + n['rx'], n['cy'] + n['ry']),
                (n['cx'] - n['rx'], n['cy'] + n['ry']), (n['cx'] + n['rx'], n['cy'] - n['ry'])]
    nums = [v for _, vals in commands(n['d']) for v in vals]
    return list(zip(nums[::2], nums[1::2]))


def _shrunk(n, c, k, name, fill):
    m = dict(n, name=name, fill=fill, stroke=None, sw=0, behind=False)
    if n['t'] == 'e':
        m.update(cx=c[0] + (n['cx'] - c[0]) * k, cy=c[1] + (n['cy'] - c[1]) * k,
                 rx=n['rx'] * k, ry=n['ry'] * k)
    else:
        out = []
        for cmd, nums in commands(n['d']):
            pts = [num(c[i % 2] + (v - c[i % 2]) * k, 1) for i, v in enumerate(nums)]
            out.append(' '.join([cmd] + pts))
        m['d'] = ' '.join(out)
    return m


def bake(n):
    """Return the tree with every gradient fill replaced by flat tones."""
    if n['t'] == 'g':
        kids = []
        for ch in n['children']:
            b = bake(ch)
            kids += b if isinstance(b, list) else [b]
        return dict(n, children=kids)
    f = n.get('fill')
    if not isinstance(f, dict):
        return n
    if f['g'] == 'linear':
        return dict(n, fill=_sample(f, .5))
    pts = _points(n)
    xs, ys = [p[0] for p in pts], [p[1] for p in pts]
    c, r = f['c'], f['r']
    dist = lambda p: ((p[0] - c[0]) ** 2 + (p[1] - c[1]) ** 2) ** .5
    inside = min(xs) < c[0] < max(xs) and min(ys) < c[1] < max(ys)
    if not inside:  # the shape sits out on the gradient's rim: one flat tone
        mid = ((min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2)
        return dict(n, fill=_sample(f, dist(mid) / r))
    ext = max(max(xs) - c[0], c[0] - min(xs), max(ys) - c[1], c[1] - min(ys))
    steps = 9 if ext > 110 else 6 if ext > 45 else 4
    out = [dict(n, fill=_sample(f, ext / r))]
    for i in range(1, steps):
        k = 1 - .82 * i / (steps - 1)
        out.append(_shrunk(n, c, k, f'{n["name"]}Tone{i}', _sample(f, k * ext / r)))
    return out
