MODUL PRAKTIKUM PEMROGRAMAN IV D4 TEKNIK INFORMATIKA 

# MODUL PRAKTIKUM 3 

# NULL SAFETY DAN PEMROGRAMAN ASINKRON 

### **3.1. Topik Bahasan** 

Modul ini dilaksanakan pada pertemuan ke-3 sesuai Rencana Pembelajaran Semester mata kuliah Pemrograman IV dan membebani CPMK-02, dengan cakupan topik sebagai berikut: 

- Deklarasi tipe nullable dan non-nullable. 

- Operator null-aware `?.` , `??` , `??=` , serta _keyword_ `late` . 

- Penanganan _error_ menggunakan `try` , `catch` , `on` , dan `finally` . 

- Konsep `Future` dan mekanisme eksekusi asinkron. 

- Penggunaan `async` dan `await` pada pengambilan data pengiriman yang tertunda. 

### **3.2. Capaian Pembelajaran** 

Mahasiswa mampu menulis program yang aman terhadap nilai null dan menangani proses yang berjalan secara asinkron (CPMK-02). 

### **3.3. Indikator Ketercapaian Pembelajaran** 

Indikator penilaian pertemuan ke-3 menurut Rencana Pembelajaran Semester adalah: 

- Ketepatan penerapan null safety 

- Ketepatan penanganan error 

- Ketepatan penggunaan fungsi asinkron 

Indikator tersebut dinyatakan tercapai apabila bukti berikut terlihat pada hasil praktikum: 

- Program berjalan tanpa error null pada seluruh skenario uji. 

- Error tertangani dengan pesan yang jelas dan tidak menghentikan program secara paksa. 

- Data hasil proses asinkron tampil setelah proses selesai, bukan sebelum proses dimulai. 

- Penggunaan `await` dan penanganan `Future` tepat sesuai alur program. 

### **3.4. Teori Pendukung** 

## Null Safety 

Sejak Dart versi 2.12 seluruh tipe bersifat non-nullable secara bawaan. Artinya sebuah variabel bertipe `String` dijamin selalu berisi teks dan tidak pernah bernilai null. Apabila suatu variabel memang boleh kosong, tipenya harus ditandai dengan tanda tanya, 

UNIVERSITAS LOGISTIK DAN BISNIS INTERNASIONAL  |  17 

MODUL PRAKTIKUM PEMROGRAMAN IV D4 TEKNIK INFORMATIKA 

misalnya `String?` . Jaminan ini diperiksa oleh _compiler_ sehingga error akses nilai null terdeteksi sebelum program dijalankan, bukan setelah aplikasi dipakai pengguna. 

Pada aplikasi logistik, sejumlah data memang bersifat opsional: catatan penerima, koordinat lokasi pengantaran, atau waktu barang diterima. Data semacam itu tepat dimodelkan sebagai tipe nullable, sedangkan data wajib seperti nomor resi dan kota tujuan dimodelkan sebagai tipe non-nullable. 

## Operator Null-Aware 

- `?.` mengakses anggota hanya bila nilainya tidak null, dan menghasilkan null bila nilainya null. 

- `??` memberikan nilai pengganti ketika operand di sebelah kirinya bernilai null. 

- `??=` menetapkan nilai hanya bila variabel masih bernilai null. 

- `!` memaksa compiler menganggap nilai tidak null. Operator ini hanya boleh digunakan bila benar-benar yakin, karena akan memunculkan error saat program berjalan bila ternyata nilainya null. 

- `late` menunda pengisian nilai variabel non-nullable hingga saat pertama kali digunakan. 

_Kode Program 3.1 Penggunaan operator null-aware_ 

```
String? catatanPenerima;
DateTime? waktuDiterima;
```

```
finalpanjangCatatan = catatanPenerima?.length ?? 0;
catatanPenerima ??= 'Tidak ada catatan';
```

```
finalstatus = waktuDiterima == null ? 'Dalam perjalanan' : 'Diterima';
```

Tabel 4. Operator null-aware pada bahasa Dart 

|**Operator**|**Fungsi**|**Contoh**|
|---|---|---|
|`?.`|Mengakses anggota hanya bila nilainya tidak null|`catatan?.length`|
|`??`|Memberi nilai pengganti ketika operand kiri null|`catatan ?? "kosong"`|
|`??=`|Mengisi variabel hanya bila masih null|`catatan ??= "kosong"`|
|`!`|Memaksa nilai dianggap tidak null|`waktu!.toIso8601String()`|
|`late`|Menunda pengisian variabel non-nullable|`late final Database db;`|



## Penanganan Error 

