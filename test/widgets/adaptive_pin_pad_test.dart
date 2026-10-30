import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savings_app/widgets/pin/adaptive_pin_pad.dart';
import 'package:savings_app/widgets/pin/pin_dots.dart';

Future<void> tapDigits(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.byKey(Key('pin-key-$d')));
    await tester.pump(const Duration(milliseconds: 120));
  }
}

Widget host(Widget child, {double scale = 1}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
    child: Scaffold(
      body: SingleChildScrollView(child: Center(child: child)),
    ),
  ),
);

int filledDots(WidgetTester tester) =>
    tester.widget<PinDots>(find.byType(PinDots)).filled;

void main() {
  testWidgets('completes once with the entered digits', (tester) async {
    final done = <String>[];
    await tester.pumpWidget(
      host(AdaptivePinPad(length: 4, onCompleted: done.add)),
    );
    await tapDigits(tester, '1357');
    expect(done, ['1357']);
  });

  testWidgets('does not complete before the length is reached', (tester) async {
    final done = <String>[];
    await tester.pumpWidget(
      host(AdaptivePinPad(length: 4, onCompleted: done.add)),
    );
    await tapDigits(tester, '135');
    expect(done, isEmpty);
    expect(filledDots(tester), 3);
  });

  testWidgets('backspace removes the last digit', (tester) async {
    final done = <String>[];
    await tester.pumpWidget(
      host(AdaptivePinPad(length: 4, onCompleted: done.add)),
    );
    await tapDigits(tester, '12');
    await tester.tap(find.byKey(const Key('pin-backspace')));
    await tester.pump(const Duration(milliseconds: 120));
    expect(filledDots(tester), 1);
    await tapDigits(tester, '999');
    expect(done, ['1999']);
  });

  testWidgets('clear() empties the entry', (tester) async {
    final key = GlobalKey<AdaptivePinPadState>();
    await tester.pumpWidget(
      host(AdaptivePinPad(key: key, length: 4, onCompleted: (_) {})),
    );
    await tapDigits(tester, '12');
    key.currentState!.clear();
    await tester.pump();
    expect(filledDots(tester), 0);
  });

  for (final size in const [Size(360, 640), Size(412, 915)]) {
    testWidgets('no overflow at $size with text scale 1.5', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        host(AdaptivePinPad(length: 4, onCompleted: (_) {}), scale: 1.5),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      for (var d = 0; d <= 9; d++) {
        final box = tester.getSize(find.byKey(Key('pin-key-$d')));
        expect(box.width, greaterThanOrEqualTo(56));
        expect(box.height, greaterThanOrEqualTo(56));
      }
    });
  }
}
