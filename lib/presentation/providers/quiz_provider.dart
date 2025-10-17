import 'package:chaoxing_ft/domain/entities/quiz.dart';
import 'package:chaoxing_ft/presentation/providers/base_provider.dart';
import 'package:chaoxing_ft/services/quiz/quiz_service.dart';

/// Provider for quiz state management
class QuizProvider extends BaseProvider {

  QuizProvider(this.quizService);
  final QuizService quizService;

  List<Quiz> _quizzes = [];
  Quiz? _currentQuiz;
  Map<String, String> _currentAnswers = {};
  bool _isQuizActive = false;
  DateTime? _quizStartTime;

  List<Quiz> get quizzes => _quizzes;
  Quiz? get currentQuiz => _currentQuiz;
  Map<String, String> get currentAnswers => _currentAnswers;
  bool get isQuizActive => _isQuizActive;
  DateTime? get quizStartTime => _quizStartTime;

  /// Get quizzes for a chapter
  Future<void> fetchQuizzesForChapter(String chapterId) async {
    setLoading(true);
    setError(null);
    try {
      _quizzes = await quizService.getQuizzesForChapter(chapterId);
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Start a quiz
  Future<void> startQuiz(String quizId) async {
    setLoading(true);
    setError(null);
    try {
      _currentQuiz = await quizService.startQuiz(quizId);
      _isQuizActive = true;
      _quizStartTime = DateTime.now();
      _currentAnswers = {};
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Submit quiz answers
  Future<void> submitQuiz(String quizId, Map<String, String> answers) async {
    setLoading(true);
    setError(null);
    try {
      _currentQuiz = await quizService.submitQuiz(quizId, answers);
      _isQuizActive = false;
      _quizStartTime = null;
      _currentAnswers = {};
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Save quiz progress
  Future<void> saveQuizProgress(String quizId, Map<String, String> answers) async {
    setLoading(true);
    setError(null);
    try {
      await quizService.saveQuizProgress(quizId, answers);
      _currentAnswers = answers;
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Get quiz results
  Future<void> getQuizResults(String quizId) async {
    setLoading(true);
    setError(null);
    try {
      _currentQuiz = await quizService.getQuizResults(quizId);
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Get quiz attempts
  Future<void> getQuizAttempts(String quizId) async {
    setLoading(true);
    setError(null);
    try {
      _quizzes = await quizService.getQuizAttempts(quizId);
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Get quiz statistics
  Future<Map<String, dynamic>> getQuizStatistics(String quizId) async {
    setLoading(true);
    setError(null);
    try {
      return await quizService.getQuizStatistics(quizId);
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Update answer for a question
  void updateAnswer(String questionId, String answer) {
    _currentAnswers[questionId] = answer;
    notifyListeners();
  }

  /// Clear answer for a question
  void clearAnswer(String questionId) {
    _currentAnswers.remove(questionId);
    notifyListeners();
  }

  /// Clear all answers
  void clearAllAnswers() {
    _currentAnswers.clear();
    notifyListeners();
  }

  /// Get answer for a question
  String? getAnswer(String questionId) {
    return _currentAnswers[questionId];
  }

  /// Check if question is answered
  bool isQuestionAnswered(String questionId) {
    return _currentAnswers.containsKey(questionId) && _currentAnswers[questionId]!.isNotEmpty;
  }

  /// Get answered questions count
  int get answeredQuestionsCount {
    return _currentAnswers.values.where((answer) => answer.isNotEmpty).length;
  }

  /// Get progress percentage
  double get progress {
    if (_currentQuiz == null || _currentQuiz!.totalQuestions == 0) return 0.0;
    return answeredQuestionsCount / _currentQuiz!.totalQuestions;
  }

  /// Reset quiz state
  void resetQuizState() {
    _currentQuiz = null;
    _currentAnswers = {};
    _isQuizActive = false;
    _quizStartTime = null;
    notifyListeners();
  }
}
