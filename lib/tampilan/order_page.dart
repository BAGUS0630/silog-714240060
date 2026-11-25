import 'package:flutter/material.dart';

import '../data/order_api.dart';
import '../data/order_repository.dart';
import '../model/order.dart';

class OrderPage extends StatefulWidget {
  final OrderRepository repository;

  OrderPage({super.key, OrderRepository? repository})
    : repository = repository ?? OrderRepository();

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late Future<HasilMuatOrder> _future;
  final List<Order> _orderTambahan = [];
  final _searchC = TextEditingController();
  String _kataKunci = '';

  @override
  void initState() {
    super.initState();
    _future = widget.repository.ambilDaftar();
  }

  @override
  void dispose() {
    _searchC.dispose();
    widget.repository.tutup();
    super.dispose();
  }

  Future<void> _muatUlang() async {
    setState(() => _future = widget.repository.ambilDaftar());
  }

  Future<void> _kirimContoh() async {
    try {
      final hasil = await widget.repository.kirimOrder(
        Order(
          idPelanggan: 7,
          judul: 'Order pengiriman Bandung - Surabaya',
          keterangan: '3 koli, berat total 42 kg, layanan reguler',
        ),
      );
      if (!mounted) return;
      setState(() {
        _orderTambahan.removeWhere((order) => order.id == hasil.order.id);
        _orderTambahan.insert(0, hasil.order);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasil.tertunda
                ? 'Order disimpan di perangkat dan menunggu koneksi'
                : 'Order terkirim dengan id ${hasil.order.id}',
          ),
        ),
      );
    } on GagalApi catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  Future<void> _ubahOrder(Order order) async {
    final judulC = TextEditingController(text: order.judul);
    final keteranganC = TextEditingController(text: order.keterangan);

    final hasil = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ubah Order #${order.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: judulC,
              decoration: const InputDecoration(
                labelText: 'Judul Order',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keteranganC,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Keterangan Order',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (hasil == true && mounted) {
      try {
        final orderDiubah = order.salinDengan(
          judul: judulC.text.trim(),
          keterangan: keteranganC.text.trim(),
        );
        final hasilPut = await widget.repository.perbaruiOrder(orderDiubah);
        if (!mounted) return;
        setState(() {
          final idxTambahan = _orderTambahan.indexWhere((o) => o.id == order.id);
          if (idxTambahan != -1) {
            _orderTambahan[idxTambahan] = hasilPut;
          }
        });
        _muatUlang();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order #${order.id} berhasil diperbarui (PUT)')),
        );
      } on GagalApi catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui order: $e')),
        );
      }
    }
  }

  Future<void> _hapusOrder(Order order) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Order'),
        content: Text('Hapus order #${order.id}: "${order.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ya == true && order.id != null && mounted) {
      try {
        await widget.repository.hapusOrder(order.id!);
        if (!mounted) return;
        setState(() {
          _orderTambahan.removeWhere((o) => o.id == order.id);
        });
        _muatUlang();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order #${order.id} berhasil dihapus (DELETE)')),
        );
      } on GagalApi catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus order: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order dari Layanan Web'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _muatUlang),
        ],
      ),
      body: FutureBuilder<HasilMuatOrder>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _muatUlang,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }
          final hasil = snapshot.data!;
          final semuaData = [
            ..._orderTambahan.where(
              (order) =>
                  !hasil.orders.any((tersimpan) => tersimpan.id == order.id),
            ),
            ...hasil.orders,
          ];
          final jumlahTertunda = semuaData
              .where((order) => order.menungguSinkronisasi)
              .length;
          final offline = hasil.offline || jumlahTertunda > 0;

          // Filter pencarian berdasarkan kata kunci pada judul (dilakukan pada sisi aplikasi)
          final data = _kataKunci.trim().isEmpty
              ? semuaData
              : semuaData
                  .where((o) =>
                      o.judul.toLowerCase().contains(_kataKunci.trim().toLowerCase()))
                  .toList();

          if (semuaData.isEmpty) {
            return Column(
              children: [
                if (offline) _pesanOffline(hasil, jumlahTertunda),
                const Expanded(
                  child: Center(
                    child: Text('Belum ada order yang tersimpan di perangkat'),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              if (offline) _pesanOffline(hasil, jumlahTertunda),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  controller: _searchC,
                  decoration: InputDecoration(
                    hintText: 'Cari berdasarkan judul order...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchC.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchC.clear();
                              setState(() => _kataKunci = '');
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
                  onChanged: (val) => setState(() => _kataKunci = val),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Menampilkan ${data.length} dari ${semuaData.length} order',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              Expanded(
                child: data.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada order dengan judul "$_kataKunci"',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _muatUlang,
                        child: ListView.separated(
                          itemCount: data.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final o = data[i];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  o.id != null && o.id! > 0 ? '${o.id}' : 'Lokal',
                                ),
                              ),
                              title: Text(
                                o.judul,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                o.keterangan,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (o.menungguSinkronisasi)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Text('Menunggu koneksi'),
                                    )
                                  else
                                    Text('Plg ${o.idPelanggan}'),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (aksi) {
                                      if (aksi == 'ubah') {
                                        _ubahOrder(o);
                                      } else if (aksi == 'hapus') {
                                        _hapusOrder(o);
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(
                                        value: 'ubah',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 20),
                                            SizedBox(width: 8),
                                            Text('Ubah (PUT)'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'hapus',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, size: 20, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Hapus (DELETE)', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _kirimContoh,
        icon: const Icon(Icons.cloud_upload),
        label: const Text('Kirim Order'),
      ),
    );
  }

  Widget _pesanOffline(HasilMuatOrder hasil, int jumlahTertunda) {
    final pesan = hasil.offline
        ? 'Offline: ${hasil.pesanOffline}. Data yang tampil berasal dari perangkat.'
        : '$jumlahTertunda order menunggu koneksi. Tekan muat ulang saat online.';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Text(pesan),
    );
  }
}
