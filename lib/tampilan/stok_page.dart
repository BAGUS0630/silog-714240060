import 'package:flutter/material.dart';

import '../data/preferensi.dart';
import '../data/stok_repository.dart';
import '../model/stok.dart';
import 'form_stok_page.dart';
import '../main.dart';

class StokPage extends StatefulWidget {
  const StokPage({super.key});

  @override
  State<StokPage> createState() => _StokPageState();
}

class _StokPageState extends State<StokPage> {
  static const _daftarGudang = ['GD-BDG', 'GD-JKT', 'GD-SBY'];

  final _repo = StokRepository.instance;
  final _pref = Preferensi();
  final _searchC = TextEditingController();

  List<Stok> _daftar = [];
  String _gudang = 'GD-BDG';
  bool _memuat = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  Future<void> _muat({String? kataKunci}) async {
    setState(() => _memuat = true);
    _gudang = await _pref.ambilGudangTerakhir();
    final query = kataKunci ?? _searchC.text.trim();
    final data = await _repo.ambilSemua(
      kodeGudang: _gudang,
      kataKunci: query.isEmpty ? null : query,
    );

    if (!mounted) return;

    setState(() {
      _daftar = data;
      _memuat = false;
    });
  }

  Future<void> _pilihGudang(String kodeGudang) async {
    await _pref.simpanGudangTerakhir(kodeGudang);
    await _muat();
  }

  Future<void> _tambah5Contoh() async {
    for (int i = 0; i < 5; i++) {
      final waktu = DateTime.now().add(Duration(milliseconds: i * 50));
      await _repo.simpan(
        Stok(
          kodeBarang: 'B-${waktu.microsecondsSinceEpoch}',
          namaBarang: 'Barang Uji ${waktu.microsecondsSinceEpoch}',
          kodeGudang: _gudang,
          jumlah: 25,
          diperbaruiPada: waktu,
        ),
      );
    }
    await _muat();
  }

  Future<void> _bukaFormulirTambah() async {
    final gudangTerpilih = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => FormStokPage(kodeGudang: _gudang)),
    );
    if (gudangTerpilih != null) {
      await _pilihGudang(gudangTerpilih);
    }
  }

  Future<void> _ubahJumlah(Stok stok, int delta) async {
    final baru = stok.jumlah + delta;
    if (baru < 0) return;
    await _repo.perbarui(stok.salinDengan(jumlah: baru));
    await _muat();
  }

  Future<void> _hapus(Stok stok) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus data stok'),
        content: Text('Hapus ${stok.namaBarang} dari gudang $_gudang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ya == true && stok.id != null) {
      await _repo.hapus(stok.id!);
      await _muat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _daftar.fold<int>(0, (a, s) => a + s.jumlah);

    return Scaffold(
      appBar: AppBar(
        title: Text('Stok Gudang $_gudang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: 'Tambah 5 Data Contoh',
            onPressed: _tambah5Contoh,
          ),
          PopupMenuButton<String>(
            tooltip: 'Pilih gudang',
            initialValue: _gudang,
            onSelected: _pilihGudang,
            itemBuilder: (context) => _daftarGudang
                .map(
                  (kode) => PopupMenuItem(
                    value: kode,
                    child: Text(kode == _gudang ? '$kode (dipilih)' : kode),
                  ),
                )
                .toList(),
            icon: const Icon(Icons.warehouse_outlined),
          ),
          IconButton(
            icon: Icon(
              SiLogApp.of(context)?.isDarkMode == true
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: 'Ubah Tema',
            onPressed: () {
              final state = SiLogApp.of(context);
              if (state != null) {
                state.ubahModeGelap(!state.isDarkMode);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchC,
              decoration: InputDecoration(
                hintText: 'Cari nama barang...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchC.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchC.clear();
                          _muat();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: (val) => _muat(kataKunci: val),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'Total stok: $total unit dari ${_daftar.length} jenis barang',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: _memuat
                ? const Center(child: CircularProgressIndicator())
                : _daftar.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _searchC.text.isNotEmpty
                                  ? 'Tidak ditemukan barang dengan nama "${_searchC.text}"'
                                  : 'Belum ada data stok di gudang $_gudang',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (_searchC.text.isEmpty) ...[
                              const SizedBox(height: 16),
                              FilledButton.tonalIcon(
                                onPressed: _tambah5Contoh,
                                icon: const Icon(Icons.playlist_add),
                                label: const Text('Isi 5 Data Contoh Otomatis'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _daftar.length,
                        itemBuilder: (context, i) {
                          final s = _daftar[i];
                          return ListTile(
                            title: Text(s.namaBarang),
                            subtitle: Text(
                              '${s.kodeBarang} - ${s.jumlah} unit',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                  ),
                                  tooltip: 'Kurangi jumlah ${s.namaBarang}',
                                  onPressed: () => _ubahJumlah(s, -1),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  tooltip: 'Tambah jumlah ${s.namaBarang}',
                                  onPressed: () => _ubahJumlah(s, 1),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Hapus ${s.namaBarang}',
                                  onPressed: () => _hapus(s),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaFormulirTambah,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Stok'),
      ),
    );
  }
}
