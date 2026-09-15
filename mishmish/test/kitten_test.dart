import 'package:flutter_test/flutter_test.dart';
import 'package:mishmish/models/kitten.dart';

void main() {
  group('Kitten.fromJson', () {
    test('parses a complete backend payload', () {
      final kitten = Kitten.fromJson({
        'id': 1,
        'name': 'مشمش',
        'breed': 'شيرازي برتقالي',
        'age': '3 شهور',
        'description': 'قط ودود',
        'price': '150.00',
        'image_url': '/images/cats/1_mishmish.jpg',
        'is_favorite': true,
      });

      expect(kitten.id, 1);
      expect(kitten.name, 'مشمش');
      expect(kitten.price, 150.0);
      expect(kitten.isFavorite, isTrue);
    });

    test('never crashes on missing or malformed fields', () {
      final kitten = Kitten.fromJson({});

      expect(kitten.id, 0);
      expect(kitten.name, '');
      expect(kitten.price, 0);
      expect(kitten.imageUrl, '');
      expect(kitten.isFavorite, isFalse);
    });

    test('handles numeric price payloads', () {
      final kitten = Kitten.fromJson({
        'id': 2,
        'name': 'توتي',
        'breed': 'شيرازي',
        'age': '4 شهور',
        'description': 'هادئة',
        'price': 200,
        'image_url': '',
      });

      expect(kitten.price, 200.0);
    });
  });

  group('Kitten image resolution', () {
    const base = Kitten(
      id: 1,
      name: 'مشمش',
      breed: 'شيرازي',
      age: '3 شهور',
      description: 'ودود',
      price: 150,
      imageUrl: '',
    );

    test('returns empty string when no image', () {
      expect(base.imageUrlResolved, '');
    });

    test('passes absolute urls through untouched', () {
      final k = base.copyWith(imageUrl: 'https://example.com/cat.jpg');
      expect(k.imageUrlResolved, 'https://example.com/cat.jpg');
    });

    test('resolves relative backend paths against server root', () {
      final k =
          base.copyWith(imageUrl: '/images/cats/1_mishmish.jpg');
      expect(k.imageUrlResolved, contains('/images/cats/1_mishmish.jpg'));
      expect(k.imageUrlResolved, startsWith('http'));
    });

    test('derives a bundled asset fallback path', () {
      final k =
          base.copyWith(imageUrl: '/images/cats/1_mishmish.jpg');
      expect(k.localAssetPath, 'assets/images/cats/1_mishmish.jpg');
    });
  });

  test('copyWith preserves unchanged fields', () {
    const kitten = Kitten(
      id: 1,
      name: 'مشمش',
      breed: 'شيرازي',
      age: '3 شهور',
      description: 'ودود',
      price: 150,
      imageUrl: '',
    );

    final updated = kitten.copyWith(isFavorite: true);

    expect(updated.isFavorite, isTrue);
    expect(updated.name, 'مشمش');
    expect(updated.id, 1);
  });
}
