# Savings App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Flutter savings app from the assessment brief: login, dashboard, savings products, product details, create savings, profile with logout, and a public-API fetch, with its own original visual identity.

**Architecture:** Layered Flutter app (screens → Riverpod providers → repositories → services) with SharedPreferences for local persistence, `http` for the public mock API, and Material 3 theming. Each task produces tested, committed code that runs on its own.

**Tech Stack:** Flutter (latest stable), Dart, flutter_riverpod, shared_preferences, http, intl, mocktail (dev), google_fonts (OFL fonts), Material Symbols icons.

**Spec:** `BUILD_GUIDE.md` in the project root, plus `Flutter Developer Technical Assessment - Koins MFB.pdf` (the brief).

## Global Constraints

- Flutter: latest stable; record the exact version in the README.
- Material 3 with `useMaterial3: true`.
- Demo login: `test@bank.com` / `Password123`; password minimum 8 characters.
- Total savings shown on the dashboard: `₦850,000` (fixed, per brief).
- Currency format: `₦` prefix, thousands separators, no decimals.
- Profile data source: `https://dummyjson.com/users/1`; no API keys.
- Visual identity: original logo, original palette, open-licensed fonts and icons only. No third-party brand marks, logos, fonts, or illustrations.
- Every task ends with `flutter analyze` clean and its tests passing.

## Review Focus

1. Email entered with surrounding spaces or uppercase letters (e.g. ` Test@Bank.com `) should log in like the trimmed lowercase address.
2. Amounts with commas (e.g. `1,000,000`) should be accepted and stored as numbers.
3. Tapping Login or Create twice quickly should not submit twice or push two routes.
4. Corrupt or unreadable saved plans in SharedPreferences should not crash the dashboard.
5. Offline or timed-out profile request should show the error state with a working retry.

Each line above gets its test in the task that owns the code (noted per task below).

---

## File Structure

Created in `lib/` (see BUILD_GUIDE.md §4.1 for the full tree):
- `core/theme/app_theme.dart`: Material 3 light and dark themes.
- `core/errors/app_exception.dart`: single error type.
- `core/constants/app_constants.dart`: mock credentials, API base URL, total savings.
- `utils/validators.dart`, `utils/formatters.dart`: pure functions, no Flutter imports.
- `models/*.dart`: plain Dart with `fromJson`/`toJson`.
- `services/auth_service.dart`, `services/local_storage_service.dart`, `services/user_api_service.dart`.
- `repositories/auth_repository.dart`, `repositories/savings_repository.dart`, `repositories/profile_repository.dart`.
- `providers/providers.dart`, `providers/auth_provider.dart`, `providers/savings_provider.dart`, `providers/profile_provider.dart`.
- `screens/…` and `widgets/…` per BUILD_GUIDE.md.
- `assets/brand/` (logo SVG), `assets/fonts/` (OFL font files), `assets/icons/` (if any custom icons).

Tests in `test/` mirror `lib/`.

---

### Task 1: Project scaffold, dependencies, theme

