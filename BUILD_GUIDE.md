# Savings App: Build Guide (Flutter Technical Assessment)

This guide walks you through building the savings app described in the assessment brief, from an empty folder to a submittable repo with APK, screenshots, README, and architecture write-up.

**Scope note:** Build everything yourself from this guide and the brief. Use only the public mock APIs the brief names (dummyjson.com here). Don't reuse any third-party or company endpoints, API keys, or code found elsewhere, including from decompiling other apps. The reviewers grade your own work.

---

## 0. What you're building

| Screen | Purpose | Data source |
|---|---|---|
| Login | Email/password with validation, mock auth | Hardcoded credentials |
| Dashboard | Greeting, total savings, quick actions, 3 recent plans | Mock + local plans |
| Savings Products | List of 4 products, search and filter (bonus) | Local seed data |
| Product Details | Details + "Create Savings" button | Local seed data |
| Create Savings | Form with dropdown, validation, success message | User input, saved locally |
| Profile | Name, email, phone from a public API, logout | `dummyjson.com/users/1` |

Persisted locally: the logged-in user and the created savings plans.

---

## 1. Environment

1. Install the **latest stable Flutter** from https://docs.flutter.dev/get-started/install.
2. Verify:
   ```bash
   flutter --version
   flutter doctor
   ```
   Fix anything marked with a red `✗` that's relevant to your target platform (Android toolchain at minimum).
3. Record the exact output of `flutter --version` now. You'll paste it into the README (Section 18).

---

## 2. Create the project

```bash
flutter create --org com.yourname --project-name koins_savings_app koins_savings_app
cd koins_savings_app
git init
git add .
git commit -m "chore: initial flutter project"
```

Commit early and often. The brief grades **Git usage**, so small, descriptive commits look good.

Suggested commit sequence:
1. `chore: initial flutter project`
2. `feat(core): add theme, validators and error types`
3. `feat(auth): mock login with validation`
4. `feat(storage): persist logged-in user and plans`
5. `feat(products): product list and details`
6. `feat(savings): create savings flow`
7. `feat(profile): fetch user from public API, logout`
8. `feat(ui): loading, empty and error states`
9. `test: unit and widget tests`
10. `docs: README and architecture`

---

## 3. Dependencies

```bash
flutter pub add flutter_riverpod shared_preferences http intl
flutter pub add --dev mocktail
```

| Package | Why |
|---|---|
| `flutter_riverpod` | State management and dependency injection (see Section 4) |
| `shared_preferences` | Persist logged-in user and savings plans (brief allows SharedPreferences, Hive, or SQLite) |
| `http` | Call the public mock API |
| `intl` | Format currency (₦) and numbers |
| `mocktail` (dev) | Mock repositories in unit tests |

`flutter_test` and `flutter_lints` come with the default project.

Your `pubspec.yaml` dependencies section should look like this after `pub add`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  http: ^1.2.2
  intl: ^0.19.0
  shared_preferences: ^2.3.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  mocktail: ^1.0.4
```

`pub add` will pick the newest compatible versions. Keep whatever it writes, then copy the final versions into your README.

---

## 4. Architecture

### 4.1 Folder structure (matches the brief)

```
lib/
├── core/
│   ├── theme/app_theme.dart          # Material 3 ThemeData
│   ├── errors/app_exception.dart     # One error type for the whole app
│   ├── constants/app_constants.dart  # Mock credentials, API base URL, seed data keys
│   └── network/no_internet.dart      # (optional) connectivity helper
├── models/
│   ├── savings_product.dart
│   ├── savings_plan.dart
│   └── user_profile.dart
├── services/
│   ├── auth_service.dart             # Mock login, no backend
│   ├── local_storage_service.dart    # SharedPreferences wrapper
│   └── user_api_service.dart         # HTTP calls to dummyjson
├── repositories/
│   ├── auth_repository.dart
│   ├── savings_repository.dart       # Products + plans, uses storage
│   └── profile_repository.dart       # Uses the API service
├── providers/
│   ├── providers.dart                # Global providers (SharedPreferences, services)
│   ├── auth_provider.dart
│   ├── savings_provider.dart
│   └── profile_provider.dart
├── screens/
│   ├── login/login_screen.dart
│   ├── dashboard/dashboard_screen.dart
│   ├── products/products_screen.dart
│   ├── products/product_details_screen.dart
│   ├── savings/create_savings_screen.dart
│   └── profile/profile_screen.dart
├── widgets/
│   ├── savings_product_card.dart
│   ├── savings_plan_tile.dart
│   ├── app_text_field.dart
│   ├── loading_view.dart
│   ├── empty_view.dart
│   └── error_view.dart
├── utils/
│   ├── validators.dart
│   └── formatters.dart
└── main.dart
```

Create the folders now:

```bash
cd lib
mkdir -p core/theme core/errors core/constants models services repositories providers screens/login screens/dashboard screens/products screens/savings screens/profile widgets utils
```

### 4.2 Layers and data flow

```
Screen (UI)  →  Provider (state)  →  Repository (what data)  →  Service (where data comes from)
                                                                     ├─ AuthService        (mock)
                                                                     ├─ LocalStorageService (SharedPreferences)
                                                                     └─ UserApiService     (HTTP)
