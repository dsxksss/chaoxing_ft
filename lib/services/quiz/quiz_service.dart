import 'package:chaoxing_ft/domain/entities/quiz.dart';
import 'package:chaoxing_ft/domain/usecases/quiz_usecase.dart';

/// Service for quiz operations
class QuizService {

  QuizService({
    required this.getQuizDetailsUseCase,
    required this.getQuizzesForChapterUseCase,
    required this.startQuizUseCase,
    required this.submitQuizUseCase,
    required this.getQuizResultsUseCase,
    required this.saveQuizProgressUseCase,
    required this.getQuizAttemptsUseCase,
    required this.getQuizStatisticsUseCase,
  });
  final GetQuizDetailsUseCase getQuizDetailsUseCase;
  final GetQuizzesForChapterUseCase getQuizzesForChapterUseCase;
  final StartQuizUseCase startQuizUseCase;
  final SubmitQuizUseCase submitQuizUseCase;
  final GetQuizResultsUseCase getQuizResultsUseCase;
  final SaveQuizProgressUseCase saveQuizProgressUseCase;
  final GetQuizAttemptsUseCase getQuizAttemptsUseCase;
  final GetQuizStatisticsUseCase getQuizStatisticsUseCase;

  /// Get quiz details
  Future<Quiz> getQuizDetails(String quizId) async {
    return await getQuizDetailsUseCase(quizId);
  }

  /// Get quizzes for a chapter
  Future<List<Quiz>> getQuizzesForChapter(String chapterId) async {
    return await getQuizzesForChapterUseCase(chapterId);
  }

  /// Start a quiz
  Future<Quiz> startQuiz(String quizId) async {
    return await startQuizUseCase(quizId);
  }

  /// Submit quiz answers
  Future<Quiz> submitQuiz(String quizId, Map<String, String> answers) async {
    return await submitQuizUseCase(quizId, answers);
  }

  /// Get quiz results
  Future<Quiz> getQuizResults(String quizId) async {
    return await getQuizResultsUseCase(quizId);
  }

  /// Save quiz progress
  Future<void> saveQuizProgress(String quizId, Map<String, String> answers) async {
    return await saveQuizProgressUseCase(quizId, answers);
  }

  /// Get quiz attempts
  Future<List<Quiz>> getQuizAttempts(String quizId) async {
    return await getQuizAttemptsUseCase(quizId);
  }

  /// Get quiz statistics
  Future<Map<String, dynamic>> getQuizStatistics(String quizId) async {
    return await getQuizStatisticsUseCase(quizId);
  }
}
