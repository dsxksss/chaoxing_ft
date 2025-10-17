import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../core/errors/error_handler.dart';

/// Task service for business logic
class TaskService {
  TaskService(
    this._taskRepository,
    this._errorHandler,
  );

  final TaskRepository _taskRepository;
  final ErrorHandler _errorHandler;

  /// Get tasks by course ID
  Future<List<Task>> getTasksByCourseId(String courseId) async {
    try {
      return await _taskRepository.getTasksByCourseId(courseId);
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskService.getTasksByCourseId');
      return [];
    }
  }

  /// Get tasks by chapter ID
  Future<List<Task>> getTasksByChapterId(String chapterId) async {
    try {
      return await _taskRepository.getTasksByChapterId(chapterId);
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskService.getTasksByChapterId');
      return [];
    }
  }

  /// Get task by ID
  Future<Task?> getTaskById(String taskId) async {
    try {
      return await _taskRepository.getTaskById(taskId);
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskService.getTaskById');
      return null;
    }
  }

  /// Update task progress
  Future<void> updateTaskProgress(String taskId, double progress) async {
    try {
      await _taskRepository.updateTaskProgress(taskId, progress);
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskService.updateTaskProgress');
    }
  }

  /// Mark task as completed
  Future<void> markTaskAsCompleted(String taskId) async {
    try {
      await _taskRepository.markTaskAsCompleted(taskId);
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskService.markTaskAsCompleted');
    }
  }

  /// Get user-friendly error message
  String getUserFriendlyErrorMessage(dynamic error) {
    if (error.toString().contains('Session is not valid')) {
      return '会话已过期，请重新登录';
    } else if (error.toString().contains('Network')) {
      return '网络连接失败，请检查网络设置';
    } else if (error.toString().contains('Course ID cannot be empty')) {
      return '课程ID不能为空';
    } else if (error.toString().contains('Chapter ID cannot be empty')) {
      return '章节ID不能为空';
    } else {
      return '获取任务数据失败，请稍后重试';
    }
  }
}