```

Rules that keep it clean:
- **Screens** never call services or `http` directly. They read providers.
- **Providers** hold UI state and call repositories.
- **Repositories** decide where data comes from and convert failures into `AppException`.
- **Services** do one I/O job each and know nothing about UI.
- **Models** are plain Dart classes with `fromJson`/`toJson`, no Flutter imports.

### 4.3 Why Riverpod (for your architecture write-up)

Use this reasoning in your README's "Architecture" section:
- **Compile-time safe:** providers are typed and resolved at compile time (`ref.watch(x)`), so missing wiring fails early.
- **Testable:** you can override any provider in tests with `ProviderScope(overrides: [...])`, so no real network or disk is needed.
- **No `BuildContext` for logic:** business logic lives in providers, not widgets.
- **Scales without boilerplate:** `Notifier` gives a clear place for state transitions without the ceremony of Bloc.
- **Matches the brief:** it's on the list, and it's the option with the least boilerplate for an app of this size.

---

## 5. Theme (Material 3)

`lib/core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static const _seed = Color(0xFF1F3A93);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(height: 1.4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
```

Use `Theme.of(context).textTheme` everywhere instead of hardcoded font sizes. That's what the brief means by "consistent typography."

---

## 6. Core: errors, constants, validators, formatters

`lib/core/errors/app_exception.dart`:

```dart
class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}
```

`lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  static const mockEmail = 'test@bank.com';
  static const mockPassword = 'Password123';
  static const userApiBase = 'https://dummyjson.com';
  static const greetingName = 'John Doe';
  static const totalSavings = 850000;
}
```

`lib/utils/validators.dart`:

```dart
class Validators {
  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static String? requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? email(String? value) {
    final required = requiredField(value, 'Email');
    if (required != null) return required;
    if (!_emailRegex.hasMatch(value!.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? positiveNumber(String? value, String label) {
    final required = requiredField(value, label);
    if (required != null) return required;
    final parsed = num.tryParse(value!.replaceAll(',', ''));
    if (parsed == null || parsed <= 0) return '$label must be a positive number';
    return null;
  }
}
```

`lib/utils/formatters.dart`:

```dart
import 'package:intl/intl.dart';

final _naira = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0);

String formatNaira(num amount) => _naira.format(amount);
```

---

## 7. Models

`lib/models/savings_product.dart`:

```dart
class SavingsProduct {
  final String id;
  final String name;
  final double interestRate; // percent, e.g. 12
  final int? durationMonths;  // null means flexible
  final String description;
  final int minDeposit;

  const SavingsProduct({
    required this.id,
    required this.name,
    required this.interestRate,
    required this.durationMonths,
    required this.description,
    required this.minDeposit,
  });

  String get durationLabel =>
      durationMonths == null ? 'Flexible' : '$durationMonths Months';
}
```

`lib/models/savings_plan.dart`:

```dart
class SavingsPlan {
  final String id;
  final String name;
  final String productType;
  final int targetAmount;
  final int monthlyContribution;
  final int durationMonths;
  final DateTime createdAt;

  const SavingsPlan({
    required this.id,
    required this.name,
    required this.productType,
    required this.targetAmount,
    required this.monthlyContribution,
    required this.durationMonths,
    required this.createdAt,
  });

  factory SavingsPlan.fromJson(Map<String, dynamic> json) => SavingsPlan(
        id: json['id'] as String,
        name: json['name'] as String,
        productType: json['productType'] as String,
        targetAmount: json['targetAmount'] as int,
        monthlyContribution: json['monthlyContribution'] as int,
        durationMonths: json['durationMonths'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'productType': productType,
        'targetAmount': targetAmount,
        'monthlyContribution': monthlyContribution,
        'durationMonths': durationMonths,
        'createdAt': createdAt.toIso8601String(),
      };
}
```

`lib/models/user_profile.dart`:

```dart
class UserProfile {
  final String fullName;
  final String email;
  final String phone;

  const UserProfile({required this.fullName, required this.email, required this.phone});

  // dummyjson.com/users/1 returns firstName, lastName, email, phone
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        fullName: '${json['firstName']} ${json['lastName']}',
        email: json['email'] as String,
        phone: json['phone'] as String,
      );
}
```

---

## 8. Services

`lib/services/auth_service.dart`:

```dart
import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';

class AuthService {
  Future<void> login(String email, String password) async {
    // Simulate network latency so the loading state is visible
    await Future.delayed(const Duration(milliseconds: 800));

    final ok = email.trim().toLowerCase() == AppConstants.mockEmail &&
        password == AppConstants.mockPassword;
    if (!ok) throw const AppException('Invalid email or password');
  }
}
```

`lib/services/local_storage_service.dart`:

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/savings_plan.dart';

class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _userKey = 'logged_in_email';
  static const _plansKey = 'savings_plans';

  String? get loggedInEmail => _prefs.getString(_userKey);

  Future<void> saveLoggedInEmail(String email) => _prefs.setString(_userKey, email);

  Future<void> clearLoggedInUser() => _prefs.remove(_userKey);

  List<SavingsPlan> loadPlans() {
    final raw = _prefs.getString(_plansKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SavingsPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> savePlans(List<SavingsPlan> plans) {
    final encoded = jsonEncode(plans.map((p) => p.toJson()).toList());
    return _prefs.setString(_plansKey, encoded);
  }
}
```

`lib/services/user_api_service.dart`:

```dart
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/user_profile.dart';

class UserApiService {
  UserApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<UserProfile> fetchUser(int id) async {
    try {
      final res = await _client
          .get(Uri.parse('${AppConstants.userApiBase}/users/$id'))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        throw AppException('Server error (${res.statusCode})');
      }
      return UserProfile.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } on SocketException {
      throw const AppException('No internet connection');
    } on TimeoutException {
      throw const AppException('Request timed out. Please try again.');
    } on FormatException {
      throw const AppException('Unexpected response from server');
    }
  }
}
```

Note: `AppException` is thrown inside the `try`, so it isn't caught by the `on` clauses above. Those clauses only catch network and parsing errors, which is intentional.

---

## 9. Repositories

`lib/repositories/auth_repository.dart`:

```dart
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';

class AuthRepository {
  AuthRepository(this._auth, this._storage);

  final AuthService _auth;
  final LocalStorageService _storage;

  String? get currentUserEmail => _storage.loggedInEmail;

  Future<void> login(String email, String password) async {
    await _auth.login(email, password);
    await _storage.saveLoggedInEmail(email.trim().toLowerCase());
  }

  Future<void> logout() => _storage.clearLoggedInUser();
}
```

`lib/repositories/savings_repository.dart`:

```dart
import '../models/savings_plan.dart';
import '../models/savings_product.dart';
import '../services/local_storage_service.dart';

class SavingsRepository {
  SavingsRepository(this._storage);

  final LocalStorageService _storage;

  // Seed data from the brief. Local so the app works offline.
  static const products = [
    SavingsProduct(
      id: 'target',
      name: 'Target Savings',
      interestRate: 12,
      durationMonths: 12,
      description: 'Save towards a specific goal with fixed monthly contributions.',
      minDeposit: 5000,
    ),
    SavingsProduct(
      id: 'fixed',
      name: 'Fixed Deposit',
      interestRate: 18,
      durationMonths: 6,
      description: 'Lock funds for six months at a higher rate.',
      minDeposit: 50000,
    ),
    SavingsProduct(
      id: 'education',
      name: 'Education Savings',
      interestRate: 10,
      durationMonths: null,
      description: 'Build a fund for school fees, with withdrawals when you need them.',
      minDeposit: 5000,
    ),
    SavingsProduct(
      id: 'vacation',
      name: 'Vacation Savings',
      interestRate: 8,
      durationMonths: null,
      description: 'Plan your next trip with flexible withdrawals.',
      minDeposit: 2000,
    ),
  ];

  // Seed plans shown on the dashboard. Stored in memory only, not persisted.
  static final seedPlans = [
    SavingsPlan(
      id: 'seed-1',
      name: 'Emergency Fund',
      productType: 'Fixed Deposit',
      targetAmount: 120000,
      monthlyContribution: 10000,
      durationMonths: 12,
      createdAt: DateTime(2026, 1, 1),
    ),
    // Add two more seeds with different names and frequencies
  ];

  Future<List<SavingsProduct>> getProducts() async => products;

  List<SavingsPlan> get seedPlansForDashboard => seedPlans;

  Future<List<SavingsPlan>> getUserPlans() async => _storage.loadPlans();

  Future<void> createPlan(SavingsPlan plan) async {
    final current = _storage.loadPlans();
    await _storage.savePlans([...current, plan]);
  }
}
```

Write two more seed plans yourself so the dashboard shows three. Keep the first one exactly as in the brief (Emergency Fund, ₦120,000, Monthly).

`lib/repositories/profile_repository.dart`:

```dart
import '../models/user_profile.dart';
import '../services/user_api_service.dart';

class ProfileRepository {
  ProfileRepository(this._api);

  final UserApiService _api;

  Future<UserProfile> getProfile() => _api.fetchUser(1);
}
```

---

## 10. Providers

`lib/providers/providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/auth_repository.dart';
import '../repositories/profile_repository.dart';
import '../repositories/savings_repository.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/user_api_service.dart';

// Overridden in main.dart with the real instance
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in main()'),
);

final localStorageProvider = Provider(
  (ref) => LocalStorageService(ref.watch(sharedPreferencesProvider)),
);

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(AuthService(), ref.watch(localStorageProvider)),
);

final savingsRepositoryProvider = Provider(
  (ref) => SavingsRepository(ref.watch(localStorageProvider)),
);

final profileRepositoryProvider = Provider(
  (ref) => ProfileRepository(UserApiService()),
);
```

`lib/providers/auth_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/errors/app_exception.dart';
import 'providers.dart';

/// null = logged out, otherwise the logged-in email
class AuthNotifier extends Notifier<String?> {
  @override
  String? build() => ref.read(authRepositoryProvider).currentUserEmail;

  Future<void> login(String email, String password) async {
    await ref.read(authRepositoryProvider).login(email, password);
    state = email.trim().toLowerCase();
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, String?>(AuthNotifier.new);
```

Notes:
- `login` throws `AppException` on failure. The login screen catches it and shows the message.
- Use `ref.read` inside methods and `ref.watch` inside `build`.
- Riverpod 2 API: `Notifier` and `AsyncNotifier` are the replacements for the deprecated `StateNotifier`.

`lib/providers/savings_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/savings_plan.dart';
import '../models/savings_product.dart';
import 'providers.dart';

final productsProvider = FutureProvider<List<SavingsProduct>>((ref) {
  return ref.watch(savingsRepositoryProvider).getProducts();
});

class SavingsPlansNotifier extends AsyncNotifier<List<SavingsPlan>> {
  @override
  Future<List<SavingsPlan>> build() async {
    final seeds = ref.read(savingsRepositoryProvider).seedPlansForDashboard;
    final saved = await ref.read(savingsRepositoryProvider).getUserPlans();
    return [...seeds, ...saved];
  }

  Future<void> createPlan(SavingsPlan plan) async {
    await ref.read(savingsRepositoryProvider).createPlan(plan);
    ref.invalidateSelf(); // reload the list from storage
  }
}

final savingsPlansProvider =
    AsyncNotifierProvider<SavingsPlansNotifier, List<SavingsPlan>>(
  SavingsPlansNotifier.new,
);
```

`SavingsRepository` exposes the seed plans through the `seedPlansForDashboard` getter (added in Section 9), so the provider doesn't reach into the class's static fields.

`lib/providers/profile_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import 'providers.dart';

final profileProvider = FutureProvider.autoDispose<UserProfile>((ref) {
  return ref.watch(profileRepositoryProvider).getProfile();
});
```

`autoDispose` means the profile refetches each time the screen opens. Use `ref.invalidate(profileProvider)` for pull-to-refresh.

---

## 11. Shared widgets (loading, empty, error)

These three states are required by the brief. Build them once and reuse them.

`lib/widgets/loading_view.dart`:

```dart
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator());
}
```

`lib/widgets/empty_view.dart`:

```dart
import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(message, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
```

`lib/widgets/error_view.dart`:

```dart
import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 12. Screens

Build in this order. Each one depends only on the ones before it.

### 12.1 Login (`screens/login/login_screen.dart`)

Requirements from the brief: email, password, login button, forgot password and register (both non-functional), validation, navigate to dashboard on success.

Key implementation:

```dart
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).login(_email.text, _password.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // build(): Form with TextFormFields using Validators.email and Validators.password,
  // a FilledButton calling _submit (disabled while _loading), a CircularProgressIndicator
  // inside the button while loading, and two TextButtons for Forgot password / Register
  // that show a SnackBar "Coming soon" (non-functional but visible).
}
```

Things reviewers check on this screen:
- Validation messages appear under each field, not just in a snackbar.
- The password field has a show/hide toggle (`_obscure`).
- Submit works with the keyboard's "done" action (`textInputAction` and `onFieldSubmitted`).
- Use `AutofillHints` for email and password.

Add `ConsumerStatefulWidget` imports from `flutter_riverpod`, and `AppException` from `core/errors`.

### 12.2 Dashboard (`screens/dashboard/dashboard_screen.dart`)

Layout, top to bottom:
1. Greeting card: "Good Morning, John Doe" (use the time of day for the greeting, but the brief shows Good Morning, so you can hardcode it if you want to match the spec exactly; state your choice in the README).
2. Total savings card: `formatNaira(AppConstants.totalSavings)`, which shows ₦850,000.
3. Quick actions row: two `FilledButton.tonalIcon` buttons, "Create Savings" (goes to create screen) and "View Products" (goes to products).
4. "Recent Savings" section: `ref.watch(savingsPlansProvider)`, with `.when(loading:, error:, data:)`. Show the first three items as tiles with name, amount, and frequency.
5. Profile icon in the app bar, going to Profile.

Use `ref.watch(savingsPlansProvider).when(...)` for loading, error (`ErrorView`), and empty (`EmptyView`) states.

### 12.3 Savings Products (`screens/products/products_screen.dart`)

- `ref.watch(productsProvider).when(...)` for the list.
- Each card (`widgets/savings_product_card.dart`) shows name, interest rate as a chip, duration, short description, and a "View Details" button that pushes the details screen with the product as an argument.
- Bonus: a search field (`TextField` with `onChanged` setting a `StateProvider<String>`) and a filter chip for "Flexible" vs "Fixed term" both reuse the same list.

### 12.4 Product Details (`screens/products/product_details_screen.dart`)

- Takes a `SavingsProduct` in the constructor.
- Shows plan name, interest rate, minimum deposit (`formatNaira(product.minDeposit)`), and duration (`product.durationLabel`).
- "Create Savings" button pushes the create screen, passing the product so the dropdown defaults to it.

### 12.5 Create Savings (`screens/savings/create_savings_screen.dart`)

Fields: savings name (text), product type (`DropdownButtonFormField<SavingsProduct>` built from `productsProvider`), target amount, monthly contribution, duration (months).

Validation: all fields required, amounts must be positive (`Validators.positiveNumber`). Use `AutovalidateMode.onUserInteraction` once the user has tapped submit once.

On submit:
```dart
final plan = SavingsPlan(
  id: DateTime.now().microsecondsSinceEpoch.toString(),
  name: _name.text.trim(),
  productType: _product!.name,
  targetAmount: int.parse(_target.text.replaceAll(',', '')),
  monthlyContribution: int.parse(_monthly.text.replaceAll(',', '')),
  durationMonths: int.parse(_duration.text),
  createdAt: DateTime.now(),
);
await ref.read(savingsPlansProvider.notifier).createPlan(plan);
if (!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Savings Created Successfully')),
);
Navigator.of(context).popUntil((route) => route.settings.name == '/dashboard');
```

Note: `popUntil` only works if the dashboard route is named `/dashboard`. Set that in `main.dart` (Section 13).

### 12.6 Profile (`screens/profile/profile_screen.dart`)

- `ref.watch(profileProvider).when(...)` shows full name, email, phone with icons.
- Loading shows `LoadingView`. Error shows `ErrorView` with `onRetry: () => ref.invalidate(profileProvider)`.
- Logout button: `await ref.read(authProvider.notifier).logout();` then `Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);`.

---

## 13. main.dart and routing

`lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/providers.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/login/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const SavingsApp(),
    ),
  );
}

