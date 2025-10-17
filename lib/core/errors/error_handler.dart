import 'package:logger/logger.dart';

/// Custom exception classes for Chaoxing Flutter app
class ChaoxingException implements Exception {

  ChaoxingException(this.message, {this.code, this.originalError});
  final String message;
  final String? code;
  final dynamic originalError;

  @override
  String toString() => 'ChaoxingException: $message';
}

class AuthenticationException extends ChaoxingException {
  AuthenticationException(super.message, {super.code, super.originalError});
}

class NetworkException extends ChaoxingException {
  NetworkException(super.message, {super.code, super.originalError});
}

class DataParsingException extends ChaoxingException {
  DataParsingException(super.message, {super.code, super.originalError});
}

class TaskProcessingException extends ChaoxingException {
  TaskProcessingException(super.message, {super.code, super.originalError});
}

class QuestionBankException extends ChaoxingException {
  QuestionBankException(super.message, {super.code, super.originalError});
}

/// Error handling utility class
class ErrorHandler {

  ErrorHandler._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }
  static ErrorHandler? _instance;
  late Logger _logger;

  static ErrorHandler get instance {
    _instance ??= ErrorHandler._internal();
    return _instance!;
  }

  /// Handle and log errors
  void handleError(dynamic error, {StackTrace? stackTrace, String? context}) {
    if (error is ChaoxingException) {
      _logger.e(
        'Chaoxing Error: ${error.message}',
        error: error.originalError,
        stackTrace: stackTrace,
      );
    } else {
      _logger.e(
        'Unexpected Error: $error',
        error: error,
        stackTrace: stackTrace,
      );
    }

    if (context != null) {
      _logger.d('Context: $context');
    }
  }

  /// Log info messages
  void logInfo(String message, {String? context}) {
    _logger.i(message);
    if (context != null) {
      _logger.d('Context: $context');
    }
  }

  /// Log debug messages
  void logDebug(String message, {String? context}) {
    _logger.d(message);
    if (context != null) {
      _logger.d('Context: $context');
    }
  }

  /// Log warning messages
  void logWarning(String message, {String? context}) {
    _logger.w(message);
    if (context != null) {
      _logger.d('Context: $context');
    }
  }

  /// Create authentication error
  ChaoxingException createAuthError(String message, {String? code, dynamic originalError}) {
    return AuthenticationException(message, code: code, originalError: originalError);
  }

  /// Create network error
  ChaoxingException createNetworkError(String message, {String? code, dynamic originalError}) {
    return NetworkException(message, code: code, originalError: originalError);
  }

  /// Create data parsing error
  ChaoxingException createDataParsingError(String message, {String? code, dynamic originalError}) {
    return DataParsingException(message, code: code, originalError: originalError);
  }

  /// Create task processing error
  ChaoxingException createTaskProcessingError(String message, {String? code, dynamic originalError}) {
    return TaskProcessingException(message, code: code, originalError: originalError);
  }

  /// Create question bank error
  ChaoxingException createQuestionBankError(String message, {String? code, dynamic originalError}) {
    return QuestionBankException(message, code: code, originalError: originalError);
  }

  /// Get user-friendly error message
  String getUserFriendlyMessage(ChaoxingException error) {
    switch (error.runtimeType) {
      case AuthenticationException _:
        return '登录失败，请检查用户名和密码';
      case NetworkException _:
        return '网络连接失败，请检查网络设置';
      case DataParsingException _:
        return '数据解析失败，请重试';
      case TaskProcessingException _:
        return '任务处理失败，请重试';
      case QuestionBankException _:
        return '题库服务异常，请稍后重试';
      default:
        return '发生未知错误，请重试';
    }
  }
}
