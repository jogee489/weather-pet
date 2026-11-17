"""Dragon: small furnace. Adores heat and storms, sulks in the cold."""
from anim import wave, jitter, blink, zs, hop, chain


def frills(v):
    """Positive droops both head frills."""
    return {'earL.rot': -v, 'earR.rot': v}


def wings(v):
    """Positive raises both wings."""
    return {'wingL.rot': v, 'wingR.rot': -v}


def flap(base, amp, period, length):
    return {'wingL.rot': wave(base, amp, period, length),
            'wingR.rot': wave(-base, -amp, period, length)}


SHIVER = lambda: {'root.pos': jitter((0, 0), (2.5, 0), 2, 0, 44) +
                              jitter((0, 0), (2.5, 0), 2, 64, 108) + [(120, (0, 0), 'lin')]}

STATES = [
    ('sunny', dict(  # basking with wings spread to the sun
        face=dict(eyes='happy', mouth='open'), length=120,
        pose={**wings(12)},
        loop=chain(120, flap(12, 6, 60, 120),
                   {'head.rot': wave(0, 3, 120, 120), 'tail.rot': wave(0, 8, 60, 120),
                    'torso.scale': wave((1, 1), (.012, .02), 60, 120)}))),
    ('cloudy', dict(  # mildly interested, looking around
        face=dict(eyes='big', mouth='o'), length=120,
        pose={},
        loop=chain(120, blink(84), flap(0, 3, 60, 120),
                   {'head.rot': [(0, 0, 'lin'), (20, -9, 'back'), (52, -9, 'lin'), (70, 9, 'back'),
                                 (100, 9, 'lin'), (114, 0, 'io')],
                    'tail.rot': [(0, 0, 'lin'), (40, 0, 'lin'), (44, -16, 'out'), (52, 0, 'back'),
                                 (120, 0, 'lin')]}))),
    ('rainy', dict(  # sulking; shakes water off its wings
        face=dict(eyes='half', mouth='frown'), length=120,
        pose={'head.pos': (0, 7), **frills(22), **wings(-14)},
        loop={'wingL.rot': [(0, -14, 'lin'), (56, -14, 'lin')] + [
                  (59 + i * 3, -14 + 16 * (1 if i % 2 == 0 else -.3), 'lin') for i in range(6)] + [
                  (84, -14, 'back'), (120, -14, 'lin')],
              'wingR.rot': [(0, 14, 'lin'), (56, 14, 'lin')] + [
                  (59 + i * 3, 14 - 16 * (1 if i % 2 == 0 else -.3), 'lin') for i in range(6)] + [
                  (84, 14, 'back'), (120, 14, 'lin')],
              'tail.rot': [(0, 0, 'lin'), (20, 0, 'lin'), (24, -12, 'out'), (30, 0, 'in'),
                           (120, 0, 'lin')],
              'head.rot': wave(0, 1.5, 60, 120)})),
    ('stormy', dict(  # in its element: wings up, roaring back at the thunder
        face=dict(eyes='open', mouth='open', brow=-20), length=90,
        pose={**frills(-14), **wings(24)},
        loop=chain(90, flap(24, 10, 18, 90),
                   {'head.rot': [(0, 0, 'lin'), (36, 0, 'lin'), (42, 5, 'io'), (48, -10, 'out'),
                                 (64, -10, 'lin'), (74, 0, 'back')],
                    'mouth.scale': [(0, (1, 1), 'lin'), (42, (1, 1), 'lin'), (48, (1.35, 1.6), 'out'),
                                    (64, (1.3, 1.5), 'lin'), (72, (1, 1), 'io')],
                    'root.scale': [(0, (1, 1), 'lin'), (40, (1.05, .93), 'io'),
                                   (48, (.96, 1.07), 'out'), (64, (.97, 1.05), 'lin'),
                                   (74, (1, 1), 'back')],
                    'tail.rot': wave(0, 10, 30, 90)}))),
    ('snowy', dict(  # miserable: fire can't keep up
        face=dict(eyes='half', mouth='frown', brow=14), length=120,
        pose={'root.scale': (1.04, .94), 'head.pos': (0, 7), **frills(24), **wings(-20)},
        loop=chain(120, SHIVER(), {'head.rot': wave(0, 2, 60, 120)}))),
    ('windy', dict(  # braced; wings and frills buffeted
        face=dict(eyes='squint', mouth='frown'), length=80,
        pose={'root.rot': -5, 'head.rot': -3},
        loop={'earL.rot': wave(-10, 6, 8, 80), 'earR.rot': wave(34, 7, 8, 80, .2),
              'wingL.rot': wave(-6, 6, 10, 80), 'wingR.rot': wave(-22, 9, 10, 80, .3),
              'tail.rot': wave(-10, 6, 10, 80, .1),
              'root.rot': wave(-5, 1.5, 40, 80)})),
    ('hot', dict(  # perfect weather: lazily fanning itself, blissful
        face=dict(eyes='happy', mouth='open'), length=120,
        pose={**wings(16), 'head.rot': 4},
        loop=chain(120, flap(16, 14, 40, 120),
                   {'head.rot': wave(4, 4, 120, 120), 'tail.rot': wave(0, 12, 40, 120),
                    'torso.scale': wave((1, 1), (.012, .02), 40, 120)}))),
    ('cold', dict(  # worst case: curled tight, wings wrapped, shivering
        face=dict(eyes='squint', mouth='frown', brow=16), length=120,
        pose={'root.scale': (1.07, .9), 'head.pos': (0, 9), **frills(26), **wings(-26)},
        loop=chain(120, SHIVER(), {'head.rot': wave(0, 1.5, 60, 120)}))),
    ('night', dict(  # asleep, wings folded
        face=dict(eyes='sleep', mouth='w'), length=120,
        pose={'root.scale': (1.14, .76), 'head.pos': (-6, 30), 'head.rot': -8,
              'pawL.o': 0, 'pawR.o': 0, **frills(16), **wings(-28)},
        loop=chain(120, zs(120),
                   {'torso.scale': wave((1.02, 1.03), (.02, .045), 120, 120),
                    'head.pos': wave((-6, 30), (0, 2.5), 120, 120),
                    'tail.rot': [(0, 0, 'lin'), (80, 0, 'lin'), (84, -10, 'out'), (92, 0, 'back')]}))),
    ('foggy', dict(  # peering into the murk
        face=dict(eyes='open', mouth='o'), length=120,
        pose={'head.pos': (0, -3)},
        loop=chain(120, blink(62),
                   {'head.rot': [(0, 0, 'lin'), (14, 0, 'lin'), (30, -11, 'back'), (56, -11, 'lin'),
                                 (74, 11, 'back'), (100, 11, 'lin'), (116, 0, 'io')],
                    'earL.rot': [(0, 0, 'lin'), (30, -14, 'io'), (60, 0, 'io')],
                    'earR.rot': [(0, 0, 'lin'), (76, 14, 'io'), (104, 0, 'io')]}))),
    ('loading', dict(  # hovering impatiently
        face=dict(eyes='happy', mouth='open'), length=40,
        pose={'root.pos': (0, -22), **wings(10)},
        loop=chain(40, flap(10, 20, 8, 40),
                   {'root.pos': wave((0, -22), (0, 6), 20, 40),
                    'tail.rot': wave(0, 10, 20, 40)}))),
]
