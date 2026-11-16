"""Dog rig: golden puppy redrawn from 'Dog weather set.png'."""
from rig import G, P, E, mirror, radial, linear, ell_d
from parts import OLW, union, eye, brow, mouth, blush, plume_tail, zzz

NAME = 'Dog'
PERSONALITY = 'Loves every kind of weather. Except thunder.'
GUIDES = [(86, 'crown fluff'), (112, 'crown'), (338, 'chin'), (468, 'ground')]
PARTS = ['head (pivot: chin)', 'floppy ear L / R + ear fluff (pivot: top)',
         'eye L / R, brows, brow dots', 'mouth, nose, tongue', 'top fluff x2',
         'tail plume (pivot: base), tail tip', 'body, haunches, chest bib',
         'front legs, paws, hind feet', 'collar, bone tag', 'ground shadow']

PAL = dict(
    fur_light='#FCD88A', fur='#F3B450', fur_shade='#D98F2E',
    ear='#E7A23C', ear_shade='#C47A22', outline='#96561C',
    cream_light='#FFFBF0', cream='#FFF1D4', cream_shade='#F0D2A2',
    nose='#2B1D22', blush='#F2703A', eye='#2B1D22', eye_glow='#7A4A22',
    shine='#5B8FD9', mouth='#B8323C', tongue='#FF8E8E', white='#FFFFFF',
    collar='#C8382C', collar_shade='#8E221C', tag='#F6C74F',
)
LID = '#F8C264'
HEAD_FUR = radial(256, 185, 195, (0, PAL['fur_light']), (.55, PAL['fur']),
                  (1, PAL['fur_shade']))
BODY_FUR = radial(256, 350, 130, (0, PAL['fur_light']), (.6, PAL['fur']),
                  (1, PAL['fur_shade']))
SKULL = ('M 256 112 C 326 112 388 152 392 222 C 394 266 376 304 344 320 '
         'C 316 334 284 338 256 338 C 228 338 196 334 168 320 '
         'C 136 304 118 266 120 222 C 124 152 186 112 256 112 Z')
TOP_FLUFF = [
    ('topFluff1', 'M 230 124 C 230 106 238 94 248 86 C 254 96 256 110 256 124 Z'),
    ('topFluff2', 'M 250 124 C 254 106 264 96 278 90 C 278 104 276 116 270 126 Z'),
]
EAR_L = [
    ('earFluffL1', 'M 92 276 C 86 296 88 316 98 334 C 108 320 114 304 114 288 Z'),
    ('earFluffL2', 'M 110 288 C 110 308 116 324 128 336 C 134 320 134 304 130 288 Z'),
    ('earFlapL', 'M 172 134 C 132 128 100 158 90 204 C 82 246 84 284 100 306 '
                 'C 122 318 146 298 152 264 C 158 228 168 182 190 150 Z'),
]