Error pada Dart dibedakan menjadi `Error` yang menandakan kekeliruan pemrograman dan `Exception` yang menandakan kondisi tidak normal yang wajar terjadi, misalnya koneksi terputus atau data tidak ditemukan. Blok `try` membungkus kode yang berpotensi gagal, blok `on` menangkap jenis _exception_ tertentu, blok `catch` menangkap exception secara umum beserta _stack trace_ -nya, dan blok `finally` selalu dijalankan baik terjadi error maupun tidak. 

UNIVERSITAS LOGISTIK DAN BISNIS INTERNASIONAL  |  18 

MODUL PRAKTIKUM PEMROGRAMAN IV D4 TEKNIK INFORMATIKA 

Exception sebaiknya ditangkap pada tingkat yang mampu mengambil keputusan, lalu disampaikan kepada pengguna dalam bahasa yang dapat dipahami. Menampilkan pesan teknis mentah kepada pengguna akhir bukan merupakan penanganan error yang memadai. 

## Pemrograman Asinkron dan Future 

Dart mengeksekusi kode pada satu _thread_ yang dikelola melalui _event loop_ . Operasi yang memakan waktu, seperti pemanggilan layanan web atau pembacaan basis data, tidak boleh menghentikan thread tersebut karena antarmuka akan membeku. Operasi semacam itu dijalankan secara asinkron dan hasilnya diwakili oleh objek `Future` . 

Sebuah `Future` berada pada salah satu dari tiga keadaan: belum selesai, selesai dengan nilai, atau selesai dengan error. Keyword `await` menunggu `Future` selesai lalu mengambil nilainya, dan hanya boleh digunakan di dalam fungsi yang ditandai `async` . Fungsi `async` selalu mengembalikan `Future` , sehingga fungsi yang tidak mengembalikan nilai ditulis dengan tipe return `Future<void>` . 

Ketika beberapa operasi asinkron tidak saling bergantung, `Future.wait` dapat dipakai untuk menjalankannya secara bersamaan sehingga total waktu tunggu jauh lebih singkat dibandingkan menunggunya satu per satu. 



<!-- Start of picture text -->
Sinkron (tanpa await)<br>permintaan Future belum proses selesai<br>dikirim selesai dicetak tanpa dipakai<br>Asinkron (dengan await)<br>permintaan menunggu nilai diterima<br>dikirim Future selesai lalu dicetak<br>— ——<br>event loop tetap berjalan<br><!-- End of picture text -->

Gambar 3. Perbedaan urutan eksekusi tanpa dan dengan await 

### **3.5. Alat Pendukung** 

Perangkat keras, perangkat lunak, dan bahan yang diperlukan pada modul ini adalah: 

- Flutter SDK dan Dart SDK. 

- Visual Studio Code beserta ekstensi Flutter dan Dart. 

- Terminal PowerShell. 

- Repositori GitHub pribadi praktikan (satu repositori untuk seluruh modul praktikum). 

UNIVERSITAS LOGISTIK DAN BISNIS INTERNASIONAL  |  19 

MODUL PRAKTIKUM PEMROGRAMAN IV D4 TEKNIK INFORMATIKA 

### **3.6. Langkah-langkah Praktikum** 

## A. Penyiapan 

1. Buka proyek `silog_app` melalui menu File > Open Folder pada Visual Studio Code, lalu buka terminal terintegrasi melalui menu Terminal > New Terminal. Buat cabang kerja modul ini pada terminal dengan perintah `git checkout -b praktikum/modul-03` , kemudian pastikan cabang aktif melalui `git branch` . 

2. Buat dua berkas di dalam direktori `latihan` melalui panel Explorer: klik kanan direktori `latihan` , pilih New File, lalu ketik `modul03_nullsafety.dart` ; ulangi langkah yang sama untuk `modul03_async.dart` . 

## B. Latihan 1: Null Safety 

1. Ketik kode berikut pada berkas `latihan/modul03_nullsafety.dart` , lalu simpan melalui `Ctrl+S` . 

_Kode Program 3.2 Penanganan data pengiriman yang bersifat opsional_ 

```
classDataKiriman {
finalStringresi;            // wajib
finalStringkotaTujuan;      // wajib
finalString? catatan;        // opsional
finalDateTime? waktuTerima;  // opsional
DataKiriman({
requiredthis.resi,
requiredthis.kotaTujuan,
this.catatan,
this.waktuTerima,
  });
}
Stringringkasan(DataKirimank) {
finalcatatan = k.catatan ?? '(tanpa catatan)';
finalstatus = k.waktuTerima == null
      ? 'Dalam perjalanan'
      : 'Diterima pada ${k.waktuTerima!.toIso8601String()}';
return'${k.resi} | ${k.kotaTujuan} | $status | $catatan';
}
voidmain() {
finaldaftar = <DataKiriman>[
DataKiriman(resi: 'SLG-001', kotaTujuan: 'Bandung'),
DataKiriman(
resi: 'SLG-002',
kotaTujuan: 'Surabaya',
catatan: 'Titipkan ke satpam',
waktuTerima: DateTime(2026, 9, 12, 10, 30),
    ),
  ];
for (finalkindaftar) {
print(ringkasan(k));
  }
}
```

