# Playwright + Flutter Web — Errors Encountered & Resolved

Real failures hit during the weather-pet project, with the exact error,
what caused it, and what fixed it.

---

## Error 1: `toBeVisible()` always fails on Flutter text

**Symptom**
```
Error: Locator expected to be visible
  Received: <flt-paragraph style="visibility: hidden; ...">18°C</flt-paragraph>
```

**Cause**
Flutter's HTML renderer marks every `flt-paragraph` as `visibility: hidden` in
CSS. Flutter drives visibility through its own rendering pipeline, not CSS.
Playwright's `toBeVisible()` checks CSS visibility and always fails.

**Fix**
```ts
// WRONG
await expect(page.getByText(/\d+°C/)).toBeVisible();

// CORRECT
await expect(page.getByText(/\d+°C/).first()).toBeAttached({ timeout: 10_000 });
```

---

## Error 2: `click()` times out — Flutter swallows all pointer events

**Symptom**
```
Error: locator.click: Timeout 30000ms exceeded
  waiting for element to receive pointer events
  element intercepts pointer events: <flutter-view id="flt-glass-pane" ...>
```

**Cause**
`flutter-view` sits over the entire page and intercepts 100% of pointer events.
Playwright can never deliver a click to a Flutter widget.

**Fix**
Don't click — navigate by URL instead.
```ts
// WRONG
await page.getByText('Settings').click();

// CORRECT
await page.goto('/#/settings');
```

---

## Error 3: `page.goto('/settings')` returns 404 and Flutter never boots

**Symptom**
Page loads a 404 from the static file server. No Flutter content appears.
All subsequent selectors time out.

**Cause**
Flutter web uses hash-based routing by default. `/settings` is a real URL path
that the file server tries to serve as a file — it doesn't exist, so 404.
The correct Flutter route is `/#/settings`.

**Fix**
```ts
// WRONG — hits static file server, Flutter never loads
await page.goto('/settings');

// CORRECT
await page.goto('/#/settings');
```

---

## Error 4: `scrollIntoViewIfNeeded()` fails for off-screen elements

**Symptom**
Tried `await element.scrollIntoViewIfNeeded()` before asserting on elements
near the bottom of the screen (humidity %, wind speed). Still timed out.

**Cause**
Flutter renders its own layout — DOM scroll APIs have no effect on what Flutter
has drawn. `scrollIntoViewIfNeeded` moves the DOM node but Flutter doesn't
rerender in response.

**Fix**
Don't scroll. Just assert with `toBeAttached()` — if the element is in the DOM
it will be found regardless of scroll position.
```ts
// WRONG
await page.getByText(/%/).scrollIntoViewIfNeeded();
await expect(page.getByText(/%/)).toBeVisible();

// CORRECT
await expect(page.getByText(/%/).first()).toBeAttached({ timeout: 10_000 });
```

---

## Error 5: Strict mode violation — locator matches more than one element

**Symptom**
```
Error: strict mode violation: getByText(/\d+°C/) resolved to 2 elements:
  1) <flt-paragraph>18°C</flt-paragraph>
  2) <flt-paragraph>Feels like 16°C</flt-paragraph>
```

**Cause**
The regex `/\d+°C/` matches both the main temperature and the "Feels like"
line. Playwright strict mode throws when a locator resolves to multiple elements.

**Fix**
```ts
// WRONG
await expect(page.getByText(/\d+°C/)).toBeAttached();

// CORRECT — take the first match
await expect(page.getByText(/\d+°C/).first()).toBeAttached();
```

---

## Error 6: All tests fail because geolocation/API is not mocked

**Symptom**
App shows "Could not fetch weather" error state. Temperature never appears.
Tests that check for `°C` time out.

**Cause**
In CI there is no GPS hardware and outbound API calls are unreliable.
Without mocks the app hits real Open-Meteo and the browser geolocation API,
both of which fail or time out.

**Fix**
Set up mocks in `beforeEach` for every spec:
```ts
async function setupWeatherMocks(context: BrowserContext, page: Page) {
  await context.grantPermissions(['geolocation']);
  await context.setGeolocation({ latitude: 51.5074, longitude: -0.1278 });
  await page.route('**/api.open-meteo.com/**', async route => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify(mockForecastResponse()),
    });
  });
}
```

---

## Error 7: GitHub Pages shows the README, not the Flutter app

**Symptom**
`https://jogee489.github.io/weather-pet/` renders the repo README.
No Flutter UI appears.

