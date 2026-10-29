# Architecture

## Layers

```
Screen (UI)  →  Provider (state)  →  Repository (what data)  →  Service (where data comes from)
                                                                    ├─ AuthService          (mock login)
                                                                    ├─ LocalStorageService  (SharedPreferences)
                                                                    └─ UserApiService       (HTTP, dummyjson.com)
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
├── core/           theme, error type, constants
├── models/         SavingsProduct, SavingsPlan, UserProfile
├── services/       AuthService, LocalStorageService, UserApiService
├── repositories/   AuthRepository, SavingsRepository, ProfileRepository
├── providers/      Riverpod providers (one file per feature)
├── screens/        login, dashboard, products, savings, profile
├── widgets/        shared UI: states, cards, ring, text field, count-up, reveal
├── utils/          validators, formatters, plan progress
└── main.dart       app entry, auth gate, named routes
```

## State management: Riverpod

- **Compile-time safe.** Providers are typed and resolved at compile time, so a missing dependency fails early.
- **Testable.** Tests replace any provider with `ProviderScope(overrides: [...])`. The widget tests use this to swap in mock SharedPreferences and a mock HTTP client, so they never touch the network or disk.
- **No `BuildContext` in business logic.** Logic lives in providers and repositories, not widgets.
- **Clear state transitions.** `Notifier` and `AsyncNotifier` hold the auth session, the plan list, and the product filter.

The app uses Riverpod 3.3.2. It has no `StateProvider`: the product filter is a `Notifier`, because `StateProvider` moved to a legacy import in Riverpod 3.

## Data flow: login

1. `LoginScreen` validates the form with `Validators.email` and `Validators.password`.
2. On submit, it calls `authProvider.notifier.login(email, password)`.
3. `AuthNotifier` calls `AuthRepository.login`.
4. `AuthRepository` calls `AuthService.login`, which checks the demo credentials and throws `AppException` if they're wrong.
5. On success, `AuthRepository` saves the normalised email through `LocalStorageService`.
6. `AuthNotifier` sets its state to the email. `SavingsApp` watches that state and rebuilds with the dashboard as home.
7. The login screen also pushes `/dashboard`, so the user lands there immediately.

If the credentials are wrong, `AppException` reaches the screen and is shown in a snackbar. The button is disabled while the request is in flight, so a double tap can't submit twice.

## Local storage

| Key | Type | Contents | Written by |
|---|---|---|---|
| `logged_in_email` | String | Normalised email of the signed-in user | `AuthRepository.login` |
| `savings_plans` | JSON list | Plans the user has created | `SavingsRepository.createPlan` |

If `savings_plans` holds corrupt JSON, `LocalStorageService.loadPlans` returns an empty list and the app keeps running.

## Error handling

- All failures are converted to `AppException(message)` at the service boundary, so screens handle one error type.
- `UserApiService` maps socket errors to "No internet connection", timeouts to "Request timed out", non-200 responses to "Server error (code)", and malformed bodies to "Unexpected response from server".
- Screens show `ErrorView` with a retry button for data that failed to load, and snackbars for user actions that failed.
- `FlutterError.onError` is set in `main`. It's the hook point for crash reporting in release builds.

## Motion

Animations are built from Flutter's own widgets. No external animation files are used.

- `CountUpText` animates the total savings from zero on first build.
- `ProgressRing` animates each plan's progress from zero, using a `CustomPainter`.
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
- **Time-based progress.** Rings show time elapsed because there are no deposits yet. This will change once deposits exist.
- **Fixed total.** The ₦850,000 total is fixed, as the brief specifies, so it doesn't change when plans are created.
- **Local products.** Products are seed data in the repository. A real app would fetch them and cache the result.
- **Named routes.** Screens navigate by route name, and the create screen receives the selected product as a route argument. The success path returns to the first route in the stack, because the dashboard can be the home route.