class SavingsApp extends ConsumerWidget {
  const SavingsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedIn = ref.watch(authProvider) != null;

    return MaterialApp(
      title: 'Savings',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      // Auth gate: decides the first screen from the persisted user
      home: loggedIn ? const DashboardScreen() : const LoginScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        // add /products, /profile, /create-savings here
      },
    );
  }
}
```

Use `home:` for the auth gate so a returning user skips login. Named routes make `popUntil` and `pushNamedAndRemoveUntil` work.

---

## 14. Error handling checklist

Map each case from the brief to where you handle it:

| Case | Where | What the user sees |
|---|---|---|
| Empty login fields | `Validators` in `LoginScreen` | Inline field error |
| Invalid email format | `Validators.email` | Inline error |
| Password under 8 characters | `Validators.password` | Inline error |
| Wrong credentials | `AuthService` throws `AppException` | Snackbar with message |
| Empty create-savings fields | `Validators.requiredField` | Inline error |
| Non-numeric or zero amount | `Validators.positiveNumber` | Inline error |
| API failure (HTTP 5xx) | `UserApiService` | `ErrorView` with retry |
| No internet | `SocketException` → `AppException` | `ErrorView` with retry |
| Timeout | `TimeoutException` → `AppException` | `ErrorView` with retry |
| Corrupt stored data | Wrap `loadPlans` decode in try/catch, return `[]` and log | Empty state, app keeps working |
| Unexpected exception | Top-level `FlutterError.onError` in `main` and `catch (_)` in screens | Generic snackbar, no crash |

Add to `main()` before `runApp`:

```dart
FlutterError.onError = (details) {
  FlutterError.presentError(details);
  // Log to your analytics or crash tool here
};
```

For corrupt storage, wrap the decode:

```dart
List<SavingsPlan> loadPlans() {
  final raw = _prefs.getString(_plansKey);
  if (raw == null) return [];
  try {
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => SavingsPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return []; // corrupt data: start fresh rather than crash
  }
}
```

---

## 15. Bonus features (pick two, then do them well)

The brief asks you to implement "any of" the bonuses. Quality beats quantity. Good picks for this app:

1. **Pull to refresh** (easy): wrap the dashboard and products lists in `RefreshIndicator`, calling `ref.invalidate(savingsPlansProvider)` or `ref.invalidate(productsProvider)`.
2. **Search and filter products** (medium): `StateProvider<String>` for the query and `StateProvider<bool?>` for the flexible filter, with a derived `Provider` combining both.
3. **Unit tests** (medium): covered in Section 16.
4. **Animations** (easy-medium): `AnimatedSwitcher` on the total savings card, or a `Hero` from product card to details.

Avoid biometrics and PIN login for a first build. They need platform setup and device testing, and the time is better spent on tests and polish.

---

## 16. Tests

Create:
- `test/utils/validators_test.dart`: unit test each validator with empty, invalid, and valid inputs.
- `test/repositories/savings_repository_test.dart`: use `SharedPreferences.setMockInitialValues({})`, then verify `createPlan` persists and `getUserPlans` returns it.
- `test/widgets/login_screen_test.dart`: pump the login screen inside a `ProviderScope` with `sharedPreferencesProvider` overridden, enter an invalid email, tap login, and expect "Enter a valid email address".

Example validator test:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:koins_savings_app/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty', () {
      expect(Validators.email(''), 'Email is required');
    });
    test('rejects bad format', () {
      expect(Validators.email('not-an-email'), 'Enter a valid email address');
    });
    test('accepts valid email', () {
      expect(Validators.email('test@bank.com'), isNull);
    });
  });
}
```

