import 'package:flutter/material.dart';
import 'app_drawer.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/sale_service.dart';
import '../models/user_model.dart';
import '../models/cart_item.dart';
import '../models/sale_model.dart';

class SalesPage extends StatefulWidget {
  final User user;
  final ProductService productService;
  final SaleService saleService;

  const SalesPage({
    super.key,
    required this.user,
    required this.productService,
    required this.saleService,
  });

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  late Future<List<Product>> _productsFuture;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  final List<CartItem> _cartItems = [];
  bool _processingSale = false;

  final Map<String, String> _categories = {
    'All': 'All',
    'Food': 'food',
    'Drink': 'drink',
    'Other': 'other',
  };

  String _selectedCategoryKey = 'All';

  @override
  void initState() {
    super.initState();
    _productsFuture = _initializeProducts();
  }

  Future<List<Product>> _initializeProducts() async {
    final products = await widget.productService.getAllProducts();
    _allProducts = products;
    _filterProducts();
    return products;
  }

  void _filterProducts() {
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

  void _addToCart(Product product) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );
      if (existingIndex >= 0) {
        _cartItems[existingIndex].quantity++;
      } else {
        _cartItems.add(CartItem(product: product, quantity: 1));
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  double _calculateTotal() {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> _charge() async {
    if (_cartItems.isEmpty) return;

    setState(() => _processingSale = true);

    try {
      final sale = Sale(
        id: '', // Backend generates ID
        products: _cartItems
            .map(
              (item) =>
                  SaleItem(product: item.product, quantity: item.quantity),
            )
            .toList(),
        cashier: UserRef(
          id: widget.user.id ?? '',
          username: widget.user.username,
          role: widget.user.role,
        ),
        total: _calculateTotal(),
        date: DateTime.now(),
      );

      await widget.saleService.createSale(sale);

      setState(() {
        _cartItems.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale completed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to process sale: $e')));
    } finally {
      setState(() => _processingSale = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Sales'),
            const SizedBox(width: 20),
            DropdownButton<String>(
              value: _selectedCategoryKey,
              onChanged: (String? newKey) {
                if (newKey != null) {
                  setState(() {
                    _selectedCategoryKey = newKey;
                    _filterProducts();
                  });
                }
              },
              items: _categories.keys.map<DropdownMenuItem<String>>((
                String key,
              ) {
                return DropdownMenuItem<String>(value: key, child: Text(key));
              }).toList(),
            ),
          ],
        ),
      ),
      drawer: AppDrawer(user: widget.user),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading products'));
                }

                if (_filteredProducts.isEmpty && _allProducts.isNotEmpty) {
                  return const Center(
                    child: Text('No products match this category.'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1 / 1,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final product = _filteredProducts[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => _addToCart(product),
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.deepPurple.shade50,
                              child: Text(
                                product.name.isNotEmpty
                                    ? product.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text('\$${product.price.toStringAsFixed(2)}'),
                            if (product.stockQuantity < 5)
                              Text(
                                'Low Stock: ${product.stockQuantity}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.deepPurple.shade50,
                  width: double.infinity,
                  child: const Text(
                    "Current Ticket",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                Expanded(
                  child: _cartItems.isEmpty
                      ? const Center(child: Text("Ticket is empty"))
                      : ListView.builder(
                          itemCount: _cartItems.length,
                          itemBuilder: (context, index) {
                            final item = _cartItems[index];
                            return ListTile(
                              title: Text(item.product.name),
                              subtitle: Text(
                                '${item.quantity} x \$${item.product.price.toStringAsFixed(2)}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '\$${item.totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _removeFromCart(index),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5,
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total:",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "\$${_calculateTotal().toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _cartItems.isEmpty || _processingSale
                              ? null
                              : _charge,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: _processingSale
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "CHARGE",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
