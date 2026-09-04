import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {'emoji': '🐱', 'title': 'مشمش', 'subtitle': 'اعثر على قطتك المفضلة واعتنقها بحب'},
    {'emoji': '❤️', 'title': 'تصفح واحفظ', 'subtitle': 'تصفح مجموعتنا من القطط اللطيفة واحفظ المفضلة لديك'},
    {'emoji': '🏠', 'title': 'مرحباً بك!', 'subtitle': 'ابدأ رحلتك في عالم القطط الآن'},
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(page['emoji']!, style: const TextStyle(fontSize: 100)),
                        const SizedBox(height: 30),
                        Text(page['title']!, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        Text(page['subtitle']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Color(0xFF636E72))),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? const Color(0xFFFF6B6B) : const Color(0xFFDDD),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                  } else {
                    _completeOnboarding();
                  }
                },
                child: Text(_currentPage < _pages.length - 1 ? 'التالي' : 'ابدأ الآن'),
              ),
            ),
            const SizedBox(height: 20),
            if (_currentPage < _pages.length - 1)
              TextButton(
                onPressed: _completeOnboarding,
                child: const Text('تخطي', style: TextStyle(color: Color(0xFF636E72))),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
