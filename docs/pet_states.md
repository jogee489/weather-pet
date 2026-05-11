# Pet States

Each state is driven by real weather data via the Open-Meteo API.
The same state drives both the background animation and the pet character image/animation.

---

## sunny
**Trigger:** WMO code 0 (clear sky), daytime, temperature 0–34 °C, wind ≤ 40 km/h.

**Background:** A sun disc sits in the upper centre. Ten white rays rotate slowly — one full revolution every 8 seconds. A soft radial glow pulses outward from the centre.

**Pet:** Gently floats upward and back in a 2-second cycle (±14 px vertical bob). Happy, content expression.

---

## cloudy
**Trigger:** WMO codes 1–3 (mainly clear → overcast), daytime, temperature 0–34 °C, wind ≤ 40 km/h.

**Background:** Five semi-transparent white cloud blobs drift left-to-right across the screen, evenly phase-staggered so the screen is never empty. Each cloud takes 8 seconds to cross.

**Pet:** Gentle diagonal float (default fall-through: 3-second sinusoidal drift, ±4 px horizontal + ±8 px vertical). Relaxed, mild expression.

---

## rainy
**Trigger:** WMO codes 51–67, 80–82 (drizzle, rain, freezing rain, rain showers).

**Background:** 80 light-blue rain streaks fall at a 20° angle. Each streak completes two full passes down the screen per 8-second loop (~4 s per pass).

**Pet:** Sways left-to-right in a 1.8-second cycle (±8 px horizontal). Wet, slightly miserable expression.

---

## snowy
**Trigger:** WMO codes 71–77, 85–86 (snow, snow grains, snow showers).

**Background:** 70 white snowflake dots fall slowly, each completing one pass in 8 seconds. Each flake follows a gentle sinusoidal horizontal drift (±15 px) to feel floaty.

**Pet:** Slow upward float in a 3.5-second cycle (±10 px vertical). Cold, bundled-up expression.

---

## stormy
**Trigger:** WMO codes 95–99 (thunderstorm, thunderstorm with hail).

**Background:** 110 dark blue-grey rain streaks fall steeply at 25°, four passes per 8-second loop (~2 s per pass — fast and heavy). A lightning flash fires every 7 seconds: sharp white full-screen bloom with an exponential decay and a brief secondary flicker.

**Pet:** Rapid horizontal shudder at 90 ms per cycle (±9 px) — mimics being startled by thunder. Scared, wide-eyed expression.

---

## windy
**Trigger:** Wind speed > 40 km/h (regardless of WMO code, daytime, temperature 0–34 °C).

**Background:** Six white spiral arcs drift left-to-right, each spinning two full turns per 8-second loop. Four green/amber tumbling leaves bob vertically and rotate as they cross the screen.

**Pet:** Sways side-to-side with a slow rotational tilt in a 1.4-second cycle (±8° rotation). Squinting, wind-blown expression.

---

## hot
**Trigger:** Apparent temperature ≥ 35 °C, daytime.

**Background:** A deep-orange heat-haze gradient rises from the bottom of the screen. 14 vertical wavy heat-shimmer columns rise upward, each completing two passes per 8-second loop with a sinusoidal lateral wave that grows toward the top.

**Pet:** Slow pulsing scale in a 1.4-second cycle (100%–107%) — languid, overheated breathing effect. Panting, exhausted expression.

---

## cold
**Trigger:** Apparent temperature < 0 °C, daytime.

**Background:** A frosted-glass vignette feathers in from all four edges (white radial gradient, transparent centre → 45% white at corners). Snowflake crystal ornaments grow from each corner. 18 tiny ice-mote particles drift slowly upward with a gentle lateral sway.

**Pet:** Fast horizontal shiver at 110 ms per cycle (±5 px) — rapid trembling. Shivering, cold expression.

---

## night
**Trigger:** `is_day = 0` from the API (local sunset to sunrise), regardless of other conditions.

**Background:** 90 stars scattered across the full screen. Stars come in three colour temperatures (warm amber, neutral white, cool blue-white) at varying sizes. Each star twinkles independently at 1, 2, or 3 cycles per 8-second loop; ~15% get a soft glow halo for depth.

**Pet:** Slow gentle breathing scale in a 4-second cycle (96%–100%). Sleepy, drowsy expression.

---

## foggy
**Trigger:** WMO codes 45, 48 (fog, depositing rime fog).

**Background:** 14 wide, flat, semi-transparent fog blobs drift at varying heights. Blobs at even-indexed positions move at double speed for a parallax layering effect (near fog moves faster). Each blob bobs very gently up and down (±18 px, 8-second cycle).

**Pet:** Default diagonal drift (3-second sinusoidal float). Confused, squinting expression.

---

## loading
**Trigger:** While weather data is being fetched on first launch or after a refresh.

**Background:** No particle layer — plain gradient background only.

**Pet:** Rhythmic pulse scale in a 900 ms cycle (90%–100%) — a “breathing” anticipation loop. Neutral, waiting expression.

---

## State priority order

When multiple conditions are true simultaneously the following precedence applies:

1. `night` — API reports `is_day = 0`
2. `hot` — apparent temperature ≥ 35 °C
3. `cold` — apparent temperature < 0 °C
4. `windy` — wind speed > 40 km/h
5. WMO-code states: `sunny`, `cloudy`, `foggy`, `rainy`, `snowy`, `stormy`

`loading` is only active while a fetch is in progress and is never derived from weather data.
