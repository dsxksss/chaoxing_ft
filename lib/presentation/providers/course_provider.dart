import '../../domain/entities/course.dart';
import '../../services/course/course_service.dart';
import '../providers/base_provider.dart';

/// Course provider for state management
class CourseProvider extends BaseProvider {

  CourseProvider(this._courseService);
  final CourseService _courseService;
  
  List<Course> _courses = [];
  Course? _selectedCourse;
  List<Map<String, dynamic>> _chapters = [];
  List<Map<String, dynamic>> _tasks = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Course> get courses => _courses;
  Course? get selectedCourse => _selectedCourse;
  List<Map<String, dynamic>> get chapters => _chapters;
  List<Map<String, dynamic>> get tasks => _tasks;
  Map<String, dynamic> get statistics => _statistics;
  @override
  bool get isLoading => _isLoading;
  @override
  String? get errorMessage => _errorMessage;

  /// Load all courses
  Future<void> loadCourses() async {
    await executeWithLoading(() async {
      _courses = await _courseService.getCourses();
    });
  }

  /// Get all courses
  Future<void> getCourses() async {
    try {
      setLoading(true);
      clearError();

      final courses = await _courseService.getCourses();
      _courses = courses;
      notifyListeners();
    } catch (e) {
      final errorMessage = _courseService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  /// Get course by ID
  Future<void> getCourseById(String courseId) async {
    try {
      setLoading(true);
      clearError();

      final course = await _courseService.getCourseById(courseId);
      
      if (course != null) {
        _selectedCourse = course;
        notifyListeners();
      } else {
        setError('课程未找到');
      }
    } catch (e) {
      final errorMessage = _courseService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  /// Get course chapters
  Future<void> getCourseChapters(String courseId) async {
    try {
      setLoading(true);
      clearError();

      final chapters = await _courseService.getCourseChapters(courseId);
      _chapters = chapters;
      notifyListeners();
    } catch (e) {
      final errorMessage = _courseService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  /// Get course progress
  Future<double?> getCourseProgress(String courseId) async {
    try {
      final progress = await _courseService.getCourseProgress(courseId);
      return progress;
    } catch (e) {
      final errorMessage = _courseService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
      return null;
    }
  }

  /// Update course progress
  Future<void> updateCourseProgress(String courseId, double progress) async {
    try {
      await _courseService.updateCourseProgress(courseId, progress);
      
      // Update local course data
      final courseIndex = _courses.indexWhere((c) => c.id == courseId);
      if (courseIndex != -1) {
        _courses[courseIndex] = _courses[courseIndex].copyWith(progress: progress);
        notifyListeners();
      }
      
      if (_selectedCourse?.id == courseId) {
        _selectedCourse = _selectedCourse!.copyWith(progress: progress);
        notifyListeners();
      }
    } catch (e) {
      final errorMessage = _courseService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
    }
  }

  /// Get course tasks
  Future<void> getCourseTasks(String courseId) async {
    try {
      setLoading(true);
      clearError();

      final tasks = await _courseService.getCourseTasks(courseId);
      _tasks = tasks;
      notifyListeners();
    } catch (e) {
      final errorMessage = _courseService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  /// Get course task by ID
  Future<Map<String, dynamic>?> getCourseTask(String courseId, String taskId) async {
    try {
      final task = await _courseService.getCourseTask(courseId, taskId);
      return task;
    } catch (e) {
      final errorMessage = _courseService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
      return null;
    }
  }

  /// Update task progress
  Future<void> updateTaskProgress(String courseId, String taskId, double progress) async {
    try {
      await _courseService.updateTaskProgress(courseId, taskId, progress);
      
      // Update local task data
      final taskIndex = _tasks.indexWhere((t) => t['id'] == taskId);
      if (taskIndex != -1) {
        _tasks[taskIndex]['progress'] = progress;
        notifyListeners();
      }
    } catch (e) {
      final errorMessage = _courseService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
    }
  }

  /// Get course notifications
  Future<List<Map<String, dynamic>>> getCourseNotifications(String courseId) async {
    try {
      final notifications = await _courseService.getCourseNotifications(courseId);
      return notifications;
    } catch (e) {
      final errorMessage = _courseService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String courseId, String notificationId) async {
    try {
      await _courseService.markNotificationAsRead(courseId, notificationId);
    } catch (e) {
      final errorMessage = _courseService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
    }
  }

  /// Get course statistics
  Future<void> getCourseStatistics(String courseId) async {
    try {
      setLoading(true);
      clearError();

      final statistics = await _courseService.getCourseStatistics(courseId);
      _statistics = statistics;
      notifyListeners();
    } catch (e) {
      final errorMessage = _courseService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  /// Refresh course data
  Future<void> refreshCourseData(String courseId) async {
    try {
      setLoading(true);
      clearError();

      await _courseService.refreshCourseData(courseId);
      
      // Refresh local data
      await getCourseById(courseId);
      await getCourseChapters(courseId);
      await getCourseTasks(courseId);
      await getCourseStatistics(courseId);
    } catch (e) {
      final errorMessage = _courseService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  }

  /// Clear course cache
  Future<void> clearCourseCache(String courseId) async {
    try {
      await _courseService.clearCourseCache(courseId);
      
      // Clear local data
      if (_selectedCourse?.id == courseId) {
        _selectedCourse = null;
        _chapters = [];
        _tasks = [];
        _statistics = {};
        notifyListeners();
      }
    } catch (e) {
      final errorMessage = _courseService.getUserFriendlyErrorMessage(e);
      setError(errorMessage);
    }
  }

  /// Select course
  void selectCourse(Course course) {
    _selectedCourse = course;
    notifyListeners();
  }

  /// Clear selected course
  void clearSelectedCourse() {
    _selectedCourse = null;
    _chapters = [];
    _tasks = [];
    _statistics = {};
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
    super.setError(error);
  }

}
