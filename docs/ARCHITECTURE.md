# Architecture

## Layers

```
Screen (UI)  ->  Provider (state)  ->  Repository (what data)  ->  Service (where data comes from)
                                                                     |- AuthService          (mock login)
                                                                     |- LocalStorageService  (SharedPreferences: user, onboarding flag)
                                                                     |- PlanDatabase         (SQLite via sqflite: savings plans)
                                                                     |- PinStore             (flutter_secure_storage: PIN hash, attempts)
                                                                     |- BiometricGate        (local_auth)
                                                                     |- MockPushService      (in-memory notifications)
                                                                     `- UserApiService       (HTTP, dummyjson.com)
```

Rules that keep the layers separate:

- **Screens** never call services or `http` directly. They read providers.
- **Providers** hold UI state and call repositories.
- **Repositories** decide where data comes from and turn failures into `AppException`.
- **Services** do one I/O job each and know nothing about the UI.
- **Models** are plain Dart classes with `fromJson` and `toJson`. They have no Flutter imports.

## Folder structure

```
lib/
|- core/           theme (AppColors, AppSpacing, AppTheme), error type, constants, navigator key
|- models/         SavingsProduct, SavingsPlan, UserProfile, AppNotification
|- services/       auth, storage, plan database, PIN store, biometrics, mock push, user API
|- repositories/   AuthRepository, SavingsRepository, ProfileRepository
|- providers/      Riverpod providers (auth, app lock, savings, products, profile, notifications)
|- screens/        splash, onboarding, login, auth (PIN setup, lock, biometric offer), dashboard, products, savings, profile, notifications
|- widgets/        shared UI, including LockGate, BrandLoader, pin/ (AdaptivePinPad, PinDots)
|- utils/          validators, formatters, plan progress, savings tally, startup route, PIN hashing
`- main.dart       app entry, navigator key, named routes
```

## State management: Riverpod

- **Compile-time safe.** Providers are typed and resolved at compile time, so a missing dependency fails early.
- **Testable.** Tests replace any provider with `ProviderScope(overrides: [...])`. The widget tests use this to swap in mock SharedPreferences and a mock HTTP client, so they never touch the network or disk.
- **No `BuildContext` in business logic.** Logic lives in providers and repositories, not widgets.
- **Clear state transitions.** `Notifier` and `AsyncNotifier` hold the auth session, the plan list, and the product filter.

The app uses Riverpod 3.3.2. It has no `StateProvider`: the product filter is a `Notifier`, because `StateProvider` moved to a legacy import in Riverpod 3.

## Auth and lock flow

Navigation uses named routes on one navigator (`appNavigatorKey`). The splash decides the first screen from stored state (`resolveStartupDestination`):

1. **First launch:** splash -> `/onboarding` -> `/login`.
2. **Login:** the demo credentials are checked by `AuthService`; the email is saved. The login screen then goes to `/pin-setup` if no PIN exists, otherwise `/dashboard`.
3. **PIN setup:** 4 digits, stored as a salted hash in secure storage. If the device supports biometrics, `/biometric-offer` follows; either choice ends at `/dashboard`.
4. **Cold start, signed in with a PIN:** the splash replaces itself with `/lock` (`lockOnColdStart`). On unlock, `/lock` is replaced by `/dashboard`.
5. **Resume:** `LockGate` listens for `paused` or `hidden`. For a signed-in user with a PIN it sets `appLockProvider`, and pushes a `/lock` route on the app navigator. Unlocking removes that route and the user is back where they were.
6. **Lock screen:** PIN or biometrics unlock it. Back closes the app (`PopScope` plus `SystemNavigator.pop`) and never shows the screen beneath. Three wrong PINs clear the stack to `/login` with "Too many attempts. Please log in again."
7. **Logout** (profile) also clears the stack back to `/login`.

If the PIN check errors, `LockGate` fails closed and locks.

## Local storage

| Store | Contents | Written by |
|---|---|---|
| SQLite (`sqflite`) | Savings plans | `SavingsRepository` through `PlanDatabase` |
| SharedPreferences | `logged_in_email`, onboarding-complete flag | `AuthRepository`, onboarding |
| flutter_secure_storage | PIN hash and salt, failed-attempt count | `PinStore` |

