import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/kitten.dart';
import '../home/kitten_detail_screen.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  List<Kitten> favorites = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final data = await ApiService.getFavorites();
      setState(() {
        favorites = data.map((e) {
          final k = e['kitten'] ?? e;
          return Kitten.fromJson(k);
        }).toList();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)));

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_border_rounded, size: 40, color: Color(0xFFFF6B6B)),
            ),
            const SizedBox(height: 16),
            const Text('قائمة المفضلة فارغة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('أضف قططك المفضلة من الرئيسية للرجوع إليها لاحقاً', style: TextStyle(color: Color(0xFF636E72))),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async { setState(() => loading = true); await _fetch(); },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: favorites.length,
        itemBuilder: (context, i) {
          final k = favorites[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://cataas.com/cat?width=100&height=100&random=${k.id}',
                  width: 70, height: 70, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 70,
                    height: 70,
                    color: const Color(0xFFFFF0F0),
                    child: const Center(child: Icon(Icons.pets, color: Color(0xFFFF6B6B))),
                  ),
                ),
              ),
              title: Text(k.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${k.breed} • ${k.price.toStringAsFixed(0)} ر.س'),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Color(0xFFFF6B6B)),
                onPressed: () async {
                  await ApiService.toggleFavorite(k.id);
                  _fetch();
                },
              ),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => KittenDetailScreen(kitten: k))),
            ),
          );
        },
      ),
    );
  }
}
