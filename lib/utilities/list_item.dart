import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uascapstone/components/akun.dart';
import 'package:uascapstone/components/transaksi.dart';

class ListItem extends StatefulWidget {
  final Transaksi transaksi;
  final Akun akun;
  final bool isTransaksi;

  ListItem({
    Key? key,
    required this.transaksi,
    required this.akun,
    required this.isTransaksi,
  }) : super(key: key);

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  void deleteTransaksi() async {
    try {
      await _firestore
          .collection('transaksi')
          .doc(widget.transaksi.docId)
          .delete();

      // Hapus gambar dari storage jika ada
      if (widget.transaksi.gambar != '') {
        await _storage.refFromURL(widget.transaksi.gambar!).delete();
      }

      Navigator.popAndPushNamed(context, '/dashboard');
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(context, '/detail', arguments: {
            'transaksi': widget.transaksi,
            'akun': widget.akun,
          });
        },
        onLongPress: () {
          if (widget.isTransaksi) {
            showDialog(
              context: context,
              builder: (BuildContext) {
                return AlertDialog(
                  title: Text('Delete ${widget.transaksi.nama}?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        deleteTransaksi();
                      },
                      child: Text('Delete'),
                    ),
                  ],
                );
              },
            );
          }
        },
        leading: widget.transaksi.gambar != ''
            ? Image.network(
                widget.transaksi.gambar!,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/istock-default.jpg',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
        title: Text(
          widget.transaksi.nama,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nominal: ${widget.transaksi.nominal}'),
            Text('Kategori: ${widget.transaksi.kategori}'),
          ],
        ),
      ),
    );
  }
}
