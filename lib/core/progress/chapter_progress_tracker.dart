import 'dart:async';
import 'package:chaoxing_ft/domain/entities/chapter.dart';
import 'package:chaoxing_ft/domain/entities/task.dart';
import 'package:chaoxing_ft/presentation/providers/chapter_provider.dart';
import 'package:chaoxing_ft/core/logging/chapter_logger.dart';

/// Chapter progress tracker
class ChapterProgressTracker {
  
  ChapterProgressTracker({
    required this.chapterId,
    required this.chapterProvider,
    required this.tasks,
  });
  final String chapterId;
  final ChapterProvider chapterProvider;
  final List<Task> tasks;
  
  Timer? _progressUpdateTimer;
  static const Duration _updateInterval = Duration(seconds: 30);

  /// Start tracking chapter progress
  void startTracking() {
    _progressUpdateTimer = Timer.periodic(_updateInterval, (timer) {
      _updateChapterProgress();
    });
    ChapterLogger.logProgressTrackingStarted(chapterId);
  }

  /// Stop tracking chapter progress
  void stopTracking() {
    _progressUpdateTimer?.cancel();
    _progressUpdateTimer = null;
    ChapterLogger.logProgressTrackingStopped(chapterId);
  }

  /// Update chapter progress based on task completion
  void _updateChapterProgress() {
    if (tasks.isEmpty) return;

    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final progress = completedTasks / tasks.length;

    chapterProvider.updateChapterProgress(chapterId, progress);
    ChapterLogger.logProgressUpdated(chapterId, progress);

    // Check if chapter is completed
    if (progress >= 1.0) {
      _markChapterAsCompleted();
    }
  }

  /// Mark chapter as completed
  void _markChapterAsCompleted() {
    chapterProvider.markChapterAsCompleted(chapterId);
    ChapterLogger.logChapterCompleted(chapterId);
    stopTracking();
  }

  /// Update progress when task is completed
  void onTaskCompleted(String taskId) {
    final task = tasks.firstWhere((t) => t.id == taskId);
    if (!task.isCompleted) {
      ChapterLogger.logTaskCompleted(chapterId, taskId);
      _updateChapterProgress();
    }
  }

  /// Update progress when task progress changes
  void onTaskProgressChanged(String taskId, double progress) {
    ChapterLogger.logTaskProgressChanged(chapterId, taskId, progress);
    _updateChapterProgress();
  }

  /// Get current progress
  double get currentProgress {
    if (tasks.isEmpty) return 0.0;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    return completedTasks / tasks.length;
  }

  /// Get completed tasks count
  int get completedTasksCount {
    return tasks.where((task) => task.isCompleted).length;
  }

  /// Get total tasks count
  int get totalTasksCount {
    return tasks.length;
  }

  /// Check if chapter is completed
  bool get isCompleted {
    return currentProgress >= 1.0;
  }

  /// Get remaining tasks count
  int get remainingTasksCount {
    return totalTasksCount - completedTasksCount;
  }

  /// Get progress percentage
  String get progressPercentage {
    return '${(currentProgress * 100).toInt()}%';
  }

  /// Dispose resources
  void dispose() {
    stopTracking();
  }
}

/// Chapter progress calculator
class ChapterProgressCalculator {
  /// Calculate progress from task completion data
  static double calculateProgress(List<Task> tasks) {
    if (tasks.isEmpty) return 0.0;
    
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    return completedTasks / tasks.length;
  }

  /// Calculate weighted progress based on task points
  static double calculateWeightedProgress(List<Task> tasks) {
    if (tasks.isEmpty) return 0.0;
    
    double totalPoints = 0.0;
    double earnedPoints = 0.0;
    
    for (final task in tasks) {
      final taskPoints = task.metadata?['points'] as double? ?? 1.0;
      totalPoints += taskPoints;
      
      if (task.isCompleted) {
        earnedPoints += taskPoints;
      }
    }
    
    return totalPoints > 0 ? earnedPoints / totalPoints : 0.0;
  }

