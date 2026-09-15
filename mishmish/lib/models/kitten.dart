import '../config/app_config.dart';

class Kitten {
  final int id;
  final String name;
  final String breed;
  final String age;
  final String description;
  final double price;
  final String imageUrl;
  final bool isFavorite;

  const Kitten({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  String get imageUrlResolved {
    if (imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    return '${AppConfig.serverRoot}$imageUrl';
  }

  String get localAssetPath {
    final fileName = imageUrl.split('/').last;
    return 'assets/images/cats/$fileName';
  }

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
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      breed: json['breed']?.toString() ?? '',
      age: json['age']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      imageUrl: json['image_url']?.toString() ?? '',
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,
    );
  }
}
