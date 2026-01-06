import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../theme_provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.deepPurple.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white24,
                  radius: 30,
                  child: Icon(Icons.person, color: Colors.white, size: 35),
                ),
                const SizedBox(height: 10),
                Text(
                  user.role.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home', arguments: user);
            },
          ),
          ListTile(
            leading: const Icon(Icons.store_outlined),
            title: const Text('Products'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                context,
                '/products',
                arguments: user,
              );
            },
          ),
          if (user.role == 'admin')
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Users'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(
                  context,
                  '/users',
                  arguments: user,
                );
              },
            ),
          if (user.role == 'admin')
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('Analytics'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(
                  context,
                  '/dashboard',
                  arguments: user,
                );
              },
            ),
          if (user.role == 'admin' || user.role == 'cashier')
            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined),
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
          const Divider(),
          SwitchListTile(
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: themeProvider.isDarkMode ? Colors.amber : Colors.blue,
            ),
            title: const Text('Dark Mode'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent),
            ),
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
