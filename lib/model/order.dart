class Order {
  final int? id;
  final int idPelanggan;
  final String judul;
  final String keterangan;
  final bool menungguSinkronisasi;

  Order({
    this.id,
    required this.idPelanggan,
    required this.judul,
    required this.keterangan,
    this.menungguSinkronisasi = false,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as int?,
    idPelanggan: json['userId'] as int? ?? 0,
    judul: (json['title'] as String?) ?? '(tanpa judul)',
    keterangan: (json['body'] as String?) ?? '',
  );

  factory Order.fromLocalJson(Map<String, dynamic> json) => Order(
    id: json['id'] as int?,
    idPelanggan: json['userId'] as int? ?? 0,
    judul: (json['title'] as String?) ?? '(tanpa judul)',
    keterangan: (json['body'] as String?) ?? '',
    menungguSinkronisasi: json['menungguSinkronisasi'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'userId': idPelanggan,
    'title': judul,
    'body': keterangan,
  };

  Map<String, dynamic> toLocalJson() => {
    ...toJson(),
    'id': id,
    'menungguSinkronisasi': menungguSinkronisasi,
  };

  Order salinDengan({
    int? id,
    int? idPelanggan,
    String? judul,
    String? keterangan,
    bool? menungguSinkronisasi,
  }) => Order(
    id: id ?? this.id,
    idPelanggan: idPelanggan ?? this.idPelanggan,
    judul: judul ?? this.judul,
    keterangan: keterangan ?? this.keterangan,
    menungguSinkronisasi: menungguSinkronisasi ?? this.menungguSinkronisasi,
  );

  @override
  String toString() => 'Order#$id $judul';
}
