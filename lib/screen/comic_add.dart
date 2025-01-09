import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:uas_komiku/class/category.dart';
import 'package:uas_komiku/class/komik.dart';

class NewComic extends StatefulWidget {
  const NewComic({super.key});

  @override
  State<NewComic> createState() => _NewComicState();
}

class _NewComicState extends State<NewComic> {
  final _formKey = GlobalKey<FormState>();
  String _title = "";
  String _author = "";
  String _description = "";
  final _controllerDate = TextEditingController();
  String _img = "";
  int comicID = 0;
  bool _isSubmitted = false;

  Komik? _pc;

  Widget comboGenre = Text('Tambah Kategori');

  Uint8List? _imageBytes;

  Future<bool> validateImage(String imageUrl) async {
    http.Response res;
    try {
      res = await http.get(Uri.parse(imageUrl));
    } catch (e) {
      return false;
    }
    if (res.statusCode != 200) return false;
    Map<String, dynamic> data = res.headers;
    if (data['content-type'] == 'image/jpeg' || 
    data['content-type'] == 'image/png' || 
    data['content-type'] == 'image/gif') {
      return true;
    }
    return false;
  }

  Future<String> fetchData() async {
    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160421021/uas/detailcomic.php"),
      body: {'id': comicID.toString()});
    if (response.statusCode == 200) {
    return response.body;
    } else {
    throw Exception('Failed to read API');
    }
  }

  bacaData() {
    fetchData().then((value) {
    Map json = jsonDecode(value);
    _pc = Komik.fromJson(json['data']);
    setState(() {
      generateComboGenre();
      if(!_isSubmitted){
        _isSubmitted = true;
      }
    });
    });
  }

  void submit() async {
    final response = await http
        .post(Uri.parse("https://ubaya.xyz/flutter/160421021/uas/newcomic.php"), body: {
      'title': _title,
      'author': _author,
      'release_at': _controllerDate.text,
      'img': _img,
      'description':_description
    });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        setState(() {
          comicID = json['id'];
          bacaData();
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses Menambah Data')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error')));
      throw Exception('Failed to read API');
    }
  }

   Future<List> daftarGenre() async {
    Map json;
    final response = await http.post(
    Uri.parse("https://ubaya.xyz/flutter/160421021/uas/dropdowncategorylist.php"),
      body: {'comic_id': comicID.toString()});
    
    if (response.statusCode == 200) {
    print(response.body);
    json = jsonDecode(response.body);
    return json['data'];
    } else {
    throw Exception('Failed to read API');
    }
  }

  void addGenre(genre_id) async {
    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160421021/uas/addcomiccategory.php"),
      body: {'genre_id': genre_id.toString(), 'comic_id': comicID.toString()
    });
    if (response.statusCode == 200) {
    print(response.body);
    Map json = jsonDecode(response.body);
    if (json['result'] == 'success') {
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Sukses menambah Kategori')));
      setState(() {
      bacaData();
      });
    }
    } else {
      throw Exception('Failed to read API');
    }
 }

  void deleteGenre(genre_id) async {
    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160421021/uas/deletecomiccategory.php"),
      body: {'genre_id': genre_id.toString(), 'comic_id': comicID.toString()
    });
    if (response.statusCode == 200) {
    print(response.body);
    Map json = jsonDecode(response.body);
    if (json['result'] == 'success') {
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Sukses menghapus Kategori')));
      setState(() {
      bacaData();
      });
    }
    } else {
      throw Exception('Failed to read API');
    }
 }
 
  void generateComboGenre() {
    List<Genre> genres;
    var data = daftarGenre();
    data.then((value) {
    genres = List<Genre>.from(value.map((i) {
      return Genre.fromJSON(i);}));
      setState(() {
      comboGenre = DropdownButton(
      dropdownColor: Colors.grey[100],
      hint: const Text("Tambah Kategori"),
      isDense: false,
      items: genres.map((gen) {
        return DropdownMenuItem(
        value: gen.id,
        child: Column(children: <Widget>[
          Text(gen.name, overflow: TextOverflow.visible),
        ]),
        );
      }).toList(),
      onChanged: (value) {
        addGenre(value);
      });
    }); 
      });
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
      return SafeArea(
        child: Container(
        color: Colors.white,
        child: Wrap(
          children: <Widget>[
          ListTile(
            tileColor: Colors.white,
            leading: const Icon(Icons.photo_library),
            title: const Text('Galeri'),
            onTap: () {
              imgGaleri();
              Navigator.of(context).pop();
            }),
            ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Kamera'),
            onTap: () {
              imgKamera();
              Navigator.of(context).pop();
            },
          ),
          ],
        ),
        ),
      );
      });
  }

  imgGaleri() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxHeight: 600,
      maxWidth: 600);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
  }

  imgKamera() async {
    final picker = ImagePicker();
    final image =
      await picker.pickImage( 
      source: ImageSource.camera, 
      imageQuality: 20);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
  }

  void uploadScene64() async {
    String base64Image = base64Encode(_imageBytes!);
    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160421021/uploadscene64.php"),
      body: {
        'comic_id': comicID.toString(),
        'image': base64Image,
      },
    );
    if (response.statusCode == 200) {
    Map json = jsonDecode(response.body);
    if (json['result'] == 'success') {
          if (!mounted) return;
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Sukses mengupload Scene')));
        setState(() {
          _imageBytes = null;
          bacaData();
        });
    }
    } else {
    throw Exception('Failed to read API');
    }
  }

  void deleteScene64(filepath) async {
    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160421021/deletescene64.php"),
      body: {'filepath': filepath.toString()
    });
    if (response.statusCode == 200) {
    print(response.body);
    Map json = jsonDecode(response.body);
    if (json['result'] == 'success') {
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Sukses menghapus scene')));
      setState(() {
        bacaData();
      });
    }
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Cari Komik - Baca Komik Disini',
          style: GoogleFonts.arvo(color: Colors.deepPurple)),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                onChanged: (value) {
                  _title = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul harus diisi';
                  }
                  return null;
                },
              )),
              Padding(
                padding: EdgeInsets.all(10), 
                child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Author',
                ),
                onChanged: (value) {
                  _author = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul harus diisi';
                  }
                  return null;
                },
              )),
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment:MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Release Date',
                      ),
                      readOnly: true,
                      controller: _controllerDate,
                    )),
                    ElevatedButton(
                      onPressed: () {
                        showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2200)).then((value) {
                              setState(() {
                                _controllerDate.text =
                                  value.toString().substring(0, 10);
                              });
                          });
                      },
                      child: Icon(
                        Icons.calendar_today_sharp,
                        color: Colors.blue,
                          size: 24.0,
                      ))
                  ],
              )),
              Padding(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                ),
                onChanged: (value) {
                  _description = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi harus diisi';
                  }
                  return null;
                },
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: 6,
              )),
              Padding(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'URL Poster',
                ),
                onChanged: (value) {
                  validateImage(value).then((v) {
                    if(v) 
                    {
                      setState(() {
                        _img = value;
                      });
                    }
                    else{
                      setState(() {
                        _img = "";
                      });
                    }
                  }
                  );
                },
                validator: (value) {
                  if (value == null || !Uri.parse(value).isAbsolute) {
                    return 'url poster salah';
                  }
                  return null;
                },
              )),
              if(_img != '') Image.network(_img),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                  if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Harap Isian diperbaiki')));
                  } else{
                    submit();
                  }
                  },
                  child: Text('Submit'),
                ),
              ),
              if (_isSubmitted)
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('Kategori:'),
                ),
              if(_pc != null)
                Padding(
                padding: EdgeInsets.all(10),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _pc!.categories!.length ?? 0,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_pc!.categories![index]['genre_name']),
                         ElevatedButton(
                        onPressed: () {
                          deleteGenre(_pc!.categories![index]['genre_id']);
                        },
                        child: Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                          size: 24.0,
                        ))
                          ],
                    );
              })),
            ],
          ),)
        ));
  }
}
