import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {

  SessionManager._internal() {
    _logger = Logger();
    _dio = Dio();
    _initializeHeaders();
    _setupInterceptors();
  }
  static SessionManager? _instance;
  late Dio _dio;
  late Logger _logger;
  late SharedPreferences _prefs;
  
  // Session data
  final Map<String, String> _cookies = {};
  Map<String, String> _headers = {};
  String? _sessionId;
  DateTime? _lastActivity;
  bool _isActive = false;

  static SessionManager get instance {
    _instance ??= SessionManager._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  /// Initialize default headers (完全匹配浏览器请求)
  void _initializeHeaders() {
    _headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36',
      'Accept': '*/*',
      'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
      'Accept-Encoding': 'gzip, deflate, br, zstd',
      'sec-ch-ua': '"Chromium";v="140", "Not=A?Brand";v="24", "Google Chrome";v="140"',
      'sec-ch-ua-mobile': '?0',
      'sec-ch-ua-platform': '"Windows"',
      'Sec-Fetch-Dest': 'empty',
      'Sec-Fetch-Mode': 'cors',
      'Sec-Fetch-Site': 'same-origin',
    };
    
    _dio.options.headers.addAll(_headers);
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 5);
    _dio.options.sendTimeout = const Duration(seconds: 5);
    
    // 添加必要的静态Cookie,完全模拟浏览器行为
    _cookies['source'] = '';
    _cookies['thirdRegist'] = '0';
    _cookies['writenote'] = 'yes';
    
    // 生成随机videojs_id Cookie (模拟浏览器行为)
    _cookies['videojs_id'] = _generateVideojsId();
  }

  /// Setup interceptors to automatically handle cookies
  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Dio will automatically use the Cookie header set in options.headers
        handler.next(options);
      },
      onResponse: (response, handler) {
        // Extract cookies from response and update our cookie store
        _extractCookiesFromResponse(response);
        handler.next(response);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  /// Extract cookies from response headers
  void _extractCookiesFromResponse(Response response) {
    final setCookieHeaders = response.headers['set-cookie'];
    if (setCookieHeaders != null) {
      for (final setCookie in setCookieHeaders) {
        final parts = setCookie.split(';');
        if (parts.isNotEmpty) {
          final cookiePair = parts[0].split('=');
          if (cookiePair.length == 2) {
            final key = cookiePair[0].trim();
            final value = cookiePair[1].trim();
            if (value.isNotEmpty) {
              _cookies[key] = value;
              _logger.d('Updated cookie from response: $key=$value');
            }
          }
        }
      }
      // Update Cookie header for future requests
      updateCookies({});
    }
  }

  /// Initialize session manager with SharedPreferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSessionFromStorage();
  }

  /// Update cookies (replicates chaoxing_py cookie management)
  void updateCookies(Map<String, String> cookies) {
    _cookies.addAll(cookies);
    _dio.options.headers['Cookie'] = _cookies.entries
        .map((e) => '${e.key}=${e.value}')
        .join('; ');
    _logger.d('Updated cookies: $_cookies');
    
    // Auto-save cookies to storage if session is active
    if (_isActive && _sessionId != null) {
      saveSessionToStorage();
    }
  }

  /// Update headers
  void updateHeaders(Map<String, String> headers) {
    _headers.addAll(headers);
    _dio.options.headers.addAll(headers);
    _logger.d('Updated headers: $headers');
  }

  /// Set session ID
  void setSessionId(String sessionId) {
    _sessionId = sessionId;
    _isActive = true;
    _lastActivity = DateTime.now();
    _logger.d('Session ID set: $sessionId');
  }

  /// Get session ID
  String? get sessionId => _sessionId;

  /// Check if session is active
  bool get isActive => _isActive;

  /// Get last activity time
  DateTime? get lastActivity => _lastActivity;

  /// Validate session (check if it's still valid)
  /// Replicates chaoxing_py _validate_cookie_session logic
  Future<bool> validateSession() async {
    if (!_isActive || _sessionId == null) {
      return false;
    }

    // Check if _uid cookie exists
    if (_cookies['_uid'] == null && _cookies['UID'] == null) {
      return false;
    }

    try {
      // Make a test request to validate session
      final response = await _dio.post(
        'https://mooc2-ans.chaoxing.com/mooc2-ans/visit/courselistdata',
        data: {
          'courseType': 1,
          'courseFolderId': 0,
          'query': '',
          'superstarClass': 0,
        },
      );
      
      if (response.statusCode == 200) {
        // Check if response contains login redirect
        final responseText = response.data.toString();
        if (responseText.contains('passport2.chaoxing.com') || 
            responseText.toLowerCase().contains('login')) {
          return false;
        }
        _lastActivity = DateTime.now();
        return true;
      }
    } catch (e) {
      _logger.e('Session validation failed: $e');
    }
    
    return false;
  }

  /// Clear session
  void clearSession() {
    _cookies.clear();
    _headers.clear();
    _sessionId = null;
    _isActive = false;
    _lastActivity = null;
    
    _dio.options.headers.remove('Cookie');
    _logger.d('Session cleared');
  }

  /// Save session to storage
  Future<void> saveSessionToStorage() async {
    if (_sessionId != null) {
      await _prefs.setString('session_id', _sessionId!);
      await _prefs.setBool('is_active', _isActive);
      await _prefs.setString('last_activity', _lastActivity?.toIso8601String() ?? '');
      
      // Save cookies
      final cookieString = _cookies.entries
          .map((e) => '${e.key}=${e.value}')
          .join(';');
      await _prefs.setString('cookies', cookieString);
      
      _logger.d('Session saved to storage');
    }
  }

  /// Load session from storage
  Future<void> _loadSessionFromStorage() async {
    _sessionId = _prefs.getString('session_id');
    _isActive = _prefs.getBool('is_active') ?? false;
    final lastActivityString = _prefs.getString('last_activity');
    if (lastActivityString != null) {
      _lastActivity = DateTime.tryParse(lastActivityString);
    }
    
    // Load cookies
    final cookieString = _prefs.getString('cookies');
    if (cookieString != null && cookieString.isNotEmpty) {
      final cookiePairs = cookieString.split(';');
      for (final pair in cookiePairs) {
        final parts = pair.split('=');
        if (parts.length == 2) {
          _cookies[parts[0].trim()] = parts[1].trim();
        }
      }
      updateCookies({}); // Apply loaded cookies
    }
    
    _logger.d('Session loaded from storage: $_sessionId');
  }

  /// Get FID from cookies (replicates chaoxing_py get_fid)
  String? getFid() {
    return _cookies['fid'];
  }

  /// Get UID from cookies (replicates chaoxing_py get_uid)
  String? getUid() {
    if (_cookies.containsKey('_uid')) {
      return _cookies['_uid'];
    }
    if (_cookies.containsKey('UID')) {
      return _cookies['UID'];
    }
    _logger.w('Cannot get UID from cookies');
    return null;
  }

  /// Get current timestamp (replicates chaoxing_py get_timestamp)
  String getTimestamp() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  /// Generate random videojs_id Cookie (模拟浏览器video.js生成的Cookie)
  String _generateVideojsId() {
    // 生成类似 2315850 的随机数字
    final random = DateTime.now().millisecondsSinceEpoch % 10000000;
    return random.toString();
  }

  /// Add rate limiting (replicates chaoxing_py rate limiting)
  Future<void> rateLimit(Duration delay) async {
    await Future.delayed(delay);
  }
}
