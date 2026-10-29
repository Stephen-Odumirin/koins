import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/screens/dashboard/dashboard_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('dashboard shows greeting and total savings', (tester) async {
    await pumpWithOverrides(tester, const DashboardScreen());

    expect(find.text('Good Morning, John Doe'), findsOneWidget);
    expect(find.text('₦850,000'), findsOneWidget);
  });

  testWidgets('dashboard shows three recent plans', (tester) async {
    await pumpWithOverrides(tester, const DashboardScreen());

    expect(find.text('Emergency Fund'), findsOneWidget);
    expect(find.text('₦120,000'), findsOneWidget);
    expect(find.text('Create Savings'), findsOneWidget);
    expect(find.text('View Products'), findsOneWidget);
  });
}
