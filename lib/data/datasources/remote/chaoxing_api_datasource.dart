import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/crypto/aes_cipher.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/html/html_parser.dart';
import '../../../../core/html/html_parser_fixed.dart';

/// Chaoxing API data source - implements real API calls
/// This replicates chaoxing_py API behavior exactly
class ChaoxingApiDataSource {

  ChaoxingApiDataSource(
    this._sessionManager,
    this._aesCipher,
    this._errorHandler,
  );
  final SessionManager _sessionManager;
  final AESCipher _aesCipher;
  final ErrorHandler _errorHandler;
  final Logger _logger = Logger();

  /// Parse response data - handle both Map and String cases
  Map<String, dynamic> _parseResponseData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData;
    } else if (responseData is String) {
      try {
        return Map<String, dynamic>.from(
          jsonDecode(responseData) as Map<String, dynamic>
        );
      } catch (e) {
        _logger.e('Failed to parse JSON response: $e');
        throw Exception('服务器响应格式错误');
      }
    } else {
      _logger.e('Response data is neither Map nor String: ${responseData.runtimeType}');
      throw Exception('服务器响应格式错误');
    }
  }

  /// Login to Chaoxing platform (replicates chaoxing_py login)
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      _logger.i('Starting Chaoxing login for user: $username');

      // Encrypt credentials using AES (same as chaoxing_py)
      final encryptedUsername = _aesCipher.encryptUsername(username);
      final encryptedPassword = _aesCipher.encryptPassword(password);

      // Prepare login data (exact same as chaoxing_py)
      final loginData = {
        'fid': '-1',
        'uname': encryptedUsername,
        'password': encryptedPassword,
        'refer': 'https%3A%2F%2Fi.chaoxing.com',
        't': true,
        'forbidotherlogin': 0,
        'validate': '',
        'doubleFactorLogin': 0,
        'independentId': 0,
      };

      // Make login request to real Chaoxing API
      final response = await _sessionManager.dio.post(
        'https://passport2.chaoxing.com/fanyalogin',
        data: loginData,
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          headers: {
            // Only use basic headers like Python version
            // No Content-Type, Referer, or Origin headers
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Debug: Log response data structure
        _logger.d('Response data type: ${responseData.runtimeType}');
        _logger.d('Response data: $responseData');
        
        // Parse response data
        final parsedData = _parseResponseData(responseData);
        
        if (parsedData['status'] == true) {
          // Extract cookies from response
          final cookies = <String, String>{};
          final cookieHeaders = response.headers['set-cookie'];
          if (cookieHeaders != null) {
            _logger.d('Cookie headers type: ${cookieHeaders.runtimeType}');
            _logger.d('Cookie headers: $cookieHeaders');
            
            // Dio headers['set-cookie'] returns List<String>
            for (final cookie in cookieHeaders) {
              final parts = cookie.split(';')[0].split('=');
              if (parts.length == 2) {
                cookies[parts[0].trim()] = parts[1].trim();
              }
            }
          }
          
          // Update session with cookies
          _sessionManager.updateCookies(cookies);
          
          // Set session as active
          _sessionManager.setSessionId(username);
          
          // Save session to storage
          await _sessionManager.saveSessionToStorage();
          
          _logger.i('Login successful for user: $username');
          return {
            'success': true,
            'message': '登录成功',
            'cookies': cookies,
          };
        } else {
          final errorMsg = parsedData['msg2'] ?? parsedData['msg'] ?? '登录失败';
          _logger.w('Login failed for user: $username - $errorMsg');
          return {
            'success': false,
            'message': errorMsg,
          };
        }
      } else {
        _logger.e('Login request failed with status: ${response.statusCode}');
        return {
          'success': false,
          'message': '网络请求失败',
        };
      }
    } catch (e) {
      _logger.e('Login error: $e');
      _errorHandler.handleError(e, context: 'ChaoxingApiDataSource.login');
      return {
        'success': false,
        'message': '登录过程中发生错误: ${e.toString()}',
      };
    }
  }

  /// Get course list from Chaoxing API
  /// Strictly replicates chaoxing_py get_course_list function
  Future<List<Map<String, dynamic>>> getCourseList() async {
    _logger.d('正在读取所有的课程列表...');
    
    if (!_sessionManager.isActive) {
      throw Exception('Session is not valid, please login again');
    }

    try {
      // First, get main course list - exactly like chaoxing_py
      final mainCourseList = await _getMainCourseList();
      
      // Then get course folders and their courses - exactly like chaoxing_py
      final folderCourseList = await _getFolderCourseList();
      
      // Combine all courses - exactly like chaoxing_py
      final allCourses = [...mainCourseList, ...folderCourseList];
      
      _logger.i('课程列表读取完毕，共 ${allCourses.length} 门课程');
      return allCourses;
      
    } catch (e) {
      _logger.e('Error getting course list: $e');
      _errorHandler.handleError(e, context: 'ChaoxingApiDataSource.getCourseList');
      return [];
    }
  }

  /// Get main course list - replicates chaoxing_py main course list logic
  Future<List<Map<String, dynamic>>> _getMainCourseList() async {
    final response = await _sessionManager.dio.post(
      'https://mooc2-ans.chaoxing.com/mooc2-ans/visit/courselistdata',
      data: {
        'courseType': 1,
        'courseFolderId': 0,
        'query': '',
        'superstarClass': 0,
      },
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
        headers: {
          'Referer': 'https://mooc2-ans.chaoxing.com/mooc2-ans/visit/interaction?moocDomain=https://mooc1-1.chaoxing.com/mooc-ans',
        },
      ),
    );

    if (response.statusCode == 200) {
      final responseData = response.data;
      
      if (responseData is String) {
        // Parse HTML using our parser - exactly like chaoxing_py
        final htmlParser = ChaoxingHtmlParser.instance;
        return htmlParser.parseCourseList(responseData);
      } else {
        _logger.e('Unexpected response data type: ${responseData.runtimeType}');
        return [];
      }
    } else {
      _logger.e('Failed to get main course list: ${response.statusCode}');
      return [];
    }
  }

  /// Get course folders and their courses - replicates chaoxing_py folder logic
  Future<List<Map<String, dynamic>>> _getFolderCourseList() async {
    try {
      // Get interaction page to get folders - exactly like chaoxing_py
      final interactionResponse = await _sessionManager.dio.get(
        'https://mooc2-ans.chaoxing.com/mooc2-ans/visit/interaction',
      );

      if (interactionResponse.statusCode != 200) {
        _logger.e('Failed to get interaction page: ${interactionResponse.statusCode}');
        return [];
      }

      final interactionData = interactionResponse.data;
      if (interactionData is! String) {
        _logger.e('Unexpected interaction response data type: ${interactionData.runtimeType}');
        return [];
      }

      // Parse folders - exactly like chaoxing_py
      final htmlParser = ChaoxingHtmlParser.instance;
      final courseFolders = htmlParser.parseCourseFolder(interactionData);
      
      final allFolderCourses = <Map<String, dynamic>>[];
      
      // Get courses for each folder - exactly like chaoxing_py
      for (final folder in courseFolders) {
        try {
          final folderResponse = await _sessionManager.dio.post(
            'https://mooc2-ans.chaoxing.com/mooc2-ans/visit/courselistdata',
            data: {
              'courseType': 1,
              'courseFolderId': folder['id'],
              'query': '',
              'superstarClass': 0,
            },
            options: Options(
              contentType: 'application/x-www-form-urlencoded',
            ),
          );

          if (folderResponse.statusCode == 200) {
            final folderData = folderResponse.data;
            if (folderData is String) {
              final folderCourses = htmlParser.parseCourseList(folderData);
              allFolderCourses.addAll(folderCourses);
            }
          }
        } catch (e) {
          _logger.w('Error getting courses for folder ${folder['id']}: $e');
          continue;
        }
      }
      
      return allFolderCourses;
      
    } catch (e) {
      _logger.e('Error getting folder course list: $e');
      return [];
    }
  }

  /// Get course detail from Chaoxing API
  /// Note: This method is not used in chaoxing_py, course details are extracted from course list
  Future<Map<String, dynamic>?> getCourseDetail(String courseId) async {
    _logger.w('getCourseDetail is not implemented in chaoxing_py, course details are extracted from course list');
    return null;
  }

  /// Validate session by making a test request
  Future<bool> validateSession() async {
    try {
      final response = await _sessionManager.dio.post(
        'https://mooc2-ans.chaoxing.com/mooc2-ans/visit/courselistdata',
        data: {
          'courseType': 1,
          'courseFolderId': 0,
          'query': '',
          'superstarClass': 0,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Check if response contains login redirect
        final responseText = response.data.toString();
        if (responseText.contains('passport2.chaoxing.com') || 
            responseText.contains('login')) {
          return false;
        }
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Session validation error: $e');
      return false;
    }
  }

  /// Logout from Chaoxing platform
  Future<void> logout() async {
    try {
      _logger.i('Logging out from Chaoxing platform');
      
      // Clear session
      _sessionManager.clearSession();
      
      // Make logout request if needed
      await _sessionManager.dio.get(
        'https://passport2.chaoxing.com/logout',
      );
      
      _logger.i('Logout successful');
    } catch (e) {
      _logger.e('Logout error: $e');
      // Still clear session even if logout request fails
      _sessionManager.clearSession();
    }
  }

  /// Get course points (chapters)
  /// Replicates chaoxing_py get_course_point
  Future<Map<String, dynamic>> getCoursePoint(
    String courseId,
    String clazzId,
    String cpi,
  ) async {
    try {
      _logger.i('Fetching course points for course: $courseId');

      const url = 'https://mooc2-ans.chaoxing.com/mooc2-ans/mycourse/studentcourse';
      final params = {
        'courseid': courseId,
        'clazzid': clazzId,
        'cpi': cpi,
        'ut': 's',
      };

      final response = await _sessionManager.dio.get(
        url,
        queryParameters: params,
        options: Options(headers: {
          'Referer': 'https://mooc2-ans.chaoxing.com/mooc2-ans/visit/interaction?moocDomain=https://mooc1-1.chaoxing.com/mooc-ans',
        }),
      );

      if (response.statusCode == 200) {
        _logger.i('Course points retrieved successfully');
        
        // Response is HTML, parse it using our parser
        final responseData = response.data.toString();
        final htmlParser = ChaoxingHtmlParser.instance;
        final coursePoints = htmlParser.parseCoursePoint(responseData);
        
        return {
          'success': true,
          'points': coursePoints['points'],
        };
      } else {
        _logger.e('Course points request failed: ${response.statusCode}');
        return {'success': false};
      }
    } catch (e) {
      _logger.e('Get course points error: $e');
      _errorHandler.handleError(e, context: 'ChaoxingApiDataSource.getCoursePoint');
      return {'success': false};
    }
  }

  /// Get job list (task cards)
  /// Replicates chaoxing_py get_job_list
  Future<Map<String, dynamic>> getJobList({
    required Map<String, dynamic> course,
    required Map<String, dynamic> point,
  }) async {
    try {
      _logger.i('Fetching job list for point: ${point['id']}');

      final cardsParams = {
        'clazzid': course['clazzId'],
        'courseid': course['courseId'],
        'knowledgeid': point['id'],
        'ut': 's',
        'cpi': course['cpi'],
        'v': '2025-0424-1038-3',
        'mooc2': '1',
      };

      final allJobs = <Map<String, dynamic>>[];
      final Map<String, dynamic> jobInfo = {};

      // Try different num values (0-6)
      for (final num in ['0', '1', '2', '3', '4', '5', '6']) {
        cardsParams['num'] = num;

        final response = await _sessionManager.dio.get(
          'https://mooc1.chaoxing.com/mooc-ans/knowledge/cards',
          queryParameters: cardsParams,
        );

        if (response.statusCode != 200) {
          _logger.e('Job list request failed: ${response.statusCode}');
          continue;
        }

        // Response is HTML, parse it using our fixed parser
        final html = response.data.toString();
        final htmlParser = ChaoxingHtmlParserFixed.instance;
        final jobListResult = htmlParser.parseJobList(html);
        
        return {
          'success': true,
          'jobList': jobListResult['jobList'],
          'jobInfo': jobListResult['jobInfo'],
        };
      }

      return {
        'success': true,
        'jobList': allJobs,
        'jobInfo': jobInfo,
      };
    } catch (e) {
      _logger.e('Get job list error: $e');
      _errorHandler.handleError(e, context: 'ChaoxingApiDataSource.getJobList');
      return {
        'success': false,
        'jobList': <Map<String, dynamic>>[],
        'jobInfo': <String, dynamic>{},
      };
    }
  }
}
