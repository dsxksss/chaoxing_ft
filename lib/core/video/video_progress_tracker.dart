import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/errors/error_handler.dart';
import '../../core/logging/auth_logger.dart';
import '../../presentation/widgets/app_components.dart';

/// Video progress tracking service
class VideoProgressTracker { // 90% completion threshold
  
  VideoProgressTracker._internal();
  static final VideoProgressTracker _instance = VideoProgressTracker._internal();
  static VideoProgressTracker get instance => _instance;
  
  final ErrorHandler _errorHandler = ErrorHandler.instance;
  
  // Progress tracking data
  final Map<String, Duration> _videoPositions = {};
  final Map<String, double> _videoProgress = {};
  final Map<String, DateTime> _lastUpdateTimes = {};
  final Map<String, List<Duration>> _watchHistory = {};
  
  // Configuration
  static const Duration _saveInterval = Duration(seconds: 30);
  static const double _completionThreshold = 0.9;

  /// Update video progress
  void updateProgress(String videoId, Duration position, Duration duration) {
    try {
      if (videoId.isEmpty) {
        throw _errorHandler.createDataParsingError('Video ID cannot be empty');
      }

      _videoPositions[videoId] = position;
      _videoProgress[videoId] = duration.inMilliseconds > 0 
          ? position.inMilliseconds / duration.inMilliseconds 
          : 0.0;
      _lastUpdateTimes[videoId] = DateTime.now();
      
      // Add to watch history
      _watchHistory[videoId] ??= [];
      _watchHistory[videoId]!.add(position);
      
      AuthLogger.logInfo('Video progress updated - videoId: $videoId, position: ${position.inSeconds}s, progress: ${_videoProgress[videoId]}');
      
      // Check if video is completed
      if (_videoProgress[videoId]! >= _completionThreshold) {
        _onVideoCompleted(videoId);
      }
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoProgressTracker.updateProgress');
    }
  }

  /// Get video progress
  double getProgress(String videoId) {
    return _videoProgress[videoId] ?? 0.0;
  }

  /// Get video position
  Duration getPosition(String videoId) {
    return _videoPositions[videoId] ?? Duration.zero;
  }

  /// Check if video is completed
  bool isVideoCompleted(String videoId) {
    return _videoProgress[videoId] != null && _videoProgress[videoId]! >= _completionThreshold;
  }

  /// Get watch history
  List<Duration> getWatchHistory(String videoId) {
    return _watchHistory[videoId] ?? [];
  }

  /// Clear video progress
  void clearProgress(String videoId) {
    _videoPositions.remove(videoId);
    _videoProgress.remove(videoId);
    _lastUpdateTimes.remove(videoId);
    _watchHistory.remove(videoId);
    
    AuthLogger.logInfo('Video progress cleared - videoId: $videoId');
  }

  /// Clear all progress
  void clearAllProgress() {
    _videoPositions.clear();
    _videoProgress.clear();
    _lastUpdateTimes.clear();
    _watchHistory.clear();
    
    AuthLogger.logInfo('All video progress cleared');
  }

  /// Get progress statistics
  Map<String, dynamic> getProgressStatistics() {
    final totalVideos = _videoProgress.length;
    final completedVideos = _videoProgress.values.where((progress) => progress >= _completionThreshold).length;
    final totalProgress = _videoProgress.values.fold(0.0, (sum, progress) => sum + progress);
    final averageProgress = totalVideos > 0 ? totalProgress / totalVideos : 0.0;
    
    return {
      'totalVideos': totalVideos,
      'completedVideos': completedVideos,
      'averageProgress': averageProgress,
      'completionRate': totalVideos > 0 ? completedVideos / totalVideos : 0.0,
    };
  }

  /// On video completed
  void _onVideoCompleted(String videoId) {
    AuthLogger.logInfo('Video completed - videoId: $videoId, progress: ${_videoProgress[videoId]}');
    
    // TODO: Implement completion logic
    // - Mark task as completed
    // - Update course progress
    // - Send completion notification
    // - Update user statistics
  }

  /// Save progress to server
  Future<void> saveProgressToServer(String videoId) async {
    try {
      if (videoId.isEmpty) {
        throw _errorHandler.createDataParsingError('Video ID cannot be empty');
      }

      final position = _videoPositions[videoId];
      final progress = _videoProgress[videoId];
      
      if (position == null || progress == null) {
        AuthLogger.logWarning('No progress data to save - videoId: $videoId');
        return;
      }

      AuthLogger.logInfo('Saving video progress to server - videoId: $videoId, position: ${position.inSeconds}s, progress: $progress');
      
      // TODO: Implement actual server save logic
      // This is a placeholder implementation
      await Future.delayed(const Duration(milliseconds: 500));
      
      AuthLogger.logInfo('Video progress saved to server successfully - videoId: $videoId');
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoProgressTracker.saveProgressToServer');
    }
  }

  /// Auto-save progress
  Future<void> autoSaveProgress() async {
    try {
      final now = DateTime.now();
      final videosToSave = <String>[];
      
      for (final entry in _lastUpdateTimes.entries) {
        final videoId = entry.key;
        final lastUpdate = entry.value;
        
        if (now.difference(lastUpdate) >= _saveInterval) {
          videosToSave.add(videoId);
        }
      }
      
      for (final videoId in videosToSave) {
        await saveProgressToServer(videoId);
      }
      
      if (videosToSave.isNotEmpty) {
        AuthLogger.logInfo('Auto-saved progress for ${videosToSave.length} videos');
      }
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoProgressTracker.autoSaveProgress');
    }
  }

