# Pet States

Each state is driven by real weather data via the Open-Meteo API.
The same state drives both the background animation and the pet character image/animation.

---

## sunny
**Trigger:** WMO code 0 (clear sky), daytime, temperature 0–34 °C, wind ≤ 40 km/h.

**Background:** A sun disc sits in the upper centre. Ten white rays rotate slowly — one full revolution every 8 seconds. A soft radial glow pulses outward from the centre.

**Pet:** See the reaction table under *Animation system* — each character reacts differently.

---

## cloudy
**Trigger:** WMO codes 1–3 (mainly clear → overcast), daytime, temperature 0–34 °C, wind ≤ 40 km/h.

**Background:** Five semi-transparent white cloud blobs drift left-to-right across the screen, evenly phase-staggered so the screen is never empty. Each cloud takes 8 seconds to cross.

**Pet:** See the reaction table under *Animation system* — each character reacts differently.

---

## rainy
**Trigger:** WMO codes 51–67, 80–82 (drizzle, rain, freezing rain, rain showers).

**Background:** 80 light-blue rain streaks fall at a 20° angle. Each streak completes two full passes down the screen per 8-second loop (~4 s per pass).

**Pet:** See the reaction table under *Animation system* — each character reacts differently.

---

## snowy
**Trigger:** WMO codes 71–77, 85–86 (snow, snow grains, snow showers).

**Background:** 70 white snowflake dots fall slowly, each completing one pass in 8 seconds. Each flake follows a gentle sinusoidal horizontal drift (±15 px) to feel floaty.

**Pet:** See the reaction table under *Animation system* — each character reacts differently.

---

## stormy
**Trigger:** WMO codes 95–99 (thunderstorm, thunderstorm with hail).

**Background:** 110 dark blue-grey rain streaks fall steeply at 25°, four passes per 8-second loop (~2 s per pass — fast and heavy). A lightning flash fires every 7 seconds: sharp white full-screen bloom with an exponential decay and a brief secondary flicker.

**Pet:** See the reaction table under *Animation system* — each character reacts differently.

---

## windy
**Trigger:** Wind speed > 40 km/h (regardless of WMO code, daytime, temperature 0–34 °C).

**Background:** Six white spiral arcs drift left-to-right, each spinning two full turns per 8-second loop. Four green/amber tumbling leaves bob vertically and rotate as they cross the screen.

**Pet:** See the reaction table under *Animation system* — each character reacts differently.

---

## hot
**Trigger:** Apparent temperature ≥ 35 °C, daytime.

**Background:** A deep-orange heat-haze gradient rises from the bottom of the screen. 14 vertical wavy heat-shimmer columns rise upward, each completing two passes per 8-second loop with a sinusoidal lateral wave that grows toward the top.

**Pet:** See the reaction table under *Animation system* — each character reacts differently.

---

## cold
**Trigger:** Apparent temperature < 0 °C, daytime.

**Background:** A frosted-glass vignette feathers in from all four edges (white radial gradient, transparent centre → 45% white at corners). Snowflake crystal ornaments grow from each corner. 18 tiny ice-mote particles drift slowly upward with a gentle lateral sway.

**Pet:** See the reaction table under *Animation system* — each character reacts differently.

---

## night
**Trigger:** `is_day = 0` from the API (local sunset to sunrise), regardless of other conditions.

**Background:** 90 stars scattered across the full screen. Stars come in three colour temperatures (warm amber, neutral white, cool blue-white) at varying sizes. Each star twinkles independently at 1, 2, or 3 cycles per 8-second loop; ~15% get a soft glow halo for depth.

**Pet:** See the reaction table under *Animation system* — each character reacts differently.

---

## foggy
**Trigger:** WMO codes 45, 48 (fog, depositing rime fog).

**Background:** 14 wide, flat, semi-transparent fog blobs drift at varying heights. Blobs at even-indexed positions move at double speed for a parallax layering effect (near fog moves faster). Each blob bobs very gently up and down (±18 px, 8-second cycle).

