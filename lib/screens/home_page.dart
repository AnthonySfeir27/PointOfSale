import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String role;
  const HomePage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    // Build the role-specific body
    Widget buildDashboard() {
      List<Widget> cards = [];

      // Products accessible to all roles
      cards.add(buildCard(context, 'Products', Icons.store));

      // Inventory - admin only
      if (role == 'admin') cards.add(buildCard(context, 'Inventory', Icons.inventory));

      // Users - admin only
      if (role == 'admin') cards.add(buildCard(context, 'Users', Icons.people));

      // Sales - admin & cashier
      if (role == 'admin' || role == 'cashier') {
        cards.add(buildCard(context, 'Sales', Icons.shopping_cart));
      }

      // Transactions - admin & cashier
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
      drawer: buildDrawer(context),
      body: buildDashboard(),
    );
  }

  // Drawer with role-based items
  Drawer buildDrawer(BuildContext context) {
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
            onTap: () => Navigator.pop(context),
          ),
          // Products
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Products'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to ProductsPage()
            },
          ),
          // Inventory - admin only
          if (role == 'admin')
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Inventory'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to InventoryPage()
              },
            ),
          // Users - admin only
          if (role == 'admin')
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Users'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to UsersPage()
              },
            ),
          // Sales - admin & cashier
          if (role == 'admin' || role == 'cashier')
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Sales'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to SalesPage()
              },
            ),
          // Transactions - admin & cashier
          if (role == 'admin' || role == 'cashier')
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Transactions'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to TransactionsPage()
              },
            ),
          const Divider(),
          // Logout
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login'); // make sure route exists in main.dart
            },
          ),
        ],
      ),
    );
  }

  // Quick-access card for dashboard
  Widget buildCard(BuildContext context, String title, IconData icon) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          // Navigate to respective page
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
