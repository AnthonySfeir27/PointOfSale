import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'login_screen.dart';
class SignupScreen extends StatefulWidget {
  final UserService userService;
  const SignupScreen({super.key, required this.userService});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}
class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'customer';
  bool _loading = false;
  String? _error;

  void _signup() async {
    setState(() { _loading = true; _error = null; });

    final user = await widget.userService.createUser({
      'username': _usernameController.text,
      'password': _passwordController.text,
      'role': _role,
    });

    setState(() { _loading = false; });

    if (user != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen(userService: widget.userService)));
    } else {
      setState(() { _error = 'Sign up failed'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            DropdownButton<String>(
              value: _role,
              items: const [
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'cashier', child: Text('Cashier')),
              ],
              onChanged: (v) => setState(() { _role = v!; }),
            ),
            const SizedBox(height: 20),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(onPressed: _loading ? null : _signup, child: _loading ? const CircularProgressIndicator() : const Text('Sign Up')),
          ],
        ),
      ),
    );
  }
}
