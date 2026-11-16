"""Frog rig: round tree frog redrawn from 'Frog weather set.png'."""
from rig import G, P, E, mirror, radial, linear, ell_d
from parts import OLW, union, brow, blush

NAME = 'Frog'
PERSONALITY = 'Rain is a party. Sun is a personal insult.'
GUIDES = [(98, 'eye bump'), (150, 'crown'), (338, 'chin'), (468, 'ground')]
PARTS = ['head + eye bumps (pivot: chin)', 'eye L / R: sclera, iris, pupil, lids',
         'wide mouth, tongue, nostrils',
         'body, belly', 'thigh L / R, hind feet', 'arms, hands', 'ground shadow']

PAL = dict(
    skin_light='#C6EE78', skin='#8FD03C', skin_shade='#5EA626', spot='#4E9420',
    outline='#3A741C', belly_light='#FFFCD6', belly='#FAF0A0',
    belly_shade='#E0D472', blush='#F7A24A', iris='#3E7A1E', eye='#1F1A1C',
    shine='#5B8FD9', mouth='#C23A3C', tongue='#FF7E7E', white='#FFFFFF',
)
HEAD = radial(256, 200, 190, (0, PAL['skin_light']), (.55, PAL['skin']),
              (1, PAL['skin_shade']))
BODY = radial(256, 360, 130, (0, PAL['skin_light']), (.6, PAL['skin']),
              (1, PAL['skin_shade']))
SKULL = ('M 256 150 C 330 150 404 180 404 250 C 404 310 340 338 256 338 '
         'C 172 338 108 310 108 250 C 108 180 182 150 256 150 Z')
EX, EY = 194, 148  # left eye bump centre


def _eye(kind, side):
    c, parts = PAL, []
    if kind in ('open', 'big', 'half', 'scared'):
        parts.append(E('sclera', 0, 0, 35, 35, fill=c['white'], stroke=c['outline'], sw=3))
        if kind == 'scared':
            parts += [E('pupil', 0, 2, 11, 12, fill=c['eye']),
                      E('hi1', -4, -3, 3.5, 3.5, fill=c['white'])]
        else:
            r = 26 if kind == 'big' else 23
            parts += [E('iris', 0, 2, r + 5, r + 5, fill=c['iris']),
                      E('pupil', 0, 2, r, r, fill=c['eye'])]
            if kind == 'big':
                parts.append(E('glow', 0, 14, 16, 11, fill=radial(
                    0, 16, 18, (0, c['shine']), (1, c['eye']))))
            parts += [E('hi1', -9, -9, 9, 9, fill=c['white']),
                      E('hi2', 10, 12, 4, 4, fill=c['white'], opacity=.9)]
        if kind == 'half':
            parts += [P('lid', 'M -38 -2 C -38 -50 38 -50 38 -2 Z', fill=c['skin']),
                      P('lidline', 'M -35 -2 L 35 -2', stroke=c['outline'], sw=5)]
    elif kind == 'happy':
        parts.append(P('arc', 'M -24 8 C -16 -14 16 -14 24 8', stroke=c['eye'], sw=7))
    elif kind == 'sleep':
        parts.append(P('arc', 'M -24 -2 C -16 16 16 16 24 -2', stroke=c['eye'], sw=7))
    elif kind == 'squint':
        s = -side
        parts.append(P('chev', f'M {18*s} -15 L {-13*s} 0 L {18*s} 15',
                       stroke=c['eye'], sw=7))
    else:
        raise ValueError(kind)
    return parts


def _mouth(kind):
    c = PAL
    line = dict(stroke=c['outline'], sw=4)
    smile = P('smile', 'M 150 262 C 190 288 322 288 362 262', **line)
    if kind == 'w':
        return [smile]
    if kind == 'open':
        return [P('cavity', 'M 186 274 C 192 326 320 326 326 274 C 296 286 216 286 186 274 Z',
                  fill=c['mouth'], **line),
                E('tongue', 256, 308, 30, 10, fill=c['tongue']), smile]
    if kind == 'o':
        return [E('o', 256, 290, 13, 15, fill=c['mouth'], **line)]
    if kind == 'frown':
        return [P('frown', 'M 196 292 C 226 274 286 274 316 292', **line)]
    if kind == 'wail':
        return [P('wail', 'M 210 282 C 222 264 290 264 302 282 C 308 322 204 322 210 282 Z',
                  fill=c['mouth'], **line),
                E('tongue', 256, 306, 24, 8, fill=c['tongue'])]
    if kind == 'pant':
        return [P('cavity', 'M 200 276 C 206 310 306 310 312 276 C 290 286 222 286 200 276 Z',
                  fill=c['mouth'], **line),
                P('longTongue', 'M 238 292 C 234 322 244 336 256 336 '
                                'C 268 336 278 322 274 292 Z', fill=c['tongue'],
                  stroke=c['mouth'], sw=2), smile]
    raise ValueError(kind)


