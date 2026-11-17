"""Frog: rain is a party, sun is a personal insult."""
from anim import wave, jitter, blink, zs, hop, chain


def arms_up(start, end):
    return {'pawL.pos': [(start, (0, 0), 'lin'), (start + 5, (-14, -34), 'out'),
                         (end - 5, (-14, -34), 'lin'), (end, (0, 0), 'in')],
            'pawR.pos': [(start, (0, 0), 'lin'), (start + 5, (14, -34), 'out'),
                         (end - 5, (14, -34), 'lin'), (end, (0, 0), 'in')]}


def croak(*starts):
    """Throat pulses, each with an 'o' mouth for a few frames."""
    out = {'mouth_w.o': [(0, 1, 'hold')], 'mouth_o.o': [(0, 0, 'hold')], 'torso.scale': []}
    for at in starts:
        out['mouth_w.o'] += [(at, 0, 'hold'), (at + 14, 1, 'hold')]
        out['mouth_o.o'] += [(at, 1, 'hold'), (at + 14, 0, 'hold')]
        out['torso.scale'] += [(at, (1, 1), 'lin'), (at + 3, (1.07, 1.04), 'out'),
                               (at + 6, (1, 1), 'in'), (at + 9, (1.07, 1.04), 'out'),
                               (at + 14, (1, 1), 'in')]
    return out


BREATHE = lambda length, period=30: {'torso.scale': wave((1, 1), (.02, .03), period, length)}

STATES = [
    ('sunny', dict(  # wilting: flattened and unimpressed
        face=dict(eyes='half', mouth='pant'), length=120,
        pose={'root.scale': (1.12, .84), 'head.pos': (0, 8)},
        loop=chain(120, BREATHE(120, 24),
                   {'head.rot': wave(0, 3, 120, 120),
                    'mouth.scale': wave((1, 1.04), (0, .06), 24, 120)}))),
    ('cloudy', dict(  # content: breathing, a blink, one lazy hop
        face=dict(eyes='open', mouth='w'), length=120,
        pose={},
        loop=chain(120, blink(30), blink(100), hop(64, 18, 12),
                   {'head.rot': wave(0, 2, 120, 120)}))),
    ('rainy', dict(  # party time: big joyful hops, arms in the air
        face=dict(eyes='happy', mouth='open'), length=120,
        pose={},
        loop=chain(120, hop(6, 62, 20, .14), arms_up(8, 28), hop(62, 46, 18, .12),
                   arms_up(64, 82), {'head.rot': wave(0, 5, 60, 120)}))),
    ('stormy', dict(  # startled out of its skin
        face=dict(eyes='scared', mouth='wail'), length=90,
        pose={'root.scale': (1.06, .92)},
        loop={'root.pos': [(0, (0, 0), 'lin'), (46, (0, 0), 'lin'), (54, (0, -72), 'out'),
                           (64, (0, 0), 'in'), (90, (0, 0), 'lin')],
              'root.scale': [(0, (1.06, .92), 'lin'), (42, (1.06, .92), 'lin'),
                             (46, (1.16, .8), 'io'), (54, (.9, 1.14), 'out'),
                             (64, (1.18, .8), 'in'), (74, (1.06, .92), 'back'),
                             (90, (1.06, .92), 'lin')],
              'head.pos': jitter((0, 0), (2, 0), 2, 0, 42) + [(90, (0, 0), 'lin')]})),
    ('snowy', dict(  # never seen this before
        face=dict(eyes='big', mouth='o'), length=120,
        pose={'head.pos': (0, -4)},
        loop=chain(120, blink(70), BREATHE(120, 40),
                   {'head.rot': wave(0, 7, 60, 120)}))),
    ('windy', dict(  # light enough to get pushed around
        face=dict(eyes='squint', mouth='o'), length=80,
        pose={'root.rot': -6},
        loop={'root.pos': wave((0, 0), (9, 0), 40, 80),
              'root.rot': wave(-6, 4, 40, 80, .25),
              'head.rot': wave(0, 3, 20, 80)})),
    ('hot', dict(  # melted puddle of frog
        face=dict(eyes='half', mouth='pant'), length=120,
        pose={'root.scale': (1.18, .78), 'head.pos': (0, 12)},
        loop=chain(120, BREATHE(120, 12),
                   {'mouth.scale': wave((1, 1.08), (0, .12), 12, 120),
                    'head.rot': wave(0, 3, 120, 120)}))),
    ('cold', dict(  # stiff and shivering
        face=dict(eyes='squint', mouth='frown'), length=120,
        pose={'root.scale': (1.05, .92), 'head.pos': (0, 6)},
        loop={'root.pos': jitter((0, 0), (2.5, 0), 2, 0, 44) +
                          jitter((0, 0), (2.5, 0), 2, 64, 108) + [(120, (0, 0), 'lin')]})),
    ('night', dict(  # asleep
        face=dict(eyes='sleep', mouth='w'), length=120,
        pose={'root.scale': (1.1, .82), 'head.pos': (0, 14)},
        loop=chain(120, zs(120),
                   {'torso.scale': wave((1.02, 1.03), (.02, .04), 120, 120),
                    'head.pos': wave((0, 14), (0, 2), 120, 120)}))),
    ('foggy', dict(  # damp and happy: croaking
        face=dict(eyes='happy', mouth='w'), length=120,
        pose={},
        loop=chain(120, croak(30, 84), {'head.rot': wave(0, 3, 120, 120)}))),
    ('loading', dict(  # bouncing on the spot
        face=dict(eyes='big', mouth='open'), length=40,
        pose={},
        loop=chain(40, hop(0, 34, 14, .14), hop(22, 20, 10, .1)))),
]
