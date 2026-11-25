import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/order.dart';
import 'order_api.dart';

class HasilMuatOrder {
  final List<Order> orders;
  final bool offline;
  final String? pesanOffline;
  final int jumlahTertunda;

  const HasilMuatOrder({
    required this.orders,
    required this.offline,
    this.pesanOffline,
    required this.jumlahTertunda,
  });
}

class HasilKirimOrder {
  final Order order;
  final bool tertunda;

  const HasilKirimOrder({required this.order, required this.tertunda});
}

class OrderRepository {
  static const _kunciCache = 'order_cache_v1';
  static const _kunciTertunda = 'order_tertunda_v1';

  final OrderApi _api;

  OrderRepository({OrderApi? api}) : _api = api ?? OrderApi();

  Future<List<Order>> _baca(String kunci) async {
    final preferensi = await SharedPreferences.getInstance();
    final isi = preferensi.getString(kunci);
    if (isi == null) return [];
    final data = jsonDecode(isi) as List<dynamic>;
    return data
        .map((item) => Order.fromLocalJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _simpan(String kunci, List<Order> orders) async {
    final preferensi = await SharedPreferences.getInstance();
    await preferensi.setString(
      kunci,
      jsonEncode(orders.map((order) => order.toLocalJson()).toList()),
    );
  }

  List<Order> _gabungkan(List<Order> tersimpan, List<Order> terbaru) {
    final hasil = <String, Order>{};
    for (final order in [...tersimpan, ...terbaru]) {
      final kunci = order.id == null
          ? '${order.idPelanggan}:${order.judul}:${order.keterangan}'
          : '${order.id}';
      hasil[kunci] = order;
    }
    return hasil.values.toList();
  }

  Future<HasilMuatOrder> ambilDaftar({int limit = 10}) async {
    var cache = await _baca(_kunciCache);
    var tertunda = await _baca(_kunciTertunda);

    try {
      final terkirim = <Order>[];
      for (final order in tertunda) {
        try {
          final hasil = await _api.kirimOrder(order);
          terkirim.add(
            Order(
              id: hasil.id,
              idPelanggan: order.idPelanggan,
              judul: order.judul,
              keterangan: order.keterangan,
            ),
          );
        } on GagalApi catch (e) {
          if (e.kode != null) rethrow;
          break;
        }
      }

      if (terkirim.isNotEmpty) {
        cache = _gabungkan(cache, terkirim);
        tertunda = tertunda.skip(terkirim.length).toList();
        await _simpan(_kunciCache, cache);
        await _simpan(_kunciTertunda, tertunda);
      }

      final dariServer = await _api.ambilDaftar(limit: limit);
      cache = _gabungkan(cache, dariServer);
      await _simpan(_kunciCache, cache);
      return HasilMuatOrder(
        orders: _gabungkan(cache, tertunda),
        offline: false,
        jumlahTertunda: tertunda.length,
      );
    } on GagalApi catch (e) {
      return HasilMuatOrder(
        orders: _gabungkan(cache, tertunda),
        offline: true,
        pesanOffline: e.toString(),
        jumlahTertunda: tertunda.length,
      );
    }
  }

  Future<HasilKirimOrder> kirimOrder(Order order) async {
    try {
      final hasil = await _api.kirimOrder(order);
      final cache = await _baca(_kunciCache);
      final tersimpan = Order(
        id: hasil.id,
        idPelanggan: hasil.idPelanggan,
        judul: hasil.judul,
        keterangan: hasil.keterangan,
      );
      await _simpan(_kunciCache, _gabungkan(cache, [tersimpan]));
      return HasilKirimOrder(order: tersimpan, tertunda: false);
    } on GagalApi catch (e) {
      if (e.kode != null) rethrow;

      final tertunda = await _baca(_kunciTertunda);
      final lokal = Order(
        id: -DateTime.now().microsecondsSinceEpoch,
        idPelanggan: order.idPelanggan,
        judul: order.judul,
        keterangan: order.keterangan,
        menungguSinkronisasi: true,
      );
      await _simpan(_kunciTertunda, [...tertunda, lokal]);
      return HasilKirimOrder(order: lokal, tertunda: true);
    }
  }

  Future<Order> perbaruiOrder(Order order) async {
    final hasil = await _api.perbaruiOrder(order);
    var cache = await _baca(_kunciCache);
    final idx = cache.indexWhere((o) => o.id == order.id);
    if (idx != -1) {
      cache[idx] = hasil;
      await _simpan(_kunciCache, cache);
    }
    return hasil;
  }

  Future<void> hapusOrder(int id) async {
    await _api.hapusOrder(id);
    var cache = await _baca(_kunciCache);
    cache.removeWhere((o) => o.id == id);
    await _simpan(_kunciCache, cache);
  }

  void tutup() => _api.tutup();
}
