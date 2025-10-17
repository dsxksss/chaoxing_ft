import '../entities/video.dart';

/// Video repository interface
abstract class VideoRepository {
  /// Get video by ID
  Future<Video?> getVideoById(String videoId);

  /// Get videos by course ID
  Future<List<Video>> getVideosByCourseId(String courseId);

  /// Get videos by chapter ID
  Future<List<Video>> getVideosByChapterId(String chapterId);

  /// Update video progress
  Future<void> updateVideoProgress(String videoId, Duration currentPosition, double progress);

  /// Mark video as completed
  Future<void> markVideoAsCompleted(String videoId);

  /// Update video playback speed
  Future<void> updateVideoPlaybackSpeed(String videoId, double speed);

  /// Update video quality
  Future<void> updateVideoQuality(String videoId, String quality);

  /// Get video subtitles
  Future<List<String>> getVideoSubtitles(String videoId);

  /// Save video progress to server
  Future<void> saveVideoProgressToServer(String videoId, Duration currentPosition, double progress);

  /// Get video metadata
  Future<Map<String, dynamic>> getVideoMetadata(String videoId);

  /// Update video metadata
  Future<void> updateVideoMetadata(String videoId, Map<String, dynamic> metadata);

  /// Get video watch history
  Future<List<Map<String, dynamic>>> getVideoWatchHistory(String videoId);

  /// Add video watch record
  Future<void> addVideoWatchRecord(String videoId, Duration position, Duration duration);

  /// Get video statistics
  Future<Map<String, dynamic>> getVideoStatistics(String videoId);

  /// Refresh video data
  Future<void> refreshVideoData(String videoId);

  /// Clear video cache
  Future<void> clearVideoCache(String videoId);
}
