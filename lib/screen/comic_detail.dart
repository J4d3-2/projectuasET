import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uas_komiku/class/komik.dart';

class DetailComic extends StatefulWidget {
  int comicID;
  DetailComic({super.key, required this.comicID});
  @override
  State<StatefulWidget> createState() {
    return _DetailComicState();
  }
}
class _DetailComicState extends State<DetailComic> {

  Komik? _pc;
  @override
  void initState() {
    super.initState();
    bacaData();
  }

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
      setState(() {});
    });
  }

  void submit() async {
    final response = await http
        .post(Uri.parse("https://ubaya.xyz/flutter/160421021/deletemovie.php"), 
        body: {'id': widget.comicID.toString()});
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses Menghapus Data')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error')));
      throw Exception('Failed to read API');
    }
  }

Widget tampilData() {
if (_pc == null) {
      return const CircularProgressIndicator();
    }
    return Card(
        elevation: 10,
        margin: const EdgeInsets.all(10),
        child: Column(children: <Widget>[
          _pc!.img!=''
                ? Image.network(_pc!.img,
                  width: 200, 
                  height: 300, 
                  fit: BoxFit.cover) 
                : Image.asset("../assets/images/missing.png",
                  width: 60.0, // Set the desired width
                  height: 200.0, // Set the desired height
                  fit: BoxFit.cover)
                ,
          Text(_pc!.title, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.purple[900])),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Text(_pc!.description, style: const TextStyle(fontSize: 15))),
            const Padding(padding: EdgeInsets.all(10), child: Text("Categories:")),
            Padding(
                padding: const EdgeInsets.all(10),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _pc?.categories?.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return Center(
                        child: Text(_pc?.categories?[index]['name']),
                      );
                    })),
        ]));
  
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Detail of Popular Movie'),
        ),
        body: ListView(children: <Widget>[
          tampilData()
        ]));
  }
}
