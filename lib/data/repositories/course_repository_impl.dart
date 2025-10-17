import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../models/course_model.dart';
import '../datasources/local/hive_datasource.dart';
import '../datasources/remote/chaoxing_api_datasource.dart';
import '../../core/errors/error_handler.dart';

/// Course repository implementation
class CourseRepositoryImpl implements CourseRepository {

  CourseRepositoryImpl(
    this._hive,
    this._apiDataSource,
    this._errorHandler,
  );
  final HiveDataSource _hive;
  final ChaoxingApiDataSource _apiDataSource;
  final ErrorHandler _errorHandler;

  @override
  Future<List<Course>> getCourses() async {
    try {
      _errorHandler.logInfo('Fetching courses from Chaoxing API');

      // Get courses from real Chaoxing API
      final coursesData = await _apiDataSource.getCourseList();

      if (coursesData.isNotEmpty) {
        // Convert API data to Course entities
        final courses = coursesData.map((data) => _mapApiDataToCourse(data)).toList();
        
        // Cache courses locally
        await _cacheCourses(courses);
        
        _errorHandler.logInfo('Retrieved ${courses.length} courses from API');
        return courses;
      } else {
        // Try to get cached courses if API fails
        final cachedCourses = await _getCachedCourses();
        if (cachedCourses.isNotEmpty) {
          _errorHandler.logWarning('Using cached courses due to API failure');
          return cachedCourses;
        }
        
        _errorHandler.logWarning('No courses found from API or cache');
        return [];
      }
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseRepositoryImpl.getCourses');
      
      // Fallback to cached courses
      try {
        final cachedCourses = await _getCachedCourses();
        _errorHandler.logWarning('Using cached courses due to error: ${e.toString()}');
        return cachedCourses;
      } catch (cacheError) {
        _errorHandler.handleError(cacheError, context: 'CourseRepositoryImpl.getCourses.cache');
        return [];
      }
    }
  }

  @override
  Future<Course?> getCourseById(String courseId) async {
    try {
      _errorHandler.logInfo('Fetching course detail for ID: $courseId');

      // Get course detail from real Chaoxing API
      final courseData = await _apiDataSource.getCourseDetail(courseId);

      if (courseData != null) {
        final course = _mapApiDataToCourse(courseData);
        
        // Cache the course detail
        await _cacheCourse(course);
        
        _errorHandler.logInfo('Retrieved course detail for ID: $courseId');
        return course;
      } else {
        // Try to get from cache
        final cachedCourse = await _getCachedCourseById(courseId);
        if (cachedCourse != null) {
          _errorHandler.logWarning('Using cached course detail for ID: $courseId');
          return cachedCourse;
        }
        
        _errorHandler.logWarning('Course not found for ID: $courseId');
        return null;
      }
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseRepositoryImpl.getCourseById');
      
      // Fallback to cached course
      try {
        final cachedCourse = await _getCachedCourseById(courseId);
        if (cachedCourse != null) {
          _errorHandler.logWarning('Using cached course due to error: ${e.toString()}');
          return cachedCourse;
        }
      } catch (cacheError) {
        _errorHandler.handleError(cacheError, context: 'CourseRepositoryImpl.getCourseById.cache');
      }
      
      return null;
    }
  }

