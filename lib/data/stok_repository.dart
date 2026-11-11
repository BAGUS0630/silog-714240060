import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../model/stok.dart';

class StokRepository {
  static final StokRepository instance = StokRepository._();
  StokRepository._();

  Database? _db;
  final _store = intMapStoreFactory.store('stok');

  // --- Inisialisasi Database ---
  Future<Database> get _database async {
    if (_db != null) return _db!;

    if (kIsWeb) {
      _db = await databaseFactoryWeb.openDatabase('silog.db');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      _db = await databaseFactoryIo.openDatabase('${dir.path}/silog.db');
    }
    return _db!;
  }

  /// CREATE - Menyimpan data stok baru
  Future<int> simpan(Stok stok) async {
    final db = await _database;
    return _store.add(db, stok.toMap());
  }

  /// READ - Mencari data stok berdasarkan nama barang menggunakan Filter.matchesRegExp
  Future<List<Stok>> cariNamaBarang(String kataKunci, {String? kodeGudang}) async {
    final db = await _database;
    final pola = RegExp(kataKunci, caseSensitive: false);
    final filterNama = Filter.matchesRegExp('namaBarang', pola);

    final finder = Finder(
      filter: kodeGudang != null
          ? Filter.and([Filter.equals('kodeGudang', kodeGudang), filterNama])
          : filterNama,
      sortOrders: [SortOrder('namaBarang')],
    );
    final rekaman = await _store.find(db, finder: finder);
    return rekaman.map((r) => Stok.fromMap(r.key, r.value)).toList();
  }

  /// READ - Mengambil seluruh data, diurutkan berdasarkan nama barang
  Future<List<Stok>> ambilSemua({String? kodeGudang, String? kataKunci}) async {
    if (kataKunci != null && kataKunci.trim().isNotEmpty) {
      return cariNamaBarang(kataKunci.trim(), kodeGudang: kodeGudang);
    }
    final db = await _database;
    final finder = Finder(
      filter: kodeGudang == null
          ? null
          : Filter.equals('kodeGudang', kodeGudang),
      sortOrders: [SortOrder('namaBarang')],
    );
    final rekaman = await _store.find(db, finder: finder);
    return rekaman.map((r) => Stok.fromMap(r.key, r.value)).toList();
  }

  /// READ - Mengambil satu data berdasarkan ID
  Future<Stok?> ambilSatu(int id) async {
    final db = await _database;
    final nilai = await _store.record(id).get(db);
    return nilai == null ? null : Stok.fromMap(id, nilai);
  }

  /// UPDATE - Memperbarui data stok yang sudah ada
  Future<void> perbarui(Stok stok) async {
    if (stok.id == null) {
      throw ArgumentError('Data tanpa id tidak dapat diperbarui');
    }
    final db = await _database;
    await _store.record(stok.id!).update(db, stok.toMap());
  }

  /// DELETE - Menghapus data berdasarkan ID
  Future<void> hapus(int id) async {
    final db = await _database;
    await _store.record(id).delete(db);
  }

  /// Menghitung total jumlah stok berdasarkan kode gudang tertentu
  Future<int> totalStokGudang(String kodeGudang) async {
    final daftar = await ambilSemua(kodeGudang: kodeGudang);
    return daftar.fold<int>(0, (a, s) => a + s.jumlah);
  }

  /// Mengosongkan seluruh isi data pada store stok
  Future<void> kosongkan() async {
    final db = await _database;
    await _store.delete(db);
  }
}