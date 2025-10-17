// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chapter _$ChapterFromJson(Map<String, dynamic> json) => Chapter(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      courseId: json['courseId'] as String,
      order: (json['order'] as num).toInt(),
      taskIds: (json['taskIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isUnlocked: json['isUnlocked'] as bool? ?? true,
      unlockDate: json['unlockDate'] == null
          ? null
          : DateTime.parse(json['unlockDate'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ChapterToJson(Chapter instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'courseId': instance.courseId,
      'order': instance.order,
      'taskIds': instance.taskIds,
      'progress': instance.progress,
      'isCompleted': instance.isCompleted,
      'isUnlocked': instance.isUnlocked,
      'unlockDate': instance.unlockDate?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
