# Savings App

A simple savings application built with Flutter. Users go through onboarding, log in, set a PIN (and optionally biometrics), browse savings products, create savings plans, and view their dashboard, profile and notifications inbox.

## Setup

Requirements: Flutter 3.32.6 (Dart 3.8.1) and an Android emulator or device.

```bash
git clone <your-repo-url>
cd koins-savings-assessment
flutter pub get
flutter run            # runs on the connected Android device or emulator
flutter test           # runs the test suite
```

### Build

```bash
flutter build apk --debug     # build/app/outputs/flutter-apk/app-debug.apk
flutter build apk --release   # build/app/outputs/flutter-apk/app-release.apk
```

A copy of the release build (about 55 MB) is in `releases/savings-app-release.apk`. **The release build is signed with the debug key** (`android/app/build.gradle.kts` uses `signingConfigs.debug` for `release`), so it installs and runs but is not suitable for a store. See Improvements.

**Demo credentials:** `test@bank.com` / `Password123`

## Flutter version

- Flutter: **3.32.6** (stable channel)
- Dart: **3.8.1**
- Target: Android (`minSdk` from the Flutter default). iOS folders are scaffolded but not built or tested.

## Packages used

Versions are the resolved versions from `pubspec.lock`.

| Package | Version | Purpose |
|---|---|---|
| flutter_riverpod | 3.3.2 | State management and dependency injection |
| local_auth | 2.3.0 | Optional biometric unlock |
| flutter_secure_storage | 10.3.4 | Keeps the PIN hash and failed-attempt count in the Android Keystore-backed store |
| crypto | 3.0.8 | Salted SHA-256 hash of the PIN |
| sqflite | 2.4.2 | SQLite storage for savings plans |
| path | 1.9.1 | Builds the database file path |
| sqflite_common_ffi (dev) | 2.3.6 | Runs SQLite in unit tests on the host machine |
| shared_preferences | 2.5.3 | Logged-in user and the onboarding-complete flag |
| http | 1.6.0 | Calls to the public mock API (`dummyjson.com`) |
| intl | 0.20.2 | Naira currency and date formatting |
| flutter_svg | 2.2.3 | Renders the brand mark and onboarding illustrations |
| flutter_launcher_icons (dev) | 0.14.4 | Generates the launcher icon |
| cupertino_icons | 1.0.8 | Default Flutter icon set (template) |
| flutter_lints (dev) | 5.0.0 | Lint rules |

Fonts: **Manrope** (SIL Open Font License 1.1), bundled under `assets/fonts/`. See [`ASSETS.md`](ASSETS.md).

## Features

- Splash, then onboarding (three slides, shown once), then login
- Login with validation (email required, valid format, password required, minimum 8 characters); demo credentials above
- PIN setup after the first login (4 digits), with an optional biometric offer
- Lock on resume (app sent to the background) and on cold start; 3 wrong PIN attempts sign the user out
- Dashboard: greeting, total savings (sum of saved amounts) with a count-up animation, quick actions, recent savings newest first (three shown, "See all" when there are more), progress rings
- Savings products: searchable list; details page with a Create savings button that pre-selects the product
- Create savings as a stepper. Target = monthly amount x months is enforced in both directions; fixed-term products lock the duration. Ends with a success confirmation
- Saved plan details: the progress ring is saved / target, the same rule as the dashboard tile
- Profile loaded from `dummyjson.com`, with logout back to login
- Mock notifications inbox, opened from the profile screen
- Pull to refresh on the dashboard and products list
- Loading, empty, and error states, with retry where it makes sense
- Staggered entrance animations; motion is off when the system asks for reduced motion

## Design

- **Tokens** in `lib/core/theme/`: `AppColors` (primary `#5FA332`, brand `#81CB50`, surface `#F6F8F2`, heading `#15181B`, body `#5C6470`, accent `#F2A93B`, dark surface `#14190F`, dark card `#1E2516`), `AppSpacing`, and `AppTheme` (pill buttons and inputs, 20 px cards, Manrope with a Roboto / Noto Sans fallback for the Naira sign). Light and dark themes.
- **Adaptive PIN pad** (`lib/widgets/pin/adaptive_pin_pad.dart`): key size scales with the screen, clamped to 56-88. The `pin_code_fields` package was removed.
- **Brand loader** (`lib/widgets/brand_loader.dart`): a `CustomPainter` drawing the KoinsMFB mark; static under reduced motion. The Lottie animation and package were removed.
- **Onboarding illustrations**: original line art in `assets/onboarding/illustration_1.svg` to `_3.svg`.
- The launcher icon and in-app logo are unchanged.

## Architecture

Layered: screens, then providers, then repositories, then services. Models are plain Dart with no Flutter imports. See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the write-up.