  /// Start auto-save timer
  void startAutoSave() {
    Timer.periodic(_saveInterval, (timer) {
      autoSaveProgress();
    });
  }

  /// Stop auto-save timer
  void stopAutoSave() {
    // TODO: Implement timer cancellation
  }
}

/// Video completion handler
class VideoCompletionHandler {
  
  VideoCompletionHandler._internal();
  static final VideoCompletionHandler _instance = VideoCompletionHandler._internal();
  static VideoCompletionHandler get instance => _instance;
  
  final ErrorHandler _errorHandler = ErrorHandler.instance;

  /// Handle video completion
  Future<void> handleVideoCompletion(String videoId, String taskId, String courseId) async {
    try {
      AuthLogger.logInfo('Handling video completion - videoId: $videoId, taskId: $taskId, courseId: $courseId');
      
      // Mark task as completed
      await _markTaskAsCompleted(taskId);
      
      // Update course progress
      await _updateCourseProgress(courseId);
      
      // Send completion notification
      await _sendCompletionNotification(videoId, taskId, courseId);
      
      // Update user statistics
      await _updateUserStatistics(courseId);
      
      AuthLogger.logInfo('Video completion handled successfully - videoId: $videoId, taskId: $taskId, courseId: $courseId');
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoCompletionHandler.handleVideoCompletion');
    }
  }

  /// Mark task as completed
  Future<void> _markTaskAsCompleted(String taskId) async {
    try {
      AuthLogger.logInfo('Marking task as completed - taskId: $taskId');
      
      // TODO: Implement actual task completion logic
      // This is a placeholder implementation
      await Future.delayed(const Duration(milliseconds: 300));
      
      AuthLogger.logInfo('Task marked as completed - taskId: $taskId');
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoCompletionHandler._markTaskAsCompleted');
    }
  }

  /// Update course progress
  Future<void> _updateCourseProgress(String courseId) async {
    try {
      AuthLogger.logInfo('Updating course progress - courseId: $courseId');
      
      // TODO: Implement actual course progress update logic
      // This is a placeholder implementation
      await Future.delayed(const Duration(milliseconds: 300));
      
      AuthLogger.logInfo('Course progress updated - courseId: $courseId');
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoCompletionHandler._updateCourseProgress');
    }
  }

  /// Send completion notification
  Future<void> _sendCompletionNotification(String videoId, String taskId, String courseId) async {
    try {
      AuthLogger.logInfo('Sending completion notification - videoId: $videoId, taskId: $taskId, courseId: $courseId');
      
      // TODO: Implement actual notification logic
      // This is a placeholder implementation
      await Future.delayed(const Duration(milliseconds: 300));
      
      AuthLogger.logInfo('Completion notification sent - videoId: $videoId, taskId: $taskId, courseId: $courseId');
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoCompletionHandler._sendCompletionNotification');
    }
  }

  /// Update user statistics
  Future<void> _updateUserStatistics(String courseId) async {
    try {
      AuthLogger.logInfo('Updating user statistics - courseId: $courseId');
      
      // TODO: Implement actual user statistics update logic
      // This is a placeholder implementation
      await Future.delayed(const Duration(milliseconds: 300));
      
      AuthLogger.logInfo('User statistics updated - courseId: $courseId');
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoCompletionHandler._updateUserStatistics');
    }
  }
}

/// Video progress widget
class VideoProgressWidget extends StatefulWidget {

  const VideoProgressWidget({
    super.key,
    required this.videoId,
    required this.duration,
    this.onPositionChanged,
    this.onCompleted,
  });
  final String videoId;
  final Duration duration;
  final ValueChanged<Duration>? onPositionChanged;
  final VoidCallback? onCompleted;

  @override
  State<VideoProgressWidget> createState() => _VideoProgressWidgetState();
}

class _VideoProgressWidgetState extends State<VideoProgressWidget> {
  final VideoProgressTracker _tracker = VideoProgressTracker.instance;
  Duration _currentPosition = Duration.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentPosition = _tracker.getPosition(widget.videoId);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _tracker.getProgress(widget.videoId);
    
    return Column(
      children: [
        // Progress bar
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primaryColor,
            inactiveTrackColor: Colors.grey[300],
            thumbColor: AppTheme.primaryColor,
            overlayColor: AppTheme.primaryColor.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: progress,
            onChanged: _isDragging ? null : _onProgressChanged,
            onChangeStart: (value) {
              setState(() {
                _isDragging = true;
              });
            },
            onChangeEnd: (value) {
              setState(() {
                _isDragging = false;
              });
              _onProgressChanged(value);
            },
          ),
        ),
        
        // Time display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDuration(_currentPosition)),
            Text(_formatDuration(widget.duration)),
          ],
        ),
      ],
    );
  }

  /// On progress changed
  void _onProgressChanged(double value) {
    final position = Duration(
      milliseconds: (value * widget.duration.inMilliseconds).round(),
    );
    
    setState(() {
      _currentPosition = position;
    });
    
    _tracker.updateProgress(widget.videoId, position, widget.duration);
    widget.onPositionChanged?.call(position);
    
    // Check if completed
    if (value >= 0.9) {
      widget.onCompleted?.call();
    }
  }

  /// Format duration
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
}