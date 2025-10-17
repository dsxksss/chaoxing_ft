import '../entities/course.dart';

/// Course repository interface
abstract class CourseRepository {
  /// Get all courses for current user
  Future<List<Course>> getCourses();

  /// Get course by ID
  Future<Course?> getCourseById(String courseId);

  /// Get course chapters
  Future<List<Map<String, dynamic>>> getCourseChapters(String courseId);

  /// Get course progress
  Future<double?> getCourseProgress(String courseId);

  /// Update course progress
  Future<void> updateCourseProgress(String courseId, double progress);

  /// Get course tasks
  Future<List<Map<String, dynamic>>> getCourseTasks(String courseId);

  /// Get course task by ID
  Future<Map<String, dynamic>?> getCourseTask(String courseId, String taskId);

  /// Update task progress
  Future<void> updateTaskProgress(String courseId, String taskId, double progress);

  /// Get course notifications
  Future<List<Map<String, dynamic>>> getCourseNotifications(String courseId);

  /// Mark notification as read
  Future<void> markNotificationAsRead(String courseId, String notificationId);

  /// Get course statistics
  Future<Map<String, dynamic>> getCourseStatistics(String courseId);

  /// Refresh course data
  Future<void> refreshCourseData(String courseId);

  /// Clear course cache
  Future<void> clearCourseCache(String courseId);
}
