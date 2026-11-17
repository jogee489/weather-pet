"""Dog: loves every kind of weather, except thunder."""
from anim import wave, jitter, blink, zs, hop, chain


def ears(v):
    """Positive swings both floppy ears outward."""
    return {'earL.rot': v, 'earR.rot': -v}


WAG = lambda amp, period, length, base=0: {'tail.rot': wave(base, amp, period, length)}

STATES = [
    ('sunny', dict(  # overjoyed: fast wag, bouncing ears, a happy hop
        face=dict(eyes='happy', mouth='open'), length=120,
        pose={**ears(8)},
        loop=chain(120, WAG(16, 12, 120), hop(60, 26),
                   {'head.rot': wave(0, 4, 60, 120),
                    'earL.rot': wave(8, 5, 30, 120), 'earR.rot': wave(-8, 5, 30, 120, .5)}))),
    ('cloudy', dict(  # curious head tilts, slow wag
        face=dict(eyes='open', mouth='w'), length=120,
        pose={**ears(4)},
        loop=chain(120, WAG(8, 40, 120), blink(96),
                   {'head.rot': [(0, 0, 'lin'), (10, 0, 'lin'), (24, 10, 'back'), (54, 10, 'lin'),
                                 (70, -10, 'back'), (100, -10, 'lin'), (114, 0, 'io')],
                    'torso.scale': wave((1, 1), (.01, .018), 60, 120)}))),
    ('rainy', dict(  # soggy and sad, then a big shake-off
        face=dict(eyes='open', mouth='frown', brow=18), length=120,
        pose={'head.pos': (0, 8), **ears(-4), 'tail.rot': 14},
        loop=chain(120, blink(20),
                   {'head.rot': [(0, 0, 'lin'), (48, 0, 'lin'), (52, -6, 'io')] + [
                       (55 + i * 3, 13 * (1 if i % 2 == 0 else -1), 'lin') for i in range(7)] + [
                       (80, 0, 'back')],
                    'earL.rot': [(0, -4, 'lin'), (52, -4, 'lin'), (58, 34, 'out'), (72, 30, 'lin'),
                                 (84, -4, 'back')],
                    'earR.rot': [(0, 4, 'lin'), (52, 4, 'lin'), (58, -34, 'out'), (72, -30, 'lin'),
                                 (84, 4, 'back')],
                    'root.scale': [(0, (1, 1), 'lin'), (48, (1, 1), 'lin'), (53, (1.05, .94), 'io'),
                                   (76, (1.03, .97), 'lin'), (84, (1, 1), 'back')]}))),
    ('stormy', dict(  # the one thing it hates: cowering, trembling, flinching
        face=dict(eyes='scared', mouth='wail', brow=22), length=90,
        pose={'root.scale': (1.06, .9), 'head.pos': (0, 8), **ears(-6),
              'tail.rot': 28, 'tail.scale': (.8, .8)},
        loop={'head.pos': jitter((0, 8), (2, 0), 2, 0, 48) + [(90, (0, 8), 'lin')],
              'root.pos': [(0, (0, 0), 'lin'), (52, (0, 0), 'lin'), (58, (0, -22), 'out'),
                           (64, (0, 0), 'in'), (90, (0, 0), 'lin')],
              'root.scale': [(0, (1.06, .9), 'lin'), (52, (1.06, .9), 'lin'),
                             (58, (.96, 1.06), 'out'), (64, (1.14, .82), 'in'),
                             (74, (1.06, .9), 'back'), (90, (1.06, .9), 'lin')]})),
    ('snowy', dict(  # snow is the best thing ever: leaping at flakes
        face=dict(eyes='happy', mouth='open'), length=120,
        pose={**ears(10)},
        loop=chain(120, WAG(18, 10, 120), hop(10, 40, 16), hop(66, 30, 14),
                   {'head.rot': wave(0, 8, 60, 120),
                    'mouth.scale': [(0, (1, 1), 'lin'), (18, (1.2, 1.3), 'out'),
                                    (24, (1, 1), 'in'), (72, (1.2, 1.3), 'out'),
                                    (78, (1, 1), 'in')],
                    'earL.rot': wave(10, 8, 30, 120), 'earR.rot': wave(-10, 8, 30, 120, .5)}))),
    ('windy', dict(  # head out of the car window: ears streaming, grinning
        face=dict(eyes='happy', mouth='open'), length=80,
        pose={'root.rot': -4, 'head.rot': -3},
        loop={'earL.rot': wave(-8, 3, 8, 80), 'earR.rot': wave(-46, 9, 8, 80, .3),
              'tail.rot': wave(-12, 8, 10, 80),
              'head.rot': wave(-3, 2, 40, 80),
              'mouth.scale': wave((1.1, 1.1), (.06, .08), 20, 80)})),
    ('hot', dict(  # flopped and panting hard
        face=dict(eyes='half', mouth='pant'), length=120,
        pose={'root.scale': (1.1, .86), 'head.pos': (0, 10), **ears(-3), 'tail.rot': 20},
        loop={'torso.scale': wave((1, 1), (.02, .035), 10, 120),
              'mouth.scale': wave((1, 1.08), (0, .12), 10, 120),
              'head.pos': wave((0, 10), (0, 1.5), 10, 120),
              'head.rot': wave(0, 3, 120, 120)})),
    ('cold', dict(  # hunched, shivering in bursts, ears quivering
        face=dict(eyes='squint', mouth='frown', brow=16), length=120,
        pose={'root.scale': (1.05, .92), 'head.pos': (0, 8), **ears(-5), 'tail.rot': 22},
        loop={'root.pos': jitter((0, 0), (2.5, 0), 2, 0, 44) +
                          jitter((0, 0), (2.5, 0), 2, 64, 108) + [(120, (0, 0), 'lin')],
              'head.rot': wave(0, 1.5, 60, 120)})),
    ('night', dict(  # asleep, chasing something in a dream
        face=dict(eyes='sleep', mouth='w'), length=120,
        pose={'root.scale': (1.14, .76), 'head.pos': (0, 30), 'head.rot': 8,
              'pawL.o': 0, 'pawR.o': 0, **ears(-4), 'tail.rot': 16},
        loop=chain(120, zs(120),
                   {'torso.scale': wave((1.02, 1.03), (.02, .045), 120, 120),
                    'head.pos': wave((0, 30), (0, 2.5), 120, 120),
                    'tail.rot': [(0, 16, 'lin'), (66, 16, 'lin'), (70, 4, 'out'), (74, 20, 'io'),
                                 (78, 6, 'io'), (82, 20, 'io'), (90, 16, 'io')]}))),
    ('foggy', dict(  # can't see, so it sniffs
        face=dict(eyes='big', mouth='o'), length=120,
        pose={**ears(6)},
        loop=chain(120, blink(100),
                   {'head.rot': [(0, 0, 'lin'), (16, 12, 'back'), (60, 12, 'lin'), (76, -8, 'back'),
                                 (104, -8, 'lin'), (116, 0, 'io')],
                    'head.pos': [(0, (0, 0), 'lin'), (24, (0, 0), 'lin'), (28, (0, -5), 'out'),
                                 (32, (0, 0), 'in'), (36, (0, -5), 'out'), (40, (0, 0), 'in'),
                                 (44, (0, -5), 'out'), (48, (0, 0), 'in')],
                    'earL.rot': [(0, 6, 'lin'), (30, 16, 'io'), (60, 6, 'io')],
                    'earR.rot': [(0, -6, 'lin'), (76, -16, 'io'), (104, -6, 'io')]}))),
    ('loading', dict(  # can't wait
        face=dict(eyes='happy', mouth='open'), length=40,
        pose={},
        loop=chain(40, WAG(18, 10, 40), hop(0, 30, 14), hop(22, 18, 10)))),
]
