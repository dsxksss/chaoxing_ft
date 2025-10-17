import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/document.dart';
import '../providers/task_provider.dart';
import '../widgets/app_components.dart';

/// Document viewer widget
class DocumentViewerWidget extends StatefulWidget {
  final Document document;
  final VoidCallback? onCompleted;
  final VoidCallback? onProgressChanged;

  const DocumentViewerWidget({
    super.key,
    required this.document,
    this.onCompleted,
    this.onProgressChanged,
  });

  @override
  State<DocumentViewerWidget> createState() => _DocumentViewerWidgetState();
}

class _DocumentViewerWidgetState extends State<DocumentViewerWidget> {
  int _currentPage = 0;
  bool _isLoading = false;
  String? _content;
  List<String> _pages = [];
  bool _showControls = true;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.document.currentPage ?? 0;
    _loadDocument();
  }

  /// Load document
  Future<void> _loadDocument() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual document loading logic
      // This is a placeholder implementation
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate document content
      _content = widget.document.content ?? 'This is a sample document content.';
      _pages = _splitContentIntoPages(_content!);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载文档失败: $e')),
      );
    }
  }

  /// Split content into pages
  List<String> _splitContentIntoPages(String content) {
    // Simple page splitting logic
    final words = content.split(' ');
    const wordsPerPage = 100; // Adjust based on screen size
    final pages = <String>[];
    
    for (int i = 0; i < words.length; i += wordsPerPage) {
      final end = (i + wordsPerPage < words.length) ? i + wordsPerPage : words.length;
      pages.add(words.sublist(i, end).join(' '));
    }
    
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _isFullscreen ? double.infinity : 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _isFullscreen ? null : BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          // Document content
          _buildDocumentContent(),
          
          // Controls overlay
          if (_showControls) _buildControlsOverlay(),
          
          // Loading indicator
          if (_isLoading) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  /// Build document content
  Widget _buildDocumentContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_pages.isEmpty) {
      return const Center(
        child: Text('文档内容为空'),
      );
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document header
              _buildDocumentHeader(),
              
              const SizedBox(height: 16),
              
              // Document content
              _buildDocumentText(),
              
              const SizedBox(height: 16),
              
              // Page navigation
              _buildPageNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build document header
  Widget _buildDocumentHeader() {
    return Row(
      children: [
        // Document icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              widget.document.formatIcon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Document info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.document.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.document.formatName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        // Progress indicator
        Column(
          children: [
            CircularProgressIndicator(
              value: widget.document.progress ?? 0.0,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.document.progressPercentage}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build document text
  Widget _buildDocumentText() {
    if (_currentPage >= _pages.length) {
      return const Center(
        child: Text('页面不存在'),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(
        _pages[_currentPage],
        style: const TextStyle(
          fontSize: 16,
          height: 1.6,
        ),
      ),
    );
  }

  /// Build page navigation
  Widget _buildPageNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous page button
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _currentPage > 0 ? _previousPage : null,
        ),
        
        // Page info
        Text(
          '第 ${_currentPage + 1} 页 / 共 ${_pages.length} 页',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // Next page button
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _currentPage < _pages.length - 1 ? _nextPage : null,
        ),
      ],
    );
  }

  /// Build controls overlay
  Widget _buildControlsOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _toggleControls,
        child: Container(
          color: Colors.transparent,
          child: Column(
            children: [
              // Top controls
              _buildTopControls(),
              
              // Center controls
              Expanded(
                child: Center(
                  child: _buildCenterControls(),
                ),
              ),
              
              // Bottom controls
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build top controls
  Widget _buildTopControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _isFullscreen ? _toggleFullscreen : () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            onPressed: _toggleFullscreen,
          ),
        ],
      ),
    );
  }

  /// Build center controls
  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Previous page
        GestureDetector(
          onTap: _currentPage > 0 ? _previousPage : null,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        
        // Next page
        GestureDetector(
          onTap: _currentPage < _pages.length - 1 ? _nextPage : null,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }

  /// Build bottom controls
  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Page info
          Text(
            '第 ${_currentPage + 1} 页 / 共 ${_pages.length} 页',
            style: const TextStyle(color: Colors.white),
          ),
          
          const Spacer(),
          
          // Progress info
          Text(
            '${widget.document.progressPercentage}%',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator() {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.8),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  /// Toggle controls visibility
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    
    if (_showControls) {
      _hideControlsAfterDelay();
    }
  }

  /// Hide controls after delay
  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  /// Toggle fullscreen
  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  /// Previous page
  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _updateProgress();
    }
  }

  /// Next page
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      setState(() {
        _currentPage++;
      });
      _updateProgress();
    } else {
      _onDocumentCompleted();
    }
  }

  /// Update progress
  void _updateProgress() {
    final progress = _pages.isNotEmpty ? (_currentPage + 1) / _pages.length : 0.0;
    
    // Update task progress
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.updateTaskProgress(widget.document.id, progress);
    
    // Call progress changed callback
    widget.onProgressChanged?.call();
  }

  /// On document completed
  void _onDocumentCompleted() {
    // Mark task as completed
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.markTaskAsCompleted(widget.document.id);
    
    // Call completion callback
    widget.onCompleted?.call();
    
    // Show completion message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('文档阅读完成！')),
    );
  }
}