def build(eyes='open', mouth_k='w', ear_rot=0, brow_a=None, tail_rot=0,
          head_rot=0, head_only=False):
    c = PAL
    ol = dict(stroke=c['outline'], sw=OLW, behind=True)
    eye_l = G('eyeL', _eye(eyes, -1) + ([brow(brow_a, -1, c, -52)] if brow_a else []),
              tx=EX, ty=EY)
    eye_r = G('eyeR', _eye(eyes, 1) + ([brow(brow_a, 1, c, -52)] if brow_a else []),
              tx=512 - EX, ty=EY)
    bl = blush(c, 144, 266, 1.1)
    spots = [E('spot1', 256, 176, 9, 6, fill=c['spot'], opacity=.45),
             E('spot2', 236, 192, 5, 4, fill=c['spot'], opacity=.45),
             E('spot3', 280, 194, 6, 4, fill=c['spot'], opacity=.45)]
    head = G('head', [
        *union([('eyeBumpL', ell_d(EX, EY, 50, 50)), ('eyeBumpR', ell_d(512 - EX, EY, 50, 50)),
                ('skull', SKULL)], HEAD, c['outline']),
        E('headLight', 256, 196, 70, 20, fill=c['skin_light'], opacity=.5),
        P('lowerFace', 'M 150 262 C 190 288 322 288 362 262 C 376 300 324 332 256 332 '
                       'C 188 332 136 300 150 262 Z',
          fill=linear(256, 268, 256, 332, (0, c['belly_light']), (.5, c['belly']),
                      (1, c['belly_shade']))),
        *spots, *bl, *[mirror(b) for b in bl],
        eye_l, eye_r,
        E('nostrilL', 245, 240, 3, 4, fill=c['outline']),
        E('nostrilR', 267, 240, 3, 4, fill=c['outline']),
        G('mouth', _mouth(mouth_k)),
    ], pivot=(256, 332), rot=head_rot)
    if head_only:
        return head

    toe = dict(stroke=c['skin_shade'], sw=2.5)
    skin_lin = lambda x, y0, y1: linear(x, y0, x, y1, (0, c['skin_light']),
                                        (1, c['skin_shade']))
    foot_l = G('hindFootL', [
        *union([('toeA', ell_d(112, 456, 13, 11)), ('toeB', ell_d(132, 462, 13, 11)),
                ('foot', ell_d(158, 455, 40, 14))], skin_lin(150, 440, 472), c['outline'])])
    arm_l = G('armL', [
        E('arm', 224, 426, 15, 30, fill=skin_lin(224, 396, 456), **ol),
        *union([('fingerA', ell_d(208, 458, 9, 8)), ('fingerB', ell_d(240, 458, 9, 8)),
                ('hand', ell_d(224, 456, 18, 10))], skin_lin(224, 446, 468), c['outline'])])
    return G('frog', [
        E('shadow', 256, 468, 150, 13, fill='#000000', opacity=.14),
        *union([('thighL', ell_d(160, 420, 48, 40)), ('thighR', ell_d(352, 420, 48, 40)),
                ('body', ell_d(256, 392, 98, 72))], BODY, c['outline']),
        E('belly', 256, 400, 62, 54, fill=radial(256, 380, 70, (0, c['belly_light']),
                                                 (.6, c['belly']), (1, c['belly_shade']))),
        E('thighLightL', 150, 404, 22, 12, fill=c['skin_light'], opacity=.5),
        E('thighLightR', 362, 404, 22, 12, fill=c['skin_light'], opacity=.5),
        foot_l, mirror(foot_l), arm_l, mirror(arm_l),
        E('chinShade', 256, 342, 86, 12, fill=c['outline'], opacity=.2),
        head,
    ])


EXPRESSIONS = [
    ('Delighted', 'rainy, foggy', dict(eyes='happy', mouth_k='open')),
    ('Content', 'cloudy, loading', dict(eyes='open', mouth_k='w')),
    ('Wilting', 'sunny, hot', dict(eyes='half', mouth_k='pant')),
    ('Startled', 'stormy, cold', dict(eyes='scared', mouth_k='wail')),
    ('Wonder', 'snowy, windy', dict(eyes='big', mouth_k='o')),
    ('Asleep', 'night', dict(eyes='sleep', mouth_k='w')),
]
