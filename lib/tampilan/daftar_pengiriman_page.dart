import 'package:flutter/material.dart';

import '../data/data_contoh.dart';
import '../model/pengiriman.dart';
import '../widget/kartu_pengiriman.dart';
import '../widget/ringkasan_pengiriman.dart';
import 'detail_pengiriman_page.dart';

class DaftarPengirimanPage extends StatefulWidget {
  const DaftarPengirimanPage({super.key});

  @override
  State<DaftarPengirimanPage> createState() => _DaftarPengirimanPageState();
}

class _DaftarPengirimanPageState extends State<DaftarPengirimanPage>
    with SingleTickerProviderStateMixin {
  static const _filterStatus = [null, 'Dalam Perjalanan', 'Diterima'];

  late final TabController _tabController;
  int _tabAktif = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filterStatus.length, vsync: this)
      ..addListener(_perbaruiTabAktif);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_perbaruiTabAktif)
      ..dispose();
    super.dispose();
  }

  void _perbaruiTabAktif() {
    if (_tabAktif != _tabController.index) {
      setState(() => _tabAktif = _tabController.index);
    }
  }

  List<Pengiriman> _pengirimanTerfilter(int index) {
    final status = _filterStatus[index];
    if (status == null) {
      return dataPengiriman;
    }
    return dataPengiriman
        .where((pengiriman) => pengiriman.status == status)
        .toList(growable: false);
  }

  void _bukaDetail(Pengiriman pengiriman) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPengirimanPage(pengiriman: pengiriman),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pengirimanTerpilih = _pengirimanTerfilter(_tabAktif);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengiriman'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
            tooltip: 'Cari resi',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Dalam Perjalanan'),
            Tab(text: 'Diterima'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: RingkasanPengiriman(pengiriman: pengirimanTerpilih),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List<Widget>.generate(
                _filterStatus.length,
                (index) => _DaftarTabPengiriman(
                  pengiriman: _pengirimanTerfilter(index),
                  onTapPengiriman: _bukaDetail,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Pengiriman Baru'),
      ),
    );
  }
}

class _DaftarTabPengiriman extends StatelessWidget {
  const _DaftarTabPengiriman({
    required this.pengiriman,
    required this.onTapPengiriman,
  });

  final List<Pengiriman> pengiriman;
  final ValueChanged<Pengiriman> onTapPengiriman;

  @override
  Widget build(BuildContext context) {
    if (pengiriman.isEmpty) {
      return const Center(child: Text('Belum ada pengiriman pada status ini.'));
    }

    return ListView.builder(
      itemCount: pengiriman.length,
      itemBuilder: (context, index) {
        final item = pengiriman[index];
        return KartuPengiriman(
          pengiriman: item,
          onTap: () => onTapPengiriman(item),
        );
      },
    );
  }
}
