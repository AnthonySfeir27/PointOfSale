// C:/.../point_of_sale/lib/models/product_model.dart

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final bool inStock;
  final int stockQuantity;
  final List<String> tags;
  final Map<String, dynamic>? details;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.inStock,
    required this.stockQuantity,
    required this.tags,
    this.details,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
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
      if (dateValue is int)
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      return DateTime.now();
    }

    return Product(
      // Ensure the _id from MongoDB is correctly handled - safe casting
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'other',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      inStock: json['inStock'] as bool? ?? true,
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      tags: List<String>.from(json['tags'] as List? ?? []),
      details: json['details'] != null
          ? Map<String, dynamic>.from(json['details'])
          : null,
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
      'tags': tags,
      'details': details,
    };
  }
}
