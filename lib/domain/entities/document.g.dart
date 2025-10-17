// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Document _$DocumentFromJson(Map<String, dynamic> json) => Document(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      url: json['url'] as String?,
      content: json['content'] as String?,
      thumbnail: json['thumbnail'] as String?,
      pageCount: (json['pageCount'] as num?)?.toInt(),
      currentPage: (json['currentPage'] as num?)?.toInt(),
      progress: (json['progress'] as num?)?.toDouble(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      isReading: json['isReading'] as bool? ?? false,
      format: json['format'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      lastRead: json['lastRead'] == null
          ? null
          : DateTime.parse(json['lastRead'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DocumentToJson(Document instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'url': instance.url,
      'content': instance.content,
      'thumbnail': instance.thumbnail,
      'pageCount': instance.pageCount,
      'currentPage': instance.currentPage,
      'progress': instance.progress,
      'isCompleted': instance.isCompleted,
      'isReading': instance.isReading,
      'format': instance.format,
      'tags': instance.tags,
      'metadata': instance.metadata,
      'lastRead': instance.lastRead?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
