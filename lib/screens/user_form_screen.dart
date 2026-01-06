import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class UserFormScreen extends StatefulWidget {
  final UserService userService;
  final User? user;

  const UserFormScreen({super.key, required this.userService, this.user});

  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  int _roleVersion = 0;
  String _role = 'cashier';
  bool _loading = false;
  final List<String> _roles = ['admin', 'cashier'];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.user?.username ?? '',
    );
    _passwordController =
        TextEditingController(); // Empty default, only fill if changing
    if (widget.user != null && _roles.contains(widget.user!.role)) {
      _role = widget.user!.role;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final userData = <String, dynamic>{
        'username': _usernameController.text,
        'role': _role,
      };

      if (_passwordController.text.isNotEmpty) {
        userData['password'] = _passwordController.text;
      } else if (widget.user == null) {
        // Require password for new users
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password is required for new users')),
        );
        setState(() => _loading = false);
        return;
      }

      if (widget.user == null) {
        await widget.userService.createUser(userData);
      } else {
        await widget.userService.updateUser(widget.user!.id!, userData);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User saved successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save user: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit User' : 'Add User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a username' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: isEditing
                      ? 'Password (leave blank to keep current)'
                      : 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
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
                items: _roles
                    .map(
                      (r) => DropdownMenuItem(
                        value: r,
                        child: Text(r.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: _handleRoleChange,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _saveUser,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : Text(isEditing ? 'Update User' : 'Create User'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
