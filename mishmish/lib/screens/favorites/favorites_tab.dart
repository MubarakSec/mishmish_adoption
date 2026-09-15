import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/kitten.dart';
import '../../widgets/kitten_image.dart';
import '../../widgets/state_views.dart';
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
        loading = false;
        error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const LoadingView(message: 'جاري تحميل المفضلة...');

    if (error != null) {
      return ErrorView(
        message: error!,
        onRetry: () {
          setState(() {
            loading = true;
            error = null;
          });
          _fetch();
        },
      );
    }

    if (favorites.isEmpty) {
      return const EmptyView(
        icon: Icons.favorite_border_rounded,
        title: 'قائمة المفضلة فارغة',
        subtitle: 'أضف قططك المفضلة من الرئيسية للرجوع إليها لاحقاً',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => loading = true);
        await _fetch();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: favorites.length,
        itemBuilder: (context, i) {
          final k = favorites[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: KittenImage(
                  networkUrl: k.imageUrlResolved,
                  assetPath: k.localAssetPath,
                  width: 70,
                  height: 70,
                  iconSize: 28,
                ),
              ),
              title: Text(k.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle:
                  Text('${k.breed} • ${k.price.toStringAsFixed(0)} ر.س'),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: AppColors.primary),
                onPressed: () async {
                  try {
                    await ApiService.toggleFavorite(k.id);
                    _fetch();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString().replaceAll('Exception: ', '')),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KittenDetailScreen(kitten: k),
                  ),
                );
                if (mounted) _fetch();
              },
            ),
          );
        },
      ),
    );
  }
}
