import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chaoxing_ft/presentation/providers/auth_provider.dart';
import 'package:chaoxing_ft/presentation/providers/course_provider.dart';
import 'package:chaoxing_ft/presentation/providers/task_provider.dart';
import 'package:chaoxing_ft/core/di/dependency_injection.dart';

/// Base provider class for all providers in the app
abstract class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Set loading state
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set error message
  void setError(String? error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    setError(null);
  }

  /// Execute async operation with loading and error handling
  Future<T?> executeWithLoading<T>(
    Future<T> Function() operation, {
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) setLoading(true);
      clearError();
      
      final result = await operation();
      return result;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      if (showLoading) setLoading(false);
    }
  }

  /// Execute async operation with error handling (alias for executeWithLoading)
  Future<T?> runGuarded<T>(
    Future<T> Function() operation, {
    bool showLoading = true,
  }) async {
    return executeWithLoading(operation, showLoading: showLoading);
  }

}

/// Provider configuration for the app
class AppProviders {
  static List<ChangeNotifierProvider> get providers => [
    ChangeNotifierProvider(create: (_) => AuthProvider(DependencyInjection.instance.authService)),
    ChangeNotifierProvider(create: (_) => CourseProvider(DependencyInjection.instance.courseService)),
    ChangeNotifierProvider(create: (_) => TaskProvider(DependencyInjection.instance.taskService)),
  ];

  static Widget createAppProviders({required Widget child}) {
    return MultiProvider(
      providers: providers,
      child: child,
    );
  }
}

/// Provider extensions for easier access
extension ProviderExtension on BuildContext {
  T read<T>() => Provider.of<T>(this, listen: false);
  T watch<T>() => Provider.of<T>(this);
}