Replace `koins_savings_app` with your project name from Section 2.

Run:
```bash
flutter test
```

Paste the pass count into your README.

---

## 17. Build, run, and capture deliverables

```bash
flutter analyze          # must be clean
flutter test             # must pass
flutter run              # on an emulator or device
flutter build apk --release
```

The APK lands at `build/app/outputs/flutter-apk/app-release.apk`.

Screenshots: capture at least these, and put them in a `screenshots/` folder:
1. Login with a validation error showing
2. Dashboard
3. Products list
4. Product details
5. Create savings (filled in)
6. Savings created snackbar
7. Profile
8. An error state (turn off Wi-Fi, open profile)
9. A loading state

On an emulator: `adb exec-out screencap -p > screenshots/01-login.png`, or use the device's screenshot key.

---

## 18. README template

Create `README.md` at the repo root. Fill in every section.

````markdown
# Koins Savings App

A simple savings application built with Flutter. Users log in, browse savings products, create savings plans, and view their dashboard and profile.

## Setup

```bash
git clone <your-repo-url>
cd koins_savings_app
flutter pub get
flutter run
```

**Demo credentials:** `test@bank.com` / `Password123`

## Flutter version

- Flutter: `<paste output of flutter --version>`
- Dart: `<from the same output>`
- Target: Android (APK provided in `/build` or release page)

