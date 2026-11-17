"""Cat rig: layered vector parts redrawn from 'Weather cat  type collection.png'.

Depth comes from stacked shade/highlight shapes; fluff comes from leaf-shaped
fur clumps that share one outline with the part they sit on. Gradients here
are authoring shorthand only: rig.bake() turns them into flat tones before
export, because Flutter's HTML web renderer paints gradient fills black.
"""
from rig import G, P, E, mirror, radial, linear
from parts import OLW, union, eye, brow, mouth, plume_tail, zzz

NAME = 'Cat'
PERSONALITY = 'Dignified sun-worshipper. Takes bad weather personally.'
GUIDES = [(68, 'ear tip'), (108, 'crown'), (336, 'chin'), (468, 'ground')]
PARTS = ['head (pivot: chin)', 'ear L / R + ear fluff (pivot: base)',
         'eye L / R, brows', 'mouth, nose, whiskers',
         'cheek fluff x6, top fluff x2', 'tail plume (pivot: base), tail tip',
         'body, chest fluff', 'front paws, hind feet', 'ground shadow']

PAL = dict(
    fur_light='#FCBC4E', fur='#F7A532', fur_shade='#E3861F',
    stripe='#D9741A', outline='#A8501A', cream_light='#FFFAEE',
    cream='#FFF0D4', cream_shade='#F1D3A4', ear='#F57F62', nose='#EE5E5A',
    blush='#F2622E', eye='#2B1D22', eye_glow='#8A5426', shine='#5B8FD9',
    mouth='#B8323C', tongue='#FF8E8E', white='#FFFFFF',
)
LID = '#F9AD3B'  # head gradient colour at the eye line

HEAD_FUR = radial(256, 185, 195, (0, PAL['fur_light']), (.55, PAL['fur']),
                  (1, PAL['fur_shade']))
BODY_FUR = radial(256, 350, 125, (0, PAL['fur_light']), (.6, PAL['fur']),
                  (1, PAL['fur_shade']))


SKULL = ('M 256 108 C 330 108 398 150 402 222 C 404 262 388 300 350 318 '
         'C 318 332 285 336 256 336 C 227 336 194 332 162 318 '
         'C 124 300 108 262 110 222 C 114 150 182 108 256 108 Z')
CHEEK_FLUFF_L = [
    ('cheekFluffL1', 'M 132 222 C 110 230 92 244 78 262 C 102 264 124 258 140 250 Z'),
    ('cheekFluffL2', 'M 128 250 C 108 262 94 280 86 300 C 110 296 132 284 146 272 Z'),
    ('cheekFluffL3', 'M 140 276 C 124 290 114 306 110 324 C 132 316 152 304 164 292 Z'),
]
TOP_FLUFF = [
    ('topFluff1', 'M 236 120 C 236 104 242 92 250 84 C 256 94 258 108 258 120 Z'),
    ('topFluff2', 'M 252 120 C 254 102 264 90 276 82 C 278 96 276 110 272 122 Z'),
]


def build(eyes='open', mouth_k='w', ear_rot=0, brow_a=None, tail_rot=0,
          head_rot=0, head_only=False):
    c = PAL
    ol = dict(stroke=c['outline'], sw=OLW, behind=True)

    ear_l = G('earL', [
        P('ear', 'M 214 130 C 198 100 170 78 136 66 C 122 96 118 138 130 176 Z',
          fill=HEAD_FUR, **ol),
        P('inner', 'M 198 134 C 186 112 168 96 148 88 C 140 108 138 134 144 156 Z',
          fill=linear(150, 90, 180, 150, (0, '#FA9A82'), (1, '#E4634E'))),
        P('earFluff1', 'M 190 150 C 180 132 168 120 154 112 C 156 130 162 146 172 160 Z',
          fill=c['cream']),
        P('earFluff2', 'M 204 142 C 196 126 186 114 174 106 C 176 122 182 136 190 150 Z',
          fill=c['cream_light']),
    ], pivot=(172, 152), rot=-ear_rot)

    cheek_r = [(n.replace('L', 'R'), mirror(P(n, d))['d']) for n, d in CHEEK_FLUFF_L]
    stripes_l = [
        P('stripeL', 'M 214 119 C 220 136 226 148 231 156 C 232 146 230 132 228 115 Z',
          fill=c['stripe']),
        P('cheekStripeL1', 'M 114 228 C 130 230 142 235 150 243 C 140 243 128 241 113 240 Z',
          fill=c['stripe']),
        P('cheekStripeL2', 'M 114 252 C 130 252 140 256 147 263 C 138 264 128 264 116 263 Z',
          fill=c['stripe']),
    ]
    whiskers_l = [
        P('whiskerL1', 'M 204 290 C 172 286 136 288 98 300', stroke=c['white'], sw=2.2,
          opacity=.9),
        P('whiskerL2', 'M 206 299 C 180 304 150 314 122 332', stroke=c['white'], sw=2.2,
          opacity=.9),
    ]
    blush_l = [E('blushL', 158, 276, 27, 16, fill=c['blush'], opacity=.28),
               E('blushCoreL', 158, 276, 19, 11, fill=c['blush'], opacity=.45)]
    eye_l = G('eyeL', eye(eyes, -1, c, LID) + ([brow(brow_a, -1, c)] if brow_a else []),
              tx=203, ty=234)
    eye_r = G('eyeR', eye(eyes, 1, c, LID) + ([brow(brow_a, 1, c)] if brow_a else []),
              tx=309, ty=234)

    head = G('head', [
        ear_l, mirror(ear_l),
        *union(TOP_FLUFF + CHEEK_FLUFF_L + cheek_r + [('skull', SKULL)], HEAD_FUR,
               c['outline']),
        E('browLight', 256, 152, 78, 26, fill=c['fur_light'], opacity=.45),
        E('muzzleL', 236, 290, 34, 28, fill=c['cream']),
        E('muzzleR', 276, 290, 34, 28, fill=c['cream']),
        E('chin', 256, 306, 30, 22, fill=c['cream']),
        E('muzzleLight', 256, 280, 34, 18, fill=c['cream_light'], opacity=.8),
        P('stripeC', 'M 248 114 C 250 136 254 152 256 162 C 258 152 262 136 264 114 Z',
          fill=c['stripe']),
        *stripes_l, *[mirror(s) for s in stripes_l],
        *blush_l, *[mirror(b) for b in blush_l],
        eye_l, eye_r,
        G('whiskersL', whiskers_l, pivot=(205, 294)),
        G('whiskersR', [mirror(w) for w in whiskers_l], pivot=(307, 294)),
        P('nose', 'M 247 263 C 251 259 261 259 265 263 C 263 269 259 272 256 272 '
                  'C 253 272 249 269 247 263 Z', fill=c['nose']),
        E('noseLight', 253, 263, 3, 1.6, fill=c['white'], opacity=.6),
        P('philtrum', 'M 256 272 L 256 280', stroke=c['outline'], sw=3.5),
        G('mouth', mouth(mouth_k, c), pivot=(256, 283)),
    ], pivot=(256, 330), rot=head_rot)
    if head_only:
        return head

    toe = dict(stroke=c['cream_shade'], sw=2.5)
    foot_l = G('hindFootL', [
        E('foot', 176, 454, 36, 17, fill=linear(176, 438, 176, 472, (0, c['cream_light']),
                                                 (1, c['cream_shade'])), **ol),
        P('toe1', 'M 164 452 L 164 464', **toe), P('toe2', 'M 180 452 L 180 465', **toe),
    ])
    paw_l = G('pawL', [
        E('paw', 226, 432, 22, 18, fill=linear(226, 414, 226, 450, (0, c['cream_light']),
                                                (1, c['cream_shade'])), **ol),
        P('toe1', 'M 219 434 L 219 444', **toe), P('toe2', 'M 231 434 L 231 444', **toe),
    ])

    tail = plume_tail(
        linear(80, 380, 200, 440, (0, c['fur_light']), (.5, c['fur']), (1, c['fur_shade'])),
        linear(80, 350, 110, 400, (0, c['cream_light']), (1, c['cream'])),
        c['outline'], c['stripe'], tail_rot)

    body_stripes_l = [
        P('bodyStripeL1', 'M 161 364 C 176 366 188 373 196 382 C 184 381 172 379 159 377 Z',
          fill=c['stripe']),
        P('bodyStripeL2', 'M 157 390 C 172 390 184 395 192 403 C 180 404 168 404 158 403 Z',
          fill=c['stripe']),
    ]
    return G('cat', [E('shadow', 256, 468, 140, 13, fill='#000000', opacity=.14), G('root', [
        tail,
        G('torso', [
            E('body', 256, 385, 100, 78, fill=BODY_FUR, **ol),
            *body_stripes_l, *[mirror(s) for s in body_stripes_l],
            E('bellyShade', 256, 440, 70, 22, fill=c['fur_shade'], opacity=.45),
        ], pivot=(256, 462)),
        foot_l, mirror(foot_l),
        P('chest', 'M 204 322 C 202 350 210 368 224 382 C 226 372 230 366 234 362 '
                   'C 236 380 244 394 256 404 C 268 394 276 380 278 362 '
                   'C 282 366 286 372 288 382 C 302 368 310 350 308 322 Z',
          fill=linear(256, 330, 256, 404, (0, c['cream']), (1, c['cream_shade'])),
          stroke=c['cream_shade'], sw=3, behind=True),
        P('chestLight', 'M 236 336 C 238 356 246 372 256 382 C 266 372 274 356 276 336 Z',
          fill=c['cream_light'], opacity=.8),
        E('chinShade', 256, 340, 74, 15, fill=c['outline'], opacity=.2),
        paw_l, mirror(paw_l),
        head,
    ], pivot=(256, 466)), *zzz(356, 176)])


EXPRESSIONS = [
    ('Delighted', 'sunny, hot', dict(eyes='happy', mouth_k='open')),
    ('Unimpressed', 'cloudy, foggy', dict(eyes='half', mouth_k='w')),
    ('Offended', 'rainy, windy', dict(eyes='squint', mouth_k='frown', ear_rot=28, brow_a=-18)),
    ('Terrified', 'stormy', dict(eyes='scared', mouth_k='wail', ear_rot=40, brow_a=20)),
    ('Wonder', 'snowy, loading', dict(eyes='big', mouth_k='o')),
    ('Asleep', 'night', dict(eyes='sleep', mouth_k='w', ear_rot=12)),
]