  Future<List<Course>> searchCourses(String query) async {
    try {
      _errorHandler.logInfo('Searching courses with query: $query');

      // Get all courses first
      final allCourses = await getCourses();
      
      if (query.isEmpty) {
        return allCourses;
      }

      // Filter courses by query (case-insensitive)
      final filteredCourses = allCourses.where((course) {
        return course.name.toLowerCase().contains(query.toLowerCase()) ||
               (course.teacher?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
               (course.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();

      _errorHandler.logInfo('Found ${filteredCourses.length} courses matching query: $query');
      return filteredCourses;
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseRepositoryImpl.searchCourses');
      return [];
    }
  }

  Future<void> refreshCourses() async {
    try {
      _errorHandler.logInfo('Refreshing courses from API');

      // Clear cache
      await _clearCourseCache();

      // Fetch fresh data from API
      await getCourses();

      _errorHandler.logInfo('Courses refreshed successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseRepositoryImpl.refreshCourses');
    }
  }

  // TODO: Implement remaining CourseRepository methods
  @override
  Future<List<Map<String, dynamic>>> getCourseChapters(String courseId) async {
    throw UnimplementedError('getCourseChapters not implemented yet');
  }

  @override
  Future<double?> getCourseProgress(String courseId) async {
    throw UnimplementedError('getCourseProgress not implemented yet');
  }

  @override
  Future<void> updateCourseProgress(String courseId, double progress) async {
    throw UnimplementedError('updateCourseProgress not implemented yet');
  }

  @override
  Future<List<Map<String, dynamic>>> getCourseTasks(String courseId) async {
    throw UnimplementedError('getCourseTasks not implemented yet');
  }

  @override
  Future<Map<String, dynamic>?> getCourseTask(String courseId, String taskId) async {
    throw UnimplementedError('getCourseTask not implemented yet');
  }

  @override
  Future<void> updateTaskProgress(String courseId, String taskId, double progress) async {
    throw UnimplementedError('updateTaskProgress not implemented yet');
  }

  @override
  Future<List<Map<String, dynamic>>> getCourseNotifications(String courseId) async {
    throw UnimplementedError('getCourseNotifications not implemented yet');
  }

  @override
  Future<void> markNotificationAsRead(String courseId, String notificationId) async {
    throw UnimplementedError('markNotificationAsRead not implemented yet');
  }

  @override
  Future<void> clearCourseCache(String courseId) async {
    try {
      await _hive.clearCourseData(courseId);
      _errorHandler.logInfo('Course cache cleared for ID: $courseId');
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseRepositoryImpl.clearCourseCache');
    }
  }

  @override
  Future<Map<String, dynamic>> getCourseStatistics(String courseId) async {
    try {
      _errorHandler.logInfo('Getting course statistics for ID: $courseId');
      
      // TODO: Implement actual statistics from API
      return {
        'totalTasks': 0,
        'completedTasks': 0,
        'progress': 0.0,
        'lastAccessed': null,
      };
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseRepositoryImpl.getCourseStatistics');
      return {};
    }
  }

  @override
  Future<void> refreshCourseData(String courseId) async {
    try {
      _errorHandler.logInfo('Refreshing course data for ID: $courseId');
      
      // Get fresh course detail from API
      await getCourseById(courseId);
      
      _errorHandler.logInfo('Course data refreshed for ID: $courseId');
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseRepositoryImpl.refreshCourseData');
    }
  }

  /// Map API data to Course entity
  Course _mapApiDataToCourse(Map<String, dynamic> data) {
    return Course(
      id: data['courseId']?.toString() ?? data['id']?.toString() ?? '',
      // Prefer keys from chaoxing_py HTML parser
      name: data['title'] ?? data['courseName'] ?? data['name'] ?? '未知课程',
      description: data['desc'] ?? data['courseDescription'] ?? data['description'],
      teacher: data['teacher'] ?? data['teacherName'] ?? '未知教师',
      semester: data['semester'] ?? data['term'],
      startDate: data['startDate'] != null ? DateTime.tryParse(data['startDate']) : null,
      endDate: data['endDate'] != null ? DateTime.tryParse(data['endDate']) : null,
      isActive: _mapStatus(data['status']),
      progress: (data['progress'] ?? 0.0).toDouble(),
      totalChapters: data['totalTasks'] ?? 0,
      completedChapters: data['completedTasks'] ?? 0,
      coverImage: data['imageUrl'] ?? data['coverUrl'],
      courseUrl: data['courseUrl'] ?? data['url'],
    );
  }

  /// Map API status to boolean
  bool _mapStatus(dynamic status) {
    if (status == null) return true;
    
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'active':
      case '1':
      case 'true':
        return true;
      case 'inactive':
      case '0':
      case 'false':
        return false;
      case 'completed':
      case 'finished':
        return true; // Completed courses are still active
      case 'archived':
        return false;
      default:
        return true;
    }
  }

  /// Cache courses locally
  Future<void> _cacheCourses(List<Course> courses) async {
    try {
      for (final course in courses) {
        await _cacheCourse(course);
      }
      _errorHandler.logInfo('Cached ${courses.length} courses locally');
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseRepositoryImpl._cacheCourses');
    }
  }

  /// Cache a single course locally
  Future<void> _cacheCourse(Course course) async {
    try {
      final courseModel = CourseModel.fromEntity(course);
      await _hive.saveCourse(course.id, courseModel.toJson());
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseRepositoryImpl._cacheCourse');
    }
  }

  /// Get cached courses
  Future<List<Course>> _getCachedCourses() async {
    try {
      final coursesData = _hive.getAllCourses();
      return coursesData.map((data) => CourseModel.fromJson(data).toEntity()).toList();
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseRepositoryImpl._getCachedCourses');
      return [];
    }
  }

  /// Get cached course by ID
  Future<Course?> _getCachedCourseById(String courseId) async {
    try {
      final courseData = _hive.getCourse(courseId);
      if (courseData != null) {
        return CourseModel.fromJson(courseData).toEntity();
      }
      return null;
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseRepositoryImpl._getCachedCourseById');
      return null;
    }
  }

  /// Clear course cache
  Future<void> _clearCourseCache() async {
    try {
      await _hive.clearAll();
      _errorHandler.logInfo('Course cache cleared');
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseRepositoryImpl._clearCourseCache');
    }
  }
}