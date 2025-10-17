import 'package:json_annotation/json_annotation.dart';

part 'course.g.dart';

/// Course entity representing a learning course
@JsonSerializable()
class Course {

  const Course({
    required this.id,
    required this.name,
    this.description,
    this.teacher,
    this.school,
    this.semester,
    this.year,
    this.term,
    this.className,
    this.courseCode,
    this.courseUrl,
    this.coverImage,
    this.startDate,
    this.endDate,
    this.totalChapters,
    this.completedChapters,
    this.progress,
    this.isActive = true,
    this.lastAccessed,
  });

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
  final String id;
  final String name;
  final String? description;
  final String? teacher;
  final String? school;
  final String? semester;
  final String? year;
  final String? term;
  final String? className;
  final String? courseCode;
  final String? courseUrl;
  final String? coverImage;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? totalChapters;
  final int? completedChapters;
  final double? progress;
  final bool isActive;
  final DateTime? lastAccessed;
  Map<String, dynamic> toJson() => _$CourseToJson(this);

  Course copyWith({
    String? id,
    String? name,
    String? description,
    String? teacher,
    String? school,
    String? semester,
    String? year,
    String? term,
    String? className,
    String? courseCode,
    String? courseUrl,
    String? coverImage,
    DateTime? startDate,
    DateTime? endDate,
    int? totalChapters,
    int? completedChapters,
    double? progress,
    bool? isActive,
    DateTime? lastAccessed,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      teacher: teacher ?? this.teacher,
      school: school ?? this.school,
      semester: semester ?? this.semester,
      year: year ?? this.year,
      term: term ?? this.term,
      className: className ?? this.className,
      courseCode: courseCode ?? this.courseCode,
      courseUrl: courseUrl ?? this.courseUrl,
      coverImage: coverImage ?? this.coverImage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalChapters: totalChapters ?? this.totalChapters,
      completedChapters: completedChapters ?? this.completedChapters,
      progress: progress ?? this.progress,
      isActive: isActive ?? this.isActive,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }

  /// Check if course is completed
  bool get isCompleted => progress != null && progress! >= 1.0;

  /// Check if course is in progress
  bool get isInProgress => progress != null && progress! > 0.0 && progress! < 1.0;

  /// Check if course is not started
  bool get isNotStarted => progress == null || progress! == 0.0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Course && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Course(id: $id, name: $name, progress: $progress)';
  }
}
