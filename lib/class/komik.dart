class Komik {
  int id;
  String title;
  String author;
  double rating;
  String releaseAt;
  String img;
  String description;
  List? categories;
  List? pages;
  List? reacts;

  Komik({
    required this.id,
    required this.title,
    required this.author,
    required this.rating,
    required this.releaseAt,
    required this.img,
    required this.description,
    this.categories,
    this.pages,
    this.reacts,
  });

  factory Komik.fromJson(Map<String, dynamic> json) {
    return Komik(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? 'Unknown Title',
      author: json['author'] ?? 'Unknown Author',
      rating: json['rating'] == null ? 0.0 // Provide a default value when `rating` is null
        : (json['rating'] is int 
        ? json['rating'].toDouble() // Convert int to double directly
        : double.tryParse(json['rating'].toString()) ?? 0.0),
      releaseAt: json['released_at'] ?? 'Unknown Release Date',
      img: json['img'] ?? '',
      description: json['description'] ?? 'No Description',
      categories: json['categories'] ,
      pages: json['pages'],
      reacts: json['reacts'],
    );
  }
}

List<Komik> PCs = [];
