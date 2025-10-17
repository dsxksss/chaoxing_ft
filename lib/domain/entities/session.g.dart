// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Session _$SessionFromJson(Map<String, dynamic> json) => Session(
      id: json['id'] as String,
      userId: json['userId'] as String,
      sessionToken: json['sessionToken'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      cookies: (json['cookies'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      userAgent: json['userAgent'] as String?,
      ipAddress: json['ipAddress'] as String?,
    );

Map<String, dynamic> _$SessionToJson(Session instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'sessionToken': instance.sessionToken,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'isActive': instance.isActive,
      'cookies': instance.cookies,
      'headers': instance.headers,
      'userAgent': instance.userAgent,
      'ipAddress': instance.ipAddress,
    };
