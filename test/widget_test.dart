// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:silog_app/main.dart';

void main() {
  testWidgets('SiLogApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SiLogApp());

    // Verify that student info is displayed.
    expect(find.text('SiLog - Modul 1'), findsOneWidget);
    expect(find.text('Muhammad Bagus Tri Atmaja'), findsOneWidget);
  });
}
