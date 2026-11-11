import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/stok_repository.dart';
import '../model/stok.dart';

class FormStokPage extends StatefulWidget {
  final String kodeGudang;

  const FormStokPage({super.key, required this.kodeGudang});

  @override
  State<FormStokPage> createState() => _FormStokPageState();
}

class _FormStokPageState extends State<FormStokPage> {
  final _formKey = GlobalKey<FormState>();
  final _kodeBarangC = TextEditingController();
  final _namaBarangC = TextEditingController();
  final _jumlahC = TextEditingController();
  late String _kodeGudangTerpilih;
  bool _sedangMenyimpan = false;

  final _repo = StokRepository.instance;

  @override
  void initState() {
    super.initState();
    _kodeGudangTerpilih = widget.kodeGudang;
  }

  @override
  void dispose() {
    _kodeBarangC.dispose();
    _namaBarangC.dispose();
    _jumlahC.dispose();
    super.dispose();
  }

  String? _wajib(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label wajib diisi';
    return null;
  }

  String? _validasiKodeBarang(String? v) {
    final dasar = _wajib(v, 'Kode barang');
    if (dasar != null) return dasar;
    final nilai = v!.trim().toUpperCase();
    if (nilai.length < 3) {
      return 'Kode barang minimal 3 karakter';
    }
    final pola = RegExp(r'^[A-Z0-9-]+$');
    if (!pola.hasMatch(nilai)) {
      return 'Kode barang hanya boleh huruf, angka, dan strip (-)';
    }
    return null;
  }

  String? _validasiNamaBarang(String? v) {
    final dasar = _wajib(v, 'Nama barang');
    if (dasar != null) return dasar;
    if (v!.trim().length < 3) {
      return 'Nama barang minimal 3 karakter';
    }
    return null;
  }

  String? _validasiJumlah(String? v) {
    final dasar = _wajib(v, 'Jumlah stok');
    if (dasar != null) return dasar;
    final angka = int.tryParse(v!.trim());
    if (angka == null) return 'Jumlah stok harus berupa angka bulat';
    if (angka < 1) return 'Jumlah stok minimal 1 unit';
    if (angka > 100000) return 'Jumlah stok maksimal 100.000 unit';
    return null;
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _sedangMenyimpan = true);

    try {
      final kodeBarang = _kodeBarangC.text.trim().toUpperCase();
      final namaBarang = _namaBarangC.text.trim();
      final jumlah = int.parse(_jumlahC.text.trim());

      // Validasi kode barang unik di gudang yang sama
      final stokGudang = await _repo.ambilSemua(kodeGudang: _kodeGudangTerpilih);
      final duplikat = stokGudang.any((s) => s.kodeBarang.toUpperCase() == kodeBarang);
      if (duplikat) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kode barang $kodeBarang sudah ada di gudang $_kodeGudangTerpilih'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _sedangMenyimpan = false);
        return;
      }

      final stokBaru = Stok(
        kodeBarang: kodeBarang,
        namaBarang: namaBarang,
        kodeGudang: _kodeGudangTerpilih,
        jumlah: jumlah,
        diperbaruiPada: DateTime.now(),
      );

      await _repo.simpan(stokBaru);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok $namaBarang berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _sedangMenyimpan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const daftarGudang = ['GD-BDG', 'GD-JKT', 'GD-SBY'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Stok Barang'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _kodeBarangC,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Kode Barang',
                  hintText: 'Contoh: BRG-001',
                  prefixIcon: Icon(Icons.qr_code),
                  border: OutlineInputBorder(),
                ),
                validator: _validasiKodeBarang,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _namaBarangC,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang',
                  hintText: 'Contoh: Sepatu Olahraga Pria',
                  prefixIcon: Icon(Icons.inventory_2),
                  border: OutlineInputBorder(),
                ),
                validator: _validasiNamaBarang,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _kodeGudangTerpilih,
                decoration: const InputDecoration(
                  labelText: 'Gudang Penyimpanan',
                  prefixIcon: Icon(Icons.warehouse),
                  border: OutlineInputBorder(),
                ),
                items: daftarGudang.map((g) {
                  return DropdownMenuItem(value: g, child: Text('Gudang $g'));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _kodeGudangTerpilih = val);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jumlahC,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Jumlah Stok (Unit)',
                  hintText: 'Contoh: 50',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
                validator: _validasiJumlah,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _sedangMenyimpan ? null : _simpan,
                icon: _sedangMenyimpan
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(_sedangMenyimpan ? 'Menyimpan...' : 'Simpan Stok'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
