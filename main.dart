import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DataEntryScreen(),
    );
  }
}

class DataEntryScreen extends StatefulWidget {
  @override
  _DataEntryScreenState createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  TextEditingController npmController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController tempatLahirController = TextEditingController();
  TextEditingController tanggalLahirController = TextEditingController();
  String agama = 'Islam';
  String jenisKelamin = 'Pria';
  File? imageFile;

  Future<void> sendData() async {
    final uri = Uri.parse('https://mahasiswaweb.000webhostapp.com/form_mahasiswa/save_data.php');
    var request = http.MultipartRequest('POST', uri)
      ..fields['npm'] = npmController.text
      ..fields['nama'] = namaController.text
      ..fields['tempat_lahir'] = tempatLahirController.text
      ..fields['tanggal_lahir'] = tanggalLahirController.text
      ..fields['agama'] = agama
      ..fields['jenis_kelamin'] = jenisKelamin
      ..files.add(await http.MultipartFile.fromPath('foto', imageFile!.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      print("Upload successful");

      // Tampilkan pesan di layar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data berhasil disimpan'),
        ),
      );

      // Kosongkan semua elemen
      npmController.clear();
      namaController.clear();
      tempatLahirController.clear();
      tanggalLahirController.clear();
      setState(() {
        agama = 'Islam';
        jenisKelamin = 'Pria';
        imageFile = null;
      });
    } else {
      print("Upload failed");

      // Tampilkan pesan di layar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data gagal disimpan'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Entri Data Mahasiswa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: npmController,
              decoration: InputDecoration(labelText: 'NPM'),
            ),
            TextField(
              controller: namaController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: tempatLahirController,
              decoration: InputDecoration(labelText: 'Tempat Lahir'),
            ),
            TextField(
              controller: tanggalLahirController,
              decoration: InputDecoration(labelText: 'Tanggal Lahir'),
            ),
            DropdownButtonFormField<String>(
              value: agama,
              items: ['Islam', 'Kristen', 'Hindu', 'Budha']
                  .map((e) => DropdownMenuItem(child: Text(e), value: e))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  agama = value!;
                });
              },
              decoration: InputDecoration(labelText: 'Agama'),
            ),
            DropdownButtonFormField<String>(
              value: jenisKelamin,
              items: ['Pria', 'Wanita']
                  .map((e) => DropdownMenuItem(child: Text(e), value: e))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  jenisKelamin = value!;
                });
              },
              decoration: InputDecoration(labelText: 'Jenis Kelamin'),
            ),
            imageFile == null
                ? Text("Belum ada foto")
                : Image.file(
                    imageFile!,
                    width: 300,
                    height: 300,
                  ),
            ElevatedButton(
              onPressed: () async {
                final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    imageFile = File(pickedFile.path);
                  });
                }
              },
              child: Text('Pilih Foto dari Galeri'),
            ),
            ElevatedButton(
              onPressed: () {
                sendData();
              },
              child: Text('Simpan'),
            ),
            ElevatedButton(
              onPressed: () {
                // Batalkan entri data
              },
              child: Text('Batal'),
            ),
          ],
        ),
      ),
    );
  }
}
