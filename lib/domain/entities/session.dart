import 'package:json_annotation/json_annotation.dart';

part 'session.g.dart';

/// Session entity representing user session
@JsonSerializable()
class Session {

  const Session({
    required this.id,
    required this.userId,
    required this.sessionToken,
    required this.createdAt,
    required this.expiresAt,
    this.isActive = true,
    this.cookies = const {},
    this.headers = const {},
    this.userAgent,
    this.ipAddress,
  });

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);
  final String id;
  final String userId;
  final String sessionToken;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;
  final Map<String, String> cookies;
  final Map<String, String> headers;
  final String? userAgent;
  final String? ipAddress;
  Map<String, dynamic> toJson() => _$SessionToJson(this);

  Session copyWith({
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
    return Session(
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

  /// Check if session is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if session is valid
  bool get isValid => isActive && !isExpired;

  /// Get session duration
  Duration get duration => expiresAt.difference(createdAt);

  /// Get remaining time
  Duration get remainingTime => expiresAt.difference(DateTime.now());

  /// Add cookie to session
  Session addCookie(String name, String value) {
    final newCookies = Map<String, String>.from(cookies);
    newCookies[name] = value;
    return copyWith(cookies: newCookies);
  }

  /// Remove cookie from session
  Session removeCookie(String name) {
    final newCookies = Map<String, String>.from(cookies);
    newCookies.remove(name);
    return copyWith(cookies: newCookies);
  }

  /// Add header to session
  Session addHeader(String name, String value) {
    final newHeaders = Map<String, String>.from(headers);
    newHeaders[name] = value;
    return copyWith(headers: newHeaders);
  }

  /// Remove header from session
  Session removeHeader(String name) {
    final newHeaders = Map<String, String>.from(headers);
    newHeaders.remove(name);
    return copyWith(headers: newHeaders);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Session && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Session(id: $id, userId: $userId, isValid: $isValid)';
  }
}
