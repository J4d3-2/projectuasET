import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:uas_komiku/class/komik.dart';
import 'package:uas_komiku/class/category.dart';


class EditComic extends StatefulWidget {
  int comicID;
  EditComic({super.key, required this.comicID});

  @override
  EditComicState createState() {
    return EditComicState();
  }
}

class EditComicState extends State<EditComic> {
  final _formKey = GlobalKey<FormState>();

  Komik? _pc;
  TextEditingController _titleCont = TextEditingController();
  TextEditingController _authorCont= TextEditingController();
  TextEditingController _releaseDate = TextEditingController();
  TextEditingController _descCont = TextEditingController();
  TextEditingController _imgCont = TextEditingController();

  Widget comboGenre = Text('Edit Kategori');

  Uint8List? _imageBytes;


  Future<String> fetchData() async {
    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160421021/uas/detailcomic.php"),
      body: {'id': widget.comicID.toString()});
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
      _titleCont.text = _pc!.title;
      _authorCont.text = _pc!.author;
      _releaseDate.text = _pc!.releaseAt;
      _descCont.text = _pc!.description;
      _imgCont.text=_pc!.img;

      generateComboGenre();
    });
    });
  }

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

  void submit() async {
    final response = await http.post(
      Uri.parse("https://ubaya.xyz/flutter/160421021/uas/updatecomic.php"),
      body: {
      'title': _pc!.title,
      'author': _pc!.author,
      'release_date': _pc!.releaseAt,          
      'description':_pc!.description.toString(),
      'img':_imgCont.text,
      'comic_id': widget.comicID.toString()
      });
      if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
            if (!mounted) return;
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sukses mengubah Data')));
      }
      } else {
        throw Exception('Failed to read API');
      }
  }

  Future<List> daftarGenre() async {
    Map json;
    final response = await http.post(
    Uri.parse("https://ubaya.xyz/flutter/160421021/uas/dropdowncategorylist.php"),
      body: {'comic_id': widget.comicID.toString()});
    
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
      body: {'genre_id': genre_id.toString(), 'comic_id': widget.comicID.toString()
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
      body: {'genre_id': genre_id.toString(), 'comic_id': widget.comicID.toString()
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
      hint: const Text("Edit Kategori"),
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
      Uri.parse("https://ubaya.xyz/flutter/160421021/uas/uploadcomicpages.php"),
      body: {
        'comic_id': widget.comicID.toString(),
        'image': base64Image,
      },
    );
    if (response.statusCode == 200) {
    Map json = jsonDecode(response.body);
    if (json['result'] == 'success') {
          if (!mounted) return;
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Sukses mengupload Page')));
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
      Uri.parse("https://ubaya.xyz/flutter/160421021/uas/deletecomicpages.php"),
      body: {'filepath': filepath.toString()
    });
    if (response.statusCode == 200) {
    print(response.body);
    Map json = jsonDecode(response.body);
    if (json['result'] == 'success') {
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Sukses menghapus Page')));
      setState(() {
        bacaData();
      });
    }
    } else {
      throw Exception('Failed to read API');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bacaData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Edit Komik"),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
            children: <Widget>[
              Text(widget.comicID.toString()),
              Padding(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  decoration: const InputDecoration(
                  labelText: 'Title',
                  ),
                  onChanged: (value) {
                      _pc!.title = value;
                  },
                  controller: _titleCont,
                  validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'judul harus diisi';
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
                  _pc!.author = value;
                  },
                  controller: _authorCont,
              )),
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                  Expanded(
                    child: TextFormField(
                    decoration: const InputDecoration(
                    labelText: 'Release Date',
                    ),
                    readOnly: true,
                    controller: _releaseDate,
                  )),
                  ElevatedButton(
                    onPressed: () {
                      showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2200))
                        .then((value) {
                      setState(() {
                        _releaseDate.text =
                          value.toString().substring(0, 10);
                        _pc!.releaseAt=_releaseDate.text;
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
                labelText: 'Description',
                ),
                onChanged: (value) {
                  _pc!.description = value;
                  },
                controller: _descCont,
                validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Description harus diisi';
                }
                return null;
                },
              )),
              Padding(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                decoration: const InputDecoration(labelText: 'URL Poster',),
                              onChanged: (value) {
                                validateImage(value).then((v) {
                                  if(v) 
                                  {
                                    setState(() {
                                    });
                                  }
                                  else{
                                    setState(() {
                                      _imgCont.text = "";
                                    });
                                  }
                                }
                                );
                              },
                              controller: _imgCont,
                validator: (value) {
                        if (value == null || !Uri.parse(value).isAbsolute) {
                          return 'alamat url salah';
                        }
                        return null;
                    },
              )),
              if(_imgCont.text!='') Image.network(_imgCont.text),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                onPressed: () {
                  var state = _formKey.currentState;
                  if (state == null || !state.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Harap Isian diperbaiki')));
                  } else {
                  submit();
                  }
                },
                child: Text('Submit'),
                ),
              ),
              Padding(padding: EdgeInsets.all(10), child: Text('Kategori:')),
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
                        Text(_pc!.categories![index]['name']),
                         ElevatedButton(
                        onPressed: () {
                          deleteGenre(_pc!.categories![index]['id']);
                        },
                        child: Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                          size: 24.0,
                        ))
                          ],
                    );
              })),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: comboGenre),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text("Pages")),
                if(_pc != null)
              Padding(
                padding: const EdgeInsets.all(10),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _pc!.pages?.length ?? 0,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.network("https://ubaya.xyz/flutter/160421021/uas/"+_pc?.pages?[index]),
                        ElevatedButton(
                          onPressed: () {
                            deleteScene64(_pc!.pages?[index]);
                          },
                        child: Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                          size: 24.0,
                        ))
                          ],
                    );
                    })),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                  onPressed: () {
                    _showPicker(context);
                  },
                  child: const Text('Pick Pages'),
                  ),
                ),
                if(_imageBytes!=null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Image.memory(_imageBytes!)),
                if(_imageBytes!=null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(child: const Text("Upload"),
                    onPressed: () => uploadScene64())),
            ],
          ),
          ),
        ));
  }
}



