class User {
  final String? id;
  final String username;
  final String role;
  final String? password;
  final DateTime? createdAt;

  User({
    this.id,
    required this.username,
    required this.role,
    this.password,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Safe date parsing - handles both String and Date objects
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          return null;
        }
      }
      if (dateValue is DateTime) return dateValue;
      // If it's a number (timestamp), convert it
      if (dateValue is int)
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      return null;
    }

    return User(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      username: json['username']?.toString() ?? '',
      role: json['role']?.toString() ?? 'cashier',
      password: json['password']?.toString(),
      createdAt: parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'role': role, 'password': password};
  }
}
