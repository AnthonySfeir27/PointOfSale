import 'package:flutter/material.dart';
import 'app_drawer.dart'; // make sure this path matches your project

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

      if (role == 'admin' || role == 'cashier') cards.add(buildCard(context, 'Sales', Icons.shopping_cart));
      if (role == 'admin' || role == 'cashier') cards.add(buildCard(context, 'Transactions', Icons.receipt));

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
    return AppDrawer(
      role: role,
      child: buildDashboard(),
    );
  }
  Widget buildCard(BuildContext context, String title, IconData icon) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {

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
