# CLAUDE.md — Development notes for Claude Code

## Communication rules

- Skip fluff and preamble. Be brief.
- No narration. State what you're doing only when asking permission.
- Summaries: 1–2 sentences max. User will ask for more.
- Sentences: 3–6 words. Drop articles (the, a, an).

## Git rules

- Branching: `feature/`, `bug/`, `chore/` + short description (e.g. `bug/fix-cat-images`).
- Never commit without asking first.
- Never merge without explicit instruction.
- Binary assets (PNGs): always commit via git to a branch, then PR → merge. Never push binaries via `mcp__github__push_files` — shell substitution is not expanded in MCP parameters.
- All commits must use author `JJ Dorko <jdorko90@gmail.com>`:
  ```
  git -c user.name="JJ Dorko" -c user.email="jdorko90@gmail.com" commit ...
  ```

## Before removing any method, field, or asset

Run `grep -r <name> .` across the whole repo (lib/, test/, docs/) before
deleting anything. Tests, providers, and other screens may reference it.
The CI runs `flutter analyze --fatal-infos` and `flutter test`, so any
missing reference breaks the build immediately.

## Pushing to main

Direct `git push origin main` is blocked. Two safe paths:

**Text/code files** — use `mcp__github__push_files`.

**Binary files (PNGs, etc.)** — commit to a feature/bug/chore branch, push via git, then PR → merge via MCP. Never use `mcp__github__push_files` for binaries; shell substitution (`$(cat ...)`) is not expanded in MCP parameters and the literal string gets stored instead.

Verify PNG integrity before committing:
```python
data = open('file.png', 'rb').read(8)
assert data == bytes([137,80,78,71,13,10,26,10]), "not a valid PNG"
```

## CI pipeline (`.github/workflows/ci.yml`)

- `flutter analyze --fatal-infos` — compile check + lints, runs on every push
- `flutter test --coverage` — unit tests
- Playwright E2E — builds web, serves on port 8080, runs browser tests
- GitHub Pages deploy — only on pushes to `main`

## Asset conventions

- Pet images: `assets/images/<animal>/<state>.png` (one per `PetState` value)
- Source sprite sheets: `assets/<Animal> weather set.png` — kept for reference, not bundled at runtime
- Rive slots (future): `assets/rive/<animal>/<variant>.riv` — see `docs/pet_states.md`

## Weather API

Uses [Open-Meteo](https://open-meteo.com/) — free, no key, no rate limit for
reasonable usage. Reverse geocoding uses Nominatim (OpenStreetMap); can be
slow (~1 s). Consider caching or parallelising the geocode call.
