// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$TaskTypeEnumMap, json['type']),
      description: json['description'] as String?,
      courseId: json['courseId'] as String?,
      chapterId: json['chapterId'] as String?,
      url: json['url'] as String?,
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: (json['duration'] as num).toInt()),
      isCompleted: json['isCompleted'] as bool? ?? false,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$TaskTypeEnumMap[instance.type]!,
      'description': instance.description,
      'courseId': instance.courseId,
      'chapterId': instance.chapterId,
      'url': instance.url,
      'duration': instance.duration?.inMicroseconds,
      'isCompleted': instance.isCompleted,
      'progress': instance.progress,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$TaskTypeEnumMap = {
  TaskType.video: 'video',
  TaskType.document: 'document',
  TaskType.quiz: 'quiz',
  TaskType.reading: 'reading',
  TaskType.assignment: 'assignment',
  TaskType.discussion: 'discussion',
};
