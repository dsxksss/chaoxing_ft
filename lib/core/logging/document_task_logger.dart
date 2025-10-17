import 'package:logger/logger.dart';
import '../../core/errors/error_handler.dart';

/// Document task logging utilities
class DocumentTaskLogger {
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

  /// Log document task start
  static void logDocumentTaskStart(String documentId, String taskId, String courseId) {
    _logger.i('📄 Document task started - documentId: $documentId, taskId: $taskId, courseId: $courseId');
  }

  /// Log document task pause
  static void logDocumentTaskPause(String documentId, String taskId, int page) {
    _logger.i('⏸️ Document task paused - documentId: $documentId, taskId: $taskId, page: $page');
  }

  /// Log document task resume
  static void logDocumentTaskResume(String documentId, String taskId, int page) {
    _logger.i('▶️ Document task resumed - documentId: $documentId, taskId: $taskId, page: $page');
  }

  /// Log document task completion
  static void logDocumentTaskCompletion(String documentId, String taskId, String courseId, Duration totalTime) {
    _logger.i('✅ Document task completed - documentId: $documentId, taskId: $taskId, courseId: $courseId, totalTime: ${totalTime.inSeconds}s');
  }

  /// Log document loading start
  static void logDocumentLoadingStart(String documentId, String url) {
    _logger.i('📥 Document loading started - documentId: $documentId, url: $url');
  }

  /// Log document loading progress
  static void logDocumentLoadingProgress(String documentId, double progress) {
    _logger.d('📊 Document loading progress - documentId: $documentId, progress: ${(progress * 100).toStringAsFixed(1)}%');
  }

  /// Log document loading completion
  static void logDocumentLoadingCompletion(String documentId, int size) {
    _logger.i('📥 Document loading completed - documentId: $documentId, size: $size');
  }

  /// Log document loading error
  static void logDocumentLoadingError(String documentId, String error) {
    _logger.e('❌ Document loading error - documentId: $documentId, error: $error');
    _errorHandler.handleError(error, context: 'DocumentTaskLogger.logDocumentLoadingError');
  }

  /// Log page navigation
  static void logPageNavigation(String documentId, int fromPage, int toPage) {
    _logger.d('📖 Page navigation - documentId: $documentId, fromPage: $fromPage, toPage: $toPage');
  }

  /// Log page bookmark
  static void logPageBookmark(String documentId, int page, bool added) {
    _logger.i('🔖 Page bookmark ${added ? 'added' : 'removed'} - documentId: $documentId, page: $page');
  }

  /// Log page note
  static void logPageNote(String documentId, int page, String note, bool added) {
    _logger.i('📝 Page note ${added ? 'added' : 'removed'} - documentId: $documentId, page: $page, note: $note');
  }

  /// Log document search
  static void logDocumentSearch(String query, int resultsCount) {
    _logger.i('🔍 Document search - query: $query, resultsCount: $resultsCount');
  }

  /// Log document download
  static void logDocumentDownload(String documentId, String path, int size) {
    _logger.i('⬇️ Document downloaded - documentId: $documentId, path: $path, size: $size');
  }

  /// Log document cache
  static void logDocumentCache(String documentId, String action, {int? size}) {
    _logger.d('💾 Document cache $action - documentId: $documentId, size: $size');
  }

  /// Log document format
  static void logDocumentFormat(String documentId, String format) {
    _logger.d('📄 Document format - documentId: $documentId, format: $format');
  }

  /// Log document size
  static void logDocumentSize(String documentId, int size) {
    _logger.d('📏 Document size - documentId: $documentId, size: $size');
  }

  /// Log document metadata
  static void logDocumentMetadata(String documentId, Map<String, dynamic> metadata) {
    _logger.d('📋 Document metadata - documentId: $documentId, metadata: $metadata');
  }

  /// Log document reading time
  static void logDocumentReadingTime(String documentId, Duration readingTime) {
    _logger.d('⏱️ Document reading time - documentId: $documentId, readingTime: ${readingTime.inSeconds}s');
  }

  /// Log document progress update
  static void logDocumentProgressUpdate(String documentId, int page, double progress) {
    _logger.d('📊 Document progress updated - documentId: $documentId, page: $page, progress: $progress');
  }

