import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:uas_komiku/class/category.dart'; // Pastikan ini adalah path untuk model Genre
import 'comic_list.dart';

class CategoryList extends StatefulWidget {
  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  List<Genre> categories = []; // Menggunakan model Genre
  bool isLoading = true; // Indikator loading
  String errorMessage = ''; // Pesan error jika API gagal

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://ubaya.xyz/flutter/160421021/uas/categorylist.php'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'success') {
          setState(() {
            categories = (data['data'] as List)
                .map((json) => Genre.fromJSON(json))
                .toList(); // Memproses data ke dalam model Genre
          });
        } else {
          setState(() {
            errorMessage = 'Gagal memuat kategori.';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kategori Komik',
        style: GoogleFonts.arvo(color: Colors.deepPurple)),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Indikator loading
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage)) // Pesan error
              : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey, width: 1), // Bottom border
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          category.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ComicList(
                                categoryId: category.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
