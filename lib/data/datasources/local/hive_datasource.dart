import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

class HiveDataSource {

  HiveDataSource._internal() {
    _logger = Logger();
  }
  static HiveDataSource? _instance;
  late Logger _logger;
  
  // Box names
  static const String _courseBoxName = 'courses';
  static const String _chapterBoxName = 'chapters';
  static const String _taskBoxName = 'tasks';
  static const String _questionBoxName = 'questions';
  static const String _progressBoxName = 'progress';

  static HiveDataSource get instance {
    _instance ??= HiveDataSource._internal();
    return _instance!;
  }

  /// Initialize Hive storage
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      
      // Register adapters (will be implemented when models are created)
      // Hive.registerAdapter(CourseAdapter());
      // Hive.registerAdapter(ChapterAdapter());
      // Hive.registerAdapter(TaskAdapter());
      // Hive.registerAdapter(QuestionAdapter());
      // Hive.registerAdapter(ProgressAdapter());
      
      // Open boxes
      await Hive.openBox(_courseBoxName);
      await Hive.openBox(_chapterBoxName);
      await Hive.openBox(_taskBoxName);
      await Hive.openBox(_questionBoxName);
      await Hive.openBox(_progressBoxName);
      
      _logger.d('Hive storage initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize Hive storage: $e');
      rethrow;
    }
  }

  /// Get course box
  Box get courseBox => Hive.box(_courseBoxName);

  /// Get chapter box
  Box get chapterBox => Hive.box(_chapterBoxName);

  /// Get task box
  Box get taskBox => Hive.box(_taskBoxName);

  /// Get question box
  Box get questionBox => Hive.box(_questionBoxName);

  /// Get progress box
  Box get progressBox => Hive.box(_progressBoxName);

  /// Save course data
  Future<void> saveCourse(String courseId, Map<String, dynamic> courseData) async {
    try {
      await courseBox.put(courseId, courseData);
      _logger.d('Course saved: $courseId');
    } catch (e) {
      _logger.e('Failed to save course: $e');
      rethrow;
    }
  }

  /// Get course data
  Map<String, dynamic>? getCourse(String courseId) {
    try {
      final data = courseBox.get(courseId);
      return data != null ? Map<String, dynamic>.from(data) : null;
    } catch (e) {
      _logger.e('Failed to get course: $e');
      return null;
    }
  }

  /// Get all courses
  List<Map<String, dynamic>> getAllCourses() {
    try {
      final courses = <Map<String, dynamic>>[];
      for (final key in courseBox.keys) {
        final data = courseBox.get(key);
        if (data != null) {
          courses.add(Map<String, dynamic>.from(data));
        }
      }
      return courses;
    } catch (e) {
      _logger.e('Failed to get all courses: $e');
      return [];
    }
  }

  /// Save chapter data
  Future<void> saveChapter(String chapterId, Map<String, dynamic> chapterData) async {
    try {
      await chapterBox.put(chapterId, chapterData);
      _logger.d('Chapter saved: $chapterId');
    } catch (e) {
      _logger.e('Failed to save chapter: $e');
      rethrow;
    }
  }

  /// Get chapter data
  Map<String, dynamic>? getChapter(String chapterId) {
    try {
      final data = chapterBox.get(chapterId);
      return data != null ? Map<String, dynamic>.from(data) : null;
    } catch (e) {
      _logger.e('Failed to get chapter: $e');
      return null;
    }
  }

  /// Save task data
  Future<void> saveTask(String taskId, Map<String, dynamic> taskData) async {
    try {
      await taskBox.put(taskId, taskData);
      _logger.d('Task saved: $taskId');
    } catch (e) {
      _logger.e('Failed to save task: $e');
      rethrow;
    }
  }

  /// Get task data
  Map<String, dynamic>? getTask(String taskId) {
    try {
      final data = taskBox.get(taskId);
      return data != null ? Map<String, dynamic>.from(data) : null;
    } catch (e) {
      _logger.e('Failed to get task: $e');
      return null;
    }
  }

  /// Save question data
  Future<void> saveQuestion(String questionId, Map<String, dynamic> questionData) async {
    try {
      await questionBox.put(questionId, questionData);
      _logger.d('Question saved: $questionId');
    } catch (e) {
      _logger.e('Failed to save question: $e');
      rethrow;
    }
  }

  /// Get question data
  Map<String, dynamic>? getQuestion(String questionId) {
    try {
      final data = questionBox.get(questionId);
      return data != null ? Map<String, dynamic>.from(data) : null;
    } catch (e) {
      _logger.e('Failed to get question: $e');
      return null;
    }
  }

  /// Save progress data
  Future<void> saveProgress(String progressId, Map<String, dynamic> progressData) async {
    try {
      await progressBox.put(progressId, progressData);
      _logger.d('Progress saved: $progressId');
    } catch (e) {
      _logger.e('Failed to save progress: $e');
      rethrow;
    }
  }

  /// Get progress data
  Map<String, dynamic>? getProgress(String progressId) {
    try {
      final data = progressBox.get(progressId);
      return data != null ? Map<String, dynamic>.from(data) : null;
    } catch (e) {
      _logger.e('Failed to get progress: $e');
      return null;
    }
  }

  /// Clear all data
  Future<void> clearAll() async {
    try {
      await courseBox.clear();
      await chapterBox.clear();
      await taskBox.clear();
      await questionBox.clear();
      await progressBox.clear();
      _logger.d('All Hive data cleared');
    } catch (e) {
      _logger.e('Failed to clear Hive data: $e');
      rethrow;
    }
  }

  /// Clear specific course data
  Future<void> clearCourseData(String courseId) async {
    try {
      // Remove course
      await courseBox.delete(courseId);
      
      // Remove related chapters
      final chapterKeys = chapterBox.keys.where((key) => key.toString().startsWith(courseId));
      for (final key in chapterKeys) {
        await chapterBox.delete(key);
      }
      
      // Remove related tasks
      final taskKeys = taskBox.keys.where((key) => key.toString().startsWith(courseId));
      for (final key in taskKeys) {
        await taskBox.delete(key);
      }
      
      // Remove related progress
      final progressKeys = progressBox.keys.where((key) => key.toString().startsWith(courseId));
      for (final key in progressKeys) {
        await progressBox.delete(key);
      }
      
      _logger.d('Course data cleared: $courseId');
    } catch (e) {
      _logger.e('Failed to clear course data: $e');
      rethrow;
    }
  }

  /// Close all boxes
  Future<void> close() async {
    try {
      await Hive.close();
      _logger.d('Hive storage closed');
    } catch (e) {
      _logger.e('Failed to close Hive storage: $e');
    }
  }
}
