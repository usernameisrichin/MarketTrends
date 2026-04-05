// widget_test.dart — Basic Flutter test
//
// Flutter generates this file automatically.
// It's a smoke test — just checks the app can launch without crashing.
//
// Run with: flutter test

import 'package:flutter_test/flutter_test.dart';
import 'package:market_app/main.dart';

void main() {
  testWidgets('App smoke test — launches without crashing', (WidgetTester tester) async {
    // Build the app and trigger a frame
    await tester.pumpWidget(const MarketApp());

    // Verify that the dashboard title appears on screen
    expect(find.text('Market — Portfolio Dashboard'), findsOneWidget);
  });
}
