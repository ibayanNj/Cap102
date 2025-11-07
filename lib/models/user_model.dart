class UserModel {
  // ✅ Changed from User to UserModel
  final String id;
  final String name;
  final String role;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // ✅ Update constructor name
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'role': role};
  }
}
