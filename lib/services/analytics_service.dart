import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_stats.dart';

class AnalyticsService {
  final String baseUrl;

  AnalyticsService({required this.baseUrl});

  Future<DashboardStats> fetchDashboardStats() async {
    final response = await http.get(Uri.parse('$baseUrl/dashboard'));

    if (response.statusCode == 200) {
      return DashboardStats.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load dashboard stats');
    }
  }
}