  /// Calculate time-based progress
  static double calculateTimeBasedProgress(List<Task> tasks) {
    if (tasks.isEmpty) return 0.0;
    
    Duration totalDuration = Duration.zero;
    Duration completedDuration = Duration.zero;
    
    for (final task in tasks) {
      final taskDuration = task.duration ?? Duration.zero;
      totalDuration += taskDuration;
      
      if (task.isCompleted) {
        completedDuration += taskDuration;
      }
    }
    
    return totalDuration.inMilliseconds > 0 
        ? completedDuration.inMilliseconds / totalDuration.inMilliseconds 
        : 0.0;
  }

  /// Calculate completion rate
  static double calculateCompletionRate(List<Task> tasks) {
    if (tasks.isEmpty) return 0.0;
    
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    return completedTasks / tasks.length;
  }

  /// Get progress statistics
  static Map<String, dynamic> getProgressStatistics(List<Task> tasks) {
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final inProgressTasks = tasks.where((task) => task.isInProgress).length;
    final notStartedTasks = totalTasks - completedTasks - inProgressTasks;
    
    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'inProgressTasks': inProgressTasks,
      'notStartedTasks': notStartedTasks,
      'completionRate': totalTasks > 0 ? completedTasks / totalTasks : 0.0,
      'progressRate': totalTasks > 0 ? (completedTasks + inProgressTasks) / totalTasks : 0.0,
    };
  }

  /// Estimate completion time
  static Duration estimateCompletionTime(List<Task> tasks) {
    if (tasks.isEmpty) return Duration.zero;
    
    Duration remainingTime = Duration.zero;
    
    for (final task in tasks) {
      if (!task.isCompleted) {
        final taskDuration = task.duration ?? const Duration(minutes: 30);
        remainingTime += taskDuration;
      }
    }
    
    return remainingTime;
  }

  /// Get formatted completion time
  static String getFormattedCompletionTime(List<Task> tasks) {
    final duration = estimateCompletionTime(tasks);
    
    if (duration.inDays > 0) {
      return '${duration.inDays}天${duration.inHours.remainder(24)}小时';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}小时${duration.inMinutes.remainder(60)}分钟';
    } else {
      return '${duration.inMinutes}分钟';
    }
  }
}

/// Chapter progress validator
class ChapterProgressValidator {
  /// Validate progress value
  static bool isValidProgress(double progress) {
    return progress >= 0.0 && progress <= 1.0;
  }

  /// Validate chapter completion
  static bool isChapterCompleted(List<Task> tasks) {
    if (tasks.isEmpty) return false;
    return tasks.every((task) => task.isCompleted);
  }

  /// Validate chapter unlock conditions
  static bool canUnlockChapter(Chapter chapter, List<Chapter> previousChapters) {
    // Check if chapter is already unlocked
    if (chapter.isUnlocked) return false;
    
    // Check if unlock date has passed
    if (chapter.unlockDate != null && DateTime.now().isBefore(chapter.unlockDate!)) {
      return false;
    }
    
    // Check if previous chapters are completed (if required)
    final requiredPreviousChapters = previousChapters.where((ch) => 
      ch.order < chapter.order && ch.metadata?['required'] == true
    ).toList();
    
    return requiredPreviousChapters.every((ch) => ch.isCompleted);
  }

  /// Validate progress update
  static bool canUpdateProgress(Chapter chapter, double newProgress) {
    // Check if chapter is unlocked
    if (!chapter.isUnlocked) return false;
    
    // Check if chapter is already completed
    if (chapter.isCompleted) return false;
    
    // Check if progress is valid
    if (!isValidProgress(newProgress)) return false;
    
    // Check if progress is not decreasing
    return newProgress >= chapter.progress;
  }

  /// Get validation errors
  static List<String> getValidationErrors(Chapter chapter, double newProgress) {
    final errors = <String>[];
    
    if (!chapter.isUnlocked) {
      errors.add('章节未解锁');
    }
    
    if (chapter.isCompleted) {
      errors.add('章节已完成');
    }
    
    if (!isValidProgress(newProgress)) {
      errors.add('进度值无效');
    }
    
    if (newProgress < chapter.progress) {
      errors.add('进度不能倒退');
    }
    
    return errors;
  }
}
