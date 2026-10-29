import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'models/savings_product.dart';
import 'providers/auth_provider.dart';
import 'providers/providers.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/products/products_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/savings/create_savings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Unexpected framework errors: show them in debug, and hook crash
  // reporting in here for release builds.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) debugPrint('Unhandled Flutter error: ${details.exception}');
  };

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
      // Auth gate: a returning user skips login
      home: loggedIn ? const DashboardScreen() : const LoginScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/products': (_) => const ProductsScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/create-savings': (context) => CreateSavingsScreen(
              initialProduct: ModalRoute.of(context)?.settings.arguments
                  as SavingsProduct?,
            ),
      },
    );
  }
}
