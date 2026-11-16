"""Dragon rig: green hatchling redrawn from 'Dragon weather set.png'."""
from rig import G, P, E, mirror, radial, linear, ell_d
from parts import OLW, union, eye, brow, mouth, blush

NAME = 'Dragon'
PERSONALITY = 'Small furnace. Adores heat and storms, sulks in the cold.'
GUIDES = [(56, 'horn tip'), (112, 'crown'), (338, 'chin'), (468, 'ground')]
PARTS = ['head (pivot: chin)', 'frill L / R (pivot: base)', 'horns, crown spikes',
         'eye L / R, brows', 'snout, nostrils, mouth, fang',
         'wing L / R (pivot: shoulder)', 'tail + spade tip (pivot: base)',
         'body, belly plates', 'arms, hind feet', 'ground shadow']

PAL = dict(
    skin_light='#A9DE66', skin='#72B840', skin_shade='#4C9230', spot='#3F8228',
    outline='#2C5A1C', belly_light='#FFF8C4', belly='#F5E48E',
    belly_shade='#D8BE5C', horn_light='#FCEDB4', horn='#EBCB72',
    horn_shade='#BF9840', wing='#F7A83A', wing_shade='#D9781C',
    blush='#F28A3A', eye='#2B1D22', eye_glow='#6E8A22', shine='#5B8FD9',
    mouth='#B8323C', tongue='#FF8E8E', white='#FFFFFF',
)
LID = '#8ACB50'
HEAD = radial(256, 185, 195, (0, PAL['skin_light']), (.55, PAL['skin']),
              (1, PAL['skin_shade']))
BODY = radial(256, 350, 130, (0, PAL['skin_light']), (.6, PAL['skin']),
              (1, PAL['skin_shade']))
SKULL = ('M 256 112 C 322 112 380 150 388 214 C 396 262 384 304 348 322 '
         'C 318 336 286 338 256 338 C 226 338 194 336 164 322 '
         'C 128 304 116 262 124 214 C 132 150 190 112 256 112 Z')


