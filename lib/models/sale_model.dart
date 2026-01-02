import 'product_model.dart';

class UserRef {
  final String id;
  final String? username;
  final String? role;

  UserRef({
    required this.id,
    this.username,
    this.role,
  });

  factory UserRef.fromJson(Map<String, dynamic> json) {
    return UserRef(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      username: json['username']?.toString(),
      role: json['role']?.toString(),
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
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
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
    // Safe date parsing - handles both String and Date objects
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          return DateTime.now();
        }
      }
      if (dateValue is DateTime) return dateValue;
      // If it's a number (timestamp), convert it
      if (dateValue is int) return DateTime.fromMillisecondsSinceEpoch(dateValue);
      return DateTime.now();
    }

    return Sale(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      products: (json['products'] as List?)
              ?.map((e) => SaleItem.fromJson(e))
              .toList() ??
          [],
      cashier: UserRef.fromJson(json['cashier'] ?? {}),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      date: parseDate(json['date']),
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
