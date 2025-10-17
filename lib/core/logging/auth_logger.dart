import 'package:logger/logger.dart';

/// Authentication logging utilities
class AuthLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );


  /// Log login attempt
  static void logLoginAttempt(String username, {String? ipAddress, String? userAgent}) {
    _logger.i('🔐 Login attempt started - username: $username, ip: $ipAddress, userAgent: $userAgent');
  }

  /// Log login success
  static void logLoginSuccess(String username, String userId, {String? sessionId}) {
    _logger.i('✅ Login successful - username: $username, userId: $userId, sessionId: $sessionId');
  }

  /// Log login failure
  static void logLoginFailure(String username, String reason, {String? errorCode}) {
    _logger.w('❌ Login failed - username: $username, reason: $reason, errorCode: $errorCode');
  }

  /// Log logout
  static void logLogout(String username, String userId, {String? sessionId}) {
    _logger.i('🚪 Logout - username: $username, userId: $userId, sessionId: $sessionId');
  }

  /// Log session validation
  static void logSessionValidation(String sessionId, bool isValid, {String? reason}) {
    _logger.d('🔍 Session validation - sessionId: $sessionId, isValid: $isValid, reason: $reason');
  }

  /// Log session refresh
  static void logSessionRefresh(String sessionId, bool success, {String? reason}) {
    _logger.d('🔄 Session refresh - sessionId: $sessionId, success: $success, reason: $reason');
  }

  /// Log credential save
  static void logCredentialSave(String username, bool success) {
    _logger.d('💾 Credential save - username: $username, success: $success');
  }

  /// Log credential clear
  static void logCredentialClear(String username, bool success) {
    _logger.d('🗑️ Credential clear - username: $username, success: $success');
  }

  /// Log authentication error
  static void logAuthError(String operation, dynamic error, {String? username}) {
    _logger.e('🚨 Authentication error - operation: $operation, error: $error, username: $username');
  }

  /// Log security event
  static void logSecurityEvent(String event, Map<String, dynamic> details) {
    _logger.w('🔒 Security event - event: $event, details: $details');
  }

  /// Log suspicious activity
  static void logSuspiciousActivity(String activity, Map<String, dynamic> details) {
    _logger.e('⚠️ Suspicious activity detected - activity: $activity, details: $details');
  }

  /// Log rate limit
  static void logRateLimit(String operation, String identifier, int attempts) {
    _logger.w('⏱️ Rate limit exceeded - operation: $operation, identifier: $identifier, attempts: $attempts');
  }

  /// Log API call
  static void logApiCall(String endpoint, String method, {Map<String, dynamic>? params}) {
    _logger.d('🌐 API call - endpoint: $endpoint, method: $method, params: $params');
  }

  /// Log API response
  static void logApiResponse(String endpoint, int statusCode, {Map<String, dynamic>? data}) {
    _logger.d('📡 API response - endpoint: $endpoint, statusCode: $statusCode, data: $data');
  }

  /// Log API error
  static void logApiError(String endpoint, int statusCode, String error) {
    _logger.e('❌ API error - endpoint: $endpoint, statusCode: $statusCode, error: $error');
  }

  /// Log user activity
  static void logUserActivity(String userId, String activity, {Map<String, dynamic>? details}) {
    _logger.i('👤 User activity - userId: $userId, activity: $activity, details: $details');
  }

  /// Log performance metric
  static void logPerformanceMetric(String operation, Duration duration, {Map<String, dynamic>? metadata}) {
    _logger.d('⚡ Performance metric - operation: $operation, duration: ${duration.inMilliseconds}ms, metadata: $metadata');
  }

  /// Log debug message
  static void logDebug(String message, {Map<String, dynamic>? data}) {
    _logger.d('🐛 Debug - message: $message, data: $data');
  }

  /// Log info message
  static void logInfo(String message, {Map<String, dynamic>? data}) {
    _logger.i('ℹ️ Info - message: $message, data: $data');
  }

  /// Log warning message
  static void logWarning(String message, {Map<String, dynamic>? data}) {
    _logger.w('⚠️ Warning - message: $message, data: $data');
  }

  /// Log error message
  static void logError(String message, {Map<String, dynamic>? data, dynamic error}) {
    _logger.e('❌ Error - message: $message, data: $data, error: $error');
  }
}