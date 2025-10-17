import '../entities/course.dart';
import '../repositories/course_repository.dart';
import '../../core/errors/error_handler.dart';

/// Course use case
class CourseUseCase {

  CourseUseCase(this._courseRepository, this._errorHandler);
  final CourseRepository _courseRepository;
  final ErrorHandler _errorHandler;

  /// Get all courses for current user
  Future<List<Course>> getCourses() async {
    try {
      _errorHandler.logInfo('Fetching all courses');
      final courses = await _courseRepository.getCourses();
      _errorHandler.logInfo('Retrieved ${courses.length} courses');
      return courses;
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseUseCase.getCourses');
      rethrow;
    }
  }

  /// Get course by ID
  Future<Course?> getCourseById(String courseId) async {
    try {
      if (courseId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching course: $courseId');
      final course = await _courseRepository.getCourseById(courseId);
      
      if (course != null) {
        _errorHandler.logInfo('Course found: ${course.name}');
      } else {
        _errorHandler.logWarning('Course not found: $courseId');
      }
      
      return course;
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseUseCase.getCourseById');
      return null;
    }
  }

  /// Get course chapters
  Future<List<Map<String, dynamic>>> getCourseChapters(String courseId) async {
    try {
      if (courseId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching chapters for course: $courseId');
      final chapters = await _courseRepository.getCourseChapters(courseId);
      _errorHandler.logInfo('Retrieved ${chapters.length} chapters');
      return chapters;
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseUseCase.getCourseChapters');
      return [];
    }
  }

  /// Get course progress
  Future<double?> getCourseProgress(String courseId) async {
    try {
      if (courseId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching progress for course: $courseId');
      final progress = await _courseRepository.getCourseProgress(courseId);
      _errorHandler.logInfo('Course progress: $progress');
      return progress;
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseUseCase.getCourseProgress');
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

      _errorHandler.logInfo('Updating progress for course $courseId: $progress');
      await _courseRepository.updateCourseProgress(courseId, progress);
      _errorHandler.logInfo('Course progress updated successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseUseCase.updateCourseProgress');
      rethrow;
    }
  }

  /// Get course tasks
  Future<List<Map<String, dynamic>>> getCourseTasks(String courseId) async {
    try {
      if (courseId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching tasks for course: $courseId');
      final tasks = await _courseRepository.getCourseTasks(courseId);
      _errorHandler.logInfo('Retrieved ${tasks.length} tasks');
      return tasks;
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseUseCase.getCourseTasks');
      return [];
    }
  }

  /// Get course task by ID
  Future<Map<String, dynamic>?> getCourseTask(String courseId, String taskId) async {
    try {
      if (courseId.isEmpty || taskId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID and Task ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching task $taskId for course: $courseId');
      final task = await _courseRepository.getCourseTask(courseId, taskId);
      
      if (task != null) {
        _errorHandler.logInfo('Task found: ${task['name']}');
      } else {
        _errorHandler.logWarning('Task not found: $taskId');
      }
      
      return task;
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseUseCase.getCourseTask');
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

      _errorHandler.logInfo('Updating progress for task $taskId in course $courseId: $progress');
      await _courseRepository.updateTaskProgress(courseId, taskId, progress);
      _errorHandler.logInfo('Task progress updated successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseUseCase.updateTaskProgress');
      rethrow;
    }
  }

  /// Get course notifications
  Future<List<Map<String, dynamic>>> getCourseNotifications(String courseId) async {
    try {
      if (courseId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching notifications for course: $courseId');
      final notifications = await _courseRepository.getCourseNotifications(courseId);
      _errorHandler.logInfo('Retrieved ${notifications.length} notifications');
      return notifications;
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseUseCase.getCourseNotifications');
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String courseId, String notificationId) async {
    try {
      if (courseId.isEmpty || notificationId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID and Notification ID cannot be empty');
      }

      _errorHandler.logInfo('Marking notification $notificationId as read for course: $courseId');
      await _courseRepository.markNotificationAsRead(courseId, notificationId);
      _errorHandler.logInfo('Notification marked as read');
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseUseCase.markNotificationAsRead');
      rethrow;
    }
  }

  /// Get course statistics
  Future<Map<String, dynamic>> getCourseStatistics(String courseId) async {
    try {
      if (courseId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching statistics for course: $courseId');
      final statistics = await _courseRepository.getCourseStatistics(courseId);
      _errorHandler.logInfo('Course statistics retrieved');
      return statistics;
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseUseCase.getCourseStatistics');
      return {};
    }
  }

  /// Refresh course data
  Future<void> refreshCourseData(String courseId) async {
    try {
      if (courseId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID cannot be empty');
      }

      _errorHandler.logInfo('Refreshing data for course: $courseId');
      await _courseRepository.refreshCourseData(courseId);
      _errorHandler.logInfo('Course data refreshed successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseUseCase.refreshCourseData');
      rethrow;
    }
  }

  /// Clear course cache
  Future<void> clearCourseCache(String courseId) async {
    try {
      if (courseId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID cannot be empty');
      }

      _errorHandler.logInfo('Clearing cache for course: $courseId');
      await _courseRepository.clearCourseCache(courseId);
      _errorHandler.logInfo('Course cache cleared');
    } catch (e) {
      _errorHandler.handleError(e, context: 'CourseUseCase.clearCourseCache');
      rethrow;
    }
  }
}
