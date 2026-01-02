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
    return Product(
      id: json['_id'],
      name: json['name'],
      category: json['category'],
      price: (json['price'] as num).toDouble(),
      inStock: json['inStock'] ?? true,
      stockQuantity: json['stockQuantity'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      details: json['details'] != null
          ? Map<String, dynamic>.from(json['details'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
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
