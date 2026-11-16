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
- Loops start and end on the same pose, so they repeat without a jump.
- No gradients reach the file: Flutter's HTML web renderer paints Lottie
  gradient fills black. `rig.bake()` turns them into stacked flat tones.
- Only shapes, fills, strokes, group transforms and markers are used — no
  masks, mattes, effects or expressions.

## Checking a change

1. `flutter test` — markers exist for every pet × state, size budget, widget sequencing.
2. Validate against the Lottie spec: `npx -p @lottie-animation-community/lottie-specs lottie-specs <file>`. Expect 0 errors.
3. Render the same frames in lottie-web and with `verify/flutter_sheet_test.dart` and compare.
