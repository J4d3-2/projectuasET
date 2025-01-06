class Genre {
  int category_id;
  String category_name;
  Genre({
    required this.category_id, 
    required this.category_name
    });

  factory Genre.fromJSON(Map<String, dynamic> json) {
    return Genre(
      category_id: json["value"],
      category_name: json["label"],
    );
  }
}
