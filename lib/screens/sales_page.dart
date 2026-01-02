// C:/.../point_of_sale/lib/screens/sales_page.dart

import 'package:flutter/material.dart';
import 'package:point_of_sale/screens/app_drawer.dart';
import '../models/product_model.dart';import '../services/product_service.dart';

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  late Future<List<Product>> _productsFuture;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  // **FIX 1:** Match these categories with your backend's `enum`.
  // The values should be 'food', 'drink', 'other'.
  // The keys can be whatever you want to display in the UI.
  final Map<String, String> _categories = {
    'All': 'All', // Special case for showing all items
    'Food': 'food',
    'Drink': 'drink',
    'Other': 'other',
  };

  // This will hold the key for the dropdown, e.g., 'Food'
  String _selectedCategoryKey = 'All';

  @override
  void initState() {
    super.initState();
    _productsFuture = _initializeProducts();
  }

  // Use a separate async method for better state management in initState
  Future<List<Product>> _initializeProducts() async {
    // This fetches all products initially.
    final products = await ProductService.getAllProducts();
    _allProducts = products; // Store them
    _filterProducts(); // Apply the initial filter
    return products;
  }

  void _filterProducts() {
    // Get the backend-friendly value, e.g., 'food'
    final filterValue = _categories[_selectedCategoryKey];

    setState(() {
      if (filterValue == 'All') {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts
            .where((product) => product.category == filterValue)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String role = "cashier";

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const SizedBox(width: 16),
            // **FIX 2:** Update Dropdown to work with the Map.
            DropdownButton<String>(
              value: _selectedCategoryKey, // Use the key for the value
              onChanged: (String? newKey) {
                if (newKey != null) {
                  setState(() {
                    _selectedCategoryKey = newKey;
                    _filterProducts(); // Re-run the filter when category changes
                  });
                }
              },
              // Build dropdown items from the Map's keys
              items: _categories.keys.map<DropdownMenuItem<String>>((String key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(key), // Display the user-friendly key
                );
              }).toList(),
            ),
          ],
        ),
      ),
      drawer: AppDrawer(role: role),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  // This error is more helpful for debugging.
                  print("--- FUTURE BUILDER ERROR ---");
                  print(snapshot.error);
                  print(snapshot.stackTrace);
                  print("--------------------------");
                  return const Center(
                    child: Text(
                      'Error loading products.\nCheck console for details.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                // **FIX 3:** Display the GridView directly if data is ready.
                // The filtering is now handled by _filterProducts().
                if (_filteredProducts.isEmpty && _allProducts.isNotEmpty) {
                  return const Center(child: Text('No products match this category.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 3 / 2,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final product = _filteredProducts[index];
                    return Card(
                      elevation: 2.0,
                      child: InkWell(
                        onTap: () {
                          print('${product.name} (Price: \$${product.price}) selected');
                          // TODO: Add product to the ticket
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              product.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                const Text(
                  "Ticket",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Column(
                    children: [], // For ticket items
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text("Charge")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
