# petgen — the pets, as code

Draws the four weather pets as layered vector rigs and exports one Lottie
file per pet to `assets/lottie/<pet>/<pet>.json`. Pure Python 3, no
dependencies.

```bash
python3 tool/petgen/build.py assets/lottie cat dog dragon frog
```

```bash
python3 tool/petgen/sheet.py cat /tmp/cat_sheet.svg
```

| File | What it holds |
|---|---|
| `rig.py` | Scene model (groups, paths, ellipses), SVG output, gradient baking |
| `parts.py` | Eyes, brows, mouths, blush, tail, Zs shared by all pets |
| `cat.py` `dog.py` `dragon.py` `frog.py` | Each pet's shapes, palette, expressions |
| `<pet>_states.py` | Pose and loop for each of the 11 weather states |
| `anim.py` | Builds the timeline: enter / loop / exit per state, blink-hidden face swaps |
| `lottie.py` | Lottie JSON exporter |
| `sheet.py` | Model sheet SVG for one pet |
| `verify/flutter_sheet_test.dart` | Renders loop frames with Flutter's player for side-by-side checks |

## Rules the rigs follow

- Every pet has groups named `root`, `torso`, `head`, `eyeL`, `eyeR`, `mouth`,
  `pawL`, `pawR`, and `earL` / `earR` / `tail` where the animal has them.
  State files animate `<group>.pos`, `.rot`, `.scale` and `.o` (opacity).
  `build.py` fails if a state animates a group the rig lacks.
- Each eye is `eyeSlot<S>` > [`eye<S>` > [`eye<S>Blink` > open-eye variants,
  closed-eye variants], `brow<S>`]. Baked blinks scale `eye<S>`; the app's
  random blink scales `eye<S>Blink`, so brows and line-art eyes are never
  squashed. A baked `blink()` in a closed-eye state is a build error.
- Only the eye and mouth variants a pet's states use are exported.
- Loops start and end on the same pose, so they repeat without a jump.
  `timeline()` fails on a loop key past the loop length or a final key that
  differs from the first.
- `wave()` is a true sine: keys sit on peaks and zero crossings (which may be
  fractional frames), each with an ease fitted to the sine's slope.
- `chain()` joins moves on one channel end to end and fails if two overlap.
  A `hop()` owns `root.scale` until 8 frames after it lands.
- Path numbers are plain decimals (`rig.num`); exponents are a build error.
- No gradients reach the file: Flutter's HTML web renderer paints Lottie
  gradient fills black. `rig.bake()` turns them into stacked flat tones.
- Only shapes, fills, strokes, group transforms and markers are used — no
  masks, mattes, effects or expressions.

## Checking a change

1. `python3 -m unittest discover tool/petgen/tests` — generator rules above.
2. `flutter test` — markers exist for every pet × state, eye structure, size budget, widget sequencing.
3. Validate against the Lottie spec: `npx -p @lottie-animation-community/lottie-specs lottie-specs <file>`. Expect 0 errors.
4. Render the same frames in lottie-web and with `verify/flutter_sheet_test.dart` and compare.
