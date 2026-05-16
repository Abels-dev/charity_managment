import 'profile_role.dart';

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    this.bio,
    this.phone,
  });

  final String id;
  final String name;
  final String email;
  final ProfileRole role;
  final String? bio;
  final String? phone;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  User copyWith({
    String? id,
    String? name,
    String? email,
    ProfileRole? role,
    String? bio,
    String? phone,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.value,
      'bio': bio,
      'phone': phone,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: ProfileRole.fromJson(json['role'] as String),
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
