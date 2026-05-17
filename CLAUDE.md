# CLAUDE.md — Development notes for Claude Code

## Before removing any method, field, or asset

Run `grep -r <name> .` across the whole repo (lib/, test/, docs/) before
deleting anything. Tests, providers, and other screens may reference it.
The CI runs `flutter analyze --fatal-infos` and `flutter test`, so any
missing reference breaks the build immediately.

## Pushing to main

All pushes to `main` go via MCP (`mcp__github__push_files` / `mcp__github__delete_file`)
because direct `git push origin main` is blocked by the session proxy.
Binary files (PNGs, etc.) must be base64-encoded and provided as the `content`
field — the GitHub API decodes them server-side. Verify PNG headers with:

```python
data = open('file.png', 'rb').read(8)
assert data == bytes([137,80,78,71,13,10,26,10]), "not a valid PNG binary"
```

If the file is ~50 bytes and starts with `iVBOR`, it was accidentally stored
as a base64 text string — re-extract from the source sprite sheet.

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
