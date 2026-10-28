// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:silog_app/main.dart';

void main() {
  testWidgets('SiLogApp menampilkan daftar, tab, dan ringkasan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SiLogApp());

    expect(find.text('Daftar Pengiriman'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Dalam Perjalanan'), findsWidgets);
    expect(find.text('Diterima'), findsWidgets);
    expect(find.text('Jumlah pengiriman'), findsOneWidget);
    expect(find.text('Total nilai barang'), findsOneWidget);
    expect(find.text('Rp24.325.000'), findsOneWidget);
    expect(find.text('SLG-2026-0001'), findsOneWidget);
    expect(find.text('Sepatu Lari Pria x 10'), findsOneWidget);

    await tester.tap(find.widgetWithText(Tab, 'Diterima'));
    await tester.pumpAndSettle();

    expect(find.text('SLG-2026-0003'), findsWidgets);
    expect(find.text('SLG-2026-0001'), findsNothing);
    expect(find.text('SLG-2026-0002'), findsNothing);
    expect(find.text('Rp9.625.000'), findsOneWidget);
  });
}
