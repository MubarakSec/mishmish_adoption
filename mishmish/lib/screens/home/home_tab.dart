import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/kitten.dart';
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

  @override
  void initState() {
    super.initState();
    _fetch();
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
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<Kitten> get _filteredKittens {
    return _kittens.where((k) {
      final matchesSearch = k.name.contains(_searchQuery) ||
          k.breed.contains(_searchQuery) ||
          k.description.contains(_searchQuery);
      final matchesBreed = _selectedBreed == 'الكل' || k.breed.contains(_selectedBreed);
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
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF0F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wifi_off_rounded, size: 36, color: Color(0xFFFF6B6B)),
              ),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Color(0xFF636E72))),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() { _loading = true; _error = null; });
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
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'ابحث عن اسم أو سلالة القط...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFF6B6B)),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
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
                    selectedColor: const Color(0xFFFF6B6B),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF636E72),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    backgroundColor: const Color(0xFFF1F2F6),
                    onSelected: (selected) {
                      setState(() => _selectedBreed = selected ? breed : 'الكل');
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
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF0F0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.pets, size: 36, color: Color(0xFFFF6B6B)),
                        ),
                        const SizedBox(height: 16),
                        const Text('لا توجد قطط مطابقة للبحث', style: TextStyle(fontSize: 16, color: Color(0xFF636E72))),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            MaterialPageRoute(builder: (_) => KittenDetailScreen(kitten: kitten)),
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
    final imageUri = kitten.imageUrl.isNotEmpty ? kitten.imageUrl : 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=600';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    imageUri,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 130,
                      color: const Color(0xFFFFF0F0),
                      child: const Center(
                        child: Icon(Icons.pets, size: 44, color: Color(0xFFFF6B6B)),
                      ),
                    ),
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
                        kitten.isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: kitten.isFavorite ? Colors.red : const Color(0xFFFF6B6B),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${kitten.breed} • ${kitten.age}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF636E72)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${kitten.price.toStringAsFixed(0)} ر.س',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6B6B)),
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
