import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silog_app/data/data_contoh.dart';
import 'package:silog_app/main.dart';
import 'package:silog_app/tampilan/form_pengiriman_page.dart';

void main() {
  testWidgets('resi yang sudah terdaftar ditolak', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FormPengirimanPage()));

    await tester.enterText(
      find.byKey(const Key('nomor-resi-field')),
      'SLG-2026-0001',
    );
    await tester.pumpAndSettle();

    expect(find.text('Nomor resi sudah digunakan'), findsOneWidget);
  });

  testWidgets('berat barang divalidasi pada rentang 0,1 hingga 5000 kg', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: FormPengirimanPage()));
    final beratField = find.byKey(const Key('berat-barang-field'));

    await tester.ensureVisible(beratField);

    await tester.enterText(beratField, '0.1');
    await tester.pumpAndSettle();
    expect(
      find.text('Berat barang harus antara 0,1 dan 5000 kg'),
      findsNothing,
    );

    await tester.enterText(beratField, '0.09');
    await tester.pumpAndSettle();
    expect(
      find.text('Berat barang harus antara 0,1 dan 5000 kg'),
      findsOneWidget,
    );

    await tester.enterText(beratField, '5000');
    await tester.pumpAndSettle();
    expect(
      find.text('Berat barang harus antara 0,1 dan 5000 kg'),
      findsNothing,
    );

    await tester.enterText(beratField, '5000.1');
    await tester.pumpAndSettle();
    expect(
      find.text('Berat barang harus antara 0,1 dan 5000 kg'),
      findsOneWidget,
    );
  });

  testWidgets('pengiriman dihapus dari daftar setelah konfirmasi', (
    tester,
  ) async {
    final dataSemula = List.of(dataPengiriman);
    addTearDown(() {
      dataPengiriman
        ..clear()
        ..addAll(dataSemula);
    });

    await tester.pumpWidget(const SiLogApp());
    await tester.tap(find.text('SLG-2026-0001').first);
    await tester.pumpAndSettle();
    final hapusButton = find.text('Hapus Pengiriman');
    await tester.ensureVisible(hapusButton);
    await tester.tap(hapusButton);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
    await tester.pumpAndSettle();

    expect(find.text('SLG-2026-0001'), findsNothing);
  });
}
