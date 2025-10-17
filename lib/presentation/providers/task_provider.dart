import '../../domain/entities/task.dart';
import '../../services/task/task_service.dart';
import '../providers/base_provider.dart';

/// Task provider for state management
class TaskProvider extends BaseProvider {

  TaskProvider(this._taskService);
  final TaskService _taskService;
  
  List<Task> _tasks = [];
  Task? _selectedTask;
  Map<String, double> _taskProgress = {};
  Map<String, bool> _taskCompletion = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Task> get tasks => _tasks;
  Task? get selectedTask => _selectedTask;
  Map<String, double> get taskProgress => _taskProgress;
  Map<String, bool> get taskCompletion => _taskCompletion;
  @override
  bool get isLoading => _isLoading;
  @override
  String? get errorMessage => _errorMessage;

  /// Get tasks by course ID
  /// Replicates chaoxing_py process_course flow
  Future<void> getTasksByCourseId(String courseId) async {
    try {
      setLoading(true);
      clearError();

      // Get tasks from real API - replicates chaoxing_py process_course
      _tasks = await _taskService.getTasksByCourseId(courseId);
      
      notifyListeners();
    } catch (e) {
      final errorMessage = _taskService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  /// Get tasks by chapter ID
  /// Replicates chaoxing_py process_chapter flow
  Future<void> getTasksByChapterId(String chapterId) async {
    try {
      setLoading(true);
      clearError();

      // Get tasks from real API - replicates chaoxing_py process_chapter
      _tasks = await _taskService.getTasksByChapterId(chapterId);
      
      notifyListeners();
    } catch (e) {
      final errorMessage = _taskService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  /// Fetch tasks by type
  Future<void> fetchTasksByType(TaskType type) async {
    try {
      setLoading(true);
      clearError();

      // TODO: Implement actual task fetching logic
      // This is a placeholder implementation
      await Future.delayed(const Duration(milliseconds: 500));
      
      _tasks = _tasks.where((task) => task.type == type).toList();
      notifyListeners();
    } catch (e) {
      final errorMessage = _taskService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  /// Select task
  void selectTask(Task task) {
    _selectedTask = task;
    notifyListeners();
  }

  /// Clear selected task
  void clearSelectedTask() {
    _selectedTask = null;
    notifyListeners();
  }

  /// Update task progress
  Future<void> updateTaskProgress(String taskId, double progress) async {
    try {
      if (progress < 0.0 || progress > 1.0) {
        throw Exception('Progress must be between 0.0 and 1.0');
      }

      _taskProgress[taskId] = progress;
      
      // Update task in list
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex] = _tasks[taskIndex].copyWith(progress: progress);
      }
      
      // Update selected task if it's the same
      if (_selectedTask?.id == taskId) {
        _selectedTask = _selectedTask!.copyWith(progress: progress);
      }
      
      notifyListeners();
    } catch (e) {
      final errorMessage = _taskService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
    }
  }

  /// Mark task as completed
  Future<void> markTaskAsCompleted(String taskId) async {
    try {
      _taskCompletion[taskId] = true;
      _taskProgress[taskId] = 1.0;
      
      // Update task in list
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex] = _tasks[taskIndex].copyWith(
          isCompleted: true,
          progress: 1.0,
        );
      }
      
      // Update selected task if it's the same
      if (_selectedTask?.id == taskId) {
        _selectedTask = _selectedTask!.copyWith(
          isCompleted: true,
          progress: 1.0,
        );
      }
      
      notifyListeners();
    } catch (e) {
      final errorMessage = _taskService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
    }
  }

  /// Get task progress
  double getTaskProgress(String taskId) {
    return _taskProgress[taskId] ?? 0.0;
  }

  /// Check if task is completed
  bool isTaskCompleted(String taskId) {
    return _taskCompletion[taskId] ?? false;
  }

  /// Get completed tasks count
  int get completedTasksCount {
    return _tasks.where((task) => task.isCompleted).length;
  }

  /// Get total tasks count
  int get totalTasksCount {
    return _tasks.length;
  }

  /// Get completion percentage
  double get completionPercentage {
    if (_tasks.isEmpty) return 0.0;
    return completedTasksCount / totalTasksCount;
  }

  /// Get tasks by type
  List<Task> getTasksByType(TaskType type) {
    return _tasks.where((task) => task.type == type).toList();
  }

  /// Get video tasks
  List<Task> get videoTasks {
    return getTasksByType(TaskType.video);
  }

  /// Get document tasks
  List<Task> get documentTasks {
    return getTasksByType(TaskType.document);
  }

  /// Get quiz tasks
  List<Task> get quizTasks {
    return getTasksByType(TaskType.quiz);
  }

  /// Get assignment tasks
  List<Task> get assignmentTasks {
    return getTasksByType(TaskType.assignment);
  }

  /// Get discussion tasks
  List<Task> get discussionTasks {
    return getTasksByType(TaskType.discussion);
  }

  /// Get other tasks (reading tasks)
  List<Task> get otherTasks {
    return getTasksByType(TaskType.reading);
  }

  /// Clear all tasks
  void clearAllTasks() {
    _tasks = [];
    _selectedTask = null;
    _taskProgress = {};
    _taskCompletion = {};
    notifyListeners();
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
    _errorMessage = error;
    notifyListeners();
  }

}