## Architecture

Layered architecture: screens → providers → repositories → services. See `docs/ARCHITECTURE.md`.

State management: Riverpod (`flutter_riverpod`). Chosen for compile-time safety, easy test overrides, and no `BuildContext` in business logic.

## Packages used

| Package | Version | Purpose |
|---|---|---|
| flutter_riverpod | `<from pubspec.lock>` | State management and DI |
| shared_preferences | `<from pubspec.lock>` | Persist logged-in user and plans |
| http | `<from pubspec.lock>` | Public mock API |
| intl | `<from pubspec.lock>` | Currency formatting |
| mocktail (dev) | `<from pubspec.lock>` | Test mocks |

## Features

- Login with validation (mock auth)
- Dashboard with total savings and recent plans
- Savings products list and details
- Create savings with validation
- Profile fetched from a public API, with logout
- Loading, empty, and error states
- `<list your bonus features>`

## Assumptions

- Authentication is mocked. Credentials are hardcoded and no token is issued.
- Total savings is a fixed ₦850,000 per the brief. Created plans do not change it.
- Created plans are stored locally and start with no deposits.
- The profile screen uses `dummyjson.com/users/1` as the logged-in user's data.
- Products are local seed data because the brief lists them, not an API.
- Greeting is hardcoded "Good Morning, John Doe" per the brief.
- Forgot password and register are visible but show a "Coming soon" message.

