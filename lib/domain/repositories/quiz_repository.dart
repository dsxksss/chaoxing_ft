import 'package:chaoxing_ft/domain/entities/quiz.dart';

/// Repository interface for quiz operations
abstract class QuizRepository {
  /// Get quiz details by ID
  Future<Quiz> getQuizDetails(String quizId);

  /// Get quizzes for a chapter
  Future<List<Quiz>> getQuizzesForChapter(String chapterId);

  /// Start a quiz
  Future<Quiz> startQuiz(String quizId);

  /// Submit quiz answers
  Future<Quiz> submitQuiz(String quizId, Map<String, String> answers);

  /// Get quiz results
  Future<Quiz> getQuizResults(String quizId);

  /// Save quiz progress
  Future<void> saveQuizProgress(String quizId, Map<String, String> answers);

  /// Get quiz attempts
  Future<List<Quiz>> getQuizAttempts(String quizId);

  /// Get quiz statistics
  Future<Map<String, dynamic>> getQuizStatistics(String quizId);
}
