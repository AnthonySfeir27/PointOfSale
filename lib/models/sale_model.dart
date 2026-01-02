import 'product_model.dart';

class UserRef {
  final String id;
  final String? name;
  final String? email;

  UserRef({
    required this.id,
    this.name,
    this.email,
  });

  factory UserRef.fromJson(Map<String, dynamic> json) {
    return UserRef(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class SaleItem {
  final Product product;
  final int quantity;

  SaleItem({
    required this.product,
    required this.quantity,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.id,
      'quantity': quantity,
    };
  }
}

/// Main Sale model
class Sale {
  final String id;
  final List<SaleItem> products;
  final UserRef cashier;
  final double total;
  final DateTime date;

  Sale({
    required this.id,
    required this.products,
    required this.cashier,
    required this.total,
    required this.date,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['_id'],
      products: (json['products'] as List)
          .map((e) => SaleItem.fromJson(e))
          .toList(),
      cashier: UserRef.fromJson(json['cashier']),
      total: (json['total'] as num).toDouble(),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((e) => e.toJson()).toList(),
      'cashier': cashier.id,
      'total': total,
    };
  }
}
