import 'package:flutter/material.dart';
import '../../core/errors/error_handler.dart';
import '../../core/logging/auth_logger.dart';
import '../../presentation/widgets/app_components.dart';

/// Document page navigation controller
class DocumentPageNavigationController {
  
  DocumentPageNavigationController._internal();
  static final DocumentPageNavigationController _instance = DocumentPageNavigationController._internal();
  static DocumentPageNavigationController get instance => _instance;
  
  final ErrorHandler _errorHandler = ErrorHandler.instance;
  
  // Navigation state
  final Map<String, int> _currentPages = {};
  final Map<String, int> _totalPages = {};
  final Map<String, List<int>> _visitedPages = {};
  final Map<String, List<int>> _bookmarkedPages = {};
  final Map<String, Map<int, String>> _pageNotes = {};

  /// Set total pages for document
  void setTotalPages(String documentId, int totalPages) {
    if (totalPages < 0) {
      throw _errorHandler.createDataParsingError('Total pages cannot be negative');
    }
    
    _totalPages[documentId] = totalPages;
    _currentPages[documentId] ??= 0;
    _visitedPages[documentId] ??= [];
    _bookmarkedPages[documentId] ??= [];
    _pageNotes[documentId] ??= {};
    
    AuthLogger.logInfo('Total pages set - documentId: $documentId, totalPages: $totalPages');
  }

  /// Get current page
  int getCurrentPage(String documentId) {
    return _currentPages[documentId] ?? 0;
  }

  /// Get total pages
  int getTotalPages(String documentId) {
    return _totalPages[documentId] ?? 0;
  }

  /// Navigate to page
  void navigateToPage(String documentId, int page) {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }
      
      final totalPages = getTotalPages(documentId);
      if (page < 0 || page >= totalPages) {
        throw _errorHandler.createDataParsingError('Page $page is out of range (0-${totalPages - 1})');
      }
      
      final oldPage = _currentPages[documentId] ?? 0;
      _currentPages[documentId] = page;
      
      // Add to visited pages
      if (!_visitedPages[documentId]!.contains(page)) {
        _visitedPages[documentId]!.add(page);
      }
      
