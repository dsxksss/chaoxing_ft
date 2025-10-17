import 'package:flutter/material.dart';
import '../../core/errors/error_handler.dart';
import '../../core/logging/auth_logger.dart';
import '../../presentation/widgets/app_components.dart';

/// Document loading and completion handler
class DocumentLoadingHandler {
  
  DocumentLoadingHandler._internal();
  static final DocumentLoadingHandler _instance = DocumentLoadingHandler._internal();
  static DocumentLoadingHandler get instance => _instance;
  
  final ErrorHandler _errorHandler = ErrorHandler.instance;
  
  // Loading state
  final Map<String, bool> _loadingStates = {};
  final Map<String, String?> _loadingErrors = {};
  final Map<String, double> _loadingProgress = {};
  
  // Completion tracking
  final Map<String, bool> _completionStates = {};
  final Map<String, DateTime> _completionTimes = {};
  final Map<String, Duration> _readingTimes = {};

  /// Start loading document
  Future<void> startLoadingDocument(String documentId) async {
    try {
      _loadingStates[documentId] = true;
      _loadingErrors[documentId] = null;
      _loadingProgress[documentId] = 0.0;
      
      AuthLogger.logInfo('Document loading started - documentId: $documentId');
      
      // TODO: Implement actual document loading logic
      // This is a placeholder implementation
      await _simulateDocumentLoading(documentId);
      
      _loadingStates[documentId] = false;
      _loadingProgress[documentId] = 1.0;
      
      AuthLogger.logInfo('Document loading completed - documentId: $documentId');
    } catch (e) {
      _loadingStates[documentId] = false;
      _loadingErrors[documentId] = e.toString();
      
      AuthLogger.logError('Document loading failed - documentId: $documentId, error: ${e.toString()}');
      
      _errorHandler.handleError(e, context: 'DocumentLoadingHandler.startLoadingDocument');
    }
  }

  /// Check if document is loading
  bool isDocumentLoading(String documentId) {
    return _loadingStates[documentId] ?? false;
  }

  /// Get loading error
  String? getLoadingError(String documentId) {
    return _loadingErrors[documentId];
  }

  /// Get loading progress
  double getLoadingProgress(String documentId) {
    return _loadingProgress[documentId] ?? 0.0;
  }

  /// Simulate document loading
  Future<void> _simulateDocumentLoading(String documentId) async {
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      _loadingProgress[documentId] = i / 100.0;
    }
  }

  /// Mark document as completed
  Future<void> markDocumentAsCompleted(String documentId, String taskId, String courseId) async {
    try {
      _completionStates[documentId] = true;
      _completionTimes[documentId] = DateTime.now();
      
      AuthLogger.logInfo('Document marked as completed - documentId: $documentId, taskId: $taskId, courseId: $courseId');
      
      // TODO: Implement actual completion logic
      // - Update task progress
      // - Update course progress
      // - Send completion notification
      // - Update user statistics
      
      AuthLogger.logInfo('Document completion handled successfully - documentId: $documentId, taskId: $taskId, courseId: $courseId');
    } catch (e) {
      AuthLogger.logError('Document completion failed - documentId: $documentId, taskId: $taskId, courseId: $courseId, error: ${e.toString()}');
      
      _errorHandler.handleError(e, context: 'DocumentLoadingHandler.markDocumentAsCompleted');
    }
  }

  /// Check if document is completed
  bool isDocumentCompleted(String documentId) {
    return _completionStates[documentId] ?? false;
  }

  /// Get completion time
  DateTime? getCompletionTime(String documentId) {
    return _completionTimes[documentId];
  }

  /// Update reading time
  void updateReadingTime(String documentId, Duration readingTime) {
    _readingTimes[documentId] = readingTime;
    
    AuthLogger.logInfo('Reading time updated - documentId: $documentId, readingTime: ${readingTime.inSeconds}s');
  }

  /// Get reading time
  Duration getReadingTime(String documentId) {
    return _readingTimes[documentId] ?? Duration.zero;
  }

  /// Clear document data
  void clearDocumentData(String documentId) {
    _loadingStates.remove(documentId);
    _loadingErrors.remove(documentId);
    _loadingProgress.remove(documentId);
    _completionStates.remove(documentId);
    _completionTimes.remove(documentId);
    _readingTimes.remove(documentId);
    
    AuthLogger.logInfo('Document data cleared - documentId: $documentId');
  }

  /// Clear all data
  void clearAllData() {
    _loadingStates.clear();
    _loadingErrors.clear();
    _loadingProgress.clear();
    _completionStates.clear();
    _completionTimes.clear();
    _readingTimes.clear();
    
    AuthLogger.logInfo('All document data cleared');
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    final totalDocuments = _loadingStates.length;
    final completedDocuments = _completionStates.values.where((completed) => completed).length;
    final totalReadingTime = _readingTimes.values.fold(Duration.zero, (sum, time) => sum + time);
    
    return {
      'totalDocuments': totalDocuments,
      'completedDocuments': completedDocuments,
      'completionRate': totalDocuments > 0 ? completedDocuments / totalDocuments : 0.0,
      'totalReadingTime': totalReadingTime.inSeconds,
      'averageReadingTime': completedDocuments > 0 ? totalReadingTime.inSeconds / completedDocuments : 0,
    };
  }
}

