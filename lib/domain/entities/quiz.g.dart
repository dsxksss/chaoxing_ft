// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quiz _$QuizFromJson(Map<String, dynamic> json) => Quiz(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      url: json['url'] as String?,
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => Question.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      timeLimit: (json['timeLimit'] as num?)?.toInt(),
      attemptLimit: (json['attemptLimit'] as num?)?.toInt(),
      currentAttempt: (json['currentAttempt'] as num?)?.toInt(),
      score: (json['score'] as num?)?.toDouble(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      isPassed: json['isPassed'] as bool? ?? false,
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$QuizToJson(Quiz instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'url': instance.url,
      'questions': instance.questions,
      'timeLimit': instance.timeLimit,
      'attemptLimit': instance.attemptLimit,
      'currentAttempt': instance.currentAttempt,
      'score': instance.score,
      'isCompleted': instance.isCompleted,
      'isPassed': instance.isPassed,
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
      id: json['id'] as String,
      text: json['text'] as String,
      type: $enumDecode(_$QuestionTypeEnumMap, json['type']),
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => Option.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      correctAnswers: (json['correctAnswers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      explanation: json['explanation'] as String?,
      points: (json['points'] as num?)?.toInt(),
      userAnswer: json['userAnswer'] as String?,
      isAnswered: json['isAnswered'] as bool? ?? false,
      isCorrect: json['isCorrect'] as bool? ?? false,
      answeredAt: json['answeredAt'] == null
          ? null
          : DateTime.parse(json['answeredAt'] as String),
    );

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'type': _$QuestionTypeEnumMap[instance.type]!,
      'options': instance.options,
      'correctAnswers': instance.correctAnswers,
      'explanation': instance.explanation,
      'points': instance.points,
      'userAnswer': instance.userAnswer,
      'isAnswered': instance.isAnswered,
      'isCorrect': instance.isCorrect,
      'answeredAt': instance.answeredAt?.toIso8601String(),
    };

const _$QuestionTypeEnumMap = {
  QuestionType.singleChoice: 'singleChoice',
  QuestionType.multipleChoice: 'multipleChoice',
  QuestionType.trueFalse: 'trueFalse',
  QuestionType.fillInBlank: 'fillInBlank',
  QuestionType.essay: 'essay',
  QuestionType.matching: 'matching',
  QuestionType.ordering: 'ordering',
};

Option _$OptionFromJson(Map<String, dynamic> json) => Option(
      id: json['id'] as String,
      text: json['text'] as String,
      isCorrect: json['isCorrect'] as bool? ?? false,
      explanation: json['explanation'] as String?,
    );

Map<String, dynamic> _$OptionToJson(Option instance) => <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'isCorrect': instance.isCorrect,
      'explanation': instance.explanation,
    };
