import 'package:flutter/material.dart';
import '../../models/kitten.dart';
import '../../services/api_service.dart';

class KittenDetailScreen extends StatefulWidget {
  final Kitten kitten;
  const KittenDetailScreen({super.key, required this.kitten});

  @override
  State<KittenDetailScreen> createState() => _KittenDetailScreenState();
}

class _KittenDetailScreenState extends State<KittenDetailScreen> {
  bool _isFavorite = false;
  bool _favLoading = false;

  Future<void> _toggleFavorite() async {
    setState(() => _favLoading = true);
    try {
      final isFav = await ApiService.toggleFavorite(widget.kitten.id);
      setState(() => _isFavorite = isFav);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isFav ? 'تمت الإضافة للمفضلة ❤️' : 'تمت الإزالة من المفضلة'),
          backgroundColor: isFav ? Colors.green : Colors.grey,
          duration: const Duration(seconds: 1),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _favLoading = false);
    }
  }

  void _adopt() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🎉 مبروك!'),
        content: Text('لقد تبنيت ${widget.kitten.name} بنجاح!\nسيتواصل معك فريقنا قريباً.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('رائع!')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.kitten;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                'https://cataas.com/cat?width=600&height=600&random=${k.id}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFFFF0F0),
                  child: const Center(
                    child: Icon(Icons.pets, size: 80, color: Color(0xFFFF6B6B)),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: _favLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? Colors.red : Colors.white),
                onPressed: _favLoading ? null : _toggleFavorite,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(k.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFFF6B6B), borderRadius: BorderRadius.circular(20)),
                        child: Text('${k.price.toStringAsFixed(0)} ر.س', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(label: Text(k.breed, style: const TextStyle(fontSize: 12)), backgroundColor: const Color(0xFFF0F0F0)),
                      const SizedBox(width: 8),
                      Chip(label: Text(k.age, style: const TextStyle(fontSize: 12)), backgroundColor: const Color(0xFFE0F7FA)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('عن القط', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(k.description, style: const TextStyle(fontSize: 15, color: Color(0xFF636E72), height: 1.6)),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _adopt,
                      icon: const Icon(Icons.pets, size: 20),
                      label: const Text('تبني الآن', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _favLoading ? null : _toggleFavorite,
                      icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: const Color(0xFFFF6B6B)),
                      label: Text(_isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Color(0xFFFF6B6B))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
