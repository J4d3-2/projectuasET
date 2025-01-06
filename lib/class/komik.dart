
import 'package:uas_komiku/screen/comic_list.dart';

class Komik {
  int id;
  String title;
  String author;
  String release_at;
  String img;
  String description;
  List? category;

  Komik(
      {required this.id,
      required this.title,
      required this.author,
      required this.release_at,
      required this.img,
      required this.description,
      this.category});

  factory Komik.fromJson(Map<String, dynamic> json) {
    return Komik(
        id: json['movie_id'] as int,
        title: json['title'] as String,
        author: json['author'] as String,
        release_at: json['release_at'] as String,
        img: json['img'] != null ? json['img'].toString() : '',
        description: json['description'] as String,
        category: json['category']);
  }
}

List<Komik> PCs = [];