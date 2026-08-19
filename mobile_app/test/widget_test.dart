import 'package:flutter_test/flutter_test.dart';

import 'package:trime_app/main.dart';

void main() {
  testWidgets('TRIME app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TrimeApp());
    expect(find.byType(TrimeApp), findsOneWidget);
  });
}
