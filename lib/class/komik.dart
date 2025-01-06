class Komik {
  final int id;
  final String title;
  final String author;
  final String releaseAt;
  final String img;
  final String description;

  Komik({
    required this.id,
    required this.title,
    required this.author,
    required this.releaseAt,
    required this.img,
    required this.description,
  });

  factory Komik.fromJson(Map<String, dynamic> json) {
    return Komik(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? 'Unknown Title',
      author: json['author'] ?? 'Unknown Author',
      releaseAt: json['released_at'] ?? 'Unknown Release Date',
      img: json['img'] ?? '',
      description: json['description'] ?? 'No Description',
    );
  }
}

List<Komik> PCs = [];
