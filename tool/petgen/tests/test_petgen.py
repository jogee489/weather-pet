"""Generator tests. Run: python3 -m unittest discover tool/petgen/tests"""
import importlib
import math
import os
import sys
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

import anim  # noqa: E402
import lottie  # noqa: E402
import rig  # noqa: E402

PETS = ['cat', 'dog', 'dragon', 'frog']


def _states(pet):
    return importlib.import_module(pet + '_states').STATES


def _ease_y(ease, u):
    """Value progress of a named or explicit ease whose x handles are 1/3, 2/3."""
    if ease == 'lin':
        return u
    (ox, oy), (ix, iy) = ease
    assert abs(ox - 1 / 3) < 1e-9 and abs(ix - 2 / 3) < 1e-9
    return 3 * (1 - u) ** 2 * u * oy + 3 * (1 - u) * u ** 2 * iy + u ** 3


class WaveTest(unittest.TestCase):
    def _check(self, amp, period, length, phase):
        keys = anim.wave(0, amp, period, length, phase)
        true = lambda f: amp * math.sin(2 * math.pi * (f / period + phase))
        self.assertEqual(keys[0][0], 0)
        self.assertEqual(keys[-1][0], length)
        self.assertAlmostEqual(keys[0][1], keys[-1][1], places=5)
        worst = 0
        for (f0, v0, _), (f1, v1, ease) in zip(keys, keys[1:]):
            self.assertAlmostEqual(v1, true(f1), places=4)
            for u in (.25, .5, .75):
                got = v0 + (v1 - v0) * _ease_y(ease, u)
                worst = max(worst, abs(got - true(f0 + (f1 - f0) * u)))
        self.assertLess(worst, .03 * amp, 'wave does not follow a sine')

    def test_follows_a_sine_between_keys(self):
        self._check(10, 40, 80, 0)

    def test_follows_a_sine_with_any_phase(self):
        for phase in (.1, .2, .25, .3):
            self._check(7, 10, 80, phase)

    def test_follows_a_sine_when_quarter_periods_are_fractional(self):
        self._check(4, 6, 90, 0)

    def test_vector_wave_moves_every_axis_together(self):
        keys = anim.wave((1, 1), (.02, .03), 30, 120)
        self.assertAlmostEqual(max(v[1] for _, v, _ in keys), 1.03, places=3)
        self.assertEqual(keys[0][1], keys[-1][1])


class TimelineTest(unittest.TestCase):
    def _one(self, loop, length=40, pose=None):
        return anim.timeline([('s', dict(face=dict(eyes='open', mouth='w'),
                                         length=length, pose=pose or {}, loop=loop))])

    def test_keeps_the_ease_of_the_closing_key(self):
        tracks, _, _ = self._one({'head.rot': [(0, 0, 'lin'), (20, 8, 'out'), (40, 0, 'back')]})
        end = anim.ENTER + 40
        closing = [k for k in tracks['head.rot'] if k[0] == end]
        self.assertEqual([k[2] for k in closing], ['back'])

    def test_rejects_a_loop_that_does_not_end_where_it_starts(self):
        with self.assertRaisesRegex(ValueError, 'head.rot'):
            self._one({'head.rot': [(0, 0, 'lin'), (20, 8, 'out'), (40, 3, 'io')]})

    def test_rejects_keys_past_the_end_of_the_loop(self):
        with self.assertRaisesRegex(ValueError, 'head.rot'):
            self._one({'head.rot': [(0, 0, 'lin'), (44, 8, 'out')]})

    def test_rejects_a_baked_blink_on_closed_eyes(self):
        with self.assertRaisesRegex(ValueError, 'blink'):
            anim.timeline([('s', dict(face=dict(eyes='sleep', mouth='w'), length=40,
                                      pose={}, loop=dict(anim.blink(10))))])

    def test_every_pet_builds(self):
        for pet in PETS:
            tracks, markers, frames = anim.timeline(_states(pet))
            self.assertEqual(len(markers), 33, pet)
            self.assertGreater(frames, 0)


class ChainTest(unittest.TestCase):
    def test_rejects_moves_that_overlap_on_one_channel(self):
        with self.assertRaisesRegex(ValueError, 'root.scale'):
            anim.chain(40, anim.hop(0, 34, 16), anim.hop(20, 20, 12))

    def test_accepts_moves_that_follow_each_other(self):
        out = anim.chain(40, anim.hop(0, 34, 14), anim.hop(22, 20, 10))
        frames = [k[0] for k in out['root.scale']]
        self.assertEqual(frames, sorted(set(frames)))
        self.assertEqual(out['root.scale'][0][1], out['root.scale'][-1][1])


class ExportTest(unittest.TestCase):
    def test_rejects_two_different_keys_on_one_frame(self):
        with self.assertRaises(ValueError):
            lottie._prop([(0, 0, 'lin'), (5, 1, 'lin'), (5, 2, 'lin')], lambda v: [v], 1)

    def test_rejects_exponent_numbers_in_paths(self):
        with self.assertRaises(ValueError):
            lottie._bezier('M 1e-05 0 L 10 10')

    def test_accepts_explicit_ease_handles(self):
        prop = lottie._prop([(0, 0, 'lin'), (5, 1, ((1 / 3, .5), (2 / 3, 1)))],
                            lambda v: [v], 1)
        self.assertAlmostEqual(prop['k'][0]['o']['y'][0], .5)


class PathNumberTest(unittest.TestCase):
    def test_mirror_never_writes_exponents(self):
        self.assertEqual(rig.mirror_d('M 511.99999 0 L 10 10'), 'M 0 0 L 502 10')

    def test_ellipse_never_writes_exponents(self):
        self.assertNotIn('e', rig.ell_d(0.00001, 100, 0.00001, 20))

    def test_tiny_values_round_to_zero_not_minus_zero(self):
        self.assertEqual(rig.num(-1e-9), '0')
        self.assertEqual(rig.num(12.5), '12.5')
        self.assertEqual(rig.num(3), '3')


class RigTest(unittest.TestCase):
    def setUp(self):
        self.rigs = {p: anim.full_rig(importlib.import_module(p), _states(p)) for p in PETS}

    def test_brows_sit_outside_the_blinking_eye(self):
        for pet, root in self.rigs.items():
            for side in 'LR':
                self.assertNotIn('brow' + side, anim.names(anim.find(root, 'eye' + side)), pet)
                self.assertIsNotNone(anim.find(root, 'brow' + side), pet)

    def test_only_open_eyes_take_the_live_blink(self):
        for pet, root in self.rigs.items():
            live = anim.names(anim.find(root, 'eyeLBlink'))
            self.assertTrue(live & {'eyeL_open', 'eyeL_big', 'eyeL_half', 'eyeL_scared'}, pet)
            self.assertFalse(live & {'eyeL_sleep', 'eyeL_happy', 'eyeL_squint'}, pet)

    def test_face_variants_no_state_uses_are_left_out(self):
        for pet, root in self.rigs.items():
            used_eyes = {s['face']['eyes'] for _, s in _states(pet)} | {'open'}
            have = {n[5:] for n in anim.names(root) if n.startswith('eyeL_')}
            self.assertEqual(have, used_eyes, pet)

    def test_no_gradients_reach_the_export(self):
        def walk(n):
            self.assertNotIsInstance(n.get('fill'), dict)
            for c in n.get('children', []):
                walk(c)
        for root in self.rigs.values():
            walk(root)


if __name__ == '__main__':
    unittest.main()
