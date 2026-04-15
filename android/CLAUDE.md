# Weather Pet — Android Claude Context

## What This App Is

Flutter weather app with an animated cat mascot that reacts to live weather.
The cat changes animation style and the background gradient changes colour for
11 weather states (sunny, cloudy, rainy, snowy, stormy, windy, hot, cold,
foggy, night, loading). The app fetches real weather from Open-Meteo (free, no
API key) using the device's GPS location.

**Live web version:** https://jogee489.github.io/weather-pet/

---

## Your Job — Android Side

You are responsible for the Android-native parts of the project:

### 1. Test and fix the home screen widget
All code is written. It has NOT been tested on a real device yet.

**What the widget does:**
- Shows the cat emoji, current temperature, weather condition, and city name
- Tapping it deep-links into the app
- Updates automatically when the Flutter app fetches new weather

**How to test:**
1. Let Gradle sync complete (may take a few minutes first time)
2. `flutter run` on an emulator or physical device
3. Wait for the app to fetch weather (grant location permission)
4. Long-press the home screen → Widgets → Weather Pet → drag onto home screen
5. Verify: emoji, temperature, city name all appear correctly
6. Tap the widget → should open the app

**Key files:**
- `android/app/src/main/kotlin/com/example/weather_pet/WeatherPetWidget.kt` — the provider class
- `android/app/src/main/res/layout/weather_pet_widget.xml` — the layout
- `android/app/src/main/res/xml/weather_pet_widget_info.xml` — widget metadata
- `android/app/src/main/AndroidManifest.xml` — receiver registration
- `lib/home_widget/widget_provider.dart` — Dart side that pushes data

**Data keys written by Flutter (read these in Kotlin):**
- `temperature` — e.g. `"18°C"`
- `city` — e.g. `"London"`
- `condition` — e.g. `"Partly cloudy"`
- `emoji` — e.g. `"😸"`
- `petState` — e.g. `"sunny"`

**App Group ID:** `group.com.example.weather_pet`
**Widget class name:** `WeatherPetWidget`
**Application ID:** `com.example.weather_pet`
**Gradle version:** 8.4 (required for Java 21 compatibility)

---

### 2. Fix anything Gradle sync surfaces

Common issues to watch for:
- `home_widget` plugin version conflicts — check `pubspec.lock` and align
- Missing `compileSdk` / `minSdk` — current values delegate to Flutter defaults
- `local.properties` missing `sdk.dir` — Android Studio sets this automatically

---

### 3. Temperature unit toggle (in progress on Flutter side)

The Flutter side is implementing `°C/°F` switching on branch
`feature/temperature-unit-toggle`. Once merged, the Android widget will need
to read the persisted unit preference and display the correct unit.

The preference will be stored in SharedPreferences under key `temperature_unit`
with values `"celsius"` or `"fahrenheit"`. The Flutter side will also write a
pre-formatted string to `temperature` (e.g. `"64°F"`) so the widget can just
display it directly without converting.

---

## Architecture You Need To Know

```
locationProvider
  └── weatherProvider (AsyncNotifier<WeatherData>)
        ├── petStateProvider  ← drives cat animation + gradient
        └── widgetSyncProvider  ← pushes data to home_widget SharedPrefs
```

`widgetSyncProvider` in `lib/home_widget/widget_provider.dart` is what triggers
`HomeWidget.updateWidget()`. It is guarded with `if (kIsWeb) return;` so it
only runs on mobile.

The widget receiver in `AndroidManifest.xml` listens for two intents:
- `android.appwidget.action.APPWIDGET_UPDATE` — standard OS updates
- `es.antonborri.home_widget.action.UPDATE` — triggered by the Flutter app

---

## Key Gotchas

- **Do not modify `lib/` files** unless asked — Flutter side is managed separately
- **Gradle 8.4** — do not downgrade, it's required for Java 21
- **`android/local.properties`** is gitignored — Android Studio generates it
- The `android/.gitignore` inside the android folder ignores build outputs,
  `.gradle/`, and `local.properties` — everything else is committed
- Run `flutter pub get` in terminal if Android Studio can't resolve Flutter plugins

---

## Running the App

```bash
# From the project root
flutter pub get
flutter run                    # picks up connected device/emulator automatically
flutter run -d emulator-5554  # target specific emulator
```

To build a debug APK:
```bash
flutter build apk --debug
```

---

## Repo Info

- **Repo:** `jogee489/weather-pet`
- **Main branch:** `main`
- **Current Flutter feature branch:** `feature/temperature-unit-toggle`
- **Flutter version:** 3.22.x
- **Dart SDK:** >=3.3.0 <4.0.0
