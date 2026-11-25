import 'package:flutter/material.dart';

import '../data/data_contoh.dart';
import '../data/order_repository.dart';
import '../model/pengiriman.dart';
import '../widget/kartu_pengiriman.dart';
import 'detail_pengiriman_page.dart';
import 'form_pengiriman_page.dart';
import 'order_page.dart';
import 'stok_page.dart'; // <-- Pastikan import StokPage sudah ada
import '../main.dart';

class DaftarPengirimanPage extends StatefulWidget {
  final OrderRepository? orderRepository;

  const DaftarPengirimanPage({super.key, this.orderRepository});

  @override
  State<DaftarPengirimanPage> createState() => _DaftarPengirimanPageState();
}

class _DaftarPengirimanPageState extends State<DaftarPengirimanPage> {
  late List<Pengiriman> _daftar;
  String _filterStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _daftar = dataPengiriman;
  }

  List<Pengiriman> get _hasilSaring => _filterStatus == 'Semua'
      ? _daftar
      : _daftar.where((p) => p.status == _filterStatus).toList();

  Future<void> _bukaFormulir() async {
    final hasil = await Navigator.push<Pengiriman>(
      context,
      MaterialPageRoute(builder: (_) => const FormPengirimanPage()),
    );
    if (hasil != null) {
      setState(() => _daftar.insert(0, hasil));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pengiriman ${hasil.resi} berhasil ditambahkan'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const opsi = ['Semua', 'Menunggu Pickup', 'Dalam Perjalanan', 'Diterima'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengiriman'),
        actions: [
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
          // <-- Tombol menuju StokPage ditambahkan di sini
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'Stok Gudang',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StokPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.cloud_outlined),
            tooltip: 'Order dari Layanan Web',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderPage(repository: widget.orderRepository),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: opsi.map((o) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(o),
                    selected: _filterStatus == o,
                    onSelected: (_) => setState(() => _filterStatus = o),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              'Menampilkan ${_hasilSaring.length} dari ${_daftar.length} data',
            ),
          ),
          Expanded(
            child: _hasilSaring.isEmpty
                ? const Center(child: Text('Tidak ada data pengiriman'))
                : ListView.builder(
                    itemCount: _hasilSaring.length,
                    itemBuilder: (context, i) {
                      final item = _hasilSaring[i];
                      return KartuPengiriman(
                        pengiriman: item,
                        onTap: () async {
                          final dihapus = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetailPengirimanPage(pengiriman: item),
                            ),
                          );
                          if (dihapus == true && mounted) setState(() {});
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaFormulir,
        icon: const Icon(Icons.add),
        label: const Text('Pengiriman Baru'),
      ),
    );
  }
}
