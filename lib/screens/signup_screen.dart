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
  int _roleVersion = 0;
  String _role = 'cashier';
  bool _loading = false;
  String? _error;

  Future<void> _handleRoleChange(String? newRole) async {
    if (newRole == null) return;
    String previousRole = _role;

    // If selecting admin, verify secret
    if (newRole == 'admin' && _role != 'admin') {
      final secretVerified = await _showAdminSecretDialog();
      if (secretVerified) {
        setState(() => _role = 'admin');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin verification failed')),
          );
        }
        // Force reset the role to the previous value to update the UI
        setState(() {
          _role = previousRole;
          _roleVersion++;
        });
      }
    } else {
      setState(() => _role = newRole);
    }
  }

  Future<bool> _showAdminSecretDialog() async {
    String enteredSecret = '';
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text('Admin Verification'),
              content: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter Secret Admin Password',
                  hintText: 'Required to assign admin role',
                ),
                onChanged: (value) => enteredSecret = value,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final isValid = await widget.userService.verifyAdminSecret(
                      enteredSecret,
                    );
                    if (context.mounted) {
                      Navigator.pop(context, isValid);
                    }
                  },
                  child: const Text('Verify'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _signup() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final user = await widget.userService.createUser({
      'username': _usernameController.text,
      'password': _passwordController.text,
      'role': _role,
    });

    setState(() {
      _loading = false;
    });

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(userService: widget.userService),
        ),
      );
    } else {
      setState(() {
        _error = 'Sign up failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 10),
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 40),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        key: ValueKey('role_$_roleVersion'),
                        value: _role,
                        decoration: InputDecoration(
                          labelText: 'Role',
                          prefixIcon: const Icon(Icons.work),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                          DropdownMenuItem(
                            value: 'cashier',
                            child: Text('Cashier'),
                          ),
                        ],
                        onChanged: _handleRoleChange,
                      ),
                      const SizedBox(height: 20),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LoginScreen(userService: widget.userService),
                  ),
                ),
                child: const Text(
                  'Already have an account? Login',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
