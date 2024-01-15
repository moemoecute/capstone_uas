import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uascapstone/components/akun.dart';
import 'package:uascapstone/utilities/input_widget.dart';
import 'package:uascapstone/utilities/styles.dart';
import 'package:uascapstone/utilities/validators.dart';

class AddFormPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AddFormState();
}

class AddFormState extends State<AddFormPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  DateTime selectedDate = DateTime.now();

  bool _isLoading = false;

  String? nama;
  String? kategori;
  String? deskripsi;
  String? nominal;

  ImagePicker picker = ImagePicker();
  XFile? file;

  Image imagePreview() {
    if (file == null) {
      return Image.asset('assets/istock-default.jpg', width: 180, height: 180);
    } else {
      return Image.file(File(file!.path), width: 180, height: 180);
    }
  }

  Future<dynamic> uploadDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext) {
          return AlertDialog(
            title: Text('Pilih sumber '),
            actions: [
              TextButton(
                onPressed: () async {
                  XFile? upload =
                      await picker.pickImage(source: ImageSource.camera);

                  setState(() {
                    file = upload;
                  });

                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.camera_alt),
              ),
              TextButton(
                onPressed: () async {
                  XFile? upload =
                      await picker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    file = upload;
                  });

                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.photo_library),
              ),
            ],
          );
        });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<String> uploadImage() async {
    if (file == null) return '';

    String uniqueFilename = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      Reference dirUpload =
          _storage.ref().child('upload/${_auth.currentUser!.uid}');
      Reference storedDir = dirUpload.child(uniqueFilename);

      await storedDir.putFile(File(file!.path));

      return await storedDir.getDownloadURL();
    } catch (e) {
      return '';
    }
  }

  void addTransaksi(Akun akun) async {
    setState(() {
      _isLoading = true;
    });
    try {
      CollectionReference transaksiCollection =
          _firestore.collection('transaksi');

      // Convert DateTime to Firestore Timestamp
      Timestamp timestamp = Timestamp.fromDate(selectedDate);

      String url = await uploadImage();

      final id = transaksiCollection.doc().id;

      await transaksiCollection.doc(id).set({
        'uid': _auth.currentUser!.uid,
        'docId': id,
        'nama': nama,
        'kategori': kategori,
        'deskripsi': deskripsi,
        'gambar': url,
        /*'nama': akun.nama,*/
        'nominal': nominal,
        'tanggal': timestamp,
      }).catchError((e) {
        throw e;
      });
      Navigator.popAndPushNamed(context, '/dashboard');
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final Akun akun = arguments['akun'];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            Text('Tambah Transaksi', style: headerStyle(level: 3, dark: false)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Form(
                  child: Container(
                    margin: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        InputLayout(
                            'Berikan Nama',
                            TextFormField(
                                onChanged: (String value) => setState(() {
                                      nama = value;
                                    }),
                                validator: notEmptyValidator,
                                decoration:
                                    customInputDecoration("Nama Transaksi"))),
                        InputLayout(
                            'Berikan Nominal',
                            TextFormField(
                                onChanged: (String value) => setState(() {
                                      nominal = value;
                                    }),
                                validator: notEmptyValidator,
                                decoration:
                                    customInputDecoration("Masukan Nominal"))),
                        InputLayout(
                          'Berikan Tanggal',
                          TextFormField(
                            onTap: () {
                              _selectDate(context);
                            },
                            readOnly: true,
                            controller: TextEditingController(
                                text:
                                    "${selectedDate.toLocal()}".split(' ')[0]),
                            decoration: customInputDecoration("Pilih Tanggal"),
                          ),
                        ),
                        /*Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: imagePreview(),
                        ),*/
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 10),
                          child: ElevatedButton(
                              onPressed: () {
                                uploadDialog(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.photo_camera),
                                  Text(' Tambah File',
                                      style: headerStyle(level: 3)),
                                ],
                              )),
                        ),
                        InputLayout(
                            'Kategori',
                            DropdownButtonFormField<String>(
                                decoration:
                                    customInputDecoration('Pilih Kategori'),
                                items: dataKategori.map((e) {
                                  return DropdownMenuItem<String>(
                                      child: Text(e), value: e);
                                }).toList(),
                                onChanged: (selected) {
                                  setState(() {
                                    kategori = selected;
                                  });
                                })),
                        InputLayout(
                            "Beri Keterangan",
                            TextFormField(
                              onChanged: (String value) => setState(() {
                                deskripsi = value;
                              }),
                              keyboardType: TextInputType.multiline,
                              minLines: 3,
                              maxLines: 5,
                              decoration: customInputDecoration(
                                  'Isikan keterangan di sini'),
                            )),
                        SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          child: FilledButton(
                              style: buttonStyle,
                              onPressed: () {
                                addTransaksi(akun);
                              },
                              child: Text(
                                'Update Transaksi',
                                style: headerStyle(level: 3, dark: false),
                              )),
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
