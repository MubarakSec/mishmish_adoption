class Kitten {
  final int id;
  final String name;
  final String breed;
  final String age;
  final String description;
  final double price;
  final String imageUrl;
  final bool isFavorite;

  Kitten({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Kitten copyWith({
    int? id,
    String? name,
    String? breed,
    String? age,
    String? description,
    double? price,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return Kitten(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Kitten.fromJson(Map<String, dynamic> json) {
    return Kitten(
      id: json['id'],
      name: json['name'],
      breed: json['breed'],
      age: json['age'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'] ?? '',
      isFavorite: json['is_favorite'] == true,
    );
  }
}
