import '../entities/video.dart';
import '../repositories/video_repository.dart';
import '../../core/errors/error_handler.dart';

/// Video use case
class VideoUseCase {

  VideoUseCase(this._videoRepository, this._errorHandler);
  final VideoRepository _videoRepository;
  final ErrorHandler _errorHandler;

  /// Get video by ID
  Future<Video?> getVideoById(String videoId) async {
    try {
      if (videoId.isEmpty) {
        throw _errorHandler.createDataParsingError('Video ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching video: $videoId');
      final video = await _videoRepository.getVideoById(videoId);
      
      if (video != null) {
        _errorHandler.logInfo('Video found: ${video.name}');
      } else {
        _errorHandler.logWarning('Video not found: $videoId');
      }
      
      return video;
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoUseCase.getVideoById');
      return null;
    }
  }

  /// Get videos by course ID
  Future<List<Video>> getVideosByCourseId(String courseId) async {
    try {
      if (courseId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching videos for course: $courseId');
      final videos = await _videoRepository.getVideosByCourseId(courseId);
      _errorHandler.logInfo('Retrieved ${videos.length} videos');
      return videos;
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoUseCase.getVideosByCourseId');
      return [];
    }
  }

  /// Get videos by chapter ID
  Future<List<Video>> getVideosByChapterId(String chapterId) async {
    try {
      if (chapterId.isEmpty) {
        throw _errorHandler.createDataParsingError('Chapter ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching videos for chapter: $chapterId');
      final videos = await _videoRepository.getVideosByChapterId(chapterId);
      _errorHandler.logInfo('Retrieved ${videos.length} videos');
      return videos;
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoUseCase.getVideosByChapterId');
      return [];
    }
  }

  /// Update video progress
  Future<void> updateVideoProgress(String videoId, Duration currentPosition, double progress) async {
    try {
      if (videoId.isEmpty) {
        throw _errorHandler.createDataParsingError('Video ID cannot be empty');
      }

      if (progress < 0.0 || progress > 1.0) {
        throw _errorHandler.createDataParsingError('Progress must be between 0.0 and 1.0');
      }

      _errorHandler.logInfo('Updating progress for video $videoId: $progress');
      await _videoRepository.updateVideoProgress(videoId, currentPosition, progress);
      _errorHandler.logInfo('Video progress updated successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoUseCase.updateVideoProgress');
      rethrow;
    }
  }

  /// Mark video as completed
  Future<void> markVideoAsCompleted(String videoId) async {
    try {
      if (videoId.isEmpty) {
        throw _errorHandler.createDataParsingError('Video ID cannot be empty');
      }

      _errorHandler.logInfo('Marking video as completed: $videoId');
      await _videoRepository.markVideoAsCompleted(videoId);
      _errorHandler.logInfo('Video marked as completed');
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoUseCase.markVideoAsCompleted');
      rethrow;
    }
  }

  /// Update video playback speed
  Future<void> updateVideoPlaybackSpeed(String videoId, double speed) async {
    try {
      if (videoId.isEmpty) {
        throw _errorHandler.createDataParsingError('Video ID cannot be empty');
      }

      if (speed <= 0.0 || speed > 3.0) {
        throw _errorHandler.createDataParsingError('Playback speed must be between 0.1 and 3.0');
      }

      _errorHandler.logInfo('Updating playback speed for video $videoId: $speed');
      await _videoRepository.updateVideoPlaybackSpeed(videoId, speed);
      _errorHandler.logInfo('Video playback speed updated successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoUseCase.updateVideoPlaybackSpeed');
      rethrow;
    }
  }

  /// Update video quality
  Future<void> updateVideoQuality(String videoId, String quality) async {
    try {
      if (videoId.isEmpty) {
        throw _errorHandler.createDataParsingError('Video ID cannot be empty');
      }

      if (quality.isEmpty) {
        throw _errorHandler.createDataParsingError('Quality cannot be empty');
      }

      _errorHandler.logInfo('Updating quality for video $videoId: $quality');
      await _videoRepository.updateVideoQuality(videoId, quality);
      _errorHandler.logInfo('Video quality updated successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoUseCase.updateVideoQuality');
      rethrow;
    }
  }

  /// Get video subtitles
  Future<List<String>> getVideoSubtitles(String videoId) async {
    try {
      if (videoId.isEmpty) {
        throw _errorHandler.createDataParsingError('Video ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching subtitles for video: $videoId');
      final subtitles = await _videoRepository.getVideoSubtitles(videoId);
      _errorHandler.logInfo('Retrieved ${subtitles.length} subtitles');
      return subtitles;
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoUseCase.getVideoSubtitles');
      return [];
    }
  }

  /// Save video progress to server
  Future<void> saveVideoProgressToServer(String videoId, Duration currentPosition, double progress) async {
    try {
      if (videoId.isEmpty) {
        throw _errorHandler.createDataParsingError('Video ID cannot be empty');
      }

      if (progress < 0.0 || progress > 1.0) {
        throw _errorHandler.createDataParsingError('Progress must be between 0.0 and 1.0');
      }

      _errorHandler.logInfo('Saving video progress to server: $videoId');
      await _videoRepository.saveVideoProgressToServer(videoId, currentPosition, progress);
      _errorHandler.logInfo('Video progress saved to server successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoUseCase.saveVideoProgressToServer');
      rethrow;
    }
  }

  /// Get video metadata
  Future<Map<String, dynamic>> getVideoMetadata(String videoId) async {
    try {
      if (videoId.isEmpty) {
        throw _errorHandler.createDataParsingError('Video ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching metadata for video: $videoId');
      final metadata = await _videoRepository.getVideoMetadata(videoId);
      _errorHandler.logInfo('Video metadata retrieved');
      return metadata;
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoUseCase.getVideoMetadata');
      return {};
    }
  }

  /// Update video metadata
  Future<void> updateVideoMetadata(String videoId, Map<String, dynamic> metadata) async {
    try {
      if (videoId.isEmpty) {
        throw _errorHandler.createDataParsingError('Video ID cannot be empty');
      }

      _errorHandler.logInfo('Updating metadata for video: $videoId');
      await _videoRepository.updateVideoMetadata(videoId, metadata);
      _errorHandler.logInfo('Video metadata updated successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoUseCase.updateVideoMetadata');
      rethrow;
    }
  }

  /// Get video watch history
  Future<List<Map<String, dynamic>>> getVideoWatchHistory(String videoId) async {
    try {
      if (videoId.isEmpty) {
        throw _errorHandler.createDataParsingError('Video ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching watch history for video: $videoId');
      final history = await _videoRepository.getVideoWatchHistory(videoId);
      _errorHandler.logInfo('Retrieved ${history.length} watch records');
      return history;
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoUseCase.getVideoWatchHistory');
      return [];
    }
  }

  /// Add video watch record
  Future<void> addVideoWatchRecord(String videoId, Duration position, Duration duration) async {
    try {
      if (videoId.isEmpty) {
        throw _errorHandler.createDataParsingError('Video ID cannot be empty');
      }

      _errorHandler.logInfo('Adding watch record for video: $videoId');
      await _videoRepository.addVideoWatchRecord(videoId, position, duration);
      _errorHandler.logInfo('Watch record added successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoUseCase.addVideoWatchRecord');
      rethrow;
    }
  }

  /// Get video statistics
  Future<Map<String, dynamic>> getVideoStatistics(String videoId) async {
    try {
      if (videoId.isEmpty) {
        throw _errorHandler.createDataParsingError('Video ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching statistics for video: $videoId');
      final statistics = await _videoRepository.getVideoStatistics(videoId);
      _errorHandler.logInfo('Video statistics retrieved');
      return statistics;
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoUseCase.getVideoStatistics');
      return {};
    }
  }

  /// Refresh video data
  Future<void> refreshVideoData(String videoId) async {
    try {
      if (videoId.isEmpty) {
        throw _errorHandler.createDataParsingError('Video ID cannot be empty');
      }

      _errorHandler.logInfo('Refreshing data for video: $videoId');
      await _videoRepository.refreshVideoData(videoId);
      _errorHandler.logInfo('Video data refreshed successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoUseCase.refreshVideoData');
      rethrow;
    }
  }

  /// Clear video cache
  Future<void> clearVideoCache(String videoId) async {
    try {
      if (videoId.isEmpty) {
        throw _errorHandler.createDataParsingError('Video ID cannot be empty');
      }

      _errorHandler.logInfo('Clearing cache for video: $videoId');
      await _videoRepository.clearVideoCache(videoId);
      _errorHandler.logInfo('Video cache cleared');
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoUseCase.clearVideoCache');
      rethrow;
    }
  }
}
