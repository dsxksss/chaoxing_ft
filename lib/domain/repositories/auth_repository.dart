import '../entities/user.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Login with username and password
  /// Returns User entity on success, null on failure
  Future<User?> login(String username, String password);

  /// Logout current user
  Future<void> logout();

  /// Get current authenticated user
  Future<User?> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Save user credentials (encrypted)
  Future<void> saveCredentials(String username, String password);

  /// Clear saved credentials
  Future<void> clearCredentials();

  /// Validate session
  Future<bool> validateSession();

  /// Refresh session
  Future<bool> refreshSession();
}
