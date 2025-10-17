import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../../core/errors/error_handler.dart';

/// Course service
class CourseService {

  CourseService(this._courseRepository, this._errorHandler);
  final CourseRepository _courseRepository;
  final ErrorHandler _errorHandler;

  /// Get all courses for current user
  Future<List<Course>> getCourses() async {
    try {
      _errorHandler.logInfo('CourseService: Fetching all courses');
      final courses = await _courseRepository.getCourses();
      _errorHandler.logInfo('CourseService: Retrieved ${courses.length} courses');
      return courses;
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseService.getCourses');
      rethrow;
    }
  }

  /// Get course by ID
  Future<Course?> getCourseById(String courseId) async {
    try {
      if (courseId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID cannot be empty');
      }

      _errorHandler.logInfo('CourseService: Fetching course: $courseId');
      final course = await _courseRepository.getCourseById(courseId);
      
      if (course != null) {
        _errorHandler.logInfo('CourseService: Course found: ${course.name}');
      } else {
        _errorHandler.logWarning('CourseService: Course not found: $courseId');
      }
      
      return course;
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseService.getCourseById');
      return null;
    }
  }

  /// Get course chapters
  Future<List<Map<String, dynamic>>> getCourseChapters(String courseId) async {
    try {
      if (courseId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID cannot be empty');
      }

      _errorHandler.logInfo('CourseService: Fetching chapters for course: $courseId');
      final chapters = await _courseRepository.getCourseChapters(courseId);
      _errorHandler.logInfo('CourseService: Retrieved ${chapters.length} chapters');
      return chapters;
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseService.getCourseChapters');
      return [];
    }
  }

  /// Get course progress
  Future<double?> getCourseProgress(String courseId) async {
    try {
      if (courseId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID cannot be empty');
      }

      _errorHandler.logInfo('CourseService: Fetching progress for course: $courseId');
      final progress = await _courseRepository.getCourseProgress(courseId);
      _errorHandler.logInfo('CourseService: Course progress: $progress');
      return progress;
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseService.getCourseProgress');
      return null;
    }
  }

  /// Update course progress
  Future<void> updateCourseProgress(String courseId, double progress) async {
    try {
      if (courseId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID cannot be empty');
      }

      if (progress < 0.0 || progress > 1.0) {
        throw _errorHandler.createDataParsingError('Progress must be between 0.0 and 1.0');
      }

      _errorHandler.logInfo('CourseService: Updating progress for course $courseId: $progress');
      await _courseRepository.updateCourseProgress(courseId, progress);
      _errorHandler.logInfo('CourseService: Course progress updated successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseService.updateCourseProgress');
      rethrow;
    }
  }

  /// Get course tasks
  Future<List<Map<String, dynamic>>> getCourseTasks(String courseId) async {
    try {
      if (courseId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID cannot be empty');
      }

      _errorHandler.logInfo('CourseService: Fetching tasks for course: $courseId');
      final tasks = await _courseRepository.getCourseTasks(courseId);
      _errorHandler.logInfo('CourseService: Retrieved ${tasks.length} tasks');
      return tasks;
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseService.getCourseTasks');
      return [];
    }
  }

  /// Get course task by ID
  Future<Map<String, dynamic>?> getCourseTask(String courseId, String taskId) async {
    try {
      if (courseId.isEmpty || taskId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID and Task ID cannot be empty');
      }

      _errorHandler.logInfo('CourseService: Fetching task $taskId for course: $courseId');
      final task = await _courseRepository.getCourseTask(courseId, taskId);
      
      if (task != null) {
        _errorHandler.logInfo('CourseService: Task found: ${task['name']}');
      } else {
        _errorHandler.logWarning('CourseService: Task not found: $taskId');
      }
      
      return task;
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseService.getCourseTask');
      return null;
    }
  }

  /// Update task progress
  Future<void> updateTaskProgress(String courseId, String taskId, double progress) async {
    try {
      if (courseId.isEmpty || taskId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID and Task ID cannot be empty');
      }

      if (progress < 0.0 || progress > 1.0) {
        throw _errorHandler.createDataParsingError('Progress must be between 0.0 and 1.0');
      }

      _errorHandler.logInfo('CourseService: Updating progress for task $taskId in course $courseId: $progress');
      await _courseRepository.updateTaskProgress(courseId, taskId, progress);
      _errorHandler.logInfo('CourseService: Task progress updated successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseService.updateTaskProgress');
      rethrow;
    }
  }

  /// Get course notifications
  Future<List<Map<String, dynamic>>> getCourseNotifications(String courseId) async {
    try {
      if (courseId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID cannot be empty');
      }

      _errorHandler.logInfo('CourseService: Fetching notifications for course: $courseId');
      final notifications = await _courseRepository.getCourseNotifications(courseId);
      _errorHandler.logInfo('CourseService: Retrieved ${notifications.length} notifications');
      return notifications;
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseService.getCourseNotifications');
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String courseId, String notificationId) async {
    try {
      if (courseId.isEmpty || notificationId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID and Notification ID cannot be empty');
      }

      _errorHandler.logInfo('CourseService: Marking notification $notificationId as read for course: $courseId');
      await _courseRepository.markNotificationAsRead(courseId, notificationId);
      _errorHandler.logInfo('CourseService: Notification marked as read');
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseService.markNotificationAsRead');
      rethrow;
    }
  }

  /// Get course statistics
  Future<Map<String, dynamic>> getCourseStatistics(String courseId) async {
    try {
      if (courseId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID cannot be empty');
      }

      _errorHandler.logInfo('CourseService: Fetching statistics for course: $courseId');
      final statistics = await _courseRepository.getCourseStatistics(courseId);
      _errorHandler.logInfo('CourseService: Course statistics retrieved');
      return statistics;
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseService.getCourseStatistics');
      return {};
    }
  }

  /// Refresh course data
  Future<void> refreshCourseData(String courseId) async {
    try {
      if (courseId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID cannot be empty');
      }

      _errorHandler.logInfo('CourseService: Refreshing data for course: $courseId');
      await _courseRepository.refreshCourseData(courseId);
      _errorHandler.logInfo('CourseService: Course data refreshed successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseService.refreshCourseData');
      rethrow;
    }
  }

  /// Clear course cache
  Future<void> clearCourseCache(String courseId) async {
    try {
      if (courseId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID cannot be empty');
      }

      _errorHandler.logInfo('CourseService: Clearing cache for course: $courseId');
      await _courseRepository.clearCourseCache(courseId);
      _errorHandler.logInfo('CourseService: Course cache cleared');
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseService.clearCourseCache');
      rethrow;
    }
  }

  /// Get user-friendly error message
  String getUserFriendlyErrorMessage(dynamic error) {
    return _errorHandler.getUserFriendlyMessage(error);
  }
}