**State management: Riverpod.** Providers are typed and resolved at compile time, so a missing dependency fails early. Tests replace any provider with `ProviderScope(overrides: [...])`, so widget tests never touch the network, disk or secure storage. One state package covers state, dependency injection and async loading, so there is no second mechanism to learn.

**Navigation: `Navigator` with named routes.** The lock screen is a route on the app navigator (`appNavigatorKey`), not an overlay, so Back is handled by the lock screen's `PopScope` and never reveals the screen beneath it.

**Local storage**

- **SQLite (`sqflite`)** for savings plans, in a `plans` table (database version 2). The table is seeded in code with three plans whose saved amounts total N850,000. Plans are records that are queried and ordered, which suits a table.
- **SharedPreferences** for small flags: the logged-in email and the onboarding-complete flag.
- **flutter_secure_storage** for the PIN hash and the failed-attempt count.
- **Why no Hive:** SQLite is already needed for structured plan data, is queryable, and needs no code generation or adapters. Adding Hive would mean a third store with no benefit here.

## Assumptions

- Login is demo only. Register and Forgot Password are visible but non-functional by requirement (they show "Coming soon").
- Biometrics are optional. The user is offered them after setting a PIN and can always unlock with the PIN.
- The PIN is 4 digits.
- Android is the target. iOS is not built or tested.
- The Koins asset bundle (icon, logo, onboarding images, loading animation) is provided by the owner. Its licence is unverified; see `ASSETS.md`.
- The product list is static seed data. Search runs on that list.
- The dashboard total is the sum of saved amounts. The three seeded plans give N850,000. A newly created plan starts with nothing saved, because the app has no deposit records.
- Progress rings show saved amount as a share of the target.
- The profile screen uses `dummyjson.com/users/1` as the logged-in user's data.
- The greeting is hardcoded "Good Morning, John Doe" per the brief.
- Amounts are whole naira. Commas are accepted and removed before parsing.

## Testing

```bash
flutter test
flutter analyze lib test
```

Covers validators, formatters, storage (including corrupt-data recovery and the seeded plans table), auth, PIN and lock logic, savings and product providers, notifications, the user API service (success, HTTP error, offline, timeout, malformed body), and widget tests for the main screens.

Run both commands for the current result. Integration tests run on a device and are not part of `flutter test`.

## Screenshots

All captured on an Android emulator, in `screenshots/`.

| File | Shows |
|---|---|
| `00-launcher-koinsmfb.png` | KoinsMFB in the launcher search results |
| `00b-login-koins-theme.png` | Login screen, light theme |
| `00b-login-koins-theme-dark.png` | Login screen, dark theme |
| `00c-splash.png` | Splash screen |
| `00d-home-koinsmfb-icon.png` | Home screen with the earlier launcher icon (square inside a ring) |
| `00e-home-koinsmfb-icon-fixed.png` | Home screen with the launcher icon without the second tile |
| `01-login-empty.png` | Empty login form (first capture) |
| `01-onboarding-1.png`, `02-onboarding-2.png`, `03-onboarding-3.png` | The three onboarding slides |
| `04-login.png` | Login screen |
| `05-dashboard.png` | Dashboard |
| `06-relaunch-dashboard.png` | Dashboard after relaunching the app |
| `07-pin-setup.png` | PIN setup |
| `09-lock.png` | Lock screen |
| `10-login-after-lockout.png` | Login after too many wrong PIN attempts ("Too many attempts. Please log in again.") |
| `11-coming-soon.png` | "Coming soon" message from Forgot password / Create account |
| `13-plan-persisted-sqlite.png` | A created plan that persists in SQLite |
| `14-back-on-onboarding-to-login.png` | Back from onboarding to login |
| `15-naira-glyph.png` | The Naira sign rendering correctly |
| `16-notifications-inbox.png` | Mock notifications inbox |
| `20-splash-brand-loader.png` to `34-lock.png` | Redesign walk-through: brand loader, onboarding, login, PIN setup, dashboard, products, product details, create savings, success, all plans, saved plan details, lock |

## Known gaps

- The release APK is signed with the debug key.
- The application id is `com.example.savings_app`.
- The Naira sign uses a fallback font (Roboto / Noto Sans), because Manrope has no glyph for it.

## Improvements if given more time

- Real backend and authentication, with tokens in `flutter_secure_storage`.
- Real registration and password reset.
- Firebase Analytics and real push notifications. Unchanged by the redesign: Firebase is not started (it needs FlutterFire configuration) and push is still the mock inbox.
- PBKDF2 (or similar slow hash) for the PIN, instead of a salted SHA-256.
- A store-ready application id and a proper release signing key (see Known gaps).
- iOS build and testing.
- A test-user screen for reviewers.
- More widget tests, and integration tests run on a device in CI.
- Track real deposits, so saved amounts come from payments instead of seed data.
- Offline detection and a global offline banner.
- Localization and an accessibility audit.
