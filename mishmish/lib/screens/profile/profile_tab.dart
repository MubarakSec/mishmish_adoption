import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Future<Map<String, String>> _getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? 'مستخدم',
      'email': prefs.getString('user_email') ?? '',
    };
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('خروج', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    try {
      await ApiService.logout();
    } catch (_) {
      await ApiService.clearToken();
    }
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _getUser(),
      builder: (context, snap) {
        final name = snap.data?['name'] ?? '...';
        final email = snap.data?['email'] ?? '...';
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Container(
                width: 100, height: 100,
                decoration: const BoxDecoration(color: Color(0xFFFF6B6B), shape: BoxShape.circle),
                child: const Center(child: Text('🐱', style: TextStyle(fontSize: 50))),
              ),
              const SizedBox(height: 16),
              Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(email, style: const TextStyle(color: Color(0xFF636E72))),
              const SizedBox(height: 30),
              Card(
                child: Column(
                  children: [
                    ListTile(leading: const Icon(Icons.person), title: const Text('الاسم'), subtitle: Text(name)),
                    const Divider(height: 1),
                    ListTile(leading: const Icon(Icons.email), title: const Text('البريد الإلكتروني'), subtitle: Text(email)),
                    const Divider(height: 1),
                    ListTile(leading: const Icon(Icons.info_outline), title: const Text('عن التطبيق'), subtitle: const Text('مشمش v1.0.0')),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('تسجيل الخروج'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