**Files:**
- Create: `lib/core/theme/app_theme.dart`, `lib/core/constants/app_constants.dart`, `lib/core/errors/app_exception.dart`
- Modify: `pubspec.yaml`, `lib/main.dart` (replace counter app)
- Test: `test/core/theme_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `AppTheme.light() -> ThemeData`, `AppTheme.dark() -> ThemeData`; `AppException(String message)` implements `Exception`; `AppConstants.mockEmail`, `mockPassword`, `userApiBase`, `totalSavings` (int 850000).

- [ ] **Step 1: Write the failing test**

```dart
test('light theme uses Material 3 and dark theme is dark', () {
  expect(AppTheme.light().useMaterial3, isTrue);
  expect(AppTheme.dark().colorScheme.brightness, Brightness.dark);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/theme_test.dart`
Expected: FAIL (`AppTheme` not defined)

- [ ] **Step 3: Add dependencies and create the three core files**

Run the `flutter pub add` line from BUILD_GUIDE.md §3, then `flutter pub add google_fonts`. Implement `AppTheme`, `AppConstants`, and `AppException` as in BUILD_GUIDE.md §5–6. Use `CardThemeData`, not `CardTheme`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/theme_test.dart`
Expected: PASS. Then run `flutter analyze`. Expected: `No issues found`.

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "chore: scaffold project with theme and core constants"
```

---

### Task 2: Validators and formatters

**Files:**
- Create: `lib/utils/validators.dart`, `lib/utils/formatters.dart`
- Test: `test/utils/validators_test.dart`, `test/utils/formatters_test.dart`

**Interfaces:**
- Consumes: `AppConstants` (Task 1).
- Produces: `Validators.email(String?) -> String?`, `Validators.password(String?) -> String?`, `Validators.requiredField(String?, String label) -> String?`, `Validators.positiveNumber(String?, String label) -> String?`; `formatNaira(num) -> String`.

- [ ] **Step 1: Write the failing tests**

```dart
test('email trims and accepts valid address', () {
  expect(Validators.email(' test@bank.com '), isNull); // Review Focus 1
});
test('email rejects empty and bad format', () {
  expect(Validators.email(''), 'Email is required');
  expect(Validators.email('bad'), 'Enter a valid email address');
});
test('password needs 8 characters', () {
  expect(Validators.password('Pass123'), 'Password must be at least 8 characters');
});
test('positiveNumber accepts commas', () {
  expect(Validators.positiveNumber('1,000,000', 'Amount'), isNull); // Review Focus 2
  expect(Validators.positiveNumber('0', 'Amount'), 'Amount must be a positive number');
});
test('formatNaira renders ₦850,000', () {
  expect(formatNaira(850000), '₦850,000');
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/utils/`
Expected: FAIL (`Validators` not defined)

- [ ] **Step 3: Implement the validators and formatter**

Signatures are in Produces above. Email regex and messages as in BUILD_GUIDE.md §6. Trim before matching. `formatNaira` uses `NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0)`.

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/utils/`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "feat(utils): add validators and naira formatter"
```

---

### Task 3: Models and local storage

**Files:**
- Create: `lib/models/savings_product.dart`, `lib/models/savings_plan.dart`, `lib/models/user_profile.dart`, `lib/services/local_storage_service.dart`
- Test: `test/services/local_storage_service_test.dart`

**Interfaces:**
- Consumes: nothing new.
- Produces: `SavingsPlan` (fields per BUILD_GUIDE.md §7, `fromJson`, `toJson`); `SavingsProduct`; `UserProfile.fromJson`; `LocalStorageService(SharedPreferences)` with `loggedInEmail`, `saveLoggedInEmail(String)`, `clearLoggedInUser()`, `loadPlans() -> List<SavingsPlan>`, `savePlans(List<SavingsPlan>)`.

- [ ] **Step 1: Write the failing tests**

```dart
test('plans round-trip through storage', () async {
  SharedPreferences.setMockInitialValues({});
  final storage = LocalStorageService(await SharedPreferences.getInstance());
  await storage.savePlans([plan]);
  expect(storage.loadPlans().single.name, plan.name);
});
test('corrupt stored plans return empty list', () async {
  SharedPreferences.setMockInitialValues({'savings_plans': 'not json'});
  final storage = LocalStorageService(await SharedPreferences.getInstance());
  expect(storage.loadPlans(), isEmpty); // Review Focus 4
});
test('logged-in email persists and clears', () async {
  SharedPreferences.setMockInitialValues({});
  final storage = LocalStorageService(await SharedPreferences.getInstance());
  await storage.saveLoggedInEmail('test@bank.com');
  expect(storage.loggedInEmail, 'test@bank.com');
  await storage.clearLoggedInUser();
  expect(storage.loggedInEmail, isNull);
});
```

`plan` is a `SavingsPlan` fixture with `createdAt: DateTime(2026, 1, 1)`.

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/services/local_storage_service_test.dart`
Expected: FAIL (`LocalStorageService` not defined)

- [ ] **Step 3: Implement models and storage**

Shapes and the try/catch in `loadPlans` are in BUILD_GUIDE.md §7 and §14. Use the storage keys `logged_in_email` and `savings_plans`.

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/services/local_storage_service_test.dart`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "feat(storage): add models and SharedPreferences persistence"
```

---

### Task 4: Auth service, repository, and provider

**Files:**
- Create: `lib/services/auth_service.dart`, `lib/repositories/auth_repository.dart`, `lib/providers/providers.dart`, `lib/providers/auth_provider.dart`
- Test: `test/providers/auth_provider_test.dart`

**Interfaces:**
- Consumes: `LocalStorageService`, `AppException`, `AppConstants` (Tasks 1, 3).
- Produces: `AuthService.login(String, String) -> Future<void>` (throws `AppException` on bad credentials); `AuthRepository(AuthService, LocalStorageService)` with `currentUserEmail`, `login`, `logout`; providers `sharedPreferencesProvider` (must be overridden in `main`), `localStorageProvider`, `authRepositoryProvider`, `authProvider` (`NotifierProvider<AuthNotifier, String?>`).

- [ ] **Step 1: Write the failing tests**

```dart
test('login with demo credentials stores the email', () async {
  // ProviderContainer with sharedPreferencesProvider overridden to a mock-backed instance
  await container.read(authProvider.notifier).login(' Test@Bank.com ', 'Password123');
  expect(container.read(authProvider), 'test@bank.com'); // Review Focus 1
});
test('wrong password throws AppException and state stays null', () async {
  expect(
    () => container.read(authProvider.notifier).login('test@bank.com', 'wrongpass'),
    throwsA(isA<AppException>()),
  );
  expect(container.read(authProvider), isNull);
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/providers/auth_provider_test.dart`
Expected: FAIL (`authProvider` not defined)

- [ ] **Step 3: Implement service, repository, providers**

`AuthService.login` uses an 800 ms delay so the loading state is visible, then compares trimmed lowercase email and exact password. Provider shapes are in BUILD_GUIDE.md §9–10. Use `Notifier`, not `StateNotifier`.

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/providers/auth_provider_test.dart`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "feat(auth): add mock auth service, repository and provider"
```

---

### Task 5: Savings repository and providers

**Files:**
- Create: `lib/repositories/savings_repository.dart`, `lib/providers/savings_provider.dart`
- Test: `test/repositories/savings_repository_test.dart`, `test/providers/savings_provider_test.dart`

**Interfaces:**
- Consumes: `LocalStorageService`, `SavingsPlan`, `SavingsProduct` (Task 3); `sharedPreferencesProvider`, `localStorageProvider` (Task 4).
- Produces: `SavingsRepository(LocalStorageService)` with static `products` (the four brief products, interest and duration as in BUILD_GUIDE.md §9), getter `seedPlansForDashboard` (three plans, the first being Emergency Fund ₦120,000 monthly), `getProducts()`, `getUserPlans()`, `createPlan(SavingsPlan)`; providers `savingsRepositoryProvider`, `productsProvider` (`FutureProvider<List<SavingsProduct>>`), `savingsPlansProvider` (`AsyncNotifierProvider<SavingsPlansNotifier, List<SavingsPlan>>`, `build` returns seeds + saved, `createPlan` persists then invalidates).

- [ ] **Step 1: Write the failing tests**

```dart
test('products match the brief', () {
  final names = SavingsRepository.products.map((p) => p.name);
  expect(names, ['Target Savings', 'Fixed Deposit', 'Education Savings', 'Vacation Savings']);
});
test('created plan is persisted and returned', () async {
  await repo.createPlan(plan);
  expect((await repo.getUserPlans()).single.name, plan.name);
});
test('dashboard shows three seed plans first', () async {
  final plans = await container.read(savingsPlansProvider.future);
  expect(plans.length, greaterThanOrEqualTo(3));
  expect(plans.first.name, 'Emergency Fund');
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/repositories/ test/providers/savings_provider_test.dart`
Expected: FAIL (`SavingsRepository` not defined)

- [ ] **Step 3: Implement repository and providers**

Seed data is in BUILD_GUIDE.md §9. Write the two extra seed plans yourself (brief gives only Emergency Fund). Use `ref.invalidateSelf()` after `createPlan`.

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/repositories/ test/providers/savings_provider_test.dart`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "feat(savings): add savings repository and providers"
```

---

### Task 6: Profile API service, repository, provider

**Files:**
- Create: `lib/services/user_api_service.dart`, `lib/repositories/profile_repository.dart`, `lib/providers/profile_provider.dart`
- Test: `test/services/user_api_service_test.dart`

**Interfaces:**
- Consumes: `UserProfile`, `AppException`, `AppConstants.userApiBase` (Tasks 1, 3).
- Produces: `UserApiService({http.Client?})` with `fetchUser(int id) -> Future<UserProfile>`, throws `AppException` for non-200, socket, timeout, and format errors; `ProfileRepository(UserApiService)` with `getProfile()`; `profileProvider` (`FutureProvider.autoDispose<UserProfile>`).

- [ ] **Step 1: Write the failing tests** (use `package:http/testing.dart` `MockClient`)

```dart
test('parses dummyjson user into UserProfile', () async {
  final api = UserApiService(client: MockClient((_) async => http.Response(
      '{"firstName":"Emily","lastName":"Johnson","email":"e@x.com","phone":"+1 555"}', 200)));
  final user = await api.fetchUser(1);
  expect(user.fullName, 'Emily Johnson');
});
test('non-200 throws AppException with status', () async {
  final api = UserApiService(client: MockClient((_) async => http.Response('', 500)));
  expect(api.fetchUser(1), throwsA(isA<AppException>()));
});
test('malformed body throws AppException', () async {
  final api = UserApiService(client: MockClient((_) async => http.Response('nope', 200)));
  expect(api.fetchUser(1), throwsA(isA<AppException>())); // Review Focus 5
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/services/user_api_service_test.dart`
Expected: FAIL (`UserApiService` not defined)

- [ ] **Step 3: Implement service, repository, provider**

Shapes and the exception mapping are in BUILD_GUIDE.md §8–10. Use a 10-second timeout. Add a test for a timeout using a `MockClient` that never completes, with the timeout shortened only in tests if needed (inject the duration as a constructor parameter).

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/services/user_api_service_test.dart`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "feat(profile): fetch user profile from public API"
```

---

### Task 7: Visual identity and shared widgets

**Files:**
- Create: `assets/brand/logo.svg`, `assets/fonts/` (OFL font files), `ASSETS.md`, `lib/widgets/loading_view.dart`, `lib/widgets/empty_view.dart`, `lib/widgets/error_view.dart`, `lib/widgets/app_text_field.dart`
- Modify: `pubspec.yaml` (asset and font declarations), `lib/core/theme/app_theme.dart` (use the chosen font via `google_fonts`, or the bundled files)
- Test: `test/widgets/error_view_test.dart`

**Interfaces:**
- Consumes: `AppTheme` (Task 1).
- Produces: `LoadingView()`, `EmptyView({required IconData icon, required String message})`, `ErrorView({required String message, required VoidCallback onRetry})`, `AppTextField` (wraps `TextFormField` with the theme's decoration); `ASSETS.md` listing every asset, its source, and its license.

This task is the only place the app's look is decided. Use only:
- **Logo:** an original SVG drawn for this project (a simple mark, e.g. a stacked-coins or sprout shape in the palette).
- **Palette:** an original seed colour in `AppTheme`, not sampled from any other app.
- **Font:** a Google Fonts family under the SIL Open Font License (e.g. Inter, Manrope, or DM Sans). Record the license in `ASSETS.md`.
- **Icons:** Material Symbols or built-in `Icons` (Apache 2.0 / Flutter SDK license).
- **Illustrations:** none, or original shapes. If any stock illustration is used, its license must allow commercial use and be listed in `ASSETS.md`.

Do not use any file extracted from the Koins app. That includes its logo, fonts, Lottie animations, images, and the `flutter_assets` folder.

- [ ] **Step 1: Write the failing test**

```dart
testWidgets('ErrorView shows message and retry calls back', (tester) async {
  var retried = false;
  await tester.pumpWidget(MaterialApp(home: Scaffold(
    body: ErrorView(message: 'No internet connection', onRetry: () => retried = true))));
  expect(find.text('No internet connection'), findsOneWidget);
  await tester.tap(find.text('Try again'));
  expect(retried, isTrue);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/error_view_test.dart`
Expected: FAIL (`ErrorView` not defined)

- [ ] **Step 3: Implement widgets, logo, font, palette, and ASSETS.md**

Widget bodies are in BUILD_GUIDE.md §11. Write `ASSETS.md` as a table: file, what it is, source (where you made it or the URL it came from), license. Every row must have a real source.

- [ ] **Step 4: Run tests and analyzer**

Run: `flutter test test/widgets/error_view_test.dart` then `flutter analyze`
Expected: PASS and `No issues found`.

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "feat(ui): add shared states, original logo and open-licensed fonts"
```

---

### Task 8: Login screen

**Files:**
- Create: `lib/screens/login/login_screen.dart`
- Test: `test/widgets/login_screen_test.dart`

**Interfaces:**
- Consumes: `authProvider`, `Validators`, `AppException`, `AppTextField` (Tasks 2, 4, 7).
- Produces: `LoginScreen` (`ConsumerStatefulWidget`); on success navigates to `/dashboard`; keys `Key('login-email')`, `Key('login-password')`, `Key('login-submit')` on the fields and button.

- [ ] **Step 1: Write the failing widget tests**

```dart
testWidgets('empty submit shows required errors', (tester) async {
  await pumpLogin(tester); // ProviderScope with sharedPreferencesProvider overridden
  await tester.tap(find.byKey(const Key('login-submit')));
  await tester.pump();
  expect(find.text('Email is required'), findsOneWidget);
  expect(find.text('Password is required'), findsOneWidget);
});
testWidgets('double tap submits once', (tester) async {
  // enter demo credentials, tap submit twice in one frame
  // expect authProvider login called once (verify via a counting override)
}); // Review Focus 3
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/widgets/login_screen_test.dart`
Expected: FAIL (`LoginScreen` not defined)

- [ ] **Step 3: Implement the screen**

Follow BUILD_GUIDE.md §12.1. Disable the button while `_loading` is true, which stops the double submit. Include the show/hide password toggle, `AutofillHints`, and `textInputAction` set to done on the password field.

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/widgets/login_screen_test.dart`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "feat(login): add login screen with validation"
```

---

### Task 9: Dashboard, products, and details

**Files:**
- Create: `lib/screens/dashboard/dashboard_screen.dart`, `lib/screens/products/products_screen.dart`, `lib/screens/products/product_details_screen.dart`, `lib/widgets/savings_product_card.dart`, `lib/widgets/savings_plan_tile.dart`
- Test: `test/widgets/dashboard_screen_test.dart`, `test/widgets/products_screen_test.dart`

**Interfaces:**
- Consumes: `savingsPlansProvider`, `productsProvider`, `formatNaira`, `AppConstants.totalSavings`, `LoadingView`, `ErrorView`, `EmptyView` (Tasks 2, 5, 7).
- Produces: `DashboardScreen` (greeting "Good Morning, John Doe", total ₦850,000, quick actions "Create Savings" and "View Products", three recent plans); `ProductsScreen` (four cards, each with name, interest rate, description, "View Details"); `ProductDetailsScreen(SavingsProduct product)`.

- [ ] **Step 1: Write the failing widget tests**

```dart
testWidgets('dashboard shows greeting and total', (tester) async {
  await pumpWithOverrides(tester, const DashboardScreen());
  expect(find.text('Good Morning, John Doe'), findsOneWidget);
  expect(find.text('₦850,000'), findsOneWidget);
});
testWidgets('products screen lists four products', (tester) async {
  await pumpWithOverrides(tester, const ProductsScreen());
  expect(find.text('View Details'), findsNWidgets(4));
});
testWidgets('details shows minimum deposit', (tester) async {
  await pumpWithOverrides(tester, const ProductDetailsScreen(product: targetSavings));
  expect(find.text('₦5,000'), findsOneWidget);
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/widgets/`
Expected: FAIL (screens not defined)

- [ ] **Step 3: Implement the three screens and two cards**

Layouts per BUILD_GUIDE.md §12.2–12.4. Use `.when(loading:, error:, data:)` on the providers, with `LoadingView`, `ErrorView` (retry calls `ref.invalidate`), and `EmptyView`. Add `RefreshIndicator` on the dashboard and products lists (bonus, cheap).

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/widgets/`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "feat(dashboard): add dashboard, products and product details"
```

---

### Task 10: Create savings, profile, routing

**Files:**
- Create: `lib/screens/savings/create_savings_screen.dart`, `lib/screens/profile/profile_screen.dart`
- Modify: `lib/main.dart` (auth gate, named routes `/login`, `/dashboard`, `/products`, `/profile`, `/create-savings`, error and `FlutterError.onError` hooks)
- Test: `test/widgets/create_savings_test.dart`, `test/widgets/profile_screen_test.dart`

**Interfaces:**
- Consumes: `savingsPlansProvider`, `productsProvider`, `profileProvider`, `authProvider`, `Validators`, `formatNaira`, `SavingsPlan` (Tasks 2–6, 8, 9).
- Produces: `CreateSavingsScreen({SavingsProduct? initialProduct})` (fields: name, product dropdown, target amount, monthly contribution, duration months; success snackbar "Savings Created Successfully" then `popUntil` `/dashboard`); `ProfileScreen` (name, email, phone, logout to `/login` clearing the stack).

- [ ] **Step 1: Write the failing tests**

```dart
testWidgets('create with empty fields shows errors', (tester) async {
  await pumpWithOverrides(tester, const CreateSavingsScreen());
  await tester.tap(find.text('Create'));
  await tester.pump();
  expect(find.text('Savings name is required'), findsOneWidget);
});
testWidgets('create accepts comma amounts and saves', (tester) async {
  // enter name, pick product, target '1,000,000', monthly '50,000', duration '12', tap Create
  // expect 'Savings Created Successfully' and the plan persisted
}); // Review Focus 2
testWidgets('logout returns to login and clears the session', (tester) async {
  await pumpApp(tester, loggedIn: true);
  await tester.tap(find.text('Logout'));
  await tester.pumpAndSettle();
  expect(find.text('Login'), findsWidgets);
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/widgets/create_savings_test.dart test/widgets/profile_screen_test.dart`
Expected: FAIL (screens not defined)

- [ ] **Step 3: Implement the screens and update `main.dart`**

Create flow per BUILD_GUIDE.md §12.5, with `int.parse(value.replaceAll(',', ''))` for amounts. Wrap the Create button in the same disable-while-busy guard as login. Profile per §12.6. `main.dart` per §13 and the error hooks in §14.

- [ ] **Step 4: Run tests and analyzer**

Run: `flutter test` then `flutter analyze`
Expected: all PASS, `No issues found`.

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "feat(savings): create savings, profile, logout and routing"
```

---

### Task 11: Bonus features, Review Focus gaps, and polish

**Files:**
- Modify: `lib/screens/products/products_screen.dart` (search and filter), `lib/providers/savings_provider.dart` (corrupt-data path if needed)
- Test: `test/providers/product_filter_test.dart`

**Interfaces:**
- Consumes: `productsProvider` (Task 5).
- Produces: `productQueryProvider` (`StateProvider<String>`), `flexibleOnlyProvider` (`StateProvider<bool>`), `filteredProductsProvider` (derived list).

- [ ] **Step 1: Write the failing test**

```dart
test('search matches product name case-insensitively', () {
  container.read(productQueryProvider.notifier).state = 'FIXED';
  expect(container.read(filteredProductsProvider).single.name, 'Fixed Deposit');
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/providers/product_filter_test.dart`
Expected: FAIL (`productQueryProvider` not defined)

- [ ] **Step 3: Implement search, the flexible filter, and the pull-to-refresh wiring**

Two bonuses total: search/filter (here) and pull to refresh (Task 9). Avoid adding more.

- [ ] **Step 4: Run tests and analyzer**

Run: `flutter test` then `flutter analyze`
Expected: all PASS, `No issues found`.

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "feat(products): add search and flexible filter"
```

---

### Task 12: Documentation, screenshots, APK

**Files:**
- Create: `README.md`, `docs/ARCHITECTURE.md`, `screenshots/*.png`
- Modify: `ASSETS.md` (confirm every asset row has a source and license)

**Interfaces:**
- Consumes: everything above.
- Produces: the deliverables listed in the brief.

- [ ] **Step 1: Verify the release build**

Run: `flutter build apk --release`
Expected: `build/app/outputs/flutter-apk/app-release.apk` exists.

- [ ] **Step 2: Capture screenshots** of login (with an error), dashboard, products, details, create (filled), created snackbar, profile, an error state (airplane mode), and a loading state. Save to `screenshots/`.

- [ ] **Step 3: Write README and ARCHITECTURE** from BUILD_GUIDE.md §18–19. Fill in the Flutter version from `flutter --version` and package versions from `pubspec.lock`. Include the demo credentials.

- [ ] **Step 4: Check the submission checklist** in BUILD_GUIDE.md §20 item by item. Note any unchecked item in the README.

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "docs: README, architecture, screenshots and release APK notes"
```

---

## Self-Review

- **Spec coverage:** Login (Task 8), dashboard (Task 9), products and details (Task 9), create savings (Task 10), profile and logout (Task 10), public API (Task 6), local storage (Task 3), Material 3 and responsive layout (Tasks 1, 7), loading/empty/error states (Tasks 7, 9), error handling (Tasks 3, 6, 10), bonuses (Tasks 9, 11), README and architecture (Task 12). The brief's "forgot password and register are non-functional" is in Task 8.
- **Review Focus coverage:** items 1 (Task 4), 2 (Tasks 2, 10), 3 (Task 8), 4 (Task 3), 5 (Task 6). Each has a test.
- **Type consistency:** `savingsPlansProvider`, `productsProvider`, `profileProvider`, `authProvider`, `LocalStorageService`, `SavingsRepository.seedPlansForDashboard`, and `ErrorView({message, onRetry})` are named identically in every task that uses them.
- **Assets:** No task uses files from the Koins app. Task 7 restricts assets to original or openly licensed sources and requires `ASSETS.md` to record each source and license.

---

**Plan complete and saved to `docs/superpowers/plans/2026-10-29-savings-app.md`. Please review the plan. Which execution approach would you prefer?**

- **Subagent-driven**: A fresh subagent implements each task and a fresh reviewer checks it before the next one starts, then a whole-branch review at the end. Most thorough, but costs a fresh context per task and per review.
- **Native**: I implement every task myself in this session, then one fresh reviewer checks the whole branch. Cheapest and fastest, with no independent review until the end.

For this plan I recommend **Native**, because the 12 tasks are small and mostly depend on the interfaces the plan names, and a mistake in this assessment is low-stakes and easy to fix before submission. Does the plan capture what you want, and which approach should we use?