2. Jalankan program melalui `dart run latihan/modul03_nullsafety.dart` . 

UNIVERSITAS LOGISTIK DAN BISNIS INTERNASIONAL  |  20 

MODUL PRAKTIKUM PEMROGRAMAN IV D4 TEKNIK INFORMATIKA 

3. Hapus tanda tanya pada deklarasi `String? catatan` , amati pesan error dari compiler, kemudian kembalikan seperti semula dan catat penjelasannya pada jurnal. 

## C. Latihan 2: Penanganan Error 

1. Tambahkan kode berikut pada berkas `latihan/modul03_nullsafety.dart` , panggil fungsi `ujiPenanganan()` dari `main()` , simpan melalui `Ctrl+S` , lalu jalankan ulang melalui `dart run latihan/modul03_nullsafety.dart` . 

_Kode Program 3.3 Penanganan error dengan try-catch_ 

```
classResiTidakDitemukanimplementsException {
finalStringresi;
ResiTidakDitemukan(this.resi);
@override
StringtoString() => 'Resi $resi tidak ditemukan pada basis data.';
}
finalMap<String, String> basisResi = {
'SLG-001': 'Bandung',
'SLG-002': 'Surabaya',
};
StringcariKota(Stringresi) {
finalkota = basisResi[resi];
if (kota == null) {
throwResiTidakDitemukan(resi);
  }
returnkota;
}
voidujiPenanganan() {
for (finalresiin ['SLG-001', 'SLG-999']) {
try {
print('$resi -> ${cariKota(resi)}');
    } onResiTidakDitemukancatch (e) {
print('Peringatan: $e');
    } catch (e, s) {
print('Kesalahan tidak terduga: $e');
print(s);
    } finally {
print('Pencarian $resi selesai.');
    }
  }
}
```

## D. Latihan 3: Future, async, dan await 

1. Ketik kode berikut pada berkas `latihan/modul03_async.dart` , lalu simpan melalui `Ctrl+S` . 

_Kode Program 3.4 Simulasi pengambilan data pelacakan secara asinkron_ 

```
Future<String> ambilStatusKiriman(Stringresi) async {
// Simulasi jeda jaringan selama dua detik
awaitFuture.delayed(constDuration(seconds: 2));
if (!resi.startsWith('SLG-')) {
throwFormatException('Format resi tidak sah: $resi');
```

UNIVERSITAS LOGISTIK DAN BISNIS INTERNASIONAL  |  21 

MODUL PRAKTIKUM PEMROGRAMAN IV D4 TEKNIK INFORMATIKA 

```
  }
return'Paket $resi sedang dalam perjalanan menuju gudang transit.';
}
Future<double> ambilOngkir(Stringresi) async {
awaitFuture.delayed(constDuration(seconds: 1));
return105400;
}
Future<void> main() async {
print('1. Permintaan data dikirim...');
try {
finalstatus = awaitambilStatusKiriman('SLG-002');
print('2. $status');
finalongkir = awaitambilOngkir('SLG-002');
print('3. Ongkos kirim: Rp${ongkir.toStringAsFixed(0)}');
  } onFormatExceptioncatch (e) {
print('Kesalahan format: ${e.message}');
  } catch (e) {
print('Gagal mengambil data: $e');
  }
print('4. Proses selesai.');
}
```

   2. Jalankan program melalui `dart run latihan/modul03_async.dart` , lalu catat urutan kemunculan baris _output_ beserta jeda waktunya. 

   3. Hapus keyword `await` pada baris pemanggilan `ambilStatusKiriman` , jalankan ulang, lalu jelaskan mengapa yang tercetak adalah objek `Instance of 'Future<String>'` . 

   4. Kembalikan keyword `await` , lalu ubah argumen menjadi `'XYZ-002'` untuk menguji jalur penanganan error. 

- E. Latihan 4: Eksekusi Paralel dengan Future.wait 

_Kode Program 3.5 Menjalankan beberapa operasi asinkron secara bersamaan_ 

```
Future<void> bandingkanWaktu() async {
finalmulai = DateTime.now();
finalhasil = awaitFuture.wait([
ambilStatusKiriman('SLG-001'),
ambilOngkir('SLG-001'),
  ]);
finaldurasi = DateTime.now().difference(mulai);
print('Status : ${hasil[0]}');
print('Ongkir : ${hasil[1]}');
print('Durasi total: ${durasi.inMilliseconds} ms');
}
```

