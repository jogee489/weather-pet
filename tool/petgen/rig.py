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


def ell_d(cx, cy, rx, ry):
    """Ellipse as a four-cubic path string (so it can join a union outline)."""
    k = 0.5523
    return (f'M {cx} {cy - ry} '
            f'C {cx + rx*k:g} {cy - ry} {cx + rx} {cy - ry*k:g} {cx + rx} {cy} '
            f'C {cx + rx} {cy + ry*k:g} {cx + rx*k:g} {cy + ry} {cx} {cy + ry} '
            f'C {cx - rx*k:g} {cy + ry} {cx - rx} {cy + ry*k:g} {cx - rx} {cy} '
            f'C {cx - rx} {cy - ry*k:g} {cx - rx*k:g} {cy - ry} {cx} {cy - ry} Z')


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
    for cmd, body in re.findall(r'([MCLZ])([^MCLZ]*)', d):
        nums = [float(n) for n in _NUM.findall(body)]
        for i in range(0, len(nums), 2):
            nums[i] = 2 * axis - nums[i]
        out.append(cmd + ' ' + ' '.join(f'{n:g}' for n in nums))
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
