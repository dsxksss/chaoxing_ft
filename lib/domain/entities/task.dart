import 'package:equatable/equatable.dart';

/// Task type enum
enum TaskType {
  video('视频'),
  document('文档'),
  quiz('测验'),
  reading('阅读'),
  assignment('作业'),
  discussion('讨论');

  const TaskType(this.displayName);
  final String displayName;
}

/// Task entity representing a learning task
class Task extends Equatable {

  const Task({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.courseId,
    this.chapterId,
    this.url,
    this.duration,
    this.isCompleted = false,
    this.progress = 0.0,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });
  final String id;
  final String name;
  final TaskType type;
  final String? description;
  final String? courseId;
  final String? chapterId;
  final String? url;
  final Duration? duration;
  final bool isCompleted;
  final double progress; // 0.0 to 1.0
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        description,
        courseId,
        chapterId,
        url,
        duration,
        isCompleted,
        progress,
        metadata,
        createdAt,
        updatedAt,
      ];

  Task copyWith({
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
    return Task(
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

  /// Get formatted progress
  String get formattedProgress {
    return '${(progress * 100).toInt()}%';
  }

  /// Get formatted duration
  String get formattedDuration {
    if (duration == null) return '未知';
    final minutes = duration!.inMinutes;
    final seconds = duration!.inSeconds.remainder(60);
    return '$minutes分$seconds秒';
  }

  /// Check if task is in progress
  bool get isInProgress {
    return progress > 0.0 && !isCompleted;
  }

  /// Get task status
  String get status {
    if (isCompleted) return '已完成';
    if (isInProgress) return '进行中';
    return '未开始';
  }

  @override
  String toString() {
    return 'Task(id: $id, name: $name, type: $type, progress: $formattedProgress)';
  }
}
