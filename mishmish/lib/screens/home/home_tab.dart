import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/kitten.dart';
import '../../widgets/kitten_image.dart';
import '../../widgets/state_views.dart';
import 'kitten_detail_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<Kitten> _kittens = [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  String _selectedBreed = 'الكل';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final data = await ApiService.getKittens();
      if (mounted) {
        setState(() {
          _kittens = data.map((e) => Kitten.fromJson(e)).toList();
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite(Kitten kitten) async {
    final nextState = !kitten.isFavorite;
    setState(() {
      final idx = _kittens.indexWhere((k) => k.id == kitten.id);
      if (idx != -1) {
        _kittens[idx] = _kittens[idx].copyWith(isFavorite: nextState);
      }
    });

    try {
      final isFav = await ApiService.toggleFavorite(kitten.id);
      if (mounted) {
        setState(() {
          final idx = _kittens.indexWhere((k) => k.id == kitten.id);
          if (idx != -1) {
            _kittens[idx] = _kittens[idx].copyWith(isFavorite: isFav);
          }
        });
      }
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          final idx = _kittens.indexWhere((k) => k.id == kitten.id);
          if (idx != -1) {
            _kittens[idx] = _kittens[idx].copyWith(isFavorite: !nextState);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  List<Kitten> get _filteredKittens {
    return _kittens.where((k) {
      final matchesSearch = k.name.contains(_searchQuery) ||
          k.breed.contains(_searchQuery) ||
          k.description.contains(_searchQuery);
      final matchesBreed =
          _selectedBreed == 'الكل' || k.breed.contains(_selectedBreed);
      return matchesSearch && matchesBreed;
    }).toList();
  }

  List<String> get _breeds {
    final set = {'الكل'};
    for (final k in _kittens) {
      set.add(k.breed.split(' ').first);
    }
    return set.toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingView(message: 'جاري تحميل القطط...');
    }

    if (_error != null) {
      return ErrorView(
        message: _error!,
        onRetry: () {
          setState(() {
            _loading = true;
            _error = null;
          });
          _fetch();
        },
      );
    }

    final filtered = _filteredKittens;

    return RefreshIndicator(
      onRefresh: () async {
        await _fetch();
      },
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'ابحث عن اسم أو سلالة القط...',
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Breed filter chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _breeds.length,
              itemBuilder: (context, idx) {
                final breed = _breeds[idx];
                final isSelected = _selectedBreed == breed;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(breed),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color:
                          isSelected ? Colors.white : AppColors.textLight,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    backgroundColor: const Color(0xFFF1F2F6),
                    onSelected: (selected) {
                      setState(
                          () => _selectedBreed = selected ? breed : 'الكل');
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Grid View
          Expanded(
            child: filtered.isEmpty
                ? const EmptyView(
                    icon: Icons.pets,
                    title: 'لا توجد قطط مطابقة للبحث',
                    subtitle: 'جرّب كلمة بحث مختلفة أو غيّر فلتر السلالة',
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final kitten = filtered[i];
                      return _KittenCard(
                        kitten: kitten,
                        onFavoriteToggle: () => _toggleFavorite(kitten),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    KittenDetailScreen(kitten: kitten)),
                          );
                          _fetch();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _KittenCard extends StatelessWidget {
  final Kitten kitten;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const _KittenCard({
    required this.kitten,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.lg)),
                  child: KittenImage(
                    networkUrl: kitten.imageUrlResolved,
                    assetPath: kitten.localAssetPath,
                    height: 130,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        kitten.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 18,
                        color: kitten.isFavorite
                            ? Colors.red
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kitten.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${kitten.breed} • ${kitten.age}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${kitten.price.toStringAsFixed(0)} ر.س',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
