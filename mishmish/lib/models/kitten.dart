class Kitten {
  final int id;
  final String name;
  final String breed;
  final String age;
  final String description;
  final double price;
  final String imageUrl;

  Kitten({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory Kitten.fromJson(Map<String, dynamic> json) {
    return Kitten(
      id: json['id'],
      name: json['name'],
      breed: json['breed'],
      age: json['age'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'],
    );
  }
}
