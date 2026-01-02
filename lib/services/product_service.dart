import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  static const String baseUrl = 'http://YOUR_IP:3000/products';

  static Future<Product> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create product');
    }
  }

  static Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch products');
    }
  }

  static Future<Product> getProductById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Product not found');
    }
  }

  static Future<List<Product>> filterProducts({
    String? category,
    bool? inStock,
  }) async {
    final query = <String, String>{};
    if (category != null) query['category'] = category;
    if (inStock != null) query['inStock'] = inStock.toString();

    final uri = Uri.parse('$baseUrl/filter').replace(queryParameters: query);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Failed to filter products');
    }
  }

  static Future<Product> updateProduct(String id, Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update product');
    }
  }

  static Future<void> deleteProduct(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }

  static Future<List<Map<String, dynamic>>> getStockValueByCategory() async {
    final response =
        await http.get(Uri.parse('$baseUrl/aggregate/stock-value'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(
        jsonDecode(response.body),
      );
    } else {
      throw Exception('Failed to aggregate stock value');
    }
  }
}
