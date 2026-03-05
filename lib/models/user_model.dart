class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final List<String> permissions;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.permissions = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Web app uses user_id from /auth/me response (see RoleContext.tsx line 87)
      id: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['name'] ?? '',
      role: json['role_name'] ?? json['role'] ?? '',
      permissions: (json['permissions'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

