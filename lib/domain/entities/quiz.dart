import 'package:json_annotation/json_annotation.dart';

part 'quiz.g.dart';

/// Quiz entity representing a quiz learning task
@JsonSerializable()
class Quiz {

  const Quiz({
    required this.id,
    required this.name,
    this.description,
    this.url,
    this.questions = const [],
    this.timeLimit,
    this.attemptLimit,
    this.currentAttempt,
    this.score,
    this.isCompleted = false,
    this.isPassed = false,
    this.startTime,
    this.endTime,
    this.submittedAt,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);
  final String id;
  final String name;
  final String? description;
  final String? url;
  final List<Question> questions;
  final int? timeLimit; // in minutes
  final int? attemptLimit;
  final int? currentAttempt;
  final double? score;
  final bool isCompleted;
  final bool isPassed;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? submittedAt;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  Map<String, dynamic> toJson() => _$QuizToJson(this);

  Quiz copyWith({
    String? id,
    String? name,
    String? description,
    String? url,
    List<Question>? questions,
    int? timeLimit,
    int? attemptLimit,
    int? currentAttempt,
    double? score,
    bool? isCompleted,
    bool? isPassed,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? submittedAt,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Quiz(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      url: url ?? this.url,
      questions: questions ?? this.questions,
      timeLimit: timeLimit ?? this.timeLimit,
      attemptLimit: attemptLimit ?? this.attemptLimit,
      currentAttempt: currentAttempt ?? this.currentAttempt,
      score: score ?? this.score,
      isCompleted: isCompleted ?? this.isCompleted,
      isPassed: isPassed ?? this.isPassed,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      submittedAt: submittedAt ?? this.submittedAt,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get total questions count
  int get totalQuestions => questions.length;

  /// Get answered questions count
  int get answeredQuestions => questions.where((q) => q.isAnswered).length;

  /// Get correct answers count
  int get correctAnswers => questions.where((q) => q.isCorrect).length;

  /// Get progress percentage
  double get progress {
    if (totalQuestions == 0) return 0.0;
    return answeredQuestions / totalQuestions;
  }

  /// Get accuracy percentage
  double get accuracy {
    if (answeredQuestions == 0) return 0.0;
    return correctAnswers / answeredQuestions;
  }

  /// Get remaining time
  Duration? get remainingTime {
    if (timeLimit == null || startTime == null) return null;
    final elapsed = DateTime.now().difference(startTime!);
    final remaining = Duration(minutes: timeLimit!) - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Check if time is up
  bool get isTimeUp {
    final remaining = remainingTime;
    return remaining != null && remaining == Duration.zero;
  }

  /// Check if can attempt
  bool get canAttempt {
    if (attemptLimit == null) return true;
    return (currentAttempt ?? 0) < attemptLimit!;
  }

  /// Get remaining attempts
  int get remainingAttempts {
    if (attemptLimit == null) return -1; // Unlimited
    return attemptLimit! - (currentAttempt ?? 0);
  }

  /// Get formatted score
  String get formattedScore {
    if (score == null) return '未评分';
    return '${(score! * 100).toInt()}%';
  }

  /// Get formatted time limit
  String get formattedTimeLimit {
    if (timeLimit == null) return '无时间限制';
    return '$timeLimit 分钟';
  }

  /// Get formatted duration
  String get formattedDuration {
    if (startTime == null || endTime == null) return '未知';
    final duration = endTime!.difference(startTime!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes分$seconds秒';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Quiz && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Quiz(id: $id, name: $name, score: $score)';
  }
}

/// Question entity
@JsonSerializable()
class Question {

  const Question({
    required this.id,
    required this.text,
    required this.type,
    this.options = const [],
    this.correctAnswers = const [],
    this.explanation,
    this.points,
    this.userAnswer,
    this.isAnswered = false,
    this.isCorrect = false,
    this.answeredAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
  final String id;
  final String text;
  final QuestionType type;
  final List<Option> options;
  final List<String> correctAnswers;
  final String? explanation;
  final int? points;
  final String? userAnswer;
  final bool isAnswered;
  final bool isCorrect;
  final DateTime? answeredAt;
  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  Question copyWith({
    String? id,
    String? text,
    QuestionType? type,
    List<Option>? options,
    List<String>? correctAnswers,
    String? explanation,
    int? points,
    String? userAnswer,
    bool? isAnswered,
    bool? isCorrect,
    DateTime? answeredAt,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      options: options ?? this.options,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      explanation: explanation ?? this.explanation,
      points: points ?? this.points,
      userAnswer: userAnswer ?? this.userAnswer,
      isAnswered: isAnswered ?? this.isAnswered,
      isCorrect: isCorrect ?? this.isCorrect,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  /// Get formatted points
  String get formattedPoints {
    if (points == null) return '1分';
    return '$points分';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Question(id: $id, text: $text, type: $type)';
  }
}

/// Option entity
@JsonSerializable()
class Option {

  const Option({
    required this.id,
    required this.text,
    this.isCorrect = false,
    this.explanation,
  });

  factory Option.fromJson(Map<String, dynamic> json) => _$OptionFromJson(json);
  final String id;
  final String text;
  final bool isCorrect;
  final String? explanation;
  Map<String, dynamic> toJson() => _$OptionToJson(this);

  Option copyWith({
    String? id,
    String? text,
    bool? isCorrect,
    String? explanation,
  }) {
    return Option(
      id: id ?? this.id,
      text: text ?? this.text,
      isCorrect: isCorrect ?? this.isCorrect,
      explanation: explanation ?? this.explanation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Option && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Option(id: $id, text: $text, isCorrect: $isCorrect)';
  }
}

/// Question type enum
enum QuestionType {
  singleChoice('单选题'),
  multipleChoice('多选题'),
  trueFalse('判断题'),
  fillInBlank('填空题'),
  essay('简答题'),
  matching('匹配题'),
  ordering('排序题');

  const QuestionType(this.displayName);
  final String displayName;
}
