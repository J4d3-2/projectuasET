class Komik {
  int id;
  String title;
  String author;
  String releaseAt;
  String img;
  String description;
  List? categories;
  List? pages;

  Komik({
    required this.id,
    required this.title,
    required this.author,
    required this.releaseAt,
    required this.img,
    required this.description,
    this.categories,
    this.pages,
  });

  factory Komik.fromJson(Map<String, dynamic> json) {
    return Komik(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? 'Unknown Title',
      author: json['author'] ?? 'Unknown Author',
      releaseAt: json['released_at'] ?? 'Unknown Release Date',
      img: json['img'] ?? '',
      description: json['description'] ?? 'No Description',
      categories: json['categories'],
      pages: json['pages'],
    );
  }
}

List<Komik> PCs = [];