      AuthLogger.logInfo('Navigated to page - documentId: $documentId, oldPage: $oldPage, newPage: $page');
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentPageNavigationController.navigateToPage');
    }
  }

  /// Navigate to next page
  bool navigateToNextPage(String documentId) {
    try {
      final currentPage = getCurrentPage(documentId);
      final totalPages = getTotalPages(documentId);
      
      if (currentPage < totalPages - 1) {
        navigateToPage(documentId, currentPage + 1);
        return true;
      }
      
      return false;
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentPageNavigationController.navigateToNextPage');
      return false;
    }
  }

  /// Navigate to previous page
  bool navigateToPreviousPage(String documentId) {
    try {
      final currentPage = getCurrentPage(documentId);
      
      if (currentPage > 0) {
        navigateToPage(documentId, currentPage - 1);
        return true;
      }
      
      return false;
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentPageNavigationController.navigateToPreviousPage');
      return false;
    }
  }

  /// Navigate to first page
  void navigateToFirstPage(String documentId) {
    navigateToPage(documentId, 0);
  }

  /// Navigate to last page
  void navigateToLastPage(String documentId) {
    final totalPages = getTotalPages(documentId);
    if (totalPages > 0) {
      navigateToPage(documentId, totalPages - 1);
    }
  }

  /// Check if can navigate to next page
  bool canNavigateToNextPage(String documentId) {
    final currentPage = getCurrentPage(documentId);
    final totalPages = getTotalPages(documentId);
    return currentPage < totalPages - 1;
  }

  /// Check if can navigate to previous page
  bool canNavigateToPreviousPage(String documentId) {
    final currentPage = getCurrentPage(documentId);
    return currentPage > 0;
  }

  /// Get visited pages
  List<int> getVisitedPages(String documentId) {
    return _visitedPages[documentId] ?? [];
  }

  /// Add bookmark
  void addBookmark(String documentId, int page) {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }
      
      if (page < 0 || page >= getTotalPages(documentId)) {
        throw _errorHandler.createDataParsingError('Page $page is out of range');
      }
      
      if (!_bookmarkedPages[documentId]!.contains(page)) {
        _bookmarkedPages[documentId]!.add(page);
        _bookmarkedPages[documentId]!.sort();
        
AuthLogger.logInfo('Bookmark added - documentId: $documentId, page: $page');
      }
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentPageNavigationController.addBookmark');
    }
  }

  /// Remove bookmark
  void removeBookmark(String documentId, int page) {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }
      
      _bookmarkedPages[documentId]?.remove(page);
      
      AuthLogger.logInfo('Bookmark removed - documentId: $documentId, page: $page');
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentPageNavigationController.removeBookmark');
    }
  }

  /// Check if page is bookmarked
  bool isPageBookmarked(String documentId, int page) {
    return _bookmarkedPages[documentId]?.contains(page) ?? false;
  }

  /// Get bookmarked pages
  List<int> getBookmarkedPages(String documentId) {
    return _bookmarkedPages[documentId] ?? [];
  }

  /// Add page note
  void addPageNote(String documentId, int page, String note) {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }
      
      if (page < 0 || page >= getTotalPages(documentId)) {
        throw _errorHandler.createDataParsingError('Page $page is out of range');
      }
      
      if (note.isEmpty) {
        throw _errorHandler.createDataParsingError('Note cannot be empty');
      }
      
      _pageNotes[documentId]![page] = note;
      
      AuthLogger.logInfo('Page note added - documentId: $documentId, page: $page, note: $note');
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentPageNavigationController.addPageNote');
    }
  }

  /// Remove page note
  void removePageNote(String documentId, int page) {
    try {
      if (documentId.isEmpty) {
        throw _errorHandler.createDataParsingError('Document ID cannot be empty');
      }
      
      _pageNotes[documentId]?.remove(page);
      
      AuthLogger.logInfo('Page note removed - documentId: $documentId, page: $page');
    } catch (e) {
      _errorHandler.handleError(e, context: 'DocumentPageNavigationController.removePageNote');
    }
  }

  /// Get page note
  String? getPageNote(String documentId, int page) {
    return _pageNotes[documentId]?[page];
  }

  /// Get all page notes
  Map<int, String> getPageNotes(String documentId) {
    return _pageNotes[documentId] ?? {};
  }

  /// Clear document data
  void clearDocumentData(String documentId) {
    _currentPages.remove(documentId);
    _totalPages.remove(documentId);
    _visitedPages.remove(documentId);
    _bookmarkedPages.remove(documentId);
    _pageNotes.remove(documentId);
    
    AuthLogger.logInfo('Document navigation data cleared - documentId: $documentId');
  }

  /// Clear all data
  void clearAllData() {
    _currentPages.clear();
    _totalPages.clear();
    _visitedPages.clear();
    _bookmarkedPages.clear();
    _pageNotes.clear();
    
    AuthLogger.logInfo('All document navigation data cleared');
  }

  /// Get navigation statistics
  Map<String, dynamic> getNavigationStatistics(String documentId) {
    final totalPages = getTotalPages(documentId);
    final visitedPages = getVisitedPages(documentId);
    final bookmarkedPages = getBookmarkedPages(documentId);
    final pageNotes = getPageNotes(documentId);
    
    return {
      'totalPages': totalPages,
      'visitedPages': visitedPages.length,
      'bookmarkedPages': bookmarkedPages.length,
      'pageNotes': pageNotes.length,
      'completionRate': totalPages > 0 ? visitedPages.length / totalPages : 0.0,
    };
  }
}

/// Document page navigation widget
class DocumentPageNavigationWidget extends StatefulWidget {

  const DocumentPageNavigationWidget({
    super.key,
    required this.documentId,
    this.onPageChanged,
    this.onNextPage,
    this.onPreviousPage,
  });
  final String documentId;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onNextPage;
  final VoidCallback? onPreviousPage;

  @override
  State<DocumentPageNavigationWidget> createState() => _DocumentPageNavigationWidgetState();
}

