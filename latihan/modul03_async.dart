import 'dart:async';

// -------------------------------------------------------------
// Exception kustom untuk resi yang tidak ditemukan
// -------------------------------------------------------------
class ResiTidakDitemukan implements Exception {
  final String resi;
  ResiTidakDitemukan(this.resi);

  @override
  String toString() => 'Resi $resi tidak ditemukan pada basis data.';
}

// -------------------------------------------------------------
// Basis data simulasi: Map berisi 5 data resi (Tugas Praktikum 1)
// -------------------------------------------------------------
final Map<String, String> basisDataKiriman = {
  'SLG-001': 'Paket sedang transit di hub logistik Bandung.',
  'SLG-002': 'Paket sedang dalam perjalanan menuju gudang transit Surabaya.',
  'SLG-003': 'Paket telah tiba di pusat sortir Jakarta Barat.',
  'SLG-004': 'Paket sedang dibawa oleh kurir menuju alamat penerima.',
  'SLG-005': 'Paket telah berhasil diterima oleh Budi (Ybs) di Semarang.',
};

// -------------------------------------------------------------
// Fungsi asinkron untuk mengambil status kiriman
// -------------------------------------------------------------
Future<String> ambilStatusKiriman(String resi) async {
  // Simulasi jeda jaringan selama 2 detik
  await Future.delayed(const Duration(seconds: 2));

  // Validasi format resi
  if (!resi.startsWith('SLG-')) {
    throw FormatException('Format resi tidak sah: $resi');
  }

  // Pencarian ke basis data
  final status = basisDataKiriman[resi];
  if (status == null) {
    throw ResiTidakDitemukan(resi);
  }

  return status;
}

// -------------------------------------------------------------
// Fungsi asinkron untuk mengambil ongkir
// -------------------------------------------------------------
Future<double> ambilOngkir(String resi) async {
  // Simulasi jeda jaringan selama 1 detik
  await Future.delayed(const Duration(seconds: 1));
  return 105400;
}

// -------------------------------------------------------------
// Latihan 3: Pengambilan Data Berurutan
// -------------------------------------------------------------
Future<void> latihan3Berurutan() async {
  print('--- [LATIHAN 3] Eksekusi Asinkron Berurutan (Sequential) ---');
  print('1. Permintaan data dikirim...');
  final stopwatch = Stopwatch()..start();

  try {
    final status = await ambilStatusKiriman('SLG-002');
    print('2. $status');
    final ongkir = await ambilOngkir('SLG-002');
    print('3. Ongkos kirim: Rp${ongkir.toStringAsFixed(0)}');
  } on FormatException catch (e) {
    print('Kesalahan format: ${e.message}');
  } on ResiTidakDitemukan catch (e) {
    print('Resi tidak ditemukan: $e');
  } catch (e) {
    print('Gagal mengambil data: $e');
  }

  stopwatch.stop();
  print('4. Proses selesai.');
  print('Total durasi berurutan: ${stopwatch.elapsedMilliseconds} ms (~3 detik)');
}

// -------------------------------------------------------------
// Latihan 3: Eksperimen Tanpa Keyword await
// -------------------------------------------------------------
Future<void> latihan3TanpaAwait() async {
  print('\n--- [LATIHAN 3 - EKSPERIMEN 1] Tanpa Keyword await ---');
  print('1. Permintaan data dikirim...');
  try {
    // Memanggil tanpa kata kunci await
    final status = ambilStatusKiriman('SLG-002');
    print('2. $status');
    final ongkir = await ambilOngkir('SLG-002');
    print('3. Ongkos kirim: Rp${ongkir.toStringAsFixed(0)}');
  } on FormatException catch (e) {
    print('Kesalahan format: ${e.message}');
  } on ResiTidakDitemukan catch (e) {
    print('Resi tidak ditemukan: $e');
  } catch (e) {
    print('Gagal mengambil data: $e');
  }
  print('4. Proses selesai.');
}

// -------------------------------------------------------------
// Latihan 3: Eksperimen Argumen Tidak Sah (XYZ-002)
// -------------------------------------------------------------
Future<void> latihan3ArgumenSalah() async {
  print('\n--- [LATIHAN 3 - EKSPERIMEN 2] Pengujian Argumen Format Tidak Sah (XYZ-002) ---');
  print('1. Permintaan data dikirim...');
  try {
    final status = await ambilStatusKiriman('XYZ-002');
    print('2. $status');
    final ongkir = await ambilOngkir('XYZ-002');
    print('3. Ongkos kirim: Rp${ongkir.toStringAsFixed(0)}');
  } on FormatException catch (e) {
    print('Kesalahan format: ${e.message}');
  } on ResiTidakDitemukan catch (e) {
    print('Resi tidak ditemukan: $e');
  } catch (e) {
    print('Gagal mengambil data: $e');
  }
  print('4. Proses selesai.');
}

