import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sale_model.dart';

class SaleService {
  final String baseUrl;

  SaleService({required this.baseUrl});

  Future<Sale> createSale(Sale sale) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(sale.toJson()),
    );

    if (response.statusCode == 201) {
      return Sale.fromJson(jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      final errorMessage =
          errorBody['error']?.toString() ?? 'Failed to create sale';
      throw Exception(errorMessage);
    }
  }

  Future<List<Sale>> getSales() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Sale.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch sales');
    }
  }

  Future<Sale> getSaleById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Sale.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Sale not found');
    }
  }

  Future<Sale> updateSale(String id, Sale sale) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(sale.toJson()),
    );

    if (response.statusCode == 200) {
      return Sale.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update sale');
    }
  }

  Future<void> deleteSale(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete sale');
    }
  }

  Future<List<Map<String, dynamic>>> salesByProduct() async {
    final response = await http.get(Uri.parse('$baseUrl/aggregate/products'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to aggregate sales');
    }
  }
}