## Testing

```bash
flutter test
```

Result: `<X> tests passed`.

## Improvements if given more time

- Replace mock auth with a real backend and secure token storage (flutter_secure_storage).
- Persist products and plans in SQLite or Hive for querying and larger data.
- Add offline detection with connectivity_plus and a global offline banner.
- Add biometric login and PIN login.
- Add integration tests on a device farm.
- Localize strings and add accessibility labels audit.
- Add CI (GitHub Actions) running analyze, test, and build.

## Screenshots

See `screenshots/`.
````

---

## 19. Architecture write-up (`docs/ARCHITECTURE.md`)

Keep it to one or two pages. Cover:

1. **Layers** with a diagram (copy the flow from Section 4.2).
2. **State management choice** and why (Section 4.3).
3. **Data flow example:** walk through login from button press to dashboard navigation, naming each file it passes through.
4. **Local storage:** what is stored, under which keys, and what happens on corrupt data.
5. **Error handling strategy:** `AppException` as the one error type, with mapping at the repository/service boundary.
6. **Testing strategy:** what's unit tested, what's widget tested, and how providers are overridden.
7. **Trade-offs:** mock auth, local seed data, fixed total balance.

---

## 20. Submission checklist

- [ ] Repo on GitHub, public or shared with the reviewers
- [ ] Commit history is incremental and readable
- [ ] `flutter analyze` clean
- [ ] `flutter test` passes
- [ ] `flutter build apk --release` produces an APK, attached or linked
- [ ] README has: setup, Flutter version, packages with versions, assumptions, improvements
- [ ] `docs/ARCHITECTURE.md` explains the layers and state management choice
- [ ] Screenshots in `screenshots/` covering every screen and the error/loading states
- [ ] Demo credentials in the README
- [ ] No API keys or secrets in the repo
- [ ] Dark mode and phone-width layouts checked (the brief asks for responsive)
- [ ] Used only the public mock APIs in the brief

---

## Time budget (6–8 hours)

| Block | Time |
|---|---|
| Setup, theme, folder structure, models | 1 h |
| Auth, storage, login screen | 1.5 h |
| Dashboard, products, details | 1.5 h |
| Create savings, validation, persistence | 1 h |
| Profile, API integration, logout | 1 h |
| Loading/empty/error polish, one or two bonuses | 1 h |
| Tests | 45 min |
| APK, screenshots, README, architecture doc | 1 h |
