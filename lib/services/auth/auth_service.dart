import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/errors/error_handler.dart';

/// Authentication service
class AuthService {

  AuthService(this._authRepository, this._errorHandler);
  final AuthRepository _authRepository;
  final ErrorHandler _errorHandler;

  /// Login with username and password
  Future<User?> login(String username, String password) async {
    try {
      _errorHandler.logInfo('AuthService: Starting login for user: $username');
      
      // Validate input
      if (username.isEmpty || password.isEmpty) {
        throw _errorHandler.createAuthError('用户名和密码不能为空');
      }

      // Perform login
      final user = await _authRepository.login(username, password);
      
      if (user != null) {
        _errorHandler.logInfo('AuthService: Login successful for user: ${user.username}');
      } else {
        _errorHandler.logWarning('AuthService: Login failed for user: $username');
      }
      
      return user;
    } catch (e) {
      _errorHandler.handleError(e, context: 'AuthService.login');
      rethrow;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      _errorHandler.logInfo('AuthService: Starting logout');
      await _authRepository.logout();
      _errorHandler.logInfo('AuthService: Logout completed');
    } catch (e) {
      _errorHandler.handleError(e, context: 'AuthService.logout');
      rethrow;
    }
  }

  /// Get current authenticated user
  Future<User?> getCurrentUser() async {
    try {
      _errorHandler.logInfo('AuthService: Getting current user');
      final user = await _authRepository.getCurrentUser();
      
      if (user != null) {
        _errorHandler.logInfo('AuthService: Current user: ${user.username}');
      } else {
        _errorHandler.logInfo('AuthService: No current user');
      }
      
      return user;
    } catch (e) {
      _errorHandler.handleError(e, context: 'AuthService.getCurrentUser');
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      _errorHandler.logInfo('AuthService: Checking authentication status');
      final isAuth = await _authRepository.isAuthenticated();
      _errorHandler.logInfo('AuthService: Authentication status: $isAuth');
      return isAuth;
    } catch (e) {
      _errorHandler.handleError(e, context: 'AuthService.isAuthenticated');
      return false;
    }
  }

  /// Validate current session
  Future<bool> validateSession() async {
    try {
      _errorHandler.logInfo('AuthService: Validating session');
      final isValid = await _authRepository.validateSession();
      _errorHandler.logInfo('AuthService: Session validation result: $isValid');
      return isValid;
    } catch (e) {
      _errorHandler.handleError(e, context: 'AuthService.validateSession');
      return false;
    }
  }

  /// Refresh session
  Future<bool> refreshSession() async {
    try {
      _errorHandler.logInfo('AuthService: Refreshing session');
      final refreshed = await _authRepository.refreshSession();
      _errorHandler.logInfo('AuthService: Session refresh result: $refreshed');
      return refreshed;
    } catch (e) {
      _errorHandler.handleError(e, context: 'AuthService.refreshSession');
      return false;
    }
  }

  /// Save user credentials
  Future<void> saveCredentials(String username, String password) async {
    try {
      _errorHandler.logInfo('AuthService: Saving credentials for user: $username');
      await _authRepository.saveCredentials(username, password);
      _errorHandler.logInfo('AuthService: Credentials saved successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'AuthService.saveCredentials');
      rethrow;
    }
  }

  /// Clear saved credentials
  Future<void> clearCredentials() async {
    try {
      _errorHandler.logInfo('AuthService: Clearing saved credentials');
      await _authRepository.clearCredentials();
      _errorHandler.logInfo('AuthService: Credentials cleared successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'AuthService.clearCredentials');
      rethrow;
    }
  }

  /// Get user-friendly error message
  String getUserFriendlyErrorMessage(dynamic error) {
    return _errorHandler.getUserFriendlyMessage(error);
  }
}
