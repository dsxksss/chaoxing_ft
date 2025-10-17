// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Video _$VideoFromJson(Map<String, dynamic> json) => Video(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      url: json['url'] as String?,
      thumbnail: json['thumbnail'] as String?,
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: (json['duration'] as num).toInt()),
      currentPosition: json['currentPosition'] == null
          ? null
          : Duration(microseconds: (json['currentPosition'] as num).toInt()),
      progress: (json['progress'] as num?)?.toDouble(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      isPlaying: json['isPlaying'] as bool? ?? false,
      playbackSpeed: (json['playbackSpeed'] as num?)?.toDouble(),
      quality: json['quality'] as String?,
      subtitles: (json['subtitles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      lastWatched: json['lastWatched'] == null
          ? null
          : DateTime.parse(json['lastWatched'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$VideoToJson(Video instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'url': instance.url,
      'thumbnail': instance.thumbnail,
      'duration': instance.duration?.inMicroseconds,
      'currentPosition': instance.currentPosition?.inMicroseconds,
      'progress': instance.progress,
      'isCompleted': instance.isCompleted,
      'isPlaying': instance.isPlaying,
      'playbackSpeed': instance.playbackSpeed,
      'quality': instance.quality,
      'subtitles': instance.subtitles,
      'metadata': instance.metadata,
      'lastWatched': instance.lastWatched?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
