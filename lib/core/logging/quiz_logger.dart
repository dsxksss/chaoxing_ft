import 'package:logger/logger.dart';

/// Logger for quiz operations
class QuizLogger {
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

  /// Log quiz start
  static void logQuizStart(String quizId, String quizName) {
    _logger.i('Quiz started: $quizId ($quizName)');
  }

  /// Log quiz submission
  static void logQuizSubmission(String quizId, String quizName, Map<String, String> answers) {
    _logger.i('Quiz submitted: $quizId ($quizName), answers: ${answers.length}');
  }

  /// Log quiz completion
  static void logQuizCompletion(String quizId, String quizName, double score, bool isPassed) {
    _logger.i('Quiz completed: $quizId ($quizName), score: ${(score * 100).toInt()}%, passed: $isPassed');
  }

  /// Log quiz progress save
  static void logQuizProgressSave(String quizId, Map<String, String> answers) {
    _logger.d('Quiz progress saved: $quizId, answers: ${answers.length}');
  }

  /// Log quiz results retrieval
  static void logQuizResultsRetrieval(String quizId) {
    _logger.d('Quiz results retrieved: $quizId');
  }

  /// Log quiz attempts retrieval
  static void logQuizAttemptsRetrieval(String quizId, int attemptCount) {
    _logger.d('Quiz attempts retrieved: $quizId, count: $attemptCount');
  }

  /// Log quiz statistics retrieval
  static void logQuizStatisticsRetrieval(String quizId) {
    _logger.d('Quiz statistics retrieved: $quizId');
  }

  /// Log answer update
  static void logAnswerUpdate(String quizId, String questionId, String answer) {
    _logger.d('Answer updated: quiz=$quizId, question=$questionId, answer=$answer');
  }

  /// Log answer clear
  static void logAnswerClear(String quizId, String questionId) {
    _logger.d('Answer cleared: quiz=$quizId, question=$questionId');
  }

  /// Log quiz validation
  static void logQuizValidation(String quizId, Map<String, String> errors) {
    if (errors.isEmpty) {
      _logger.d('Quiz validation passed: $quizId');
    } else {
      _logger.w('Quiz validation failed: $quizId, errors: ${errors.keys.join(', ')}');
    }
  }

  /// Log quiz time warning
  static void logQuizTimeWarning(String quizId, Duration remainingTime) {
    _logger.w('Quiz time warning: $quizId, remaining: ${remainingTime.inMinutes} minutes');
  }

  /// Log quiz time up
  static void logQuizTimeUp(String quizId) {
    _logger.w('Quiz time up: $quizId');
  }

  /// Log quiz attempt limit reached
  static void logQuizAttemptLimitReached(String quizId, int attemptLimit) {
    _logger.w('Quiz attempt limit reached: $quizId, limit: $attemptLimit');
  }

  /// Log quiz error
  static void logQuizError(String quizId, String operation, dynamic error, StackTrace? stackTrace) {
    _logger.e('Quiz error: $quizId, operation: $operation, error: $error', 
              error: error, stackTrace: stackTrace);
  }

  /// Log quiz navigation
  static void logQuizNavigation(String quizId, int fromQuestion, int toQuestion) {
    _logger.d('Quiz navigation: $quizId, from question $fromQuestion to question $toQuestion');
  }

  /// Log quiz page view
  static void logQuizPageView(String quizId, int questionNumber, int totalQuestions) {
    _logger.d('Quiz page view: $quizId, question $questionNumber/$totalQuestions');
  }

  /// Log quiz results view
  static void logQuizResultsView(String quizId, double score, bool isPassed) {
    _logger.d('Quiz results view: $quizId, score: ${(score * 100).toInt()}%, passed: $isPassed');
  }

  /// Log quiz retry
  static void logQuizRetry(String quizId) {
    _logger.i('Quiz retry: $quizId');
  }

  /// Log quiz abandon
  static void logQuizAbandon(String quizId) {
    _logger.w('Quiz abandoned: $quizId');
  }

  /// Log quiz statistics calculation
  static void logQuizStatisticsCalculation(String quizId, Map<String, dynamic> stats) {
    _logger.d('Quiz statistics calculated: $quizId, stats: ${stats.keys.join(', ')}');
  }

  /// Log quiz performance metrics
  static void logQuizPerformanceMetrics(String quizId, Map<String, dynamic> metrics) {
    _logger.d('Quiz performance metrics: $quizId, metrics: ${metrics.keys.join(', ')}');
  }
}
