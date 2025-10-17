import 'package:chaoxing_ft/domain/entities/quiz.dart';

/// Quiz validation utilities
class QuizValidation {
  /// Validate quiz answers
  static Map<String, String> validateAnswers(Quiz quiz, Map<String, String> answers) {
    final errors = <String, String>{};

    for (final question in quiz.questions) {
      final answer = answers[question.id];
      
      if (answer == null || answer.isEmpty) {
        errors[question.id] = '请回答此题目';
        continue;
      }

      switch (question.type) {
        case QuestionType.singleChoice:
          if (!question.options.any((option) => option.id == answer)) {
            errors[question.id] = '请选择有效选项';
          }
          break;
        case QuestionType.multipleChoice:
          final selectedOptions = answer.split(',');
          for (final optionId in selectedOptions) {
            if (!question.options.any((option) => option.id == optionId)) {
              errors[question.id] = '请选择有效选项';
              break;
            }
          }
          break;
        case QuestionType.trueFalse:
          if (answer != 'true' && answer != 'false') {
            errors[question.id] = '请选择正确或错误';
          }
          break;
        case QuestionType.fillInBlank:
          if (answer.trim().isEmpty) {
            errors[question.id] = '请填写答案';
          }
          break;
        case QuestionType.essay:
          if (answer.trim().isEmpty) {
            errors[question.id] = '请填写答案';
          } else if (answer.trim().length < 10) {
            errors[question.id] = '答案太短，请至少填写10个字符';
          }
          break;
        default:
          errors[question.id] = '不支持的问题类型';
      }
    }

    return errors;
  }

  /// Check if quiz can be submitted
  static bool canSubmitQuiz(Quiz quiz, Map<String, String> answers) {
    // Check if time is up
    if (quiz.isTimeUp) {
      return false;
    }

    // Check if all required questions are answered
    for (final question in quiz.questions) {
      final answer = answers[question.id];
      if (answer == null || answer.isEmpty) {
        return false;
      }
    }

    return true;
  }

  /// Get submission warnings
  static List<String> getSubmissionWarnings(Quiz quiz, Map<String, String> answers) {
    final warnings = <String>[];

    // Check unanswered questions
    final unansweredQuestions = quiz.questions.where((q) => 
      answers[q.id] == null || answers[q.id]!.isEmpty
    ).length;

    if (unansweredQuestions > 0) {
      warnings.add('还有 $unansweredQuestions 道题目未回答');
    }

    // Check time remaining
    final remaining = quiz.remainingTime;
    if (remaining != null && remaining.inMinutes < 5) {
      warnings.add('剩余时间不足5分钟');
    }

    // Check attempt limit
    if (quiz.attemptLimit != null && !quiz.canAttempt) {
      warnings.add('已达到最大尝试次数');
    }

    return warnings;
  }

  /// Validate quiz configuration
  static Map<String, String> validateQuizConfig(Quiz quiz) {
    final errors = <String, String>{};

    if (quiz.name.isEmpty) {
      errors['name'] = '测验名称不能为空';
    }

    if (quiz.questions.isEmpty) {
      errors['questions'] = '测验必须包含至少一道题目';
    }

    for (int i = 0; i < quiz.questions.length; i++) {
      final question = quiz.questions[i];
      final questionErrors = validateQuestion(question, i + 1);
      errors.addAll(questionErrors);
    }

    if (quiz.timeLimit != null && quiz.timeLimit! <= 0) {
      errors['timeLimit'] = '时间限制必须大于0';
    }

    if (quiz.attemptLimit != null && quiz.attemptLimit! <= 0) {
      errors['attemptLimit'] = '尝试次数限制必须大于0';
    }

    return errors;
  }

  /// Validate individual question
  static Map<String, String> validateQuestion(Question question, int questionNumber) {
    final errors = <String, String>{};
    final prefix = '题目$questionNumber';

    if (question.text.isEmpty) {
      errors['$prefix.text'] = '题目内容不能为空';
    }

    if (question.type == QuestionType.singleChoice || question.type == QuestionType.multipleChoice) {
      if (question.options.isEmpty) {
        errors['$prefix.options'] = '选择题必须包含选项';
      } else {
        for (int i = 0; i < question.options.length; i++) {
          final option = question.options[i];
          if (option.text.isEmpty) {
            errors['$prefix.options.${i + 1}'] = '选项内容不能为空';
          }
        }
      }

      if (question.correctAnswers.isEmpty) {
        errors['$prefix.correctAnswers'] = '选择题必须包含正确答案';
      } else {
        for (final answerId in question.correctAnswers) {
          if (!question.options.any((option) => option.id == answerId)) {
            errors['$prefix.correctAnswers'] = '正确答案ID无效';
            break;
          }
        }
      }
    }

    if (question.points != null && question.points! <= 0) {
      errors['$prefix.points'] = '题目分值必须大于0';
    }

    return errors;
  }

  /// Calculate quiz score
  static double calculateScore(Quiz quiz, Map<String, String> answers) {
    if (quiz.questions.isEmpty) return 0.0;

    int totalPoints = 0;
    int earnedPoints = 0;

    for (final question in quiz.questions) {
      final questionPoints = question.points ?? 1;
      totalPoints += questionPoints;

      final answer = answers[question.id];
      if (answer != null && answer.isNotEmpty) {
        if (isAnswerCorrect(question, answer)) {
          earnedPoints += questionPoints;
        }
      }
    }

    return totalPoints > 0 ? earnedPoints / totalPoints : 0.0;
  }

  /// Check if answer is correct
  static bool isAnswerCorrect(Question question, String answer) {
    switch (question.type) {
      case QuestionType.singleChoice:
        return question.correctAnswers.contains(answer);
      case QuestionType.multipleChoice:
        final selectedOptions = answer.split(',');
        if (selectedOptions.length != question.correctAnswers.length) {
          return false;
        }
        for (final correctAnswer in question.correctAnswers) {
          if (!selectedOptions.contains(correctAnswer)) {
            return false;
          }
        }
        return true;
      case QuestionType.trueFalse:
        return question.correctAnswers.contains(answer);
      case QuestionType.fillInBlank:
        return question.correctAnswers.any((correct) => 
          correct.toLowerCase().trim() == answer.toLowerCase().trim()
        );
      case QuestionType.essay:
        // Essay questions typically require manual grading
        return false;
      default:
        return false;
    }
  }

  /// Get answer feedback
  static String getAnswerFeedback(Question question, String answer) {
    if (isAnswerCorrect(question, answer)) {
      return '回答正确！';
    } else {
      return '回答错误。正确答案是: ${question.correctAnswers.join(', ')}';
    }
  }

  /// Format answer for display
  static String formatAnswer(Question question, String answer) {
    switch (question.type) {
      case QuestionType.singleChoice:
        final option = question.options.firstWhere((opt) => opt.id == answer);
        return option.text;
      case QuestionType.multipleChoice:
        final selectedOptions = answer.split(',');
        final optionTexts = selectedOptions.map((id) {
          final option = question.options.firstWhere((opt) => opt.id == id);
          return option.text;
        }).toList();
        return optionTexts.join(', ');
      case QuestionType.trueFalse:
        return answer == 'true' ? '正确' : '错误';
      case QuestionType.fillInBlank:
      case QuestionType.essay:
        return answer;
      default:
        return answer;
    }
  }
}