  /// Log document fullscreen toggle
  static void logDocumentFullscreenToggle(String documentId, bool isFullscreen) {
    _logger.d('🖥️ Document fullscreen toggle - documentId: $documentId, isFullscreen: $isFullscreen');
  }

  /// Log document zoom
  static void logDocumentZoom(String documentId, double zoomLevel) {
    _logger.d('🔍 Document zoom - documentId: $documentId, zoomLevel: $zoomLevel');
  }

  /// Log document scroll
  static void logDocumentScroll(String documentId, double scrollPosition) {
    _logger.d('📜 Document scroll - documentId: $documentId, scrollPosition: $scrollPosition');
  }

  /// Log document annotation
  static void logDocumentAnnotation(String documentId, int page, String annotation, bool added) {
    _logger.i('📝 Document annotation ${added ? 'added' : 'removed'} - documentId: $documentId, page: $page, annotation: $annotation');
  }

  /// Log document highlight
  static void logDocumentHighlight(String documentId, int page, String text, bool added) {
    _logger.i('🖍️ Document highlight ${added ? 'added' : 'removed'} - documentId: $documentId, page: $page, text: $text');
  }

  /// Log document share
  static void logDocumentShare(String documentId, String method) {
    _logger.i('📤 Document shared - documentId: $documentId, method: $method');
  }

  /// Log document print
  static void logDocumentPrint(String documentId, int pages) {
    _logger.i('🖨️ Document printed - documentId: $documentId, pages: $pages');
  }

  /// Log document error
  static void logDocumentError(String documentId, String error, {String? taskId, String? courseId}) {
    _logger.e('❌ Document error - documentId: $documentId, taskId: $taskId, courseId: $courseId, error: $error');
    _errorHandler.handleError(error, context: 'DocumentTaskLogger.logDocumentError');
  }

  /// Log document warning
  static void logDocumentWarning(String documentId, String warning, {String? taskId, String? courseId}) {
    _logger.w('⚠️ Document warning - documentId: $documentId, taskId: $taskId, courseId: $courseId, warning: $warning');
  }

  /// Log document info
  static void logDocumentInfo(String documentId, String message, {Map<String, dynamic>? data}) {
    _logger.i('ℹ️ Document info - documentId: $documentId, message: $message, data: $data');
  }

  /// Log document debug
  static void logDocumentDebug(String documentId, String message, {Map<String, dynamic>? data}) {
    _logger.d('🐛 Document debug - documentId: $documentId, message: $message, data: $data');
  }

  /// Log document analytics
  static void logDocumentAnalytics(String documentId, Map<String, dynamic> analytics) {
    _logger.i('📈 Document analytics - documentId: $documentId, analytics: $analytics');
  }

  /// Log document user interaction
  static void logDocumentUserInteraction(String documentId, String interaction, {Map<String, dynamic>? details}) {
    _logger.d('👆 Document user interaction - documentId: $documentId, interaction: $interaction, details: $details');
  }

  /// Log document performance metric
  static void logDocumentPerformanceMetric(String documentId, String metric, double value, {String? unit}) {
    _logger.d('⚡ Document performance metric - documentId: $documentId, metric: $metric, value: $value, unit: $unit');
  }

  /// Log document task statistics
  static void logDocumentTaskStatistics(String courseId, Map<String, dynamic> statistics) {
    _logger.i('📊 Document task statistics - courseId: $courseId, statistics: $statistics');
  }

  /// Log document task error
  static void logDocumentTaskError(String documentId, String taskId, String error, {String? courseId}) {
    _logger.e('🚨 Document task error - documentId: $documentId, taskId: $taskId, courseId: $courseId, error: $error');
    _errorHandler.handleError(error, context: 'DocumentTaskLogger.logDocumentTaskError');
  }

  /// Log document task warning
  static void logDocumentTaskWarning(String documentId, String warning, {String? taskId, String? courseId}) {
    _logger.w('⚠️ Document task warning - documentId: $documentId, taskId: $taskId, courseId: $courseId, warning: $warning');
  }
}