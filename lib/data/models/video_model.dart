import '../../domain/entities/video.dart';

/// Video model for data layer
class VideoModel {

  VideoModel({
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

  /// Create VideoModel from Video entity
  factory VideoModel.fromEntity(Video video) {
    return VideoModel(
      id: video.id,
      name: video.name,
      description: video.description,
      url: video.url,
      thumbnail: video.thumbnail,
      duration: video.duration,
      currentPosition: video.currentPosition,
      progress: video.progress,
      isCompleted: video.isCompleted,
      isPlaying: video.isPlaying,
      playbackSpeed: video.playbackSpeed,
      quality: video.quality,
      subtitles: video.subtitles,
      metadata: video.metadata,
      lastWatched: video.lastWatched,
      createdAt: video.createdAt,
      updatedAt: video.updatedAt,
    );
  }

  /// Create VideoModel from JSON
  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      url: json['url'],
      thumbnail: json['thumbnail'],
      duration: json['duration'] != null ? Duration(milliseconds: json['duration']) : null,
      currentPosition: json['currentPosition'] != null ? Duration(milliseconds: json['currentPosition']) : null,
      progress: json['progress']?.toDouble(),
      isCompleted: json['isCompleted'] ?? false,
      isPlaying: json['isPlaying'] ?? false,
      playbackSpeed: json['playbackSpeed']?.toDouble(),
      quality: json['quality'],
      subtitles: json['subtitles'] != null ? List<String>.from(json['subtitles']) : null,
      metadata: json['metadata'] != null ? Map<String, String>.from(json['metadata']) : null,
      lastWatched: json['lastWatched'] != null ? DateTime.tryParse(json['lastWatched']) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }
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

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'url': url,
      'thumbnail': thumbnail,
      'duration': duration?.inMilliseconds,
      'currentPosition': currentPosition?.inMilliseconds,
      'progress': progress,
      'isCompleted': isCompleted,
      'isPlaying': isPlaying,
      'playbackSpeed': playbackSpeed,
      'quality': quality,
      'subtitles': subtitles,
      'metadata': metadata,
      'lastWatched': lastWatched?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to Video entity
  Video toEntity() {
    return Video(
      id: id,
      name: name,
      description: description,
      url: url,
      thumbnail: thumbnail,
      duration: duration,
      currentPosition: currentPosition,
      progress: progress,
      isCompleted: isCompleted,
      isPlaying: isPlaying,
      playbackSpeed: playbackSpeed,
      quality: quality,
      subtitles: subtitles,
      metadata: metadata,
      lastWatched: lastWatched,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Copy with new values
  VideoModel copyWith({
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
    return VideoModel(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'VideoModel(id: $id, name: $name, progress: $progress)';
  }
}
