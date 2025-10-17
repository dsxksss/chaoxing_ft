import 'package:flutter/material.dart';
import '../../core/errors/error_handler.dart';
import '../../presentation/widgets/app_components.dart';
import '../../core/logging/auth_logger.dart';

/// Video playback speed controller
class VideoPlaybackSpeedController {
  
  VideoPlaybackSpeedController._internal();
  static final VideoPlaybackSpeedController _instance = VideoPlaybackSpeedController._internal();
  static VideoPlaybackSpeedController get instance => _instance;
  
  final ErrorHandler _errorHandler = ErrorHandler.instance;
  
  // Available playback speeds
  static const List<double> _availableSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  static const double _defaultSpeed = 1.0;
  
  // Current speed for each video
  final Map<String, double> _videoSpeeds = {};

  /// Get available playback speeds
  List<double> get availableSpeeds => _availableSpeeds;

  /// Get default speed
  double get defaultSpeed => _defaultSpeed;

  /// Get current speed for video
  double getCurrentSpeed(String videoId) {
    return _videoSpeeds[videoId] ?? _defaultSpeed;
  }

  /// Set playback speed for video
  void setPlaybackSpeed(String videoId, double speed) {
    try {
      if (videoId.isEmpty) {
        throw _errorHandler.createDataParsingError('Video ID cannot be empty');
      }

      if (!_availableSpeeds.contains(speed)) {
        throw _errorHandler.createDataParsingError('Invalid playback speed: $speed');
      }

      _videoSpeeds[videoId] = speed;
      
      AuthLogger.logInfo('Playback speed set - videoId: $videoId, speed: $speed');
    } catch (e) {
      _errorHandler.handleError(e, context: 'VideoPlaybackSpeedController.setPlaybackSpeed');
    }
  }

  /// Reset speed to default
  void resetSpeed(String videoId) {
    _videoSpeeds.remove(videoId);
    
    AuthLogger.logInfo('Playback speed reset to default - videoId: $videoId, speed: $_defaultSpeed');
  }

  /// Clear all speeds
  void clearAllSpeeds() {
    _videoSpeeds.clear();
    
    AuthLogger.logInfo('All playback speeds cleared');
  }

  /// Get speed statistics
  Map<String, dynamic> getSpeedStatistics() {
    final totalVideos = _videoSpeeds.length;
    final speedCounts = <double, int>{};
    
    for (final speed in _videoSpeeds.values) {
      speedCounts[speed] = (speedCounts[speed] ?? 0) + 1;
    }
    
    return {
      'totalVideos': totalVideos,
      'speedCounts': speedCounts,
      'mostUsedSpeed': speedCounts.isNotEmpty 
          ? speedCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : _defaultSpeed,
    };
  }
}

/// Video playback speed widget
class VideoPlaybackSpeedWidget extends StatefulWidget {

  const VideoPlaybackSpeedWidget({
    super.key,
    required this.videoId,
    this.onSpeedChanged,
    this.initialSpeed,
  });
  final String videoId;
  final ValueChanged<double>? onSpeedChanged;
  final double? initialSpeed;

  @override
  State<VideoPlaybackSpeedWidget> createState() => _VideoPlaybackSpeedWidgetState();
}

