"""Face and body parts shared by all four pets."""
from rig import G, P, E, split

OLW = 8  # outline stroke, painted behind the fill so 4 px shows


def union(shapes, fill, outline):
    """Several shapes sharing one silhouette outline and one fill."""
    return ([P(n + 'Line', d, stroke=outline, sw=OLW) for n, d in shapes]
            + [P(n, d, fill=fill) for n, d in shapes])


def eye(kind, side, c, lid):
    """Eye drawn around (0,0); side is -1 (left) or +1 (right)."""
    from rig import radial
    parts = []
    if kind in ('open', 'big', 'half'):
        rx, ry = (26, 30) if kind == 'big' else (23, 27)
        parts.append(E('ball', 0, 0, rx, ry, fill=c['eye']))
        glow = c['shine'] if kind == 'big' else c['eye_glow']
        parts.append(E('glow', 0, ry * .36, rx * .66, ry * .44, fill=radial(
            0, ry * .5, rx * .8, (0, glow), (1, c['eye']))))
        k = 1.25 if kind == 'big' else 1
        parts.append(E('hi1', -7 * k, -10 * k, 7.5 * k, 8 * k, fill=c['white']))
        parts.append(E('hi2', 8 * k, 9 * k, 3.5 * k, 3.5 * k, fill=c['white'],
                       opacity=.9))
        if kind == 'half':
            parts.append(P('lid', 'M -27 -6 C -27 -40 27 -40 27 -6 Z', fill=lid))
            parts.append(P('lidline', 'M -24 -6 L 24 -6', stroke=c['eye'], sw=5))
    elif kind == 'happy':
        parts.append(P('arc', 'M -19 7 C -13 -13 13 -13 19 7',
                       stroke=c['eye'], sw=6.5))
    elif kind == 'sleep':
        parts.append(P('arc', 'M -19 -4 C -13 12 13 12 19 -4',
                       stroke=c['eye'], sw=6.5))
    elif kind == 'squint':
        s = -side
        parts.append(P('chev', f'M {15*s} -13 L {-11*s} 0 L {15*s} 13',
                       stroke=c['eye'], sw=6.5))
    elif kind == 'scared':
        parts.append(E('white', 0, 0, 24, 28, fill=c['white'],
                       stroke=c['eye'], sw=4))
        parts.append(E('pupil', 0, 2, 8, 9, fill=c['eye']))
        parts.append(E('hi1', -3, -2, 2.5, 2.5, fill=c['white']))
    else:
        raise ValueError(kind)
    return parts


def brow(angle, side, c, y=-41):
    """Short brow above an eye; positive angle lifts the inner end."""
    return G('brow', [P('b', 'M -13 0 L 13 0', stroke=c['outline'], sw=4.5)],
             ty=y, rot=angle * side)


def mouth(kind, c, style='w'):
    """Mouth around x=256, y~281. style 'w' is the cat/dog mouth, 'smile' a curve."""
    line = dict(stroke=c['outline'], sw=3.5)
    if style == 'w':
        rest = P('w', 'M 240 281 C 244 289 253 289 256 279 C 259 289 268 289 272 281',
                 **line)
    else:
        rest = G('smile', [
            P('curve', 'M 228 280 C 242 292 270 292 284 280', **line),
            P('fang', 'M 268 286 L 272 297 L 277 284 Z', fill=c['white'],
              stroke=c['outline'], sw=2)])
    if kind == 'w':
        return [rest]
    if kind == 'open':
        if style == 'w':
            cav = 'M 243 283 C 244 309 268 309 269 283 Z'
        else:
            cav = 'M 230 281 C 234 318 278 318 282 281 C 270 290 242 290 230 281 Z'
        return [P('cavity', cav, fill=c['mouth'], **line),
                E('tongue', 256, 301 if style == 'w' else 304, 9 if style == 'w' else 14,
                  6, fill=c['tongue']), rest]
    if kind == 'o':
        return [E('o', 256, 290, 6, 8, fill=c['mouth'], **line)]
    if kind == 'frown':
        if style == 'w':
            d = 'M 241 288 C 247 279 252 291 256 285 C 260 279 265 291 271 288'
        else:
            d = 'M 234 292 C 246 282 266 282 278 292'
        return [P('frown', d, **line)]
    if kind == 'wail':
        return [P('wail', 'M 242 285 C 246 277 266 277 270 285 '
                          'C 272 303 240 303 242 285 Z', fill=c['mouth'], **line),
                E('tongue', 256, 295, 7, 4, fill=c['tongue'])]
    if kind == 'pant':
        return [P('cavity', 'M 242 283 C 243 300 269 300 270 283 Z',
                  fill=c['mouth'], **line),
                P('longTongue', 'M 247 290 C 245 312 249 324 256 324 '
                                'C 263 324 267 312 265 290 Z', fill=c['tongue'],
                  stroke=c['mouth'], sw=2),
                P('tongueLine', 'M 256 296 L 256 314', stroke=c['mouth'], sw=1.5,
                  opacity=.6), rest]
    raise ValueError(kind)


def blush(c, x, y, k=1):
    return [E('blushL', x, y, 27 * k, 16 * k, fill=c['blush'], opacity=.28),
            E('blushCoreL', x, y, 19 * k, 11 * k, fill=c['blush'], opacity=.45)]


def plume_tail(fur, tip, outline, stripe=None, rot=0):
    """Fluffy tail on the left; the tip reuses the plume's exact outer edge."""
    a, b, cc, d = split((86, 430), (66, 406), (70, 366), (96, 340), .35)
    tip_d = (f'M {a[0]:.1f} {a[1]:.1f} C {b[0]:.1f} {b[1]:.1f} {cc[0]:.1f} {cc[1]:.1f} '
             f'{d[0]} {d[1]} C 104 352 110 362 122 370 C 116 376 112 384 112 393 '
             f'C 104 387 96 389 92 399 C 86 395 80 397 {a[0]:.1f} {a[1]:.1f} Z')
    stripes = [] if not stripe else [
        P('tailStripe1', 'M 108 446 C 112 432 122 420 136 412 C 130 424 124 438 122 452 Z',
          fill=stripe),
        P('tailStripe2', 'M 142 458 C 144 444 152 432 164 424 C 160 436 156 448 156 460 Z',
          fill=stripe)]
    return G('tail', [
        P('plume', 'M 200 452 C 160 464 110 458 86 430 C 66 406 70 366 96 340 '
                   'C 104 352 110 362 122 370 C 118 384 130 400 152 408 '
                   'C 168 414 184 414 198 416 Z',
          fill=fur, stroke=outline, sw=OLW, behind=True),
        *stripes, P('tailTip', tip_d, fill=tip),
    ], pivot=(190, 436), rot=rot)