**Pet:** See the reaction table under *Animation system* — each character reacts differently.

---

## loading
**Trigger:** While weather data is being fetched on first launch or after a refresh.

**Background:** No particle layer — plain gradient background only.

**Pet:** See the reaction table under *Animation system* — each character reacts differently.

---

## State priority order

When multiple conditions are true simultaneously the following precedence applies:

1. `night` — API reports `is_day = 0`
2. `hot` — apparent temperature ≥ 35 °C
3. `cold` — apparent temperature < 0 °C
4. `windy` — wind speed > 40 km/h
5. WMO-code states: `sunny`, `cloudy`, `foggy`, `rainy`, `snowy`, `stormy`

`loading` is only active while a fetch is in progress and is never derived from weather data.

---

## Animation system

Each character is one Lottie file, `assets/lottie/<id>/<id>.json`, played by
`PetWidget` with the [`lottie`](https://pub.dev/packages/lottie) package.

**Segments.** Every `PetState` has three named markers in the file:

| Marker | What it is |
|---|---|
| `<state>.enter` | Neutral pose → state pose, with anticipation and overshoot (14 frames) |
| `<state>.loop` | Seamless loop (40–120 frames at 30 fps) |
| `<state>.exit` | State pose → neutral (10 frames) |

Neutral is the hub, so any state can follow any other. On a weather change
the widget hurries the current loop to its end, plays `exit`, then the new
state's `enter`, then loops. Face swaps happen behind a blink.

**Live touches added in Dart** (not baked into the file):

- Random blinks every 2–6 s, on open eyes only (never brows or closed eyes).
- `intensity` (0–1, from `PetState.intensityFor`) speeds the loop up
  (0.8×–1.4×) and, when windy, widens ear and whisker flutter, which fades
  in and out over 300 ms. A state pinned in Preview Mode uses a fixed 0.5,
  because the live readings describe different weather.
- A state change at any moment (mid-loop, mid-enter, mid-exit) is routed
  through frames already on screen or the shared neutral pose, never a cut.
- Tap makes the pet squash and bounce.
- With the OS "reduce motion" setting on, the pet holds the first loop frame.

**Reactions.** Same weather, different opinion:

| State | Cat | Dog | Dragon | Frog |
|---|---|---|---|---|
| sunny | Basks, tail sways | Overjoyed, wagging, hops | Basks with wings spread | Wilts flat, unimpressed |
| cloudy | Bored, tail flicks | Curious head tilts | Looks around | Content, lazy hop |
| rainy | Offended, shakes wet paw | Soggy, then big shake-off | Sulks, shakes wings dry | Party: big hops, arms up |
| stormy | Trembles, jumps at thunder | Cowers, tail tucked, flinches | Roars back, wings up | Startled leap |
| snowy | Wide-eyed, bats at flakes | Leaps to catch flakes | Miserable, shivering | Amazed, staring up |
| windy | Leans in, ears and whiskers flutter | Grinning, ears streaming | Braced, wings buffeted | Pushed around |
| hot | Melted, panting | Flopped, panting hard | Blissful, fanning itself | Melted puddle |
| cold | Loaf, shivering | Hunched, shivering | Curled tight, wings wrapped | Stiff, shivering |
| night | Curled asleep, ear twitch | Asleep, dream-wagging | Asleep, wings folded | Asleep |
| foggy | Peers left and right | Sniffs the air | Peers into the murk | Happy, croaking |
| loading | Impatient hops | Hops and wags | Hovers | Bounces |

**Regenerating the files.** The art and motion live as code in `tool/petgen`
(see its README). Do not hand-edit the JSON.

**Renderer limits.** The web build uses Flutter's HTML renderer, which paints
Lottie gradient fills black. The generator therefore bakes every gradient into
stacked flat tones; the exporter refuses to emit a gradient.