**Cause**
GitHub Pages was configured to serve from the `main` branch root.
The `main` branch root has a `README.md` but no `index.html` — Pages serves
the README. The Flutter build output lives in the `gh-pages` branch
(written by the `peaceiris/actions-gh-pages` action).

**Fix**
In the GitHub repo: Settings → Pages → Source → set branch to `gh-pages`.

---

## Error 8: `flutter analyze --fatal-infos` fails on unused parameters

**Symptom** (CI failure)
```
error - Unused element '_AnimConfig.repeat' - lib/features/pet/pet_widget.dart
error - Unused element '_AnimConfig.reverse' - lib/features/pet/pet_widget.dart
```

**Cause**
`--fatal-infos` promotes info-level lint hints to errors. Fields were added to
`_AnimConfig` for future use but never read.

**Fix**
Remove unused fields. Move any logic they controlled inline (in this case
`controller.repeat(reverse: true)` was hardcoded directly in `_start()`).

---

## Error 9: `pumpAndSettle()` times out in Flutter widget tests

**Symptom**
```
flutter: Timeout waiting for pumpAndSettle to settle.
There are 1 pending timers, the first is:
  Timer (duration: 0:00:00.090000, periodic: true)
```

**Cause**
Any widget with a repeating `AnimationController` (loading spinner, pet
animation) means there are always pending timers. `pumpAndSettle()` waits for
all timers to complete — they never do.

**Fix**
```dart
// WRONG — times out when AnimationController.repeat() is active
await tester.pumpAndSettle();

// CORRECT — advance one frame, then a short extra pump to let Riverpod rebuild
await tester.pump();
await tester.pump(const Duration(milliseconds: 100));
```

---

## Error 10: `ref.watch()` called inside `refresh()` — invalid lifecycle

**Symptom** (runtime crash on retry button tap)
```
Bad state: ref.watch can only be used within the build method of a widget
or the body of a provider
```

**Cause**
`refresh()` is a method called from a button callback, not from a provider's
`build()`. `ref.watch()` is only valid during `build()`.

**Fix**
```dart
// WRONG
Future<void> refresh() async {
  final location = await ref.watch(locationProvider.future); // crashes
  ...
}

// CORRECT
Future<void> refresh() async {
  await ref.read(locationProvider.notifier).refresh();
  state = await AsyncValue.guard(() async {
    final location = await ref.read(locationProvider.future);
    ...
  });
}
```

---

## Error 11: Retry fetches stale failed location, weather still fails

**Symptom**
Tapping "Try Again" on the error screen re-shows the error immediately.
The location never updates even when GPS is now available.

**Cause**
`refresh()` only re-fetched weather using the cached (failed) location.
It didn't re-run the location provider, so the GPS error was never retried.

**Fix**
`refresh()` must refresh location first, then fetch weather:
```dart
Future<void> refresh() async {
  state = const AsyncLoading();
  await ref.read(locationProvider.notifier).refresh(); // re-run GPS first
  state = await AsyncValue.guard(() async {
    final location = await ref.read(locationProvider.future);
    return const WeatherApi().fetchWeather(lat: location.lat, lon: location.lon);
  });
}
```

---

## Error 12: `flutter build web` fails — `home_widget` not web-compatible

**Symptom** (CI failure)
```
Error: Unsupported operation: Platform._operatingSystem
```
or MissingPluginException at runtime.

**Cause**
`home_widget` is Android/iOS only. Calling `HomeWidget.*` methods during a web
build or web runtime throws because the underlying platform channels don't exist.

**Fix**
Guard all `HomeWidget` calls with `kIsWeb`:
```dart
import 'package:flutter/foundation.dart' show kIsWeb;

final widgetSyncProvider = Provider<void>((ref) {
  if (kIsWeb) return; // home_widget not supported on web
  HomeWidget.setAppGroupId(_kGroupId);
  ...
});
```

---

## Error 13: Merge conflict overwrites fixed E2E test files

**Symptom**
After merging `main` into the feature branch, Playwright tests start failing
again with the original `toBeVisible()` errors.

**Cause**
`main` had an older version of `e2e/home_screen.spec.ts` and
`e2e/navigation.spec.ts`. The merge conflict resolution accidentally kept
`main`'s broken versions.

**Fix**
When the same E2E files conflict, keep the feature branch (HEAD) version:
```bash
git checkout --ours e2e/home_screen.spec.ts
git checkout --ours e2e/navigation.spec.ts
git add e2e/
git commit
```
