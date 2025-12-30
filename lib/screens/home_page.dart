import 'package:flutter/material.dart';
import 'package:point_of_sale/screens/app_drawer.dart'; // 1. Import the shared AppDrawer

class HomePage extends StatelessWidget {
  final String role;
  const HomePage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {

    Widget buildDashboard() {
      List<Widget> cards = [];


      cards.add(buildCard(context, 'Products', Icons.store));


      if (role == 'admin') cards.add(buildCard(context, 'Inventory', Icons.inventory));


      if (role == 'admin') cards.add(buildCard(context, 'Users', Icons.people));

      if (role == 'admin' || role == 'cashier') {
        cards.add(buildCard(context, 'Sales', Icons.shopping_cart, () {
          // Also make the card navigate to the sales page
          Navigator.pushNamed(context, '/sales');
        }));
      }

      if (role == 'admin' || role == 'cashier') {
        cards.add(buildCard(context, 'Transactions', Icons.receipt));
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: cards,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('$role Home')),
      // 2. Use the shared AppDrawer widget instead of the local one
      drawer: AppDrawer(role: role),
      body: buildDashboard(),
    );
  }

  // 3. This entire method should be deleted as it's now handled by app_drawer.dart
  /*
  Drawer buildDrawer(BuildContext context) {
    ...
  }
  */

  // I've updated buildCard to accept an onTap callback
  Widget buildCard(BuildContext context, String title, IconData icon, [VoidCallback? onTap]) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap ?? () {
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
