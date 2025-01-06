import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uas_komiku/class/komik.dart';

class ComicList extends StatefulWidget {
  const ComicList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ComicListState();
  }
}

class _ComicListState extends State<ComicList> {
  String _txtcari = '';

  String _temp = 'waiting API respond…';

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse("https://ubaya.xyz/flutter/160421021/uas/comiclist.php"),
        body: {'cari': _txtcari});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  bacaData() {
    Future<String> data = fetchData();
    data.then((value) {
      Map json = jsonDecode(value);
      if (json['result'] == 'success') {
        for (var komik in json['data']) {
          Komik kom = Komik.fromJson(komik);
          PCs.add(kom);
        }
      } else {
        PCs.clear();
      }
      setState(() {});
    });
  }

  void refreshMovie() {
    // Clear the movie list and fetch the data again
    PCs.clear();
    bacaData();
  }

  Widget DaftarComicList(Comics) {
    if (Comics != null) {
      return ListView.builder(
          itemCount: Comics.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return Card(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Comics[index].img != ''
                    ? Image.network(Comics[index].img)
                    : Image.asset("../assets/images/missing.png"),
                ListTile(
                  leading: const Icon(Icons.book, size: 30),
                  title: Text(
                    PCs[index].title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  subtitle: Text(Comics[index].description),
                  // trailing: IconButton(
                  //   icon: const Icon(Icons.arrow_forward, color: Colors.blue),
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) =>
                  //             DetailKomik(movieID: PCs[index].id),
                  //       ),
                  //     ).then((refresh) {
                  //       if (refresh == true) {
                  //         refreshMovie();
                  //       }
                  //     });
                  //   },
                  // ),
                ),
              ],
            ));
          });
    } else {
      return const CircularProgressIndicator();
    }
  }

  @override
  void initState() {
    super.initState();
    bacaData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Komik')),
        body: ListView(children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.search),
              labelText: 'Judul mengandung kata:',
            ),
            onFieldSubmitted: (value) {
              _txtcari = value;
              PCs.clear();
              bacaData();
            },
          ),
          Container(
              height: MediaQuery.of(context).size.height - 100,
              child: PCs.length > 0
                  ? DaftarComicList(PCs)
                  : Text('tidak ada data'))
        ]));
  }
}
