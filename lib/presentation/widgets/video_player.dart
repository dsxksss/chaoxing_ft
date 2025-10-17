import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/video.dart';
import '../providers/task_provider.dart';
import '../widgets/app_components.dart';

/// Video player widget
class VideoPlayerWidget extends StatefulWidget {

  const VideoPlayerWidget({
    super.key,
    required this.video,
    this.onCompleted,
    this.onProgressChanged,
  });
  final Video video;
  final VoidCallback? onCompleted;
  final VoidCallback? onProgressChanged;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  bool _isPlaying = false;
  bool _isFullscreen = false;
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;
  bool _showControls = true;
  final bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _duration = widget.video.duration ?? Duration.zero;
    _currentPosition = widget.video.currentPosition ?? Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _isFullscreen ? double.infinity : 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: _isFullscreen ? null : BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Video content placeholder
          _buildVideoContent(),
          
          // Controls overlay
          if (_showControls) _buildControlsOverlay(),
          
          // Loading indicator
          if (_isBuffering) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  /// Build video content placeholder
  Widget _buildVideoContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: _isFullscreen ? null : BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              widget.video.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (widget.video.description != null)
              Text(
                widget.video.description!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 16),
            Text(
              '${_formatDuration(_currentPosition)} / ${_formatDuration(_duration)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
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
              
              // Center play button
              Expanded(
                child: Center(
                  child: _buildCenterPlayButton(),
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

  /// Build center play button
  Widget _buildCenterPlayButton() {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  /// Build bottom controls
  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress bar
          _buildProgressBar(),
          
          const SizedBox(height: 16),
          
          // Bottom controls row
          Row(
            children: [
              // Play/pause button
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: _togglePlayPause,
              ),
              
              // Speed control
              PopupMenuButton<double>(
                icon: const Icon(Icons.speed, color: Colors.white),
                onSelected: _changePlaybackSpeed,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 0.5, child: Text('0.5x')),
                  const PopupMenuItem(value: 0.75, child: Text('0.75x')),
                  const PopupMenuItem(value: 1.0, child: Text('1.0x')),
                  const PopupMenuItem(value: 1.25, child: Text('1.25x')),
                  const PopupMenuItem(value: 1.5, child: Text('1.5x')),
                  const PopupMenuItem(value: 2.0, child: Text('2.0x')),
                ],
              ),
              
              // Quality control
              PopupMenuButton<String>(
                icon: const Icon(Icons.hd, color: Colors.white),
                onSelected: _changeQuality,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: '480p', child: Text('480p')),
                  const PopupMenuItem(value: '720p', child: Text('720p')),
                  const PopupMenuItem(value: '1080p', child: Text('1080p')),
                ],
              ),
              
              const Spacer(),
              
              // Time display
              Text(
                '${_formatDuration(_currentPosition)} / ${_formatDuration(_duration)}',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build progress bar
  Widget _buildProgressBar() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppTheme.primaryColor,
        inactiveTrackColor: Colors.white.withOpacity(0.3),
        thumbColor: AppTheme.primaryColor,
        overlayColor: AppTheme.primaryColor.withOpacity(0.2),
      ),
      child: Slider(
        value: _duration.inMilliseconds > 0 
            ? _currentPosition.inMilliseconds / _duration.inMilliseconds 
            : 0.0,
        onChanged: _seekTo,
        onChangeStart: (value) {
          setState(() {
            _showControls = true;
          });
        },
        onChangeEnd: (value) {
          _hideControlsAfterDelay();
        },
      ),
    );
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      ),
    );
  }

  /// Toggle play/pause
  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    
    if (_isPlaying) {
      _startPlayback();
    } else {
      _pausePlayback();
    }
  }

  /// Toggle fullscreen
  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
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
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  /// Start playback
  void _startPlayback() {
    // TODO: Implement actual video playback
    // This is a placeholder implementation
    _simulatePlayback();
  }

  /// Pause playback
  void _pausePlayback() {
    // TODO: Implement actual video pause
    // This is a placeholder implementation
  }

  /// Simulate playback
  void _simulatePlayback() {
    if (!_isPlaying) return;
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isPlaying) {
        setState(() {
          _currentPosition = Duration(
            seconds: _currentPosition.inSeconds + 1,
          );
        });
        
        // Update progress
        final progress = _duration.inMilliseconds > 0 
            ? _currentPosition.inMilliseconds / _duration.inMilliseconds 
            : 0.0;
        
        // Update task progress
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        taskProvider.updateTaskProgress(widget.video.id, progress);
        
        // Call progress changed callback
        widget.onProgressChanged?.call();
        
        // Check if completed
        if (progress >= 1.0) {
          _onVideoCompleted();
        } else {
          _simulatePlayback();
        }
      }
    });
  }

  /// Seek to position
  void _seekTo(double value) {
    setState(() {
      _currentPosition = Duration(
        milliseconds: (value * _duration.inMilliseconds).round(),
      );
    });
  }

  /// Change playback speed
  void _changePlaybackSpeed(double speed) {
    setState(() {
    });
    
    // TODO: Implement actual speed change
  }

  /// Change quality
  void _changeQuality(String quality) {
    setState(() {
    });
    
    // TODO: Implement actual quality change
  }

  /// On video completed
  void _onVideoCompleted() {
    setState(() {
      _isPlaying = false;
      _currentPosition = _duration;
    });
    
    // Mark task as completed
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.markTaskAsCompleted(widget.video.id);
    
    // Call completion callback
    widget.onCompleted?.call();
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
