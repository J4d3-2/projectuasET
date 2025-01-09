import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:uas_komiku/class/komik.dart';
import 'package:uas_komiku/screen/comic_detail.dart';

class ComicList extends StatefulWidget {
  final int? categoryId; // Tambahkan filter kategori (opsional)

  const ComicList({super.key, this.categoryId});

  @override
  State<ComicList> createState() => _ComicListState();
}

class _ComicListState extends State<ComicList> {
  String searchQuery = '';
  List<Komik> comics = [];
  bool isLoading = true;
  String errorMessage = '';

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse("https://ubaya.xyz/flutter/160421021/uas/comiclist.php"),
        body: {
          'cari': searchQuery,
          if (widget.categoryId != null)
            'genre_id': widget.categoryId.toString(),
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'success') {
          setState(() {
            comics = (data['data'] as List)
                .map((json) => Komik.fromJson(json))
                .toList();
          });
        } else {
          setState(() {
            errorMessage = 'Tidak ada data komik.';
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

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Widget buildComicCard(Komik comic) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: comic.img.isNotEmpty
            ? Image.network(
                comic.img,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.image_not_supported),
        title: Text(
          comic.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          comic.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(Icons.arrow_forward, color: Colors.purple[900],),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailComic(comicID: comic.id),
            ),
          ).then((refresh) {
            if (refresh == true) {
              fetchData();
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cari Komik - Baca Komik Disini',
        style: GoogleFonts.arvo(color: Colors.deepPurple)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cari komik...',
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (value) {
                setState(() {
                  searchQuery = value;
                  isLoading = true;
                });
                fetchData();
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : ListView.builder(
                        itemCount: comics.length,
                        itemBuilder: (context, index) =>
                            buildComicCard(comics[index]),
                      ),
          ),
        ],
      ),
    );
  }
}
