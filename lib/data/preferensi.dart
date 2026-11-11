import 'package:shared_preferences/shared_preferences.dart';

class Preferensi {
  static const String _kGudang = 'gudang_terakhir';
  static const String _kPetugas = 'nama_petugas';
  static const String _kModeGelap = 'mode_gelap';

  // --- Gudang Terakhir ---
  Future<void> simpanGudangTerakhir(String kodeGudang) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kGudang, kodeGudang);
  }

  Future<String> ambilGudangTerakhir() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kGudang) ?? 'GD-BDG';
  }

  // --- Nama Petugas ---
  Future<void> simpanPetugas(String nama) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kPetugas, nama);
  }

  Future<String?> ambilPetugas() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kPetugas);
  }

  // --- Mode Gelap ---
  Future<void> setModeGelap(bool aktif) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kModeGelap, aktif);
  }

  Future<bool> modeGelap() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kModeGelap) ?? false;
  }

  // --- Bersihkan Data ---
  Future<void> bersihkan() async {
    final sp = await SharedPreferences.getInstance();
    await sp.clear();
  }
}