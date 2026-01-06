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
  String? _currentSaleId;

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

  void _decrementCartItem(int index) {
    setState(() {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        _cartItems.removeAt(index);
      }
    });
  }

  double _calculateTotal() {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> _showSaleCompletedDialog(double total) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Column(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
              SizedBox(height: 16),
              Text('Sale Completed'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('The transaction was successful.'),
              const SizedBox(height: 8),
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The ticket has been cleared.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _chargerOrPark({bool isParking = false}) async {
    if (_cartItems.isEmpty) return;

    String? ticketName;
    if (isParking) {
      ticketName = await _showTicketNameDialog();
      if (ticketName == null) return; // User cancelled
    }

    setState(() => _processingSale = true);

    try {
      final total = _calculateTotal();
      final sale = Sale(
        id: _currentSaleId ?? '',
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
        total: total,
        date: DateTime.now(),
        isParked: isParking,
        ticketName: ticketName,
      );

      if (_currentSaleId != null) {
        await widget.saleService.updateSale(_currentSaleId!, sale);
      } else {
        await widget.saleService.createSale(sale);
      }

      setState(() {
        _cartItems.clear();
        _currentSaleId = null;
      });

      if (isParking) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket parked successfully!')),
        );
      } else {
        await _showSaleCompletedDialog(total);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      setState(() => _processingSale = false);
    }
  }

  Future<String?> _showTicketNameDialog() async {
    String name = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Name this Ticket'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'e.g. Table 5'),
            onChanged: (value) => name = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, name),
              child: const Text('Park'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteParkedSale(String id, List<Sale> list) async {
    try {
      await widget.saleService.deleteSale(id);
      list.removeWhere((s) => s.id == id);
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Parked ticket deleted.')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  Future<void> _showParkedSalesDialog() async {
    setState(() => _processingSale = true);
    try {
      final parkedSales = await widget.saleService.getSales(isParked: true);
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: const Text('Parked Tickets'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: parkedSales.isEmpty
                        ? const Text("No parked tickets found.")
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: parkedSales.length,
                            itemBuilder: (context, index) {
                              final sale = parkedSales[index];
                              return ListTile(
                                leading: const Icon(
                                  Icons.receipt_long,
                                  color: Colors.orange,
                                ),
                                title: Text(
                                  sale.ticketName ??
                                      'Unnamed Ticket #${sale.id.substring(sale.id.length - 4)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Total: \$${sale.total.toStringAsFixed(2)}\n${sale.date.toString().substring(0, 16)}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Ticket?'),
                                        content: const Text(
                                          'Are you sure you want to discard this parked ticket?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await _deleteParkedSale(
                                        sale.id,
                                        parkedSales,
                                      );
                                      setDialogState(() {});
                                    }
                                  },
                                ),
                                isThreeLine: true,
                                onTap: () {
                                  setState(() {
                                    _cartItems.clear();
                                    for (var item in sale.products) {
                                      _cartItems.add(
                                        CartItem(
                                          product: item.product,
                                          quantity: item.quantity,
                                        ),
                                      );
                                    }
                                    _currentSaleId = sale.id;
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load tickets: $e')));
      }
    } finally {
      setState(() => _processingSale = false);
    }
  }

  Future<void> _charge() => _chargerOrPark(isParking: false);
  Future<void> _park() => _chargerOrPark(isParking: true);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Parked Tickets',
            onPressed: _showParkedSalesDialog,
          ),
        ],
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
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.orange,
                                    ),
                                    onPressed: () => _decrementCartItem(index),
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
                        height: 40,
                        child: OutlinedButton.icon(
                          onPressed: _cartItems.isEmpty || _processingSale
                              ? null
                              : _park,
                          icon: const Icon(Icons.pause),
                          label: const Text("PARK TICKET"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _cartItems.isEmpty || _processingSale
                              ? null
                              : _charge,
                          icon: const Icon(Icons.check),
                          label: _processingSale
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
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
