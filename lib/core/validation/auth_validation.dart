import 'package:flutter/material.dart';
import '../../presentation/widgets/app_components.dart';
import '../../core/errors/error_handler.dart' as errors;

/// Authentication validation utilities
class AuthValidation {

  /// Validate username
  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return '用户名不能为空';
    }
    
    if (username.length < 3) {
      return '用户名至少需要3个字符';
    }
    
    if (username.length > 50) {
      return '用户名不能超过50个字符';
    }
    
    // Check for invalid characters
    final validPattern = RegExp(r'^[a-zA-Z0-9_\u4e00-\u9fa5]+$');
    if (!validPattern.hasMatch(username)) {
      return '用户名只能包含字母、数字、下划线和中文';
    }
    
    return null;
  }

  /// Validate password
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return '密码不能为空';
    }
    
    if (password.length < 6) {
      return '密码至少需要6个字符';
    }
    
    if (password.length > 100) {
      return '密码不能超过100个字符';
    }
    
    // Check for invalid characters
    final validPattern = RegExp(r'^[a-zA-Z0-9!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?]+$');
    if (!validPattern.hasMatch(password)) {
      return '密码包含无效字符';
    }
    
    return null;
  }

  /// Validate login credentials
  static Map<String, String?> validateLoginCredentials(String username, String password) {
    return {
      'username': validateUsername(username),
      'password': validatePassword(password),
    };
  }

  /// Check if credentials are valid
  static bool areCredentialsValid(String username, String password) {
    final validation = validateLoginCredentials(username, password);
    return validation['username'] == null && validation['password'] == null;
  }
}

/// Authentication error handling utilities
class AuthErrorHandler {

  /// Handle authentication errors
  static String handleAuthError(dynamic error) {
    if (error is errors.AuthenticationException) {
      return _handleAuthenticationException(error);
    } else if (error is errors.NetworkException) {
      return _handleNetworkException(error);
    } else if (error is errors.DataParsingException) {
      return _handleDataParsingException(error);
    } else {
      return _handleGenericError(error);
    }
  }

  /// Handle authentication exception
  static String _handleAuthenticationException(errors.AuthenticationException error) {
    switch (error.code) {
      case 'INVALID_CREDENTIALS':
        return '用户名或密码错误';
      case 'ACCOUNT_LOCKED':
        return '账户已被锁定，请联系管理员';
      case 'ACCOUNT_DISABLED':
        return '账户已被禁用，请联系管理员';
      case 'SESSION_EXPIRED':
        return '会话已过期，请重新登录';
      case 'CAPTCHA_REQUIRED':
        return '需要验证码验证';
      case 'TOO_MANY_ATTEMPTS':
        return '登录尝试次数过多，请稍后再试';
      default:
        return '登录失败，请检查用户名和密码';
    }
  }

  /// Handle network exception
  static String _handleNetworkException(errors.NetworkException error) {
    switch (error.code) {
      case 'CONNECTION_TIMEOUT':
        return '连接超时，请检查网络连接';
      case 'NO_INTERNET':
        return '网络连接失败，请检查网络设置';
      case 'SERVER_ERROR':
        return '服务器错误，请稍后重试';
      case 'REQUEST_TIMEOUT':
        return '请求超时，请重试';
      default:
        return '网络连接失败，请检查网络设置';
    }
  }

  /// Handle data parsing exception
  static String _handleDataParsingException(errors.DataParsingException error) {
    switch (error.code) {
      case 'INVALID_RESPONSE':
        return '服务器响应格式错误';
      case 'MISSING_DATA':
        return '缺少必要的数据';
      case 'INVALID_FORMAT':
        return '数据格式错误';
      default:
        return '数据解析失败，请重试';
    }
  }

  /// Handle generic error
  static String _handleGenericError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('timeout')) {
      return '请求超时，请重试';
    } else if (errorString.contains('network')) {
      return '网络连接失败，请检查网络设置';
    } else if (errorString.contains('server')) {
      return '服务器错误，请稍后重试';
    } else if (errorString.contains('unauthorized')) {
      return '未授权访问，请重新登录';
    } else if (errorString.contains('forbidden')) {
      return '访问被拒绝，请联系管理员';
    } else {
      return '发生未知错误，请重试';
    }
  }

  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '关闭',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '关闭',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show warning snackbar
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning_outlined,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppTheme.warningColor,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '关闭',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