1. Panggil fungsi `bandingkanWaktu()` dari `main()` , simpan melalui `Ctrl+S` , jalankan program melalui `dart run latihan/modul03_async.dart` , lalu bandingkan durasinya dengan pemanggilan berurutan pada Latihan 3. 

UNIVERSITAS LOGISTIK DAN BISNIS INTERNASIONAL  |  22 

MODUL PRAKTIKUM PEMROGRAMAN IV D4 TEKNIK INFORMATIKA 

2. Tuliskan kesimpulan mengenai kapan `Future.wait` layak digunakan dan kapan tidak. 

## F. Tugas Praktikum 

1. Kembangkan fungsi `ambilStatusKiriman` sehingga membaca data dari sebuah `Map` berisi minimal lima resi, dan melemparkan `ResiTidakDitemukan` apabila resi tidak terdaftar. 

2. Susun fungsi `pantauBanyakResi(List<String> daftarResi)` yang memanggil fungsi tersebut untuk seluruh resi secara bersamaan, menampilkan hasil yang berhasil, dan mencatat resi yang gagal tanpa menghentikan proses. 

3. Lampirkan tangkapan layar output program untuk skenario seluruh resi sah dan skenario terdapat resi tidak sah. 

## G. Luaran yang Dinilai 

Bentuk penilaian modul ini adalah tugas praktikum dengan kriteria program bebas error null dan kesesuaian penggunaan async/await. jurnal praktikum individu diunggah ke lms ulbi paling lambat 5x24 jam setelah sesi praktikum. Agar kriteria tersebut dapat dinilai, praktikan menyerahkan luaran berikut: 

- Berkas `modul03_nullsafety.dart` dan `modul03_async.dart` . 

- Bukti program bebas error null berupa tangkapan layar `dart analyze` tanpa temuan. 

- Tangkapan layar output untuk skenario resi sah dan skenario resi tidak sah. 

- Penjelasan tertulis mengenai urutan kemunculan baris output pada program asinkron, beserta perbandingan durasi pemanggilan berurutan dan `Future.wait` . 

### **3.7. Panduan Pengumpulan Jurnal Hasil Kegiatan Praktikum** 

Tugas praktikum modul ini bersifat individu. Setiap praktikan menyusun dan mengunggah sendiri jurnalnya ke LMS ULBI paling lambat 5 x 24 jam setelah sesi praktikum berakhir, berupa berkas PDF bernama `NIM_Nama_Modul-XX.pdf` , disertai tautan repositori GitHub pribadi pada cabang `praktikum/modul-XX` . 

Sistematika jurnal: 

1. Identitas: nama, NIM, kelas, nomor dan judul modul, serta tanggal praktikum. 

2. Tujuan praktikum. 

3. Alat dan bahan yang digunakan beserta versinya. 

4. Langkah kerja, disertai tangkapan layar tiap tahap penting. 

5. Kode program beserta penjelasan singkatnya. 

6. Hasil eksekusi dan analisisnya, termasuk error yang ditemui beserta penyelesaiannya. 

7. Jawaban seluruh butir Tugas Praktikum. 

8. Kesimpulan dan kendala. 

UNIVERSITAS LOGISTIK DAN BISNIS INTERNASIONAL  |  23 

MODUL PRAKTIKUM PEMROGRAMAN IV D4 TEKNIK INFORMATIKA 

9. Tautan repositori beserta tangkapan layar riwayat _commit_ . 

Tangkapan layar wajib memperlihatkan jendela _browser_ atau emulator secara utuh beserta kode programnya, dan memuat nama serta NIM praktikan. Praktikan yang tidak mengumpulkan jurnal memperoleh nilai nol; keterlambatan dan ketidaksesuaian hasil lainnya dikenai pengurangan nilai sesuai kebijakan dosen pengampu. 

Seluruh butir pada sub bab Luaran yang Dinilai wajib dilampirkan pada jurnal. 

### **3.8. Hasil Capaian Pembelajaran Praktikum** 

Bentuk dan kriteria penilaian mengikuti Rencana Pembelajaran Semester pertemuan ke3: Tugas praktikum: program bebas error null dan kesesuaian penggunaan async/await. Jurnal praktikum individu diunggah ke LMS ULBI paling lambat 5x24 jam setelah sesi praktikum. 

Tugas praktikum modul ini bersifat individu dan dinilai dari jurnal praktikum masingmasing praktikan. 

Bobotnya 2% dari nilai akhir mata kuliah pada komponen evaluasi Praktikum (Aktivitas Partisipatif) sebesar 15% dari nilai akhir, diukur dari kelengkapan dan mutu luaran pada sub bab Luaran yang Dinilai terhadap indikator penilaian modul ini. 

UNIVERSITAS LOGISTIK DAN BISNIS INTERNASIONAL  |  24 