class _DocumentPageNavigationWidgetState extends State<DocumentPageNavigationWidget> {
  final DocumentPageNavigationController _controller = DocumentPageNavigationController.instance;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _updatePageInfo();
  }

  /// Update page info
  void _updatePageInfo() {
    _currentPage = _controller.getCurrentPage(widget.documentId);
    _totalPages = _controller.getTotalPages(widget.documentId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Page info
          Text(
            '第 ${_currentPage + 1} 页 / 共 $_totalPages 页',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Navigation controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // First page
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: _controller.canNavigateToPreviousPage(widget.documentId)
                    ? () => _navigateToFirstPage()
                    : null,
              ),
              
              // Previous page
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _controller.canNavigateToPreviousPage(widget.documentId)
                    ? () => _navigateToPreviousPage()
                    : null,
              ),
              
              // Page input
              SizedBox(
                width: 80,
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '页码',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: _navigateToPage,
                ),
              ),
              
              // Next page
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _controller.canNavigateToNextPage(widget.documentId)
                    ? () => _navigateToNextPage()
                    : null,
              ),
              
              // Last page
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: _controller.canNavigateToNextPage(widget.documentId)
                    ? () => _navigateToLastPage()
                    : null,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress bar
          LinearProgressIndicator(
            value: _totalPages > 0 ? (_currentPage + 1) / _totalPages : 0.0,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          
          const SizedBox(height: 16),
          
          // Quick navigation
          _buildQuickNavigation(),
        ],
      ),
    );
  }

  /// Build quick navigation
  Widget _buildQuickNavigation() {
    final bookmarkedPages = _controller.getBookmarkedPages(widget.documentId);
    
    if (bookmarkedPages.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快速导航',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: bookmarkedPages.map((page) {
            return ActionChip(
              label: Text('第 ${page + 1} 页'),
              onPressed: () => _navigateToPage(page.toString()),
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              labelStyle: const TextStyle(color: AppTheme.primaryColor),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Navigate to first page
  void _navigateToFirstPage() {
    _controller.navigateToFirstPage(widget.documentId);
    _updatePageInfo();
    widget.onPageChanged?.call(_currentPage);
    widget.onPreviousPage?.call();
  }

  /// Navigate to previous page
  void _navigateToPreviousPage() {
    if (_controller.navigateToPreviousPage(widget.documentId)) {
      _updatePageInfo();
      widget.onPageChanged?.call(_currentPage);
      widget.onPreviousPage?.call();
    }
  }

  /// Navigate to next page
  void _navigateToNextPage() {
    if (_controller.navigateToNextPage(widget.documentId)) {
      _updatePageInfo();
      widget.onPageChanged?.call(_currentPage);
      widget.onNextPage?.call();
    }
  }

  /// Navigate to last page
  void _navigateToLastPage() {
    _controller.navigateToLastPage(widget.documentId);
    _updatePageInfo();
    widget.onPageChanged?.call(_currentPage);
    widget.onNextPage?.call();
  }

  /// Navigate to specific page
  void _navigateToPage(String pageText) {
    try {
      final page = int.parse(pageText) - 1; // Convert to 0-based index
      if (page >= 0 && page < _totalPages) {
        _controller.navigateToPage(widget.documentId, page);
        _updatePageInfo();
        widget.onPageChanged?.call(_currentPage);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('页码超出范围 (1-$_totalPages)')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的页码')),
      );
    }
  }
}

/// Document page bookmark widget
class DocumentPageBookmarkWidget extends StatefulWidget {

  const DocumentPageBookmarkWidget({
    super.key,
    required this.documentId,
    required this.page,
    this.onBookmarkAdded,
    this.onBookmarkRemoved,
  });
  final String documentId;
  final int page;
  final VoidCallback? onBookmarkAdded;
  final VoidCallback? onBookmarkRemoved;

  @override
  State<DocumentPageBookmarkWidget> createState() => _DocumentPageBookmarkWidgetState();
}

class _DocumentPageBookmarkWidgetState extends State<DocumentPageBookmarkWidget> {
  final DocumentPageNavigationController _controller = DocumentPageNavigationController.instance;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _isBookmarked = _controller.isPageBookmarked(widget.documentId, widget.page);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
        color: _isBookmarked ? AppTheme.primaryColor : Colors.grey,
      ),
      onPressed: _toggleBookmark,
    );
  }

  /// Toggle bookmark
  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    
    if (_isBookmarked) {
      _controller.addBookmark(widget.documentId, widget.page);
      widget.onBookmarkAdded?.call();
    } else {
      _controller.removeBookmark(widget.documentId, widget.page);
      widget.onBookmarkRemoved?.call();
    }
  }
}
