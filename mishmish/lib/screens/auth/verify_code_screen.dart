import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'reset_password_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  final String? code;
  const VerifyCodeScreen({super.key, required this.email, this.code});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Demo: auto-fill code
    if (widget.code != null) {
      _codeController.text = widget.code!;
    }
  }

  Future<void> _verify() async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل رمز التحقق'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiService.verifyCode(widget.email, _codeController.text);
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ResetPasswordScreen(email: widget.email)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    try {
      final result = await ApiService.forgotPassword(widget.email);
      _codeController.text = result['code'] ?? '';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إعادة إرسال الرمز'), backgroundColor: Colors.green));
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رمز التحقق')),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔐', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 20),
            Text(widget.email, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('أدخل رمز التحقق المرسل إلى بريدك', style: TextStyle(color: Color(0xFF636E72))),
            if (widget.code != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
                child: Text('للتجربة: ${widget.code}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
            const SizedBox(height: 30),
            TextField(
              controller: _codeController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: 'رمز التحقق'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _verify,
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('تحقق'),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: _resend, child: const Text('إعادة إرسال الرمز')),
          ],
        ),
      ),
    );
  }
}
