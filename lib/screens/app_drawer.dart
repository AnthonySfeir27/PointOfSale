import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String role;
  final Widget child;

  const AppDrawer({super.key, required this.role, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$role Home')),
      drawer: Drawer(
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
              onTap: () => Navigator.pop(context),
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
                onTap: () => Navigator.pop(context),
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
      ),
      body: child, // your page content goes here
    );
  }
}
