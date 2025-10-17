import 'package:flutter/foundation.dart';
import 'package:chaoxing_ft/domain/entities/chapter.dart';
import 'package:chaoxing_ft/domain/entities/task.dart';

/// Chapter-specific exceptions
class ChapterException implements Exception {

  const ChapterException(
    this.message, {
    this.chapterId,
    this.operation,
    this.originalError,
  });
  final String message;
  final String? chapterId;
  final String? operation;
  final dynamic originalError;

  @override
  String toString() {
    final buffer = StringBuffer('ChapterException: $message');
    if (chapterId != null) buffer.write(' (Chapter ID: $chapterId)');
    if (operation != null) buffer.write(' (Operation: $operation)');
    if (originalError != null) buffer.write(' (Original: $originalError)');
    return buffer.toString();
  }
}

/// Chapter not found exception
class ChapterNotFoundException extends ChapterException {
  const ChapterNotFoundException(String chapterId) : super(
    'Chapter not found: $chapterId',
    chapterId: chapterId,
    operation: 'getChapterDetails',
  );
}

/// Chapter not unlocked exception
class ChapterNotUnlockedException extends ChapterException {
  const ChapterNotUnlockedException(String chapterId) : super(
    'Chapter not unlocked: $chapterId',
    chapterId: chapterId,
    operation: 'accessChapter',
  );
}

/// Chapter already completed exception
class ChapterAlreadyCompletedException extends ChapterException {
  const ChapterAlreadyCompletedException(String chapterId) : super(
    'Chapter already completed: $chapterId',
    chapterId: chapterId,
    operation: 'markChapterAsCompleted',
  );
}

/// Chapter progress validation exception
class ChapterProgressValidationException extends ChapterException {

  const ChapterProgressValidationException(
    String chapterId,
    this.progress,
    this.validationErrors,
  ) : super(
    'Chapter progress validation failed',
    chapterId: chapterId,
    operation: 'updateChapterProgress',
  );
  final double progress;
  final List<String> validationErrors;
}

/// Chapter unlock validation exception
class ChapterUnlockValidationException extends ChapterException {

  const ChapterUnlockValidationException(
    String chapterId,
    this.validationErrors,
  ) : super(
    'Chapter unlock validation failed',
    chapterId: chapterId,
    operation: 'unlockChapter',
  );
  final List<String> validationErrors;
}

/// Chapter completion validation exception
class ChapterCompletionValidationException extends ChapterException {

  const ChapterCompletionValidationException(
    String chapterId,
    this.validationErrors,
  ) : super(
    'Chapter completion validation failed',
    chapterId: chapterId,
    operation: 'markChapterAsCompleted',
  );
  final List<String> validationErrors;
}

/// Chapter error handler
class ChapterErrorHandler {
  /// Handle chapter errors and convert to user-friendly messages
  static String handleChapterError(dynamic error, {String? chapterId, String? operation}) {
    if (error is ChapterException) {
      return _getUserFriendlyMessage(error);
    }

    if (error is ChapterNotFoundException) {
      return '章节不存在或已被删除';
    }

    if (error is ChapterNotUnlockedException) {
      return '章节未解锁，无法访问';
    }

    if (error is ChapterAlreadyCompletedException) {
      return '章节已完成';
    }

    if (error is ChapterProgressValidationException) {
      return '进度更新失败，请检查输入';
    }

    if (error is ChapterUnlockValidationException) {
      return '章节解锁失败，请检查解锁条件';
    }

    if (error is ChapterCompletionValidationException) {
      return '章节完成失败，请检查完成条件';
    }

    // Handle network errors
    if (error.toString().contains('SocketException') || 
        error.toString().contains('TimeoutException')) {
      return '网络连接失败，请检查网络设置';
    }

    if (error.toString().contains('HttpException')) {
      return '服务器错误，请稍后再试';
    }

    // Handle generic errors
    return '操作失败，请重试';
  }

  /// Get user-friendly error message for chapter exceptions
  static String _getUserFriendlyMessage(ChapterException error) {
    switch (error.runtimeType) {
      case ChapterNotFoundException _:
        return '章节不存在或已被删除';
      case ChapterNotUnlockedException _:
        return '章节未解锁，无法访问';
      case ChapterAlreadyCompletedException _:
        return '章节已完成';
      case ChapterProgressValidationException _:
        return '进度更新失败，请检查输入';
      case ChapterUnlockValidationException _:
        return '章节解锁失败，请检查解锁条件';
      case ChapterCompletionValidationException _:
        return '章节完成失败，请检查完成条件';
      default:
        return error.message;
    }
  }

  /// Check if error is recoverable
  static bool isRecoverableError(dynamic error) {
    if (error is ChapterException) {
      return error is! ChapterNotFoundException && 
             error is! ChapterAlreadyCompletedException;
    }

    // Network errors are usually recoverable
    if (error.toString().contains('SocketException') || 
        error.toString().contains('TimeoutException')) {
      return true;
    }

    return false;
  }

  /// Get retry suggestion for error
  static String getRetrySuggestion(dynamic error) {
    if (error is ChapterNotUnlockedException) {
      return '请先完成前置章节';
    }

    if (error is ChapterProgressValidationException) {
      return '请检查进度值是否正确';
    }

    if (error is ChapterUnlockValidationException) {
      return '请检查解锁条件';
    }

    if (error is ChapterCompletionValidationException) {
      return '请完成所有必需任务';
    }

    if (error.toString().contains('SocketException') || 
        error.toString().contains('TimeoutException')) {
      return '请检查网络连接后重试';
    }

    return '请稍后重试';
  }

  /// Log error with context
  static void logError(dynamic error, {String? chapterId, String? operation}) {
    // This would typically use a logging service
    if (kDebugMode) {
      print('Chapter Error: ${error.toString()}');
    }
    if (chapterId != null) print('Chapter ID: $chapterId');
    if (operation != null) print('Operation: $operation');
  }

  /// Create chapter exception from generic error
  static ChapterException createChapterException(
    dynamic error, {
    String? chapterId,
    String? operation,
  }) {
    if (error is ChapterException) {
      return error;
    }

    return ChapterException(
      error.toString(),
      chapterId: chapterId,
      operation: operation,
      originalError: error,
    );
  }

  /// Validate chapter state for operation
  static void validateChapterState(Chapter chapter, String operation) {
    switch (operation) {
      case 'accessChapter':
        if (!chapter.isUnlocked) {
          throw ChapterNotUnlockedException(chapter.id);
        }
        break;
      case 'updateProgress':
        if (!chapter.isUnlocked) {
          throw ChapterNotUnlockedException(chapter.id);
        }
        if (chapter.isCompleted) {
          throw ChapterAlreadyCompletedException(chapter.id);
        }
        break;
      case 'markCompleted':
        if (chapter.isCompleted) {
          throw ChapterAlreadyCompletedException(chapter.id);
        }
        break;
      case 'unlockChapter':
        if (chapter.isUnlocked) {
          throw ChapterException('Chapter already unlocked', chapterId: chapter.id);
        }
        break;
    }
  }

  /// Handle chapter progress update errors
  static void handleProgressUpdateErrors(
    String chapterId,
    double progress,
    Chapter chapter,
  ) {
    // Validate chapter state
    validateChapterState(chapter, 'updateProgress');

    // Validate progress value
    if (progress < 0.0 || progress > 1.0) {
      throw ChapterProgressValidationException(
        chapterId,
        progress,
        ['Progress must be between 0.0 and 1.0'],
      );
    }

    // Check if progress is not decreasing
    if (progress < chapter.progress) {
      throw ChapterProgressValidationException(
        chapterId,
        progress,
        ['Progress cannot decrease'],
      );
    }
  }

  /// Handle chapter unlock errors
  static void handleUnlockErrors(
    String chapterId,
    Chapter chapter,
    List<Chapter> previousChapters,
  ) {
    // Validate chapter state
    validateChapterState(chapter, 'unlockChapter');

    // Check unlock conditions
    final validationErrors = <String>[];

    // Check if unlock date has passed
    if (chapter.unlockDate != null && DateTime.now().isBefore(chapter.unlockDate!)) {
      validationErrors.add('Unlock date has not passed');
    }

    // Check if previous chapters are completed (if required)
    final requiredPreviousChapters = previousChapters.where((ch) => 
      ch.order < chapter.order && ch.metadata?['required'] == true
    ).toList();

    for (final prevChapter in requiredPreviousChapters) {
      if (!prevChapter.isCompleted) {
        validationErrors.add('Required previous chapter ${prevChapter.name} is not completed');
      }
    }

    if (validationErrors.isNotEmpty) {
      throw ChapterUnlockValidationException(chapterId, validationErrors);
    }
  }

  /// Handle chapter completion errors
  static void handleCompletionErrors(
    String chapterId,
    Chapter chapter,
    List<Task> tasks,
  ) {
    // Validate chapter state
    validateChapterState(chapter, 'markCompleted');

    // Check completion conditions
    final validationErrors = <String>[];

    // Check if all required tasks are completed
    final requiredTasks = tasks.where((task) => 
      (task.metadata?['required'] as bool?) == true
    ).toList();

    for (final task in requiredTasks) {
      if (!task.isCompleted) {
        validationErrors.add('Required task ${task.name} is not completed');
      }
    }

    // Check if progress is sufficient
    if (chapter.progress < 1.0) {
      validationErrors.add('Chapter progress must be 100%');
    }

    if (validationErrors.isNotEmpty) {
      throw ChapterCompletionValidationException(chapterId, validationErrors);
    }
  }
}
