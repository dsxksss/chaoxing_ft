import '../../domain/entities/session.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session_model.g.dart';

/// Session model for data layer
@JsonSerializable()
class SessionModel extends Session {
  const SessionModel({
    required super.id,
    required super.userId,
    required super.sessionToken,
    required super.createdAt,
    required super.expiresAt,
    super.isActive,
    super.cookies,
    super.headers,
    super.userAgent,
    super.ipAddress,
  });

  factory SessionModel.fromEntity(Session session) {
    return SessionModel(
      id: session.id,
      userId: session.userId,
      sessionToken: session.sessionToken,
      createdAt: session.createdAt,
      expiresAt: session.expiresAt,
      isActive: session.isActive,
      cookies: session.cookies,
      headers: session.headers,
      userAgent: session.userAgent,
      ipAddress: session.ipAddress,
    );
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) => _$SessionModelFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SessionModelToJson(this);

  Session toEntity() {
    return Session(
      id: id,
      userId: userId,
      sessionToken: sessionToken,
      createdAt: createdAt,
      expiresAt: expiresAt,
      isActive: isActive,
      cookies: cookies,
      headers: headers,
      userAgent: userAgent,
      ipAddress: ipAddress,
    );
  }

  @override
  SessionModel copyWith({
    String? id,
    String? userId,
    String? sessionToken,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isActive,
    Map<String, String>? cookies,
    Map<String, String>? headers,
    String? userAgent,
    String? ipAddress,
  }) {
    return SessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionToken: sessionToken ?? this.sessionToken,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      cookies: cookies ?? this.cookies,
      headers: headers ?? this.headers,
      userAgent: userAgent ?? this.userAgent,
      ipAddress: ipAddress ?? this.ipAddress,
    );
  }
}