def build(eyes='open', mouth_k='w', ear_rot=0, brow_a=None, tail_rot=0,
          head_rot=0, head_only=False):
    c = PAL
    ol = dict(stroke=c['outline'], sw=OLW, behind=True)
    ear_fur = linear(120, 140, 110, 320, (0, c['ear']), (1, c['ear_shade']))
    ear_l = G('earL', union(EAR_L, ear_fur, c['outline']) + [
        P('earShine', 'M 150 150 C 126 160 110 186 104 220 C 118 196 136 172 160 160 Z',
          fill=c['fur_light'], opacity=.5)], pivot=(176, 140), rot=ear_rot)
    bl = blush(c, 174, 282)
    eye_l = G('eyeL', eye(eyes, -1, c, LID) + ([brow(brow_a, -1, c)] if brow_a else []),
              tx=208, ty=234)
    eye_r = G('eyeR', eye(eyes, 1, c, LID) + ([brow(brow_a, 1, c)] if brow_a else []),
              tx=304, ty=234)
    dots = [] if brow_a else [E('browDotL', 208, 192, 9, 6, fill=c['cream'], opacity=.9),
                              E('browDotR', 304, 192, 9, 6, fill=c['cream'], opacity=.9)]
    head = G('head', [
        *union(TOP_FLUFF + [('skull', SKULL)], HEAD_FUR, c['outline']),
        E('browLight', 256, 152, 76, 26, fill=c['fur_light'], opacity=.45),
        P('blaze', 'M 256 118 C 242 150 238 196 242 250 L 270 250 '
                   'C 274 196 270 150 256 118 Z', fill=c['cream'], opacity=.95),
        E('muzzleL', 232, 292, 38, 30, fill=c['cream']),
        E('muzzleR', 280, 292, 38, 30, fill=c['cream']),
        E('chin', 256, 310, 34, 22, fill=c['cream']),
        E('muzzleLight', 256, 282, 36, 16, fill=c['cream_light'], opacity=.8),
        *dots, *bl, *[mirror(b) for b in bl],
        eye_l, eye_r,
        P('nose', 'M 240 259 C 246 252 266 252 272 259 C 272 269 262 277 256 277 '
                  'C 250 277 240 269 240 259 Z', fill=c['nose']),
        E('noseLight', 250, 259, 6, 2.6, fill=c['white'], opacity=.55),
        P('philtrum', 'M 256 277 L 256 285', stroke=c['outline'], sw=3.5),
        G('mouth', mouth(mouth_k, c), ty=5, pivot=(256, 281), sx=1.2, sy=1.2),
        ear_l, mirror(ear_l),
    ], pivot=(256, 332), rot=head_rot)
    if head_only:
        return head

    toe = dict(stroke=c['cream_shade'], sw=2.5)
    cream_lin = lambda x, y0, y1: linear(x, y0, x, y1, (0, c['cream_light']),
                                         (1, c['cream_shade']))
    foot_l = G('hindFootL', [
        E('foot', 172, 455, 36, 16, fill=cream_lin(172, 439, 471), **ol),
        P('toe1', 'M 158 453 L 158 464', **toe), P('toe2', 'M 174 453 L 174 466', **toe)])
    leg_l = G('pawL', [
        E('leg', 228, 420, 21, 40, fill=linear(228, 380, 228, 460, (0, c['fur']),
                                               (1, c['fur_shade'])), **ol),
        E('paw', 228, 454, 25, 14, fill=cream_lin(228, 440, 468), **ol),
        P('toe1', 'M 221 453 L 221 462', **toe), P('toe2', 'M 235 453 L 235 462', **toe)])
    tail = mirror(plume_tail(
        linear(80, 380, 200, 440, (0, c['fur_light']), (.5, c['fur']), (1, c['fur_shade'])),
        linear(80, 350, 110, 400, (0, c['cream_light']), (1, c['cream'])),
        c['outline'], None, tail_rot))
    return G('dog', [E('shadow', 256, 468, 140, 13, fill='#000000', opacity=.14), G('root', [
        tail,
        G('torso', [*union([('haunchL', ell_d(178, 418, 44, 46)), ('haunchR', ell_d(334, 418, 44, 46)),
                ('body', ell_d(256, 388, 92, 78))], BODY_FUR, c['outline']),
        P('bib', 'M 200 326 C 198 356 208 376 222 390 C 224 380 228 374 234 370 '
                 'C 236 388 244 402 256 412 C 268 402 276 388 278 370 '
                 'C 284 374 288 380 290 390 C 304 376 314 356 312 326 Z',
          fill=linear(256, 334, 256, 412, (0, c['cream']), (1, c['cream_shade'])),
          stroke=c['cream_shade'], sw=3, behind=True)], pivot=(256, 462)),
        foot_l, mirror(foot_l), leg_l, mirror(leg_l),
        P('collar', 'M 190 326 C 220 348 292 348 322 326 L 320 344 '
                    'C 292 366 220 366 192 344 Z',
          fill=linear(256, 330, 256, 366, (0, c['collar']), (1, c['collar_shade'])),
          stroke=c['collar_shade'], sw=5, behind=True),
        G('tag', [
            E('tagL', 249, 372, 6, 6, fill=c['tag']), E('tagR', 263, 372, 6, 6, fill=c['tag']),
            E('tagL2', 249, 380, 6, 6, fill=c['tag']), E('tagR2', 263, 380, 6, 6, fill=c['tag']),
            P('tagBar', 'M 249 376 L 263 376', stroke=c['tag'], sw=9)], pivot=(256, 364)),
        E('chinShade', 256, 342, 72, 13, fill=c['outline'], opacity=.2),
        head,
    ], pivot=(256, 466)), *zzz(366, 176)])


EXPRESSIONS = [
    ('Delighted', 'sunny, snowy, windy', dict(eyes='happy', mouth_k='open', ear_rot=10)),
    ('Curious', 'cloudy, foggy, loading', dict(eyes='big', mouth_k='w', head_rot=8)),
    ('Soggy', 'rainy, cold', dict(eyes='open', mouth_k='frown', brow_a=18, ear_rot=-4)),
    ('Terrified', 'stormy', dict(eyes='scared', mouth_k='wail', brow_a=22, ear_rot=-6)),
    ('Panting', 'hot', dict(eyes='half', mouth_k='pant')),
    ('Asleep', 'night', dict(eyes='sleep', mouth_k='w')),
]
