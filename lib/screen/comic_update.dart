import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class NewPopMovie extends StatefulWidget {
  const NewPopMovie({super.key});

  @override
  State<NewPopMovie> createState() => _NewPopMovieState();
}

class _NewPopMovieState extends State<NewPopMovie> {
  final _formKey = GlobalKey<FormState>();
  String _title = "";
  String _author = "";
  String _description = "";
  final _controllerDate = TextEditingController();
  String _img = "";

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
    final response = await http
        .post(Uri.parse("https://ubaya.xyz/flutter/160421021/newcomic.php"), body: {
      'title': _title,
      'author': _author,
      'release_at': _controllerDate.text,
      'img': _img,
      'description':_description
    });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Tambah Komik"),
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
                inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                ],
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
            ],
          ),)
        ));
  }
}
