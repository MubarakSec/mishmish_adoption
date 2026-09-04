import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'verify_code_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;

  Future<void> _send() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل البريد الإلكتروني'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await ApiService.forgotPassword(_emailController.text);
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => VerifyCodeScreen(email: _emailController.text, code: result['code']),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نسيت كلمة المرور')),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📧', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 20),
            const Text('أدخل بريدك الإلكتروني', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('سنرسل لك رمز التحقق', style: TextStyle(color: Color(0xFF636E72))),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(hintText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _send,
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('إرسال الرمز'),
            ),
          ],
        ),
      ),
    );
  }
}
