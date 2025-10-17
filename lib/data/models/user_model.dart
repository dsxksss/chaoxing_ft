import '../../domain/entities/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// User model for data layer
@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.name,
    super.avatar,
    super.school,
    super.major,
    super.className,
    super.lastLogin,
    super.isActive,
  });

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      name: user.name,
      avatar: user.avatar,
      school: user.school,
      major: user.major,
      className: user.className,
      lastLogin: user.lastLogin,
      isActive: user.isActive,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toEntity() {
    return User(
      id: id,
      username: username,
      name: name,
      avatar: avatar,
      school: school,
      major: major,
      className: className,
      lastLogin: lastLogin,
      isActive: isActive,
    );
  }

  @override
  UserModel copyWith({
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
    return UserModel(
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
}
