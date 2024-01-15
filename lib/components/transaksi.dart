class Transaksi {
  final String uid;
  final String docId;

  final String nama;
  final String nominal;
  String? deskripsi;
  String? gambar;
  final String kategori;
  final DateTime tanggal;

  Transaksi({
    required this.uid,
    required this.docId,
    required this.nama,
    required this.nominal,
    this.deskripsi,
    this.gambar,
    required this.kategori,
    required this.tanggal,
  });
}
