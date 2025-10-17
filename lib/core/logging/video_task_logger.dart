import 'package:logger/logger.dart';
import '../../core/errors/error_handler.dart';

/// Video task logging utilities
class VideoTaskLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static final ErrorHandler _errorHandler = ErrorHandler.instance;

  /// Log video task start
  static void logVideoTaskStart(String videoId, String taskId, String courseId) {
    _logger.i('🎬 Video task started - videoId: $videoId, taskId: $taskId, courseId: $courseId');
  }

  /// Log video task pause
  static void logVideoTaskPause(String videoId, String taskId, Duration position) {
    _logger.i('⏸️ Video task paused - videoId: $videoId, taskId: $taskId, position: ${position.inSeconds}s');
  }

  /// Log video task resume
  static void logVideoTaskResume(String videoId, String taskId, Duration position) {
    _logger.i('▶️ Video task resumed - videoId: $videoId, taskId: $taskId, position: ${position.inSeconds}s');
  }

  /// Log video task completion
  static void logVideoTaskCompletion(String videoId, String taskId, String courseId, Duration totalTime) {
    _logger.i('✅ Video task completed - videoId: $videoId, taskId: $taskId, courseId: $courseId, totalTime: ${totalTime.inSeconds}s');
  }

  /// Log video progress update
  static void logVideoProgressUpdate(String videoId, Duration position, Duration duration, double progress) {
    _logger.d('📊 Video progress updated - videoId: $videoId, position: ${position.inSeconds}s, duration: ${duration.inSeconds}s, progress: $progress');
  }

  /// Log video speed change
  static void logVideoSpeedChange(String videoId, double oldSpeed, double newSpeed) {
    _logger.i('⚡ Video speed changed - videoId: $videoId, oldSpeed: $oldSpeed, newSpeed: $newSpeed');
  }

  /// Log video quality change
  static void logVideoQualityChange(String videoId, String oldQuality, String newQuality) {
    _logger.i('📺 Video quality changed - videoId: $videoId, oldQuality: $oldQuality, newQuality: $newQuality');
  }

  /// Log video error
  static void logVideoError(String videoId, String error, {String? taskId, String? courseId}) {
    _logger.e('❌ Video error - videoId: $videoId, taskId: $taskId, courseId: $courseId, error: $error');
    _errorHandler.handleError(error, context: 'VideoTaskLogger.logVideoError');
  }

  /// Log video buffering
  static void logVideoBuffering(String videoId, bool isBuffering) {
    _logger.d('🔄 Video buffering - videoId: $videoId, isBuffering: $isBuffering');
  }

  /// Log video seek
  static void logVideoSeek(String videoId, Duration fromPosition, Duration toPosition) {
    _logger.d('⏭️ Video seek - videoId: $videoId, fromPosition: ${fromPosition.inSeconds}s, toPosition: ${toPosition.inSeconds}s');
  }

  /// Log video fullscreen toggle
  static void logVideoFullscreenToggle(String videoId, bool isFullscreen) {
    _logger.d('🖥️ Video fullscreen toggle - videoId: $videoId, isFullscreen: $isFullscreen');
  }

  /// Log video controls toggle
  static void logVideoControlsToggle(String videoId, bool showControls) {
    _logger.d('🎮 Video controls toggle - videoId: $videoId, showControls: $showControls');
  }

  /// Log video subtitles toggle
  static void logVideoSubtitlesToggle(String videoId, bool showSubtitles) {
    _logger.d('📝 Video subtitles toggle - videoId: $videoId, showSubtitles: $showSubtitles');
  }

  /// Log video volume change
  static void logVideoVolumeChange(String videoId, double oldVolume, double newVolume) {
    _logger.d('🔊 Video volume changed - videoId: $videoId, oldVolume: $oldVolume, newVolume: $newVolume');
  }

  /// Log video network status
  static void logVideoNetworkStatus(String videoId, String status, {String? error}) {
    _logger.i('🌐 Video network status - videoId: $videoId, status: $status, error: $error');
  }

  /// Log video download progress
  static void logVideoDownloadProgress(String videoId, double progress, {String? status}) {
    _logger.d('⬇️ Video download progress - videoId: $videoId, progress: $progress, status: $status');
  }

  /// Log video cache status
  static void logVideoCacheStatus(String videoId, String status, {int? cacheSize}) {
    _logger.d('💾 Video cache status - videoId: $videoId, status: $status, cacheSize: $cacheSize');
  }

  /// Log video analytics
  static void logVideoAnalytics(String videoId, Map<String, dynamic> analytics) {
    _logger.i('📈 Video analytics - videoId: $videoId, analytics: $analytics');
  }

  /// Log video user interaction
  static void logVideoUserInteraction(String videoId, String interaction, {Map<String, dynamic>? details}) {
    _logger.d('👆 Video user interaction - videoId: $videoId, interaction: $interaction, details: $details');
  }

  /// Log video performance metric
  static void logVideoPerformanceMetric(String videoId, String metric, double value, {String? unit}) {
    _logger.d('⚡ Video performance metric - videoId: $videoId, metric: $metric, value: $value, unit: $unit');
  }

  /// Log video task statistics
  static void logVideoTaskStatistics(String courseId, Map<String, dynamic> statistics) {
    _logger.i('📊 Video task statistics - courseId: $courseId, statistics: $statistics');
  }

  /// Log video task error
  static void logVideoTaskError(String videoId, String taskId, String error, {String? courseId}) {
    _logger.e('🚨 Video task error - videoId: $videoId, taskId: $taskId, courseId: $courseId, error: $error');
    _errorHandler.handleError(error, context: 'VideoTaskLogger.logVideoTaskError');
  }

  /// Log video task warning
  static void logVideoTaskWarning(String videoId, String warning, {String? taskId, String? courseId}) {
    _logger.w('⚠️ Video task warning - videoId: $videoId, taskId: $taskId, courseId: $courseId, warning: $warning');
  }

  /// Log video task info
  static void logVideoTaskInfo(String videoId, String message, {Map<String, dynamic>? data}) {
    _logger.i('ℹ️ Video task info - videoId: $videoId, message: $message, data: $data');
  }

  /// Log video task debug
  static void logVideoTaskDebug(String videoId, String message, {Map<String, dynamic>? data}) {
    _logger.d('🐛 Video task debug - videoId: $videoId, message: $message, data: $data');
  }
}