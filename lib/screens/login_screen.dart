import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'home_page.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final UserService userService;
  const LoginScreen({super.key, required this.userService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  void _login() async {
    setState(() { _loading = true; _error = null; });

    final res = await widget.userService.login({
      'username': _usernameController.text,
      'password': _passwordController.text,
    });

    setState(() { _loading = false; });

    if (res != null && res['user'] != null) {
      final user = res['user'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(role: user['role']),
        ),
      );
    } else {
      setState(() { _error = res?['error'] ?? 'Login failed'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(onPressed: _loading ? null : _login, child: _loading ? const CircularProgressIndicator() : const Text('Login')),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen(userService: widget.userService))),
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
