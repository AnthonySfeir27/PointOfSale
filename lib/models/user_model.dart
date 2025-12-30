class User {
  final String? id;
  final String username;
  final String role;
  final String? password;
  final DateTime? createdAt;
  final List<String>? preferences;
  final Map<String, dynamic>? permissions;
  final List<Map<String, dynamic>>? activityLog;

  User({
    this.id,
    required this.username,
    required this.role,
    this.password,
    this.createdAt,
    this.preferences,
    this.permissions,
    this.activityLog,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      role: json['role'],
      password: json['password'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      preferences: json['preferences'] != null ? List<String>.from(json['preferences']) : [],
      permissions: json['permissions'] != null ? Map<String, dynamic>.from(json['permissions']) : {},
      activityLog: json['activityLog'] != null
          ? List<Map<String, dynamic>>.from(json['activityLog'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'role': role,
      'password': password,
      'preferences': preferences,
      'permissions': permissions,
      'activityLog': activityLog,
    };
  }
}
