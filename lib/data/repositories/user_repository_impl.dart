import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../datasources/local/shared_prefs_datasource.dart';
import '../datasources/local/hive_datasource.dart';
import '../datasources/remote/chaoxing_api_datasource.dart';
import '../../core/session/session_manager.dart';
import '../../core/errors/error_handler.dart';

/// User repository implementation
class UserRepositoryImpl implements AuthRepository {

  UserRepositoryImpl(
    this._sharedPrefs,
    this._hive,
    this._apiDataSource,
    this._sessionManager,
    this._errorHandler,
  );
  final SharedPrefsDataSource _sharedPrefs;
  final HiveDataSource _hive;
  final ChaoxingApiDataSource _apiDataSource;
  final SessionManager _sessionManager;
  final ErrorHandler _errorHandler;

  @override
  Future<User?> login(String username, String password) async {
    try {
      _errorHandler.logInfo('Starting login process for user: $username');

      // Use real Chaoxing API for login
      final loginResult = await _apiDataSource.login(username, password);

      if (loginResult['success'] == true) {
        // Create user entity from successful login
        final user = User(
          id: _sessionManager.sessionId ?? 'unknown',
          username: username,
          name: username, // Default to username
          avatar: '', // Will be populated from API if available
          lastLogin: DateTime.now(),
        );

        // Save user data to local storage
        await _saveUserToStorage(user);
        
        _errorHandler.logInfo('Login successful for user: ${user.username}');
        return user;
      } else {
        _errorHandler.logWarning('Login failed: ${loginResult['message']}');
        return null;
      }
    } catch (e) {
      _errorHandler.handleError(e, context: 'UserRepositoryImpl.login');
      return null;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      // Try to get user from local storage first
      final user = await _getUserFromStorage();
      
      if (user != null) {
        // Validate session
        if (await _apiDataSource.validateSession()) {
          return user;
        } else {
          // Session expired, clear local data
          await _clearUserFromStorage();
          return null;
        }
      }
      
      return null;
    } catch (e) {
      _errorHandler.handleError(e, context: 'UserRepositoryImpl.getCurrentUser');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      _errorHandler.logInfo('Logging out user');
      
      // Logout from API
      await _apiDataSource.logout();
      
      // Clear local storage
      await _clearUserFromStorage();
      
      _errorHandler.logInfo('Logout completed');
    } catch (e) {
      _errorHandler.handleError(e, context: 'UserRepositoryImpl.logout');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final user = await getCurrentUser();
      return user != null;
    } catch (e) {
      _errorHandler.handleError(e, context: 'UserRepositoryImpl.isAuthenticated');
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final user = await getCurrentUser();
      return user != null;
    } catch (e) {
      _errorHandler.handleError(e, context: 'UserRepositoryImpl.isLoggedIn');
      return false;
    }
  }

  /// Save user to local storage
  Future<void> _saveUserToStorage(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await _hive.saveCourse(user.id, userModel.toJson());
      await _sharedPrefs.saveUserCredentials(user.username, '');
    } catch (e) {
      _errorHandler.handleError(e, context: 'UserRepositoryImpl._saveUserToStorage');
    }
  }

  /// Get user from local storage
  Future<User?> _getUserFromStorage() async {
    try {
      final credentials = await _sharedPrefs.getUserCredentials();
      if (credentials['username'] != null) {
        final userData = _hive.getCourse(credentials['username']!);
        if (userData != null) {
          return UserModel.fromJson(userData).toEntity();
        }
      }
      return null;
    } catch (e) {
      _errorHandler.handleError(e, context: 'UserRepositoryImpl._getUserFromStorage');
      return null;
    }
  }

  /// Clear user from local storage
  Future<void> _clearUserFromStorage() async {
    try {
      final credentials = await _sharedPrefs.getUserCredentials();
      if (credentials['username'] != null) {
        await _hive.clearCourseData(credentials['username']!);
        await _sharedPrefs.clearUserCredentials();
      }
    } catch (e) {
      _errorHandler.handleError(e, context: 'UserRepositoryImpl._clearUserFromStorage');
    }
  }

  @override
  Future<void> saveCredentials(String username, String password) async {
    try {
      _errorHandler.logInfo('Saving credentials for user: $username');
      await _sharedPrefs.saveUserCredentials(username, password);
      _errorHandler.logInfo('Credentials saved successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'UserRepositoryImpl.saveCredentials');
    }
  }

  @override
  Future<void> clearCredentials() async {
    try {
      _errorHandler.logInfo('Clearing saved credentials');
      await _sharedPrefs.clearUserCredentials();
      _errorHandler.logInfo('Credentials cleared successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'UserRepositoryImpl.clearCredentials');
    }
  }

  @override
  Future<bool> validateSession() async {
    try {
      _errorHandler.logInfo('Validating session');
      final isValid = await _apiDataSource.validateSession();
      _errorHandler.logInfo('Session validation result: $isValid');
      return isValid;
    } catch (e) {
      _errorHandler.handleError(e, context: 'UserRepositoryImpl.validateSession');
      return false;
    }
  }

  @override
  Future<bool> refreshSession() async {
    try {
      _errorHandler.logInfo('Refreshing session');
      
      // TODO: Implement actual session refresh logic
      // This is a placeholder implementation
      final refreshed = await _makeRefreshRequest();
      
      _errorHandler.logInfo('Session refresh result: $refreshed');
      return refreshed;
    } catch (e) {
      _errorHandler.handleError(e, context: 'UserRepositoryImpl.refreshSession');
      return false;
    }
  }

  /// Make refresh request (placeholder implementation)
  Future<bool> _makeRefreshRequest() async {
    // TODO: Implement actual session refresh logic
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return true;
  }
}
