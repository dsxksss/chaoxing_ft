import '../../domain/entities/user.dart';
import '../../services/auth/auth_service.dart';
import '../providers/base_provider.dart';

/// Authentication provider for state management
class AuthProvider extends BaseProvider {

  AuthProvider(this._authService);
  final AuthService _authService;
  
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  @override
  bool get isLoading => _isLoading;
  @override
  String? get errorMessage => _errorMessage;

  /// Login with username and password
  Future<bool> login(String username, String password) async {
    try {
      setLoading(true);
      clearError();

      final user = await _authService.login(username, password);
      
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        setError('登录失败，请检查用户名和密码');
        return false;
      }
    } catch (e) {
      final errorMessage = _authService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      setLoading(true);
      clearError();

      await _authService.logout();
      
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      final errorMessage = _authService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  /// Get current user
  Future<void> getCurrentUser() async {
    try {
      setLoading(true);
      clearError();

      final user = await _authService.getCurrentUser();
      
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
      } else {
        _currentUser = null;
        _isAuthenticated = false;
      }
      
      notifyListeners();
    } catch (e) {
      final errorMessage = _authService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  /// Check authentication status
  Future<void> checkAuthenticationStatus() async {
    try {
      setLoading(true);
      clearError();

      final isAuth = await _authService.isAuthenticated();
      
      if (isAuth) {
        await getCurrentUser();
      } else {
        _currentUser = null;
        _isAuthenticated = false;
      }
      
      notifyListeners();
    } catch (e) {
      final errorMessage = _authService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  /// Validate session
  Future<bool> validateSession() async {
    try {
      final isValid = await _authService.validateSession();
      
      if (!isValid) {
        _currentUser = null;
        _isAuthenticated = false;
        notifyListeners();
      }
      
      return isValid;
    } catch (e) {
      final errorMessage = _authService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
      return false;
    }
  }

  /// Refresh session
  Future<bool> refreshSession() async {
    try {
      setLoading(true);
      clearError();

      final refreshed = await _authService.refreshSession();
      
      if (refreshed) {
        await getCurrentUser();
      } else {
        _currentUser = null;
        _isAuthenticated = false;
      }
      
      notifyListeners();
      return refreshed;
    } catch (e) {
      final errorMessage = _authService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Clear error
  @override
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Set loading state
  @override
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  @override
  void setError(String? error) {
    super.setError(error);
  }

}
