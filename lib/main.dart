import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'models/savings_product.dart';
import 'providers/providers.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/products/products_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/savings/create_savings_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/plan_database.dart';
import 'services/plan_migration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Unexpected framework errors: show them in debug, and hook crash
  // reporting in here for release builds.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) debugPrint('Unhandled Flutter error: ${details.exception}');
  };

  final prefs = await SharedPreferences.getInstance();
  final planDb = await PlanDatabase.open();
  // Not caught on purpose: the app should not start if plans could be lost.
  await migratePlansFromPreferences(prefs, planDb);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        planDatabaseProvider.overrideWithValue(planDb),
      ],
      child: const SavingsApp(),
    ),
  );
}

class SavingsApp extends StatelessWidget {
  const SavingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KoinsMFB',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      // The splash decides the first screen from stored state
      home: const SplashScreen(),
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
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
