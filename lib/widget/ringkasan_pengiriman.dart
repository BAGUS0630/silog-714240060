import 'package:flutter/material.dart';

import '../model/pengiriman.dart';

class RingkasanPengiriman extends StatelessWidget {
  const RingkasanPengiriman({super.key, required this.pengiriman});

  final List<Pengiriman> pengiriman;

  double get _totalNilaiBarang =>
      pengiriman.fold(0, (total, item) => total + item.nilaiBarang);

  String get _nilaiRupiah {
    final nilai = _totalNilaiBarang.toStringAsFixed(0);
    final nilaiBerformat = nilai.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (cocok) => '${cocok[1]}.',
    );
    return 'Rp$nilaiBerformat';
  }

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jumlah pengiriman', style: teks.labelLarge),
                  const SizedBox(height: 4),
                  Text('${pengiriman.length}', style: teks.titleLarge),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total nilai barang', style: teks.labelLarge),
                  const SizedBox(height: 4),
                  Text(_nilaiRupiah, style: teks.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
