import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AppDrawer extends StatelessWidget {
  final User user;
  final Widget? child;

  const AppDrawer({super.key, required this.user, this.child});

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return Scaffold(
        appBar: AppBar(title: Text('${user.role} Home')),
        drawer: _buildDrawer(context),
        body: child,
      );
    } else {
      return _buildDrawer(context);
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.deepPurple),
            child: Text(
              user.role.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home', arguments: user);
            },
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Products'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/products');
            },
          ),
          if (user.role == 'admin')
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Users'),
              onTap: () => Navigator.pop(context),
            ),
          if (user.role == 'admin' || user.role == 'cashier')
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Sales'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(
                  context,
                  '/sales',
                  arguments: user,
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
