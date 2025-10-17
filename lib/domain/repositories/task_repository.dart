import '../../domain/entities/task.dart';

/// Task repository interface
abstract class TaskRepository {
  /// Get task by ID
  Future<Task?> getTaskById(String taskId);

  /// Get tasks by course ID
  Future<List<Task>> getTasksByCourseId(String courseId);

  /// Get tasks by chapter ID
  Future<List<Task>> getTasksByChapterId(String chapterId);

  /// Update task progress
  Future<void> updateTaskProgress(String taskId, double progress);

  /// Mark task as completed
  Future<void> markTaskAsCompleted(String taskId);

  /// Get task statistics
  Future<Map<String, dynamic>> getTaskStatistics(String taskId);

  /// Save task progress
  Future<void> saveTaskProgress(String taskId, double progress);

  /// Get task completion history
  Future<List<Map<String, dynamic>>> getTaskCompletionHistory(String taskId);

  /// Get task dependencies
  Future<List<Map<String, dynamic>>> getTaskDependencies(String taskId);

  /// Get task prerequisites
  Future<List<Map<String, dynamic>>> getTaskPrerequisites(String taskId);
}