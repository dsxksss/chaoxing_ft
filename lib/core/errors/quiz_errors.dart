import 'package:chaoxing_ft/domain/entities/quiz.dart';
import 'package:chaoxing_ft/core/validation/quiz_validation.dart';

/// Quiz-specific exceptions
class QuizException implements Exception {

  const QuizException(
    this.message, {
    this.quizId,
    this.operation,
    this.originalError,
  });
  final String message;
  final String? quizId;
  final String? operation;
  final dynamic originalError;

  @override
  String toString() {
    final buffer = StringBuffer('QuizException: $message');
    if (quizId != null) buffer.write(' (Quiz ID: $quizId)');
    if (operation != null) buffer.write(' (Operation: $operation)');
    if (originalError != null) buffer.write(' (Original: $originalError)');
    return buffer.toString();
  }
}

/// Quiz not found exception
class QuizNotFoundException extends QuizException {
  const QuizNotFoundException(String quizId) : super(
    'Quiz not found: $quizId',
    quizId: quizId,
    operation: 'getQuizDetails',
  );
}

/// Quiz not available exception
class QuizNotAvailableException extends QuizException {
  const QuizNotAvailableException(String quizId, String reason) : super(
    'Quiz not available: $reason',
    quizId: quizId,
    operation: 'startQuiz',
  );
}

/// Quiz time up exception
class QuizTimeUpException extends QuizException {
  const QuizTimeUpException(String quizId) : super(
    'Quiz time is up',
    quizId: quizId,
    operation: 'submitQuiz',
  );
}

/// Quiz attempt limit exceeded exception
class QuizAttemptLimitExceededException extends QuizException {
  const QuizAttemptLimitExceededException(String quizId, int attemptLimit) : super(
    'Quiz attempt limit exceeded: $attemptLimit',
    quizId: quizId,
    operation: 'startQuiz',
  );
}

/// Quiz submission validation exception
class QuizSubmissionValidationException extends QuizException {

  const QuizSubmissionValidationException(
    String quizId,
    this.validationErrors,
  ) : super(
    'Quiz submission validation failed',
    quizId: quizId,
    operation: 'submitQuiz',
  );
  final Map<String, String> validationErrors;
}

/// Quiz answer validation exception
class QuizAnswerValidationException extends QuizException {

  const QuizAnswerValidationException(
    String quizId,
    this.questionId,
    this.answer,
    this.validationError,
  ) : super(
    'Quiz answer validation failed: $validationError',
    quizId: quizId,
    operation: 'validateAnswer',
  );
  final String questionId;
  final String answer;
  final String validationError;
}

/// Quiz error handler
class QuizErrorHandler {
  /// Handle quiz errors and convert to user-friendly messages
  static String handleQuizError(dynamic error, {String? quizId, String? operation}) {
    if (error is QuizException) {
      return _getUserFriendlyMessage(error);
    }

    if (error is QuizNotFoundException) {
      return '测验不存在或已被删除';
    }

    if (error is QuizNotAvailableException) {
      return '测验当前不可用，请稍后再试';
    }

    if (error is QuizTimeUpException) {
      return '测验时间已到，无法提交';
    }

    if (error is QuizAttemptLimitExceededException) {
      return '已达到最大尝试次数';
    }

    if (error is QuizSubmissionValidationException) {
      return '提交验证失败，请检查答案';
    }

    if (error is QuizAnswerValidationException) {
      return '答案格式错误，请重新输入';
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

  /// Get user-friendly error message for quiz exceptions
  static String _getUserFriendlyMessage(QuizException error) {
    switch (error.runtimeType) {
      case QuizNotFoundException:
        return '测验不存在或已被删除';
      case QuizNotAvailableException _:
        return '测验当前不可用，请稍后再试';
      case QuizTimeUpException _:
        return '测验时间已到，无法提交';
      case QuizAttemptLimitExceededException _:
        return '已达到最大尝试次数';
      case QuizSubmissionValidationException _:
        return '提交验证失败，请检查答案';
      case QuizAnswerValidationException _:
        return '答案格式错误，请重新输入';
      default:
        return error.message;
    }
  }

  /// Check if error is recoverable
  static bool isRecoverableError(dynamic error) {
    if (error is QuizException) {
      return error is! QuizNotFoundException && 
             error is! QuizAttemptLimitExceededException;
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
    if (error is QuizTimeUpException) {
      return '请重新开始测验';
    }

    if (error is QuizSubmissionValidationException) {
      return '请检查并修正答案后重新提交';
    }

    if (error is QuizAnswerValidationException) {
      return '请重新输入答案';
    }

    if (error.toString().contains('SocketException') || 
        error.toString().contains('TimeoutException')) {
      return '请检查网络连接后重试';
    }

    return '请稍后重试';
  }

  /// Log error with context
  static void logError(dynamic error, {String? quizId, String? operation}) {
    // This would typically use a logging service
    print('Quiz Error: ${error.toString()}');
    if (quizId != null) print('Quiz ID: $quizId');
    if (operation != null) print('Operation: $operation');
  }

  /// Create quiz exception from generic error
  static QuizException createQuizException(
    dynamic error, {
    String? quizId,
    String? operation,
  }) {
    if (error is QuizException) {
      return error;
    }

    return QuizException(
      error.toString(),
      quizId: quizId,
      operation: operation,
      originalError: error,
    );
  }

  /// Validate quiz state for operation
  static void validateQuizState(Quiz quiz, String operation) {
    switch (operation) {
      case 'startQuiz':
        if (!quiz.canAttempt) {
          throw QuizAttemptLimitExceededException(quiz.id, quiz.attemptLimit ?? 0);
        }
        if (quiz.isCompleted) {
          throw QuizNotAvailableException(quiz.id, 'Quiz already completed');
        }
        break;
      case 'submitQuiz':
        if (quiz.isTimeUp) {
          throw QuizTimeUpException(quiz.id);
        }
        if (quiz.isCompleted) {
          throw QuizNotAvailableException(quiz.id, 'Quiz already completed');
        }
        break;
      case 'getResults':
        if (!quiz.isCompleted) {
          throw QuizNotAvailableException(quiz.id, 'Quiz not completed yet');
        }
        break;
    }
  }

  /// Handle quiz submission errors
  static void handleSubmissionErrors(
    String quizId,
    Map<String, String> answers,
    Quiz quiz,
  ) {
    // Validate quiz state
    validateQuizState(quiz, 'submitQuiz');

    // Validate answers
    final validationErrors = QuizValidation.validateAnswers(quiz, answers);
    if (validationErrors.isNotEmpty) {
      throw QuizSubmissionValidationException(quizId, validationErrors);
    }

    // Check if all questions are answered
    final unansweredQuestions = quiz.questions.where((q) => 
      answers[q.id] == null || answers[q.id]!.isEmpty
    ).length;

    if (unansweredQuestions > 0) {
      throw QuizSubmissionValidationException(
        quizId,
        {'unanswered': '还有 $unansweredQuestions 道题目未回答'},
      );
    }
  }
}
