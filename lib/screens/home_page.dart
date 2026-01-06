import 'package:flutter/material.dart';
import 'app_drawer.dart';
import '../models/user_model.dart';

class HomePage extends StatelessWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    Widget buildDashboard() {
      List<Widget> cards = [];

      cards.add(
        buildCard(context, 'Products', Icons.store, () {
          Navigator.pushNamed(context, '/products');
        }),
      );

      if (user.role == 'admin')
        cards.add(buildCard(context, 'Users', Icons.people));
      if (user.role == 'admin') {
        cards.add(
          buildCard(context, 'Analytics', Icons.analytics, () {
            Navigator.pushNamed(context, '/dashboard');
          }),
        );
      }

      if (user.role == 'admin' || user.role == 'cashier') {
        cards.add(
          buildCard(context, 'Sales', Icons.shopping_cart, () {
            // Also make the card navigate to the sales page
            Navigator.pushNamed(context, '/sales', arguments: user);
          }),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: cards,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('${user.role} Home')),
      // 2. Use the shared AppDrawer widget instead of the local one
      drawer: AppDrawer(user: user),
      body: buildDashboard(),
    );
  }

  // I've updated buildCard to accept an onTap callback
  Widget buildCard(
    BuildContext context,
    String title,
    IconData icon, [
    VoidCallback? onTap,
  ]) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap:
            onTap ??
            () {
              print('$title card tapped');
            },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: Colors.deepPurple),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
