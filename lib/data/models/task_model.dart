import 'package:chaoxing_ft/domain/entities/task.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

/// Task model for data layer
@JsonSerializable()
class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.name,
    required super.type,
    super.description,
    super.courseId,
    super.chapterId,
    super.url,
    super.duration,
    super.isCompleted,
    super.progress,
    super.metadata,
    super.createdAt,
    super.updatedAt,
  });

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      name: task.name,
      type: task.type,
      description: task.description,
      courseId: task.courseId,
      chapterId: task.chapterId,
      url: task.url,
      duration: task.duration,
      isCompleted: task.isCompleted,
      progress: task.progress,
      metadata: task.metadata,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  Task toEntity() {
    return Task(
      id: id,
      name: name,
      type: type,
      description: description,
      courseId: courseId,
      chapterId: chapterId,
      url: url,
      duration: duration,
      isCompleted: isCompleted,
      progress: progress,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  TaskModel copyWith({
    String? id,
    String? name,
    TaskType? type,
    String? description,
    String? courseId,
    String? chapterId,
    String? url,
    Duration? duration,
    bool? isCompleted,
    double? progress,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      courseId: courseId ?? this.courseId,
      chapterId: chapterId ?? this.chapterId,
      url: url ?? this.url,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
