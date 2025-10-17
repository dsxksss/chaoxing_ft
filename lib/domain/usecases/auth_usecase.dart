import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../core/errors/error_handler.dart';

/// Authentication use case
class AuthUseCase {

  AuthUseCase(this._authRepository, this._errorHandler);
  final AuthRepository _authRepository;
  final ErrorHandler _errorHandler;

  /// Login with username and password
  Future<User?> login(String username, String password) async {
    try {
      if (username.isEmpty || password.isEmpty) {
        throw _errorHandler.createAuthError('用户名和密码不能为空');
      }

      _errorHandler.logInfo('Attempting login for user: $username');
      
      final user = await _authRepository.login(username, password);
      
      if (user != null) {
        _errorHandler.logInfo('Login successful for user: ${user.username}');
        // Save credentials for future use
        await _authRepository.saveCredentials(username, password);
      } else {
        _errorHandler.logWarning('Login failed for user: $username');
      }
      
      return user;
    } catch (e) {
      _errorHandler.handleError(e, context: 'AuthUseCase.login');
      rethrow;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      _errorHandler.logInfo('Logging out current user');
      await _authRepository.logout();
      _errorHandler.logInfo('Logout successful');
    } catch (e) {
      _errorHandler.handleError(e, context: 'AuthUseCase.logout');
      rethrow;
    }
  }

  /// Get current authenticated user
  Future<User?> getCurrentUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        _errorHandler.logInfo('Current user: ${user.username}');
      } else {
        _errorHandler.logInfo('No current user');
      }
      return user;
    } catch (e) {
      _errorHandler.handleError(e, context: 'AuthUseCase.getCurrentUser');
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final isAuth = await _authRepository.isAuthenticated();
      _errorHandler.logInfo('Authentication status: $isAuth');
      return isAuth;
    } catch (e) {
      _errorHandler.handleError(e, context: 'AuthUseCase.isAuthenticated');
      return false;
    }
  }

  /// Validate current session
  Future<bool> validateSession() async {
    try {
      _errorHandler.logInfo('Validating current session');
      final isValid = await _authRepository.validateSession();
      _errorHandler.logInfo('Session validation result: $isValid');
      return isValid;
    } catch (e) {
      _errorHandler.handleError(e, context: 'AuthUseCase.validateSession');
      return false;
    }
  }

  /// Refresh session
  Future<bool> refreshSession() async {
    try {
      _errorHandler.logInfo('Refreshing session');
      final refreshed = await _authRepository.refreshSession();
      _errorHandler.logInfo('Session refresh result: $refreshed');
      return refreshed;
    } catch (e) {
      _errorHandler.handleError(e, context: 'AuthUseCase.refreshSession');
      return false;
    }
  }

  /// Clear saved credentials
  Future<void> clearCredentials() async {
    try {
      _errorHandler.logInfo('Clearing saved credentials');
      await _authRepository.clearCredentials();
      _errorHandler.logInfo('Credentials cleared');
    } catch (e) {
      _errorHandler.handleError(e, context: 'AuthUseCase.clearCredentials');
      rethrow;
    }
  }
}