The `plans` table is at database version 2 and is seeded in code with three plans whose saved amounts total ₦850,000. Tests use `sqflite_common_ffi` for an in-memory database.

## Design system

`lib/core/theme/` holds the tokens. `AppColors`: primary `#5FA332`, brand `#81CB50`, surface `#F6F8F2`, heading `#15181B`, body `#5C6470`, accent `#F2A93B`, dark surface `#14190F`, dark card `#1E2516`. `AppSpacing` holds spacing and sizes. `AppTheme` builds the light and dark themes: pill buttons and inputs, 20 px cards, Manrope with a Roboto / Noto Sans fallback, because Manrope has no Naira glyph.

- `AdaptivePinPad` (`lib/widgets/pin/`) scales key size with the screen, clamped 56-88. Used by PIN setup and lock. `pin_code_fields` was removed.
- `BrandLoader` is a `CustomPainter` drawing the KoinsMFB mark; static under reduced motion. Lottie was removed.
- Onboarding uses original SVG line art in `assets/onboarding/`.

## Savings flow

- **Total savings** is the sum of saved amounts (`savings_tally`, `savings_totals_provider`). Recent savings are newest first; the dashboard shows three, with "See all" when there are more.
- **Products**: searchable list; the details page has a Create savings button that passes the product, so the create screen pre-selects it.
- **Create savings** is a stepper. Target = monthly amount x months, enforced in both directions. Fixed-term products lock the duration.
- **Saved plan details**: the progress ring is saved / target, the same rule as the dashboard tile.

## Notifications (mock)

`MockPushService` stands in for a push provider. `notificationsProvider.deliver(n)` adds a notification to an in-memory list; the inbox (`/notifications`, opened from the profile) shows them newest first, with an unread count and mark-all-read. Nothing is persisted, so the inbox resets on each app start. Real push (Firebase Cloud Messaging) is not started, as before: it needs FlutterFire configuration.

## Error handling

- All failures are converted to `AppException(message)` at the service boundary, so screens handle one error type.
- `UserApiService` maps socket errors to "No internet connection", timeouts to "Request timed out", non-200 responses to "Server error (code)", and malformed bodies to "Unexpected response from server".
- Screens show `ErrorView` with a retry button for data that failed to load, and snackbars for user actions that failed.
- `FlutterError.onError` is set in `main`. It's the hook point for crash reporting in release builds.

## Motion

Animations are built from Flutter's own widgets. No external animation files are used.

- `CountUpText` animates the total savings from zero on first build.
- `ProgressRing` animates each plan's saved-over-target progress from zero, using a `CustomPainter`.
- `StaggeredReveal` fades and slides list items in, one after another.
- `Hero` links a product card's name to the details screen title.
- The login form fades in on first build.

Every animation checks `MediaQuery.disableAnimationsOf` and skips the motion when the system asks for reduced motion.

## Testing strategy

- **Unit tests:** validators, formatters, plan progress, storage (including corrupt data), the user API service (with `MockClient`), the savings repository, and the product filter.
- **Provider tests:** auth, savings plans, and products, using a `ProviderContainer` with mocked SharedPreferences.
- **Widget tests:** login, dashboard, products, product details, create savings, profile, and the error view. A shared helper (`test/helpers/pump_app.dart`) wraps each screen in a `ProviderScope`.

## Trade-offs

- **Mock auth.** Login checks hardcoded demo credentials. A real version needs a backend, token storage, and session expiry.
- **Seeded savings.** There are no deposits, so saved amounts come from the three seeded plans (₦850,000 in total); a new plan starts with its opening deposit saved (default 0).
- **Known gaps.** The release APK is signed with the debug key, the application id is `com.example.savings_app`, and the Naira sign uses a fallback font.
- **Local products.** Products are seed data in the repository. A real app would fetch them and cache the result.
- **Named routes.** Screens navigate by route name, and the create screen receives the selected product as a route argument. The success path returns to the first route in the stack, because the dashboard can be the home route.
