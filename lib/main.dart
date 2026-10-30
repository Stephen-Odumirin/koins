import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/navigation.dart';
import 'core/theme/app_theme.dart';
import 'models/savings_product.dart';
import 'providers/providers.dart';
import 'screens/auth/biometric_offer_screen.dart';
import 'screens/auth/lock_screen.dart';
import 'screens/auth/pin_setup_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/products/products_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/savings/create_savings_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'widgets/lock_gate.dart';
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
  // A failed migration keeps the old key, so plans are retried next launch.
  // The app still starts.
  try {
    await migratePlansFromPreferences(prefs, planDb);
  } catch (e) {
    debugPrint('Plan migration failed, will retry next launch: $e');
  }

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
      navigatorKey: appNavigatorKey,
      builder: (context, child) => LockGate(child: child!),
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      // The splash decides the first screen from stored state
      home: const SplashScreen(),
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/lock': (_) => const LockScreen(),
        '/pin-setup': (_) => const PinSetupScreen(),
        '/biometric-offer': (_) => const BiometricOfferScreen(),
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
