import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserService {
  final String baseUrl;

  UserService({required this.baseUrl});

  Future<User?> createUser(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<Map<String, dynamic>?> login(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<List<User>> getUsers({String? role, String? username}) async {
    final query = <String, String>{};
    if (role != null && role != 'All') query['role'] = role;
    if (username != null && username.isNotEmpty) query['username'] = username;

    final uri = Uri.parse(baseUrl).replace(queryParameters: query);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  Future<User> getUserById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('User not found');
    }
  }

  Future<User> getUserByUsername(String username) async {
    final response = await http.get(Uri.parse('$baseUrl/username/$username'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('User not found');
    }
  }

  Future<User> updateUser(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update user');
    }
  }

  Future<void> deleteUser(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }

  Future<bool> verifyAdminSecret(String secret) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-admin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'secret': secret}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