class _VideoPlaybackSpeedWidgetState extends State<VideoPlaybackSpeedWidget> {
  final VideoPlaybackSpeedController _controller = VideoPlaybackSpeedController.instance;
  double _currentSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _currentSpeed = widget.initialSpeed ?? _controller.getCurrentSpeed(widget.videoId);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.speed),
          const SizedBox(width: 4),
          Text('${_currentSpeed}x'),
        ],
      ),
      onSelected: _onSpeedSelected,
      itemBuilder: (context) => _controller.availableSpeeds.map((speed) {
        return PopupMenuItem<double>(
          value: speed,
          child: Row(
            children: [
              if (speed == _currentSpeed)
                const Icon(Icons.check, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text('${speed}x'),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// On speed selected
  void _onSpeedSelected(double speed) {
    setState(() {
      _currentSpeed = speed;
    });
    
    _controller.setPlaybackSpeed(widget.videoId, speed);
    widget.onSpeedChanged?.call(speed);
  }
}

/// Video playback speed settings page
class VideoPlaybackSpeedSettingsPage extends StatefulWidget {
  const VideoPlaybackSpeedSettingsPage({super.key});

  @override
  State<VideoPlaybackSpeedSettingsPage> createState() => _VideoPlaybackSpeedSettingsPageState();
}

class _VideoPlaybackSpeedSettingsPageState extends State<VideoPlaybackSpeedSettingsPage> {
  final VideoPlaybackSpeedController _controller = VideoPlaybackSpeedController.instance;
  double _defaultSpeed = 1.0;
  bool _rememberSpeedPerVideo = true;
  bool _showSpeedIndicator = true;

  @override
  void initState() {
    super.initState();
    _defaultSpeed = _controller.defaultSpeed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('播放速度设置'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Default speed setting
          AppComponents.customCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '默认播放速度',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '选择默认的视频播放速度',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: _controller.availableSpeeds.map((speed) {
                    final isSelected = speed == _defaultSpeed;
                    return FilterChip(
                      label: Text('${speed}x'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _defaultSpeed = speed;
                        });
                      },
                      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                      checkmarkColor: AppTheme.primaryColor,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Speed options
          AppComponents.customCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '播放选项',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Remember speed per video
                SwitchListTile(
                  title: const Text('记住每个视频的播放速度'),
                  subtitle: const Text('为不同的视频保存不同的播放速度'),
                  value: _rememberSpeedPerVideo,
                  onChanged: (value) {
                    setState(() {
                      _rememberSpeedPerVideo = value;
                    });
                  },
                ),
                
                // Show speed indicator
                SwitchListTile(
                  title: const Text('显示速度指示器'),
                  subtitle: const Text('在播放器上显示当前播放速度'),
                  value: _showSpeedIndicator,
                  onChanged: (value) {
                    setState(() {
                      _showSpeedIndicator = value;
                    });
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Speed statistics
          AppComponents.customCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '使用统计',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSpeedStatistics(),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Reset button
          AppComponents.customButton(
            text: '重置所有设置',
            onPressed: _resetSettings,
            backgroundColor: AppTheme.errorColor,
            textColor: Colors.white,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  /// Build speed statistics
  Widget _buildSpeedStatistics() {
    final stats = _controller.getSpeedStatistics();
    
    return Column(
      children: [
        _buildStatRow('总视频数', '${stats['totalVideos']}'),
        _buildStatRow('最常用速度', '${stats['mostUsedSpeed']}x'),
        
        const SizedBox(height: 16),
        
        const Text(
          '速度使用分布',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        ..._controller.availableSpeeds.map((speed) {
          final count = stats['speedCounts'][speed] ?? 0;
          return _buildStatRow('${speed}x', '$count 个视频');
        }),
      ],
    );
  }

  /// Build stat row
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Reset settings
  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置设置'),
        content: const Text('确定要重置所有播放速度设置吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _controller.clearAllSpeeds();
              setState(() {
                _defaultSpeed = _controller.defaultSpeed;
                _rememberSpeedPerVideo = true;
                _showSpeedIndicator = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('设置已重置')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/// Video playback speed indicator
class VideoPlaybackSpeedIndicator extends StatefulWidget {

  const VideoPlaybackSpeedIndicator({
    super.key,
    required this.speed,
    required this.duration,
  });
  final double speed;
  final Duration duration;

  @override
  State<VideoPlaybackSpeedIndicator> createState() => _VideoPlaybackSpeedIndicatorState();
}

class _VideoPlaybackSpeedIndicatorState extends State<VideoPlaybackSpeedIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(VideoPlaybackSpeedIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speed != widget.speed) {
      _showIndicator();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Show indicator
  void _showIndicator() {
    setState(() {
      _isVisible = true;
    });
    
    _animationController.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _animationController.reverse().then((_) {
            if (mounted) {
              setState(() {
                _isVisible = false;
              });
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.speed,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.speed}x',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
