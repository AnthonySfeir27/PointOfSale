class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final bool inStock;
  final int stockQuantity;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.inStock,
    required this.stockQuantity,
    required this.createdAt,
  });

  factory Product.empty() {
    return Product(
      id: '',
      name: 'Unknown Product',
      category: 'other',
      price: 0.0,
      inStock: false,
      stockQuantity: 0,
      createdAt: DateTime.now(),
    );
  }

  factory Product.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Product.empty();
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
      if (dateValue is int)
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      return DateTime.now();
    }

    return Product(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'other',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      inStock: json['inStock'] as bool? ?? true,
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      createdAt: parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'inStock': inStock,
      'stockQuantity': stockQuantity,
    };
  }
}
