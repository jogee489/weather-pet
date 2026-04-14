# Playwright + Flutter Web — Lessons Learned

Everything required to make Playwright tests work against a Flutter web app,
learned the hard way on the weather-pet project.

---

## 1. Use the HTML renderer, not CanvasKit

Always build with `--web-renderer html`:

```bash
flutter build web --web-renderer html
```

CanvasKit renders everything into a single WebGL canvas. Playwright can't inspect
any text or elements inside it. The HTML renderer outputs real DOM nodes that
Playwright can query.

In CI, pass the flag to every `flutter build web` invocation.

---

## 2. Use `toBeAttached()` not `toBeVisible()`

Flutter's HTML renderer marks `flt-paragraph` elements as `visibility: hidden`
in CSS — Flutter manages its own rendering pipeline, not CSS visibility.

```ts
// WRONG — always fails for Flutter text
await expect(page.getByText('22°C')).toBeVisible();

// CORRECT
await expect(page.getByText('22°C')).toBeAttached({ timeout: 10_000 });
```

---

## 3. Hash-based routing — always use `/#/route`

Flutter web uses hash routing by default (`/#/home`, `/#/settings`).
Navigating to `/settings` (no hash) hits the static file server, returns a 404,
and Flutter never boots.

```ts
// WRONG
await page.goto('/settings');

// CORRECT
await page.goto('/#/settings');
```

---

## 4. Don't click Flutter nav elements — use URL navigation

`flutter-view` intercepts ALL pointer events on the page. Playwright click
actions time out waiting for a Flutter element to receive them.

```ts
// WRONG — times out
await page.getByText('Settings').click();

// CORRECT
await page.goto('/#/settings');
```

---

## 5. Add `waitForTimeout` after navigation

Flutter needs time to boot, run the splash sequence, and render.
Without a wait, queries run before any Flutter content exists in the DOM.

```ts
await page.goto('/');
await page.waitForTimeout(5000); // splash + weather fetch
```

For direct hash routes (skipping splash), 4000ms is usually enough:

```ts
await page.goto('/#/home');
await page.waitForTimeout(4000);
```

---

## 6. Use `.first()` to avoid strict-mode violations

A regex like `/\d+°C/` can match multiple elements on the page
(e.g. "18°C" in the main display AND "Feels like 18°C" in the subtitle).
Playwright strict mode throws if a locator matches more than one element.

```ts
// WRONG — throws if regex matches multiple elements
await expect(page.getByText(/\d+°C/)).toBeAttached();

// CORRECT
await expect(page.getByText(/\d+°C/).first()).toBeAttached();
```

---

## 7. Mock the weather API and geolocation

Without mocks the app tries real GPS + real HTTP in CI, which fails.
Set these up in `beforeEach`:

```ts
async function setupWeatherMocks(context: BrowserContext, page: Page) {
  // Fixed GPS location (London)
  await context.grantPermissions(['geolocation']);
  await context.setGeolocation({ latitude: 51.5074, longitude: -0.1278 });

  // Intercept Open-Meteo and return deterministic JSON
  await page.route('**/api.open-meteo.com/**', async route => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify(mockForecastResponse()),
    });
  });
}
```

Keep `mockForecastResponse()` in a shared `e2e/helpers.ts` so every spec uses
identical data.

---

## 8. Flutter widget tests: never use `pumpAndSettle()`

Any widget with a repeating `AnimationController` (e.g. a loading spinner or
pet animation) means `pumpAndSettle()` will time out — it waits for all
animations to settle, which never happens.

```dart
// WRONG — times out when AnimationController.repeat() is active
await tester.pumpAndSettle();

// CORRECT
await tester.pump();
await tester.pump(const Duration(milliseconds: 100));
```

---

## 9. Playwright config — key settings for Flutter web

```ts
// playwright.config.ts
export default defineConfig({
  use: {
    baseURL: 'http://localhost:8080',
    // Flutter web needs a real browser, not a headless shell
    headless: true,
  },
  timeout: 30_000,          // Flutter boot is slow
  expect: { timeout: 10_000 },
});
```

---

## 10. CI: serve the build before running tests

```yaml
- name: Serve web build & run Playwright tests
  run: |
    npx serve build/web -p 8080 &
    sleep 3                      # wait for server to be ready
    npx playwright test
```

`npx serve` is synchronous-ish but needs a moment. `sleep 3` is enough.
