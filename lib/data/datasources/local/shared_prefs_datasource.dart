import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class SharedPrefsDataSource {

  SharedPrefsDataSource._internal() {
    _logger = Logger();
  }
  static SharedPrefsDataSource? _instance;
  late SharedPreferences _prefs;
  late Logger _logger;

  static SharedPrefsDataSource get instance {
    _instance ??= SharedPrefsDataSource._internal();
    return _instance!;
  }

  /// Initialize SharedPreferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _logger.d('SharedPreferences initialized');
  }

  /// Save user credentials (encrypted)
  Future<bool> saveUserCredentials(String username, String password) async {
    try {
      await _prefs.setString('username', username);
      await _prefs.setString('password', password);
      _logger.d('User credentials saved');
      return true;
    } catch (e) {
      _logger.e('Failed to save user credentials: $e');
      return false;
    }
  }

  /// Get user credentials
  Future<Map<String, String?>> getUserCredentials() async {
    try {
      final username = _prefs.getString('username');
      final password = _prefs.getString('password');
      return {'username': username, 'password': password};
    } catch (e) {
      _logger.e('Failed to get user credentials: $e');
      return {'username': null, 'password': null};
    }
  }

  /// Save configuration settings
  Future<bool> saveConfiguration(Map<String, dynamic> config) async {
    try {
      for (final entry in config.entries) {
        final key = entry.key;
        final value = entry.value;
        
        if (value is String) {
          await _prefs.setString(key, value);
        } else if (value is int) {
          await _prefs.setInt(key, value);
        } else if (value is double) {
          await _prefs.setDouble(key, value);
        } else if (value is bool) {
          await _prefs.setBool(key, value);
        } else if (value is List<String>) {
          await _prefs.setStringList(key, value);
        }
      }
      _logger.d('Configuration saved: $config');
      return true;
    } catch (e) {
      _logger.e('Failed to save configuration: $e');
      return false;
    }
  }

  /// Get configuration settings
  Future<Map<String, dynamic>> getConfiguration() async {
    try {
      final keys = _prefs.getKeys();
      final config = <String, dynamic>{};
      
      for (final key in keys) {
        // Skip user credentials
        if (key == 'username' || key == 'password') continue;
        
        final value = _prefs.get(key);
        if (value != null) {
          config[key] = value;
        }
      }
      
      _logger.d('Configuration loaded: $config');
      return config;
    } catch (e) {
      _logger.e('Failed to get configuration: $e');
      return {};
    }
  }

  /// Save playback speed setting
  Future<bool> savePlaybackSpeed(double speed) async {
    try {
      await _prefs.setDouble('playback_speed', speed);
      _logger.d('Playback speed saved: $speed');
      return true;
    } catch (e) {
      _logger.e('Failed to save playback speed: $e');
      return false;
    }
  }

  /// Get playback speed setting
  Future<double> getPlaybackSpeed() async {
    try {
      return _prefs.getDouble('playback_speed') ?? 1.0;
    } catch (e) {
      _logger.e('Failed to get playback speed: $e');
      return 1.0;
    }
  }

  /// Save retry behavior setting
  Future<bool> saveRetryBehavior(String behavior) async {
    try {
      await _prefs.setString('retry_behavior', behavior);
      _logger.d('Retry behavior saved: $behavior');
      return true;
    } catch (e) {
      _logger.e('Failed to save retry behavior: $e');
      return false;
    }
  }

  /// Get retry behavior setting
  Future<String> getRetryBehavior() async {
    try {
      return _prefs.getString('retry_behavior') ?? 'retry';
    } catch (e) {
      _logger.e('Failed to get retry behavior: $e');
      return 'retry';
    }
  }

  /// Save selected courses
  Future<bool> saveSelectedCourses(List<String> courseIds) async {
    try {
      await _prefs.setStringList('selected_courses', courseIds);
      _logger.d('Selected courses saved: $courseIds');
      return true;
    } catch (e) {
      _logger.e('Failed to save selected courses: $e');
      return false;
    }
  }

  /// Get selected courses
  Future<List<String>> getSelectedCourses() async {
    try {
      return _prefs.getStringList('selected_courses') ?? [];
    } catch (e) {
      _logger.e('Failed to get selected courses: $e');
      return [];
    }
  }

  /// Save question bank configuration
  Future<bool> saveQuestionBankConfig(Map<String, dynamic> config) async {
    try {
      await _prefs.setString('question_bank_provider', config['provider'] ?? '');
      await _prefs.setString('question_bank_token', config['token'] ?? '');
      await _prefs.setBool('question_bank_submit', config['submit'] ?? false);
      await _prefs.setDouble('question_bank_delay', config['delay'] ?? 0.0);
      await _prefs.setDouble('question_bank_cover_rate', config['cover_rate'] ?? 0.0);
      _logger.d('Question bank config saved: $config');
      return true;
    } catch (e) {
      _logger.e('Failed to save question bank config: $e');
      return false;
    }
  }

  /// Get question bank configuration
  Future<Map<String, dynamic>> getQuestionBankConfig() async {
    try {
      return {
        'provider': _prefs.getString('question_bank_provider') ?? '',
        'token': _prefs.getString('question_bank_token') ?? '',
        'submit': _prefs.getBool('question_bank_submit') ?? false,
        'delay': _prefs.getDouble('question_bank_delay') ?? 0.0,
        'cover_rate': _prefs.getDouble('question_bank_cover_rate') ?? 0.0,
      };
    } catch (e) {
      _logger.e('Failed to get question bank config: $e');
      return {};
    }
  }

  /// Clear all data
  Future<bool> clearAll() async {
    try {
      await _prefs.clear();
      _logger.d('All SharedPreferences data cleared');
      return true;
    } catch (e) {
      _logger.e('Failed to clear SharedPreferences: $e');
      return false;
    }
  }

  /// Clear user credentials only
  Future<bool> clearUserCredentials() async {
    try {
      await _prefs.remove('username');
      await _prefs.remove('password');
      _logger.d('User credentials cleared');
      return true;
    } catch (e) {
      _logger.e('Failed to clear user credentials: $e');
      return false;
    }
  }
}
