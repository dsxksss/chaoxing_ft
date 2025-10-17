import 'package:logger/logger.dart';

/// Logger for chapter operations
class ChapterLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Log chapter fetch
  static void logChapterFetch(String courseId, int chapterCount) {
    _logger.i('Chapters fetched: course=$courseId, count=$chapterCount');
  }

  /// Log chapter details retrieval
  static void logChapterDetailsRetrieval(String chapterId) {
    _logger.d('Chapter details retrieved: $chapterId');
  }

  /// Log chapter progress update
  static void logProgressUpdated(String chapterId, double progress) {
    _logger.d('Chapter progress updated: $chapterId, progress: ${(progress * 100).toInt()}%');
  }

  /// Log chapter completion
  static void logChapterCompleted(String chapterId) {
    _logger.i('Chapter completed: $chapterId');
  }

  /// Log chapter unlock
  static void logChapterUnlocked(String chapterId) {
    _logger.i('Chapter unlocked: $chapterId');
  }

  /// Log chapter statistics retrieval
  static void logChapterStatisticsRetrieval(String chapterId) {
    _logger.d('Chapter statistics retrieved: $chapterId');
  }

  /// Log course progress summary retrieval
  static void logCourseProgressSummaryRetrieval(String courseId) {
    _logger.d('Course progress summary retrieved: $courseId');
  }

  /// Log overdue chapters retrieval
  static void logOverdueChaptersRetrieval(String courseId, int count) {
    _logger.d('Overdue chapters retrieved: course=$courseId, count=$count');
  }

  /// Log upcoming chapters retrieval
  static void logUpcomingChaptersRetrieval(String courseId, int count) {
    _logger.d('Upcoming chapters retrieved: course=$courseId, count=$count');
  }

  /// Log chapter completion timeline retrieval
  static void logChapterCompletionTimelineRetrieval(String courseId) {
    _logger.d('Chapter completion timeline retrieved: $courseId');
  }

  /// Log progress tracking started
  static void logProgressTrackingStarted(String chapterId) {
    _logger.d('Chapter progress tracking started: $chapterId');
  }

  /// Log progress tracking stopped
  static void logProgressTrackingStopped(String chapterId) {
    _logger.d('Chapter progress tracking stopped: $chapterId');
  }

  /// Log task completed
  static void logTaskCompleted(String chapterId, String taskId) {
    _logger.d('Task completed: chapter=$chapterId, task=$taskId');
  }

  /// Log task progress changed
  static void logTaskProgressChanged(String chapterId, String taskId, double progress) {
    _logger.d('Task progress changed: chapter=$chapterId, task=$taskId, progress: ${(progress * 100).toInt()}%');
  }

  /// Log chapter navigation
  static void logChapterNavigation(String fromChapterId, String toChapterId) {
    _logger.d('Chapter navigation: from $fromChapterId to $toChapterId');
  }

  /// Log chapter view
  static void logChapterView(String chapterId, String chapterName) {
    _logger.d('Chapter view: $chapterId ($chapterName)');
  }

  /// Log chapter list view
  static void logChapterListView(String courseId, int chapterCount) {
    _logger.d('Chapter list view: course=$courseId, chapters=$chapterCount');
  }

  /// Log chapter progress summary view
  static void logChapterProgressSummaryView(String courseId, double overallProgress) {
    _logger.d('Chapter progress summary view: course=$courseId, progress: ${(overallProgress * 100).toInt()}%');
  }

  /// Log chapter timeline view
  static void logChapterTimelineView(String courseId, int timelineItems) {
    _logger.d('Chapter timeline view: course=$courseId, items=$timelineItems');
  }

  /// Log chapter error
  static void logChapterError(String chapterId, String operation, dynamic error, StackTrace? stackTrace) {
    _logger.e('Chapter error: $chapterId, operation: $operation, error: $error');
  }

  /// Log chapter validation error
  static void logChapterValidationError(String chapterId, String validationError) {
    _logger.w('Chapter validation error: $chapterId, error: $validationError');
  }

  /// Log chapter unlock attempt
  static void logChapterUnlockAttempt(String chapterId, bool success) {
    if (success) {
      _logger.i('Chapter unlock attempt successful: $chapterId');
    } else {
      _logger.w('Chapter unlock attempt failed: $chapterId');
    }
  }

  /// Log chapter completion attempt
  static void logChapterCompletionAttempt(String chapterId, bool success) {
    if (success) {
      _logger.i('Chapter completion attempt successful: $chapterId');
    } else {
      _logger.w('Chapter completion attempt failed: $chapterId');
    }
  }

  /// Log chapter progress calculation
  static void logChapterProgressCalculation(String chapterId, Map<String, dynamic> stats) {
    _logger.d('Chapter progress calculated: $chapterId, stats: ${stats.keys.join(', ')}');
  }

  /// Log chapter performance metrics
  static void logChapterPerformanceMetrics(String chapterId, Map<String, dynamic> metrics) {
    _logger.d('Chapter performance metrics: $chapterId, metrics: ${metrics.keys.join(', ')}');
  }

  /// Log chapter cache operations
  static void logChapterCacheOperation(String operation, String chapterId, bool success) {
    if (success) {
      _logger.d('Chapter cache $operation successful: $chapterId');
    } else {
      _logger.w('Chapter cache $operation failed: $chapterId');
    }
  }

  /// Log chapter synchronization
  static void logChapterSynchronization(String chapterId, String operation, bool success) {
    if (success) {
      _logger.i('Chapter synchronization $operation successful: $chapterId');
    } else {
      _logger.e('Chapter synchronization $operation failed: $chapterId');
    }
  }

  /// Log chapter analytics
  static void logChapterAnalytics(String chapterId, Map<String, dynamic> analytics) {
    _logger.d('Chapter analytics: $chapterId, data: ${analytics.keys.join(', ')}');
  }
}