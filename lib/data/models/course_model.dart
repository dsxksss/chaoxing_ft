import '../../domain/entities/course.dart';
import 'package:json_annotation/json_annotation.dart';

part 'course_model.g.dart';

/// Course model for data layer
@JsonSerializable()
class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.name,
    super.description,
    super.teacher,
    super.school,
    super.semester,
    super.year,
    super.term,
    super.className,
    super.courseCode,
    super.courseUrl,
    super.coverImage,
    super.startDate,
    super.endDate,
    super.totalChapters,
    super.completedChapters,
    super.progress,
    super.isActive,
    super.lastAccessed,
  });

  factory CourseModel.fromEntity(Course course) {
    return CourseModel(
      id: course.id,
      name: course.name,
      description: course.description,
      teacher: course.teacher,
      school: course.school,
      semester: course.semester,
      year: course.year,
      term: course.term,
      className: course.className,
      courseCode: course.courseCode,
      courseUrl: course.courseUrl,
      coverImage: course.coverImage,
      startDate: course.startDate,
      endDate: course.endDate,
      totalChapters: course.totalChapters,
      completedChapters: course.completedChapters,
      progress: course.progress,
      isActive: course.isActive,
      lastAccessed: course.lastAccessed,
    );
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) => _$CourseModelFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$CourseModelToJson(this);

  Course toEntity() {
    return Course(
      id: id,
      name: name,
      description: description,
      teacher: teacher,
      school: school,
      semester: semester,
      year: year,
      term: term,
      className: className,
      courseCode: courseCode,
      courseUrl: courseUrl,
      coverImage: coverImage,
      startDate: startDate,
      endDate: endDate,
      totalChapters: totalChapters,
      completedChapters: completedChapters,
      progress: progress,
      isActive: isActive,
      lastAccessed: lastAccessed,
    );
  }

  @override
  CourseModel copyWith({
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
    return CourseModel(
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
}
