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
  String? error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final data = await ApiService.getFavorites();
      if (!mounted) return;
      setState(() {
        favorites = data.map((e) {
          final dynamic raw = e['kitten'] ?? e;
          final k = Kitten.fromJson(Map<String, dynamic>.from(raw as Map));
          // Items coming from /favorites are favorites by definition
          return k.copyWith(isFavorite: true);
        }).toList();
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)));

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 44, color: Color(0xFFFF6B6B)),
              const SizedBox(height: 12),
              Text(error!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF636E72))),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    loading = true;
                    error = null;
                  });
                  _fetch();
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

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
                  k.imageUrlResolved,
                  width: 70, height: 70, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    k.localAssetPath,
                    width: 70, height: 70, fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => Container(
                      width: 70,
                      height: 70,
                      color: const Color(0xFFFFF0F0),
                      child: const Center(child: Icon(Icons.pets, color: Color(0xFFFF6B6B))),
                    ),
                  ),
                ),
              ),
              title: Text(k.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${k.breed} • ${k.price.toStringAsFixed(0)} ر.س'),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Color(0xFFFF6B6B)),
                onPressed: () async {
                  try {
                    await ApiService.toggleFavorite(k.id);
                    _fetch();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString().replaceAll('Exception: ', '')),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => KittenDetailScreen(kitten: k)));
                if (mounted) _fetch();
              },
            ),
          );
        },
      ),
    );
  }
}