/// Document loading widget
class DocumentLoadingWidget extends StatefulWidget {

  const DocumentLoadingWidget({
    super.key,
    required this.documentId,
    this.onLoadingComplete,
    this.onLoadingError,
  });
  final String documentId;
  final VoidCallback? onLoadingComplete;
  final VoidCallback? onLoadingError;

  @override
  State<DocumentLoadingWidget> createState() => _DocumentLoadingWidgetState();
}

class _DocumentLoadingWidgetState extends State<DocumentLoadingWidget> {
  final DocumentLoadingHandler _handler = DocumentLoadingHandler.instance;
  bool _isLoading = false;
  double _progress = 0.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  /// Start loading
  Future<void> _startLoading() async {
    setState(() {
      _isLoading = true;
      _progress = 0.0;
      _error = null;
    });

    try {
      await _handler.startLoadingDocument(widget.documentId);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _progress = 1.0;
        });
        
        widget.onLoadingComplete?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
        
        widget.onLoadingError?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return AppComponents.errorWidget(
        message: '加载失败: $_error',
        onRetry: _startLoading,
      );
    }

    if (_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('加载中... ${(_progress * 100).toInt()}%'),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: _progress),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

/// Document completion widget
class DocumentCompletionWidget extends StatefulWidget {

  const DocumentCompletionWidget({
    super.key,
    required this.documentId,
    required this.taskId,
    required this.courseId,
    this.onCompleted,
  });
  final String documentId;
  final String taskId;
  final String courseId;
  final VoidCallback? onCompleted;

  @override
  State<DocumentCompletionWidget> createState() => _DocumentCompletionWidgetState();
}

class _DocumentCompletionWidgetState extends State<DocumentCompletionWidget> {
  final DocumentLoadingHandler _handler = DocumentLoadingHandler.instance;
  bool _isCompleted = false;
  DateTime? _completionTime;
  Duration _readingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _checkCompletionStatus();
  }

  /// Check completion status
  void _checkCompletionStatus() {
    _isCompleted = _handler.isDocumentCompleted(widget.documentId);
    _completionTime = _handler.getCompletionTime(widget.documentId);
    _readingTime = _handler.getReadingTime(widget.documentId);
  }

  /// Mark as completed
  Future<void> _markAsCompleted() async {
    try {
      await _handler.markDocumentAsCompleted(
        widget.documentId,
        widget.taskId,
        widget.courseId,
      );
      
      if (mounted) {
        setState(() {
          _isCompleted = true;
          _completionTime = DateTime.now();
        });
        
        widget.onCompleted?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('文档阅读完成！')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('标记完成失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            const Text(
              '文档阅读完成',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.successColor,
              ),
            ),
            if (_completionTime != null) ...[
              const SizedBox(height: 4),
              Text(
                '完成时间: ${_completionTime!.toString().substring(0, 19)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
            if (_readingTime.inSeconds > 0) ...[
              const SizedBox(height: 4),
              Text(
                '阅读时长: ${_readingTime.inMinutes} 分钟',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(
            Icons.description,
            size: 32,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 8),
          const Text(
            '文档阅读中',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AppComponents.customButton(
            text: '标记为完成',
            onPressed: _markAsCompleted,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
