# Savings App

A simple savings application built with Flutter. Users log in, browse savings products, create savings plans, and view their dashboard and profile.

## Setup

```bash
git clone <your-repo-url>
cd savings_app
flutter pub get
flutter run
```

To build the release APK:

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

A copy of the release build is in `releases/savings-app-release.apk`.

**Demo credentials:** `test@bank.com` / `Password123`

## Flutter version

- Flutter: **3.32.6** (stable channel)
- Dart: **3.8.1**
- Target: Android (`minSdk` from the Flutter default). iOS folders are scaffolded but not built or tested.

## Architecture

Layered architecture: screens → providers → repositories → services. Models are plain Dart with no Flutter imports. See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the full write-up.

State management: **Riverpod** (`flutter_riverpod`).

## Packages used

Versions are the resolved versions from `pubspec.lock`.

| Package | Version | Purpose |
|---|---|---|
| flutter_riverpod | 3.3.2 | State management and dependency injection |
| shared_preferences | 2.5.3 | Persist logged-in user and savings plans |
| http | 1.6.0 | Calls to the public mock API |
| intl | 0.20.2 | Naira currency formatting |
| flutter_svg | 2.2.3 | Renders the app logo |
| cupertino_icons | 1.0.8 | Default Flutter icon set (template) |
| flutter_test | SDK | Unit and widget tests |
| flutter_lints | 5.0.0 (dev) | Lint rules |

Fonts: **Manrope** (SIL Open Font License 1.1), bundled under `assets/fonts/`. See [`ASSETS.md`](ASSETS.md).

## Features

- Login with validation (email required, valid format, password required, minimum 8 characters)
- Dashboard: greeting, total savings with a count-up animation, quick actions, three recent plans with progress rings
- Savings products list with search and a "Flexible only" filter
- Product details with a shared-element (`Hero`) transition from the product card
- Create savings with validation, dropdown product type, and a success confirmation
- Profile loaded from a public API (`dummyjson.com`), with logout back to login
- Loading, empty, and error states, with retry where it makes sense
- Pull to refresh on the dashboard and products list
- Staggered entrance animations; all motion is turned off when the system asks for reduced motion
- Auto login: a returning user goes straight to the dashboard

## Assumptions

- Authentication is mocked. Credentials are hardcoded and no token is issued.
- Total savings is a fixed ₦850,000 per the brief. Created plans do not change it, because the app has no deposit records.
- Created plans are stored locally and start with no deposits.
- Plan progress rings show **time elapsed** (creation date to today, as a share of the plan's duration), not money saved, because there are no deposits to measure.
- The three dashboard "recent" plans are seed data in memory. Only plans the user creates are persisted.
- The profile screen uses `dummyjson.com/users/1` as the logged-in user's data.
- Products are local seed data, since the brief lists them and does not require an API for them.
- The greeting is hardcoded "Good Morning, John Doe" per the brief, regardless of the time of day.
- "Forgot password?" and "Create account" are visible but show a "Coming soon" message.
- Amounts are whole naira. Commas are accepted and removed before parsing.

## Testing

```bash
flutter test
```

Covers validators, formatters, storage (including corrupt-data recovery), auth, savings and product providers, the user API service (success, HTTP error, offline, timeout, malformed body), and widget tests for login, dashboard, products, product details, create savings, profile, and the error view.

Result at the time of writing: **52 tests passed**, `flutter analyze` reports no issues.

## Screenshots

`screenshots/01-login-empty.png` shows the login screen on an Android emulator. The remaining screens were not captured on the device. See the note in the Improvements section.

## Improvements if given more time

- Replace mock auth with a real backend, and store tokens in `flutter_secure_storage`.
- Store products and plans in SQLite or Hive for querying and larger data sets.
- Track real deposits, so progress rings can show money saved against the target.
- Add offline detection (`connectivity_plus`) and a global offline banner.
- Add biometric and PIN login.
- Add integration tests that run on a device or emulator in CI.
- Add GitHub Actions to run analyze, test, and build on every push.
- Capture the full set of screenshots with an automated integration test, rather than by hand.
- Localize strings and run an accessibility audit (screen reader labels, contrast, text scaling).
