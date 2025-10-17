import 'package:chaoxing_ft/domain/entities/quiz.dart';
import 'package:chaoxing_ft/domain/repositories/quiz_repository.dart';

/// Use case for getting quiz details
class GetQuizDetailsUseCase {

  GetQuizDetailsUseCase(this.repository);
  final QuizRepository repository;

  Future<Quiz> call(String quizId) {
    return repository.getQuizDetails(quizId);
  }
}

/// Use case for getting quizzes for a chapter
class GetQuizzesForChapterUseCase {

  GetQuizzesForChapterUseCase(this.repository);
  final QuizRepository repository;

  Future<List<Quiz>> call(String chapterId) {
    return repository.getQuizzesForChapter(chapterId);
  }
}

/// Use case for starting a quiz
class StartQuizUseCase {

  StartQuizUseCase(this.repository);
  final QuizRepository repository;

  Future<Quiz> call(String quizId) {
    return repository.startQuiz(quizId);
  }
}

/// Use case for submitting quiz answers
class SubmitQuizUseCase {

  SubmitQuizUseCase(this.repository);
  final QuizRepository repository;

  Future<Quiz> call(String quizId, Map<String, String> answers) {
    return repository.submitQuiz(quizId, answers);
  }
}

/// Use case for getting quiz results
class GetQuizResultsUseCase {

  GetQuizResultsUseCase(this.repository);
  final QuizRepository repository;

  Future<Quiz> call(String quizId) {
    return repository.getQuizResults(quizId);
  }
}

/// Use case for saving quiz progress
class SaveQuizProgressUseCase {

  SaveQuizProgressUseCase(this.repository);
  final QuizRepository repository;

  Future<void> call(String quizId, Map<String, String> answers) {
    return repository.saveQuizProgress(quizId, answers);
  }
}

/// Use case for getting quiz attempts
class GetQuizAttemptsUseCase {

  GetQuizAttemptsUseCase(this.repository);
  final QuizRepository repository;

  Future<List<Quiz>> call(String quizId) {
    return repository.getQuizAttempts(quizId);
  }
}

/// Use case for getting quiz statistics
class GetQuizStatisticsUseCase {

  GetQuizStatisticsUseCase(this.repository);
  final QuizRepository repository;

  Future<Map<String, dynamic>> call(String quizId) {
    return repository.getQuizStatistics(quizId);
  }
}