// -------------------------------------------------------------
// Latihan 4: Eksekusi Paralel Menggunakan Future.wait
// -------------------------------------------------------------
Future<void> bandingkanWaktu() async {
  print('\n--- [LATIHAN 4] Eksekusi Paralel dengan Future.wait ---');
  final mulai = DateTime.now();

  final hasil = await Future.wait([
    ambilStatusKiriman('SLG-001'),
    ambilOngkir('SLG-001'),
  ]);

  final durasi = DateTime.now().difference(mulai);
  print('Status       : ${hasil[0]}');
  print('Ongkir       : Rp${(hasil[1] as double).toStringAsFixed(0)}');
  print('Durasi total : ${durasi.inMilliseconds} ms (~2 detik)');
  print('Analisis     : Operasi berjalan simultan, waktu ditentukan oleh tugas terlama.');
}

// -------------------------------------------------------------
// Tugas Praktikum: Memantau Banyak Resi Secara Bersamaan
// -------------------------------------------------------------
Future<void> pantauBanyakResi(List<String> daftarResi) async {
  print('Memulai pemantauan ${daftarResi.length} resi secara bersamaan...');
  final stopwatch = Stopwatch()..start();

  final List<String> daftarBerhasil = [];
  final List<String> daftarGagal = [];

  // Menjalankan seluruh permintaan secara bersamaan (paralel)
  // Menangkap error per-item agar tidak memutus eksekusi resi lainnya
  final futures = daftarResi.map((resi) async {
    try {
      final status = await ambilStatusKiriman(resi);
      return {'resi': resi, 'sukses': true, 'pesan': status};
    } on ResiTidakDitemukan catch (e) {
      return {'resi': resi, 'sukses': false, 'pesan': e.toString()};
    } on FormatException catch (e) {
      return {'resi': resi, 'sukses': false, 'pesan': 'Kesalahan format: ${e.message}'};
    } catch (e) {
      return {'resi': resi, 'sukses': false, 'pesan': 'Kesalahan sistem: $e'};
    }
  }).toList();

  final hasil = await Future.wait(futures);
  stopwatch.stop();

  print('\nHasil Pemantauan (Selesai dalam ${stopwatch.elapsedMilliseconds} ms):');
  for (final item in hasil) {
    final resi = item['resi'] as String;
    final sukses = item['sukses'] as bool;
    final pesan = item['pesan'] as String;

    if (sukses) {
      print('  [BERHASIL] $resi -> $pesan');
      daftarBerhasil.add(resi);
    } else {
      print('  [GAGAL]    $resi -> $pesan');
      daftarGagal.add(resi);
    }
  }

  print('Rekapitulasi:');
  print('  - Total resi diperiksa : ${daftarResi.length}');
  print('  - Berhasil dipantau    : ${daftarBerhasil.length}');
  print('  - Gagal dipantau       : ${daftarGagal.length}');
  if (daftarGagal.isNotEmpty) {
    print('  - Rincian resi gagal   : ${daftarGagal.join(', ')}');
  }
}

// -------------------------------------------------------------
// Program Utama (main)
// -------------------------------------------------------------
Future<void> main() async {
  print('===============================================================');
  print('             MODUL 03: PEMROGRAMAN ASINKRON & FUTURE           ');
  print('===============================================================\n');

  // Menjalankan Latihan 3 (Normal, Tanpa await, dan Argumen salah)
  await latihan3Berurutan();
  await latihan3TanpaAwait();
  await latihan3ArgumenSalah();

  // Menjalankan Latihan 4
  await bandingkanWaktu();

  print('\n===============================================================');
  print('             TUGAS PRAKTIKUM: PANTAU BANYAK RESI              ');
  print('===============================================================');

  // Skenario 1: Seluruh Resi Sah
  print('\n>>> SKENARIO 1: Seluruh Resi Sah Terdaftar <<<');
  final resiSah = ['SLG-001', 'SLG-002', 'SLG-003', 'SLG-004', 'SLG-005'];
  await pantauBanyakResi(resiSah);

  // Skenario 2: Terdapat Resi Tidak Sah / Tidak Terdaftar
  print('\n>>> SKENARIO 2: Terdapat Resi Tidak Sah / Tidak Terdaftar <<<');
  final resiCampuran = [
    'SLG-001', // Sah
    'SLG-999', // Tidak ditemukan di database
    'SLG-003', // Sah
    'XYZ-004', // Format tidak valid (bukan awalan SLG-)
    'SLG-005', // Sah
  ];
  await pantauBanyakResi(resiCampuran);

  print('===============================================================');
  print('Semua proses selesai.');
}