def build(eyes='open', mouth_k='w', ear_rot=0, brow_a=None, tail_rot=0,
          head_rot=0, head_only=False, wing_rot=0):
    c = PAL
    ol = dict(stroke=c['outline'], sw=OLW, behind=True)
    horn_l = G('hornL', [
        P('horn', 'M 190 142 C 174 114 168 84 176 56 C 200 68 222 96 230 128 Z',
          fill=linear(176, 60, 220, 140, (0, c['horn_light']), (.5, c['horn']),
                      (1, c['horn_shade'])), **ol),
        P('ring1', 'M 180 92 C 188 90 196 86 202 80', stroke=c['horn_shade'], sw=3),
        P('ring2', 'M 186 118 C 196 116 206 110 214 102', stroke=c['horn_shade'], sw=3)])
    frill_l = G('frillL', [
        P('frill', 'M 140 184 L 82 166 L 112 204 L 68 214 L 110 238 L 78 262 L 136 264 Z',
          fill=linear(70, 214, 140, 214, (0, c['skin_shade']), (1, c['skin'])), **ol),
        P('frillWeb', 'M 134 198 L 104 190 L 122 212 L 96 218 L 122 232 L 106 248 L 134 250 Z',
          fill=c['skin_light'], opacity=.6)], pivot=(136, 224), rot=-ear_rot)
    spots_l = [E('spotL1', 168, 172, 7, 6, fill=c['spot'], opacity=.55),
               E('spotL2', 152, 198, 4.5, 4, fill=c['spot'], opacity=.55),
               E('spotL3', 188, 152, 4.5, 4, fill=c['spot'], opacity=.55)]
    bl = blush(c, 160, 280)
    eye_l = G('eyeL', eye(eyes, -1, c, LID) + ([brow(brow_a, -1, c)] if brow_a else []),
              tx=204, ty=228)
    eye_r = G('eyeR', eye(eyes, 1, c, LID) + ([brow(brow_a, 1, c)] if brow_a else []),
              tx=308, ty=228)
    head = G('head', [
        frill_l, mirror(frill_l), horn_l, mirror(horn_l),
        P('crest', 'M 232 122 L 244 96 L 252 112 L 258 82 L 266 112 L 274 98 L 282 122 Z',
          fill=c['skin_shade'], **ol),
        P('skull', SKULL, fill=HEAD, **ol),
        E('browLight', 256, 150, 76, 24, fill=c['skin_light'], opacity=.45),
        E('snout', 256, 286, 70, 40, fill=radial(256, 272, 74, (0, c['skin_light']),
                                                 (1, c['skin']))),
        *spots_l, *[mirror(s) for s in spots_l],
        *bl, *[mirror(b) for b in bl],
        eye_l, eye_r,
        E('nostrilL', 243, 266, 3.5, 5, fill=c['outline']),
        E('nostrilR', 269, 266, 3.5, 5, fill=c['outline']),
        G('mouth', mouth(mouth_k, c, 'smile'), ty=8),
    ], pivot=(256, 332), rot=head_rot)
    if head_only:
        return head

    wing_l = G('wingL', [
        P('membrane', 'M 186 352 L 92 290 C 98 322 90 342 70 356 C 94 360 106 374 108 394 '
                      'C 126 384 146 386 164 398 Z',
          fill=linear(80, 300, 170, 390, (0, c['wing']), (1, c['wing_shade'])), **ol),
        P('rib1', 'M 186 352 L 70 356', stroke=c['wing_shade'], sw=3),
        P('rib2', 'M 186 352 L 108 394', stroke=c['wing_shade'], sw=3),
        P('armLine', 'M 186 352 L 92 290', stroke=c['outline'], sw=14),
        P('arm', 'M 186 352 L 92 290', stroke=c['skin_shade'], sw=7),
    ], pivot=(186, 352), rot=-wing_rot)
    tail = G('tail', union([
        ('tailSpade', 'M 410 392 L 420 338 L 452 384 Z'),
        ('tailBody', 'M 312 436 C 356 466 424 458 440 420 C 448 400 440 382 426 374 '
                     'C 428 392 422 408 406 416 C 382 428 350 420 322 404 Z'),
    ], linear(320, 440, 440, 380, (0, c['skin_shade']), (.5, c['skin']),
              (1, c['skin_light'])), c['outline']), pivot=(318, 424), rot=tail_rot)
    toe = dict(stroke=c['skin_shade'], sw=2.5)
    foot_l = G('hindFootL', [
        E('foot', 176, 454, 36, 17, fill=linear(176, 438, 176, 472, (0, c['skin_light']),
                                                 (1, c['skin_shade'])), **ol),
        P('toe1', 'M 162 452 L 162 464', **toe), P('toe2', 'M 178 452 L 178 466', **toe)])
    arm_l = G('armL', [E('arm', 0, 0, 14, 24, fill=linear(0, -24, 0, 24, (0, c['skin']),
                                                          (1, c['skin_shade'])), **ol)],
              tx=214, ty=404, rot=18)
    plates = [P(f'plate{i}', f'M {214 - i*2} {y} C 238 {y + 9} 274 {y + 9} {298 + i*2} {y}',
                stroke=c['belly_shade'], sw=3) for i, y in enumerate((366, 390, 414, 438))]
    return G('dragon', [
        E('shadow', 256, 468, 140, 13, fill='#000000', opacity=.14),
        wing_l, mirror(wing_l), tail,
        *union([('haunchL', ell_d(180, 422, 42, 42)), ('haunchR', ell_d(332, 422, 42, 42)),
                ('body', ell_d(256, 390, 90, 76))], BODY, c['outline']),
        P('belly', 'M 216 328 C 200 370 204 430 230 460 L 282 460 C 308 430 312 370 296 328 Z',
          fill=linear(256, 330, 256, 460, (0, c['belly_light']), (.4, c['belly']),
                      (1, c['belly_shade']))),
        *plates,
        foot_l, mirror(foot_l), arm_l, mirror(arm_l),
        E('chinShade', 256, 342, 72, 13, fill=c['outline'], opacity=.22),
        head,
    ])


EXPRESSIONS = [
    ('Delighted', 'sunny, hot', dict(eyes='happy', mouth_k='open')),
    ('Fierce', 'stormy', dict(eyes='open', mouth_k='open', brow_a=-20, ear_rot=-14)),
    ('Sulky', 'rainy, snowy, cold', dict(eyes='half', mouth_k='frown', ear_rot=22)),
    ('Braced', 'windy', dict(eyes='squint', mouth_k='frown', ear_rot=30)),
    ('Wonder', 'cloudy, foggy, loading', dict(eyes='big', mouth_k='o')),
    ('Asleep', 'night', dict(eyes='sleep', mouth_k='w', ear_rot=16)),
]
