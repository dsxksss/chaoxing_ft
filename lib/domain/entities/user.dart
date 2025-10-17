import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// User entity representing authenticated user
@JsonSerializable()
class User {

  const User({
    required this.id,
    required this.username,
    required this.name,
    this.avatar,
    this.school,
    this.major,
    this.className,
    this.lastLogin,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  final String id;
  final String username;
  final String name;
  final String? avatar;
  final String? school;
  final String? major;
  final String? className;
  final DateTime? lastLogin;
  final bool isActive;
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? username,
    String? name,
    String? avatar,
    String? school,
    String? major,
    String? className,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      school: school ?? this.school,
      major: major ?? this.major,
      className: className ?? this.className,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, username: $username, name: $name)';
  }
}
