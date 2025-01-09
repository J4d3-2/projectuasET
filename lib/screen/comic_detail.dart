import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uas_komiku/class/komik.dart';
import 'package:uas_komiku/screen/comic_update.dart';

class DetailComic extends StatefulWidget {
  final int comicID;
  const DetailComic({super.key, required this.comicID});

  @override
  State<DetailComic> createState() => _DetailComicState();
}

class _DetailComicState extends State<DetailComic> {
  Komik? comic; // Objek komik
  bool isLoading = true; // Indikator loading
  String errorMessage = ''; // Pesan error

  @override
  void initState() {
    super.initState();
    fetchComicData();
  }

  Future<void> fetchComicData() async {
    try {
      final response = await http.post(
        Uri.parse("https://ubaya.xyz/flutter/160421021/uas/detailcomic.php"),
        body: {'id': widget.comicID.toString()},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'success') {
          setState(() {
            comic = Komik.fromJson(data['data']);
          });
        } else {
          setState(() {
            errorMessage = 'Gagal memuat data komik.';
          });
        }
      } else {
        setState(() {
          errorMessage =
              'Error ${response.statusCode}: Tidak dapat menghubungi server.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Kesalahan koneksi: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildCategories() {
    if (comic?.categories == null || comic!.categories!.isEmpty) {
      return const Text('Tidak ada kategori');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kategori:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: comic!.categories!
              .map((category) => Chip(label: Text(category['name'])))
              .toList(),
        ),
      ],
    );
  }

  Widget buildDetailCard() {
    if (comic == null) {
      return const Center(child: Text('Tidak ada data.'));
    }
    return Card(
      elevation: 10,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            comic!.img.isNotEmpty
                ? Image.network(
                    comic!.img,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image_not_supported, size: 100),
            const SizedBox(height: 16),
            Text(
              comic!.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Penulis: ${comic!.author}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Deskripsi:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(comic!.description),
            const SizedBox(height: 16),
            buildCategories(),
            Padding(
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                child: Text('Edit'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditComic(comicID: widget.comicID),
                    ),
                  );
                },
              )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Komik'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Indikator loading
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage)) // Pesan error
              : ListView(
                  children: [
                    buildDetailCard(),
                  ],
                ),
    );
  }
}
