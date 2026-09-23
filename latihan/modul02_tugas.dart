/// Model data untuk Kiriman
class Kiriman {
  final String resi;
  final String kota;
  final double berat;

  Kiriman({
    required this.resi,
    required this.kota,
    required this.berat,
  });
}

// -------------------------------------------------------------------
// FUNGSI-FUNGSI LOGIKA
// -------------------------------------------------------------------

/// 1. Menghitung total berat seluruh kiriman
double hitungTotalBerat(List<Kiriman> daftar) {
  return daftar.fold<double>(0, (total, item) => total + item.berat);
}

/// 2. Menghitung rata-rata berat kiriman
double hitungRataRataBerat(List<Kiriman> daftar) {
  if (daftar.isEmpty) return 0;
  return hitungTotalBerat(daftar) / daftar.length;
}

/// 3. Mencari kiriman dengan berat terberat
Kiriman cariKirimanTerberat(List<Kiriman> daftar) {
  return daftar.reduce((a, b) => a.berat > b.berat ? a : b);
}

/// 4. Mencari kiriman dengan berat teringan
Kiriman cariKirimanTeringan(List<Kiriman> daftar) {
  return daftar.reduce((a, b) => a.berat < b.berat ? a : b);
}

/// 5. Menentukan kategori berdasarkan berat tunggal
String tentukanKategori(double berat) {
  if (berat <= 5.0) {
    return 'Paket Kecil';
  } else if (berat <= 20.0) {
    return 'Paket Sedang';
  } else {
    return 'Kargo';
  }
}

/// 6. Menghitung rekapitulasi jumlah kiriman per kategori
Map<String, int> hitungJumlahPerKategori(List<Kiriman> daftar) {
  final Map<String, int> rekap = {
    'Paket Kecil': 0,
    'Paket Sedang': 0,
    'Kargo': 0,
  };

  for (var item in daftar) {
    String kat = tentukanKategori(item.berat);
    rekap[kat] = (rekap[kat] ?? 0) + 1;
  }

  return rekap;
}

// -------------------------------------------------------------------
// FUNGSI UTAMA
// -------------------------------------------------------------------
void main() {
  // Minimal 8 data kiriman sesuai ketentuan soal
  final List<Kiriman> daftarKiriman = [
    Kiriman(resi: 'SLG-001', kota: 'Bandung', berat: 3.0),
    Kiriman(resi: 'SLG-002', kota: 'Surabaya', berat: 12.5),
    Kiriman(resi: 'SLG-003', kota: 'Makassar', berat: 7.2),
    Kiriman(resi: 'SLG-004', kota: 'Surabaya', berat: 4.8),
    Kiriman(resi: 'SLG-005', kota: 'Jayapura', berat: 18.0),
    Kiriman(resi: 'SLG-006', kota: 'Medan', berat: 2.5),
    Kiriman(resi: 'SLG-007', kota: 'Banten', berat: 22.0),
    Kiriman(resi: 'SLG-008', kota: 'Sumedang', berat: 35.0),
  ];

  // Pemanggilan Fungsi-Fungsi Logika
  final totalBerat = hitungTotalBerat(daftarKiriman);
  final rataRataBerat = hitungRataRataBerat(daftarKiriman);
  final terberat = cariKirimanTerberat(daftarKiriman);
  final teringan = cariKirimanTeringan(daftarKiriman);
  final rekapKategori = hitungJumlahPerKategori(daftarKiriman);

  // Output Ringkasan
  print('==============================================');
  print('          LAPORAN REKAPITULASI SILOG          ');
  print('==============================================');
  print('Daftar Kiriman:');
  for (var k in daftarKiriman) {
    print(' - ${k.resi} [${k.kota}]: ${k.berat} kg (${tentukanKategori(k.berat)})');
  }

  print('\n----------------------------------------------');
  print('HASIL ANALISIS PENGIRIMAN:');
  print('----------------------------------------------');
  print('1. Total Berat Kiriman   : ${totalBerat.toStringAsFixed(2)} kg');
  print('2. Rata-Rata Berat      : ${rataRataBerat.toStringAsFixed(2)} kg');
  print('3. Kiriman Terberat     : ${terberat.resi} (${terberat.berat} kg)');
  print('4. Kiriman Teringan     : ${teringan.resi} (${teringan.berat} kg)');
  print('\n5. Rekapitulasi Kategori Kiriman:');
  rekapKategori.forEach((kategori, jumlah) {
    print('   - $kategori : $jumlah paket');
  });
  print('==============================================');
}