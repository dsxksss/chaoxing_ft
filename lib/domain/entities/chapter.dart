import 'package:json_annotation/json_annotation.dart';

part 'chapter.g.dart';

/// Chapter entity representing a course chapter
@JsonSerializable()
class Chapter {

  const Chapter({
    required this.id,
    required this.name,
    this.description,
    required this.courseId,
    required this.order,
    this.taskIds = const [],
    this.progress = 0.0,
    this.isCompleted = false,
    this.isUnlocked = true,
    this.unlockDate,
    this.completedAt,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) => _$ChapterFromJson(json);
  final String id;
  final String name;
  final String? description;
  final String courseId;
  final int order;
  final List<String> taskIds;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final bool isUnlocked;
  final DateTime? unlockDate;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  Map<String, dynamic> toJson() => _$ChapterToJson(this);


  Chapter copyWith({
    String? id,
    String? name,
    String? description,
    String? courseId,
    int? order,
    List<String>? taskIds,
    double? progress,
    bool? isCompleted,
    bool? isUnlocked,
    DateTime? unlockDate,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Chapter(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      courseId: courseId ?? this.courseId,
      order: order ?? this.order,
      taskIds: taskIds ?? this.taskIds,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockDate: unlockDate ?? this.unlockDate,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get formatted progress
  String get formattedProgress {
    return '${(progress * 100).toInt()}%';
  }

  /// Get task count
  int get taskCount => taskIds.length;

  /// Get completed task count (placeholder - would need actual task data)
  int get completedTaskCount {
    // This would typically be calculated from actual task completion data
    return (progress * taskCount).round();
  }

  /// Get remaining task count
  int get remainingTaskCount {
    return taskCount - completedTaskCount;
  }

  /// Check if chapter is in progress
  bool get isInProgress {
    return progress > 0.0 && !isCompleted;
  }

  /// Check if chapter can be unlocked
  bool get canUnlock {
    return !isUnlocked && (unlockDate == null || DateTime.now().isAfter(unlockDate!));
  }

  /// Get chapter status
  String get status {
    if (isCompleted) return '已完成';
    if (isInProgress) return '进行中';
    if (!isUnlocked) return '未解锁';
    return '未开始';
  }

  /// Get unlock status
  String get unlockStatus {
    if (isUnlocked) return '已解锁';
    if (unlockDate == null) return '未解锁';
    final now = DateTime.now();
    if (now.isBefore(unlockDate!)) {
      final days = unlockDate!.difference(now).inDays;
      return '$days天后解锁';
    }
    return '可解锁';
  }

  /// Get completion time
  String get completionTime {
    if (completedAt == null) return '未完成';
    final now = DateTime.now();
    final duration = now.difference(completedAt!);
    if (duration.inDays > 0) {
      return '${duration.inDays}天前完成';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}小时前完成';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}分钟前完成';
    } else {
      return '刚刚完成';
    }
  }

  /// Check if chapter is overdue
  bool get isOverdue {
    if (isCompleted) return false;
    if (unlockDate == null) return false;
    return DateTime.now().isAfter(unlockDate!);
  }

  /// Get overdue days
  int get overdueDays {
    if (!isOverdue) return 0;
    return DateTime.now().difference(unlockDate!).inDays;
  }

  /// Get formatted overdue status
  String get overdueStatus {
    if (!isOverdue) return '';
    final days = overdueDays;
    if (days == 1) return '逾期1天';
    return '逾期$days天';
  }

  @override
  String toString() {
    return 'Chapter(id: $id, name: $name, progress: $formattedProgress, status: $status)';
  }
}
