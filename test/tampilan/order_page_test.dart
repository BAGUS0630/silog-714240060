import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:silog_app/data/order_api.dart';
import 'package:silog_app/data/order_repository.dart';
import 'package:silog_app/model/order.dart';
import 'package:silog_app/tampilan/daftar_pengiriman_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('tombol order membuka halaman dan mengirim order', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final requests = <http.Request>[];
    final repository = OrderRepository(
      api: OrderApi(
        client: MockClient((request) async {
          requests.add(request);
          if (request.method == 'GET') {
            return http.Response(
              '[{"userId":1,"id":1,"title":"Order contoh","body":"Rincian order"}]',
              200,
            );
          }
          return http.Response(
            '{"userId":7,"id":101,"title":"Order pengiriman Bandung - Surabaya",'
            '"body":"3 koli, berat total 42 kg, layanan reguler"}',
            201,
          );
        }),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: DaftarPengirimanPage(orderRepository: repository)),
    );
    await tester.tap(find.byTooltip('Order dari Layanan Web'));
    await tester.pumpAndSettle();

    expect(find.text('Order dari Layanan Web'), findsOneWidget);
    expect(find.text('Order contoh'), findsOneWidget);
    await tester.tap(find.text('Kirim Order'));
    await tester.pumpAndSettle();

    expect(find.text('Order terkirim dengan id 101'), findsOneWidget);
    expect(requests.map((request) => request.method), ['GET', 'POST']);
    expect(jsonDecode(requests.last.body)['userId'], 7);
  });

  test('data API yang pernah dimuat tetap tersedia saat offline', () async {
    SharedPreferences.setMockInitialValues({});
    var online = true;
    final repository = OrderRepository(
      api: OrderApi(
        client: MockClient((request) async {
          if (!online) throw http.ClientException('offline');
          return http.Response(
            '[{"userId":1,"id":1,"title":"Order tersimpan","body":"Cache"}]',
            200,
          );
        }),
      ),
    );

    await repository.ambilDaftar();
    online = false;
    final hasil = await repository.ambilDaftar();

    expect(hasil.offline, isTrue);
    expect(hasil.orders.single.judul, 'Order tersimpan');
    repository.tutup();
  });

  test('order offline disimpan dan tersinkron saat koneksi kembali', () async {
    SharedPreferences.setMockInitialValues({});
    var online = false;
    final repository = OrderRepository(
      api: OrderApi(
        client: MockClient((request) async {
          if (!online) throw http.ClientException('offline');
          if (request.method == 'POST') {
            return http.Response(
              '{"userId":7,"id":101,"title":"Order offline","body":"Tertunda"}',
              201,
            );
          }
          return http.Response('[]', 200);
        }),
      ),
    );
    final draft = Order(
      idPelanggan: 7,
      judul: 'Order offline',
      keterangan: 'Tertunda',
    );

    final terkirim = await repository.kirimOrder(draft);
    final hasilOffline = await repository.ambilDaftar();
    online = true;
    final hasilOnline = await repository.ambilDaftar();

    expect(terkirim.tertunda, isTrue);
    expect(hasilOffline.orders.single.menungguSinkronisasi, isTrue);
    expect(hasilOnline.jumlahTertunda, 0);
    expect(
      hasilOnline.orders.any(
        (order) =>
            order.judul == 'Order offline' && !order.menungguSinkronisasi,
      ),
      isTrue,
    );
    repository.tutup();
  });

  test('perbaruiOrder mengirim permintaan PUT dengan benar', () async {
    final requests = <http.Request>[];
    final api = OrderApi(
      client: MockClient((request) async {
        requests.add(request);
        if (request.method == 'PUT') {
          return http.Response(
            '{"userId":1,"id":1,"title":"Judul Diperbarui","body":"Keterangan Baru"}',
            200,
          );
        }
        return http.Response('Not Found', 404);
      }),
    );

    final hasil = await api.perbaruiOrder(
      Order(id: 1, idPelanggan: 1, judul: 'Judul Diperbarui', keterangan: 'Keterangan Baru'),
    );

    expect(requests.single.method, 'PUT');
    expect(requests.single.url.path, '/posts/1');
    expect(hasil.judul, 'Judul Diperbarui');
    api.tutup();
  });

  test('hapusOrder mengirim permintaan DELETE dengan benar', () async {
    final requests = <http.Request>[];
    final api = OrderApi(
      client: MockClient((request) async {
        requests.add(request);
        if (request.method == 'DELETE') {
          return http.Response('{}', 200);
        }
        return http.Response('Not Found', 404);
      }),
    );

    await api.hapusOrder(1);

    expect(requests.single.method, 'DELETE');
    expect(requests.single.url.path, '/posts/1');
    api.tutup();
  });

  testWidgets('pencarian memfilter daftar order berdasarkan judul', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repository = OrderRepository(
      api: OrderApi(
        client: MockClient((request) async {
          return http.Response(
            '[{"userId":1,"id":1,"title":"Kirim Elektronik","body":"TV 43 Inch"},'
            '{"userId":2,"id":2,"title":"Kirim Pakaian","body":"Baju Kaos"}]',
            200,
          );
        }),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: DaftarPengirimanPage(orderRepository: repository)),
    );
    await tester.tap(find.byTooltip('Order dari Layanan Web'));
    await tester.pumpAndSettle();

    expect(find.text('Kirim Elektronik'), findsOneWidget);
    expect(find.text('Kirim Pakaian'), findsOneWidget);

    // Filter berdasarkan kata kunci "Elektronik"
    await tester.enterText(find.byType(TextField), 'Elektronik');
    await tester.pumpAndSettle();

    expect(find.text('Kirim Elektronik'), findsOneWidget);
    expect(find.text('Kirim Pakaian'), findsNothing);
  });
}
