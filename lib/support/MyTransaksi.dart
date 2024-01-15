import 'package:flutter/material.dart';
import 'package:uascapstone/components/akun.dart';
import 'package:uascapstone/components/transaksi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyTransaksi extends StatefulWidget {
  final Akun akun;
  MyTransaksi({Key? key, required this.akun}) : super(key: key);

  @override
  State<MyTransaksi> createState() => _MyTransaksiState();
}

class _MyTransaksiState extends State<MyTransaksi> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<Transaksi> listTransaksi = [];

  @override
  void initState() {
    super.initState();
    getTransaksi();
  }

  void getTransaksi() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('transaksi')
          .where('uid', isEqualTo: _auth.currentUser!.uid)
          .get();

      setState(() {
        listTransaksi.clear();
        for (var documents in querySnapshot.docs) {
          listTransaksi.add(
            Transaksi(
              uid: documents.data()['uid'],
              docId: documents.data()['docId'],
              nama: documents.data()['nama'],
              deskripsi: documents.data()['deskripsi'],
              nominal: documents.data()['nominal'],
              kategori: documents.data()['kategori'],
              gambar: documents.data()['gambar'],
              tanggal: documents['tanggal'].toDate(),
            ),
          );
        }
      });
    } catch (e) {
      print(e);
    }
  }

  // Fungsi untuk mendapatkan ikon sesuai dengan kategori
  Icon getIconByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'bayar':
        return Icon(Icons.payment, color: Colors.white);
      case 'transfer':
        return Icon(Icons.swap_horiz, color: Colors.white);
      case 'top up':
        return Icon(Icons.arrow_upward, color: Colors.white);
      default:
        return Icon(Icons.attach_money, color: Colors.white);
    }
  }

  // Navigasi ke halaman rincian (detail) transaksi
  void navigateToDetail(Transaksi transaksi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailTransaksiPage(transaksi: transaksi),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        /*appBar: AppBar(
          title: Text('Daftar Transaksi'),
        ),*/
        body: listTransaksi.isEmpty
            ? Center(
                child: Text('Tidak ada transaksi.'),
              )
            : ListView.builder(
                itemCount: listTransaksi.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: getIconByCategory(listTransaksi[index].kategori),
                      ),
                      title: Text(
                        listTransaksi[index].nama,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(listTransaksi[index].deskripsi.toString()),
                          SizedBox(height: 4),
                          Text(
                            'Nominal: Rp${listTransaksi[index].nominal}',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        navigateToDetail(listTransaksi[index]);
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class DetailTransaksiPage extends StatelessWidget {
  final Transaksi transaksi;

  DetailTransaksiPage({Key? key, required this.transaksi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama: ${transaksi.nama}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Deskripsi: ${transaksi.deskripsi}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Nominal: Rp${transaksi.nominal}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Kategori: ${transaksi.kategori}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tanggal: ${transaksi.tanggal}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Menampilkan gambar
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  transaksi.gambar ?? '',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
