import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:uas_komiku/class/komik.dart';
import 'package:uas_komiku/main.dart';
import 'package:uas_komiku/screen/comic_update.dart';

class DetailComic extends StatefulWidget {
  final int comicID;
  const DetailComic({super.key, required this.comicID});

  @override
  State<DetailComic> createState() => _DetailComicState();
}

class _DetailComicState extends State<DetailComic> {
  final _formKey = GlobalKey<FormState>();
  Komik? comic; // Objek komik
  bool isLoading = true; // Indikator loading
  String errorMessage = ''; // Pesan error
  String _comment = '';
  int _rating = 0;
  

  @override
  void initState() {
    super.initState();
    fetchComicData();
  }

  Future<void> fetchComicData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

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

  void postComment() async {
    final response = await http
        .post(Uri.parse("https://ubaya.xyz/flutter/160421021/uas/addreact.php"), body: {
      'comic_id': widget.comicID.toString(),
      'user_id': active_user,
      'rating': _rating.toString(),
      'komentar': _comment,
    });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
          fetchComicData();
        };
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses Memberi Reaksi')));
      } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error')));
      throw Exception('Failed to read API');
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        Card(
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
                        width: 200,
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
                Text('Rating: ${comic!.rating}',
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
        ),
        if(comic != null)
          Padding(
            padding: const EdgeInsets.all(10),
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: comic!.pages?.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return Image.network("https://ubaya.xyz/flutter/160421021/uas/"+comic?.pages?[index]);
                })),
        Card(
          elevation: 10,
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Berikan Rating',
                ),
                inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                ],
                onChanged: (value) {
                  _rating = int.tryParse(value) ?? 0;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Rating harus diisi';
                  }
                  return null;
                },
              )),
                Padding(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                decoration: const InputDecoration(
                labelText: 'Berikan Komentar',
                ),
                onChanged: (value) {
                  _comment = value;
                  },
                validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Komentar harus diisi';
                }
                return null;
                },
              )),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                  if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Harap Komentar diperbaiki')));
                  } else{
                    postComment();
                  }
                  },
                  child: Text('Post'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: comic!.reacts?.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return ListTile(
                        title: Text(
                          "${comic!.reacts?[index]['user_name']} - ${comic!.reacts?[index]['rating']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(comic!.reacts?[index]['comment']),
                      );
                    })),
              ]
            ),
          ),
        ),
      ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Komik', 
        style: GoogleFonts.arvo(color: Colors.deepPurple),),
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
