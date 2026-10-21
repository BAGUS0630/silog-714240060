import 'package:silog_app/layanan/layanan_pengiriman.dart';
import 'package:silog_app/layanan/moda.dart';

void main() {
  final List<LayananPengiriman> daftarLayanan = [
    PengirimanTruk(kodeLayanan: 'TRK-REG', jarakKm: 780, beratKg: 1200),
    PengirimanTruk(
      kodeLayanan: 'TRK-EXP',
      jarakKm: 780,
      beratKg: 1200,
      ekspres: true,
    ),
    PengirimanKeretaApi(
      kodeLayanan: 'KA-CARGO',
      jarakKm: 780,
      beratKg: 1200,
      stasiunAsal: 'Kiaracondong',
      stasiunTujuan: 'Pasar Turi',
    ),
    PengirimanKapal(
      kodeLayanan: 'KPL-PETI',
      jarakKm: 1450,
      beratKg: 1200,
      volumeM3: 8.5,
    ),
    PengirimanUdara(
      kodeLayanan: 'UDR-CGK',
      jarakKm: 780,
      beratKg: 1200,
      bandara: 'Soekarno-Hatta',
      panjangCm: 120,
      lebarCm: 100,
      tinggiCm: 80,
    ),
  ];

  print('=== Perbandingan Layanan Pengiriman ===');
  for (final layanan in daftarLayanan) {
    print(layanan.ringkasan());
  }

  daftarLayanan.sort((a, b) => a.hitungTarif().compareTo(b.hitungTarif()));
  print('\nLayanan termurah : ${daftarLayanan.first.kodeLayanan}');
  print(
    'Layanan tercepat : '
    '${daftarLayanan.reduce((a, b) => a.estimasiHari() <= b.estimasiHari() ? a : b).kodeLayanan}',
  );

  // Pemanfaatan mixin Terlacak
  final truk = daftarLayanan.whereType<PengirimanTruk>().first;
  truk.catatPosisi('Gudang Utama Bandung');
  truk.catatPosisi('Rest Area KM 207');
  truk.catatPosisi('Gudang Transit Semarang');

  print('\nRiwayat posisi ${truk.kodeLayanan}:');
  for (final r in truk.riwayat) {
    print('  $r');
  }
  print('Posisi terakhir: ${truk.posisiTerakhir()}');

  // === Tugas Praktikum: Demonstrasi mixin Terasuransi ===
  print('\n=== Demonstrasi Mixin Terasuransi ===');

  const nilaiBarang = 50000000.0; // Rp50.000.000

  // PengirimanKapal mengadopsi mixin Terasuransi
  final kapal = daftarLayanan.whereType<PengirimanKapal>().first;
  print('${kapal.kodeLayanan} (PengirimanKapal) menerapkan Terasuransi:');
  print('  Persentase Premi: ${kapal.persentasePremi}%');
  print(
    '  Hitung Premi: Rp${kapal.hitungPremi(nilaiBarang).toStringAsFixed(0)}',
  );
  print('  ${kapal.infoAsuransi(nilaiBarang)}');

  // PengirimanUdara mengadopsi mixin Terasuransi
  final udara = daftarLayanan.whereType<PengirimanUdara>().first;
  print('\n${udara.kodeLayanan} (PengirimanUdara) menerapkan Terasuransi:');
  print('  Persentase Premi: ${udara.persentasePremi}%');
  print(
    '  Hitung Premi: Rp${udara.hitungPremi(nilaiBarang).toStringAsFixed(0)}',
  );
  print('  ${udara.infoAsuransi(nilaiBarang)}');

  // PengirimanTruk TIDAK mengadopsi mixin Terasuransi
  final LayananPengiriman layananTruk = truk;
  print('\n${truk.kodeLayanan} (PengirimanTruk):');
  print(
    '  Apakah memiliki kemampuan Terasuransi? ${layananTruk is Terasuransi}',
  );
  print(
    '  Catatan: Pemanggilan "truk.hitungPremi(nilaiBarang)" akan ditolak saat kompilasi',
  );
  print('  karena PengirimanTruk tidak menggunakan "with Terasuransi".');
  // Uncomment baris berikut membuktikan compiler error:
  // truk.hitungPremi(nilaiBarang); // Error: The method 'hitungPremi' isn't defined for the type 'PengirimanTruk'.

  // Bukti polimorfisme mixin: iterasi semua layanan dan pengecekan runtime
  print('\n--- Status Kemampuan Asuransi Seluruh Layanan ---');
  for (final layanan in daftarLayanan) {
    if (layanan is Terasuransi) {
      final asuransi = layanan as Terasuransi;
      print(
        '  [TERASURANSI] ${layanan.kodeLayanan.padRight(8)} : ${asuransi.infoAsuransi(nilaiBarang)}',
      );
    } else {
      print(
        '  [NON-ASURANSI] ${layanan.kodeLayanan.padRight(8)} : Tidak mendukung fasilitas asuransi',
      );
    }
  }
}
