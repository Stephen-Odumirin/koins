import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/repositories/savings_repository.dart';
import 'package:savings_app/screens/products/product_details_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('details shows the Target Savings figures', (tester) async {
    await pumpWithOverrides(
      tester,
      ProductDetailsScreen(product: SavingsRepository.products.first),
    );

    expect(find.text('Target Savings'), findsOneWidget);
    expect(find.text('12%'), findsOneWidget);
    expect(find.text('₦5,000'), findsOneWidget);
    expect(find.text('12 Months'), findsOneWidget);
    expect(find.text('Create Savings'), findsOneWidget);
  });
}
