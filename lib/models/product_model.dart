// C:/.../point_of_sale/lib/models/product_model.dart

import 'dart:convert';

class Product {
  final String id;
  final String name;  final String category;
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
      // Ensure the _id from MongoDB is correctly handled
      id: json['_id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      inStock: json['inStock'] as bool? ?? true,
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      tags: List<String>.from(json['tags'] as List? ?? []),
      details: json['details'] != null
          ? Map<String, dynamic>.from(json['details'])
          : null,
      // **FIX:** Make date parsing safer. If 'createdAt' is null, use current time.
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
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
