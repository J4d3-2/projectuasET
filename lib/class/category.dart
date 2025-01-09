class Genre {
  final int id;
  final String name;
  Genre({required this.id, required this.name});
  // Factory constructor untuk membuat instance dari JSON
  factory Genre.fromJSON(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? 'Unknown Genre',
    );
  }

  // Metode untuk mengonversi instance ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
