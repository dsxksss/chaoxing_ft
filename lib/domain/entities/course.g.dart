// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      teacher: json['teacher'] as String?,
      school: json['school'] as String?,
      semester: json['semester'] as String?,
      year: json['year'] as String?,
      term: json['term'] as String?,
      className: json['className'] as String?,
      courseCode: json['courseCode'] as String?,
      courseUrl: json['courseUrl'] as String?,
      coverImage: json['coverImage'] as String?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      totalChapters: (json['totalChapters'] as num?)?.toInt(),
      completedChapters: (json['completedChapters'] as num?)?.toInt(),
      progress: (json['progress'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      lastAccessed: json['lastAccessed'] == null
          ? null
          : DateTime.parse(json['lastAccessed'] as String),
    );

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'teacher': instance.teacher,
      'school': instance.school,
      'semester': instance.semester,
      'year': instance.year,
      'term': instance.term,
      'className': instance.className,
      'courseCode': instance.courseCode,
      'courseUrl': instance.courseUrl,
      'coverImage': instance.coverImage,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'totalChapters': instance.totalChapters,
      'completedChapters': instance.completedChapters,
      'progress': instance.progress,
      'isActive': instance.isActive,
      'lastAccessed': instance.lastAccessed?.toIso8601String(),
    };
