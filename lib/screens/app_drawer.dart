import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String role;
  // 1. Make 'child' nullable by adding a '?'
  final Widget? child;

  // 2. Remove the 'required' keyword from 'child' in the constructor
  const AppDrawer({super.key, required this.role, this.child});

  @override
  Widget build(BuildContext context) {
    // 3. Add logic to handle cases where 'child' is null
    if (child != null) {
      // If there IS a child, build the full Scaffold (for SalesPage)
      return Scaffold(
        appBar: AppBar(title: Text('$role Home')),
        drawer: _buildDrawer(context),
        body: child,
      );
    } else {
      // If there is NO child, just build the Drawer itself (for HomePage)
      return _buildDrawer(context);
    }
  }

  // Extracted the drawer logic into a private method for reuse and clarity
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.deepPurple),
            child: Text(
              role.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home', arguments: role);
            },
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Products'),
            onTap: () => Navigator.pop(context),
          ),
          if (role == 'admin')
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Users'),
              onTap: () => Navigator.pop(context),
            ),
          if (role == 'admin' || role == 'cashier')
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Sales'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(
                  context,
                  '/sales',
                  arguments: role,
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
