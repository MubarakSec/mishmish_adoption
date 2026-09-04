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
  List<Kitten> kittens = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final data = await ApiService.getKittens();
      setState(() {
        kittens = data.map((e) => Kitten.fromJson(e)).toList();
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)));
    if (error != null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(error!), const SizedBox(height: 10), ElevatedButton(onPressed: () { setState(() { loading = true; error = null; }); _fetch(); }, child: const Text('حاول مرة أخرى'))]));
    if (kittens.isEmpty) return const Center(child: Text('لا توجد قطط حالياً'));

    return RefreshIndicator(
      onRefresh: () async { setState(() => loading = true); await _fetch(); },
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
        itemCount: kittens.length,
        itemBuilder: (context, i) => _KittenCard(kitten: kittens[i]),
      ),
    );
  }
}

class _KittenCard extends StatelessWidget {
  final Kitten kitten;
  const _KittenCard({required this.kitten});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => KittenDetailScreen(kitten: kitten))),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                'https://cataas.com/cat?width=300&height=300&random=${kitten.id}',
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 130, color: const Color(0xFFFFE0E0), child: const Center(child: Text('🐱', style: TextStyle(fontSize: 50)))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(kitten.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${kitten.breed} • ${kitten.age}', style: const TextStyle(fontSize: 11, color: Color(0xFF636E72)), maxLines: 1),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('${kitten.price.toStringAsFixed(0)} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6B6B))),
                      const Spacer(),
                      const Icon(Icons.favorite_border, size: 18, color: Color(0xFFFF6B6B)),
                    ],
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
