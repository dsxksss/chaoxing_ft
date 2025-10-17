// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      username: json['username'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      school: json['school'] as String?,
      major: json['major'] as String?,
      className: json['className'] as String?,
      lastLogin: json['lastLogin'] == null
          ? null
          : DateTime.parse(json['lastLogin'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'name': instance.name,
      'avatar': instance.avatar,
      'school': instance.school,
      'major': instance.major,
      'className': instance.className,
      'lastLogin': instance.lastLogin?.toIso8601String(),
      'isActive': instance.isActive,
    };
