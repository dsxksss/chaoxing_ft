import 'package:json_annotation/json_annotation.dart';

part 'video.g.dart';

/// Video entity representing a video learning task
@JsonSerializable()
class Video {

  const Video({
    required this.id,
    required this.name,
    this.description,
    this.url,
    this.thumbnail,
    this.duration,
    this.currentPosition,
    this.progress,
    this.isCompleted = false,
    this.isPlaying = false,
    this.playbackSpeed,
    this.quality,
    this.subtitles,
    this.metadata,
    this.lastWatched,
    this.createdAt,
    this.updatedAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
  final String id;
  final String name;
  final String? description;
  final String? url;
  final String? thumbnail;
  final Duration? duration;
  final Duration? currentPosition;
  final double? progress;
  final bool isCompleted;
  final bool isPlaying;
  final double? playbackSpeed;
  final String? quality;
  final List<String>? subtitles;
  final Map<String, String>? metadata;
  final DateTime? lastWatched;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  Map<String, dynamic> toJson() => _$VideoToJson(this);

  Video copyWith({
    String? id,
    String? name,
    String? description,
    String? url,
    String? thumbnail,
    Duration? duration,
    Duration? currentPosition,
    double? progress,
    bool? isCompleted,
    bool? isPlaying,
    double? playbackSpeed,
    String? quality,
    List<String>? subtitles,
    Map<String, String>? metadata,
    DateTime? lastWatched,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Video(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      url: url ?? this.url,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      currentPosition: currentPosition ?? this.currentPosition,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      isPlaying: isPlaying ?? this.isPlaying,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      quality: quality ?? this.quality,
      subtitles: subtitles ?? this.subtitles,
      metadata: metadata ?? this.metadata,
      lastWatched: lastWatched ?? this.lastWatched,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if video is fully watched
  bool get isFullyWatched => progress != null && progress! >= 1.0;

  /// Check if video is partially watched
  bool get isPartiallyWatched => progress != null && progress! > 0.0 && progress! < 1.0;

  /// Check if video is not started
  bool get isNotStarted => progress == null || progress! == 0.0;

  /// Get remaining duration
  Duration? get remainingDuration {
    if (duration == null || currentPosition == null) return null;
    return duration! - currentPosition!;
  }

  /// Get progress percentage
  int get progressPercentage {
    if (progress == null) return 0;
    return (progress! * 100).round();
  }

  /// Get formatted duration
  String get formattedDuration {
    if (duration == null) return '未知时长';
    return _formatDuration(duration!);
  }

  /// Get formatted current position
  String get formattedCurrentPosition {
    if (currentPosition == null) return '00:00';
    return _formatDuration(currentPosition!);
  }

  /// Get formatted remaining duration
  String get formattedRemainingDuration {
    if (remainingDuration == null) return '未知';
    return _formatDuration(remainingDuration!);
  }

  /// Format duration to HH:MM:SS
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Video && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Video(id: $id, name: $name, progress: $progress)';
  }
}
