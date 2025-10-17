import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chaoxing_ft/presentation/widgets/app_components.dart';
import 'package:chaoxing_ft/presentation/providers/course_provider.dart';
import 'package:chaoxing_ft/presentation/providers/task_provider.dart';
import 'package:chaoxing_ft/domain/entities/task.dart';
import 'package:chaoxing_ft/services/task/task_executor_service.dart';
import 'package:chaoxing_ft/core/session/session_manager.dart';
import 'package:chaoxing_ft/services/task/task_learning_service.dart';
import 'package:chaoxing_ft/services/video/video_learning_service.dart';
import 'package:logger/logger.dart';

/// Course list page UI
class CourseListPage extends StatefulWidget {
  const CourseListPage({super.key});

  @override
  State<CourseListPage> createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  String? _selectedCourseId;
  List<Task> _courseTasks = [];
  bool _isLoadingTasks = false;
  bool _isExecuting = false;
  Map<String, dynamic>? _executionResults;
  String _currentTaskName = '';
  double _currentTaskProgress = 0.0;
  
  // 服务实例
  late final TaskExecutorService _taskExecutorService;
  late final SessionManager _sessionManager;
  late final TaskLearningService _taskLearningService;
  late final VideoLearningService _videoLearningService;
  late final Logger _logger;

  @override
  void initState() {
    super.initState();
    
    // 初始化服务
    _sessionManager = SessionManager.instance;
    _taskLearningService = TaskLearningService(_sessionManager, Logger());
    _videoLearningService = VideoLearningService(_sessionManager, Logger());
    _logger = Logger();
    _taskExecutorService = TaskExecutorService(
      _taskLearningService,
      _videoLearningService,
      _logger,
    );
    
    // Load courses when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(context, listen: false).loadCourses();
    });
  }

  void _refreshCourses() {
    Provider.of<CourseProvider>(context, listen: false).loadCourses();
  }

  Future<void> _loadCourseTasks(String courseId) async {
    setState(() {
      _isLoadingTasks = true;
      _selectedCourseId = courseId;
    });

    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.getTasksByCourseId(courseId);
      
      setState(() {
        _courseTasks = taskProvider.tasks;
      });
    } catch (e) {
      // Handle error
      setState(() {
        _courseTasks = [];
      });
    } finally {
      setState(() {
        _isLoadingTasks = false;
      });
    }
  }

  Future<void> _executeTasks() async {
    if (_courseTasks.isEmpty || _selectedCourseId == null) return;

    setState(() {
      _isExecuting = true;
      _executionResults = null;
      _currentTaskName = '';
      _currentTaskProgress = 0.0;
    });

    try {
      // 使用任务执行服务执行所有任务
      final results = await _taskExecutorService.executeCourseTasks(
        courseId: _selectedCourseId!,
        tasks: _courseTasks,
        speed: 1.0, // 默认播放速度
        notOpenAction: 'retry', // 默认重试模式
        onProgress: (taskName, progress) {
          if (mounted) {
            setState(() {
              _currentTaskName = taskName;
              _currentTaskProgress = progress;
            });
          }
        },
      );
      
      setState(() {
        _executionResults = results;
      });
      
      // 刷新任务列表
      await _loadCourseTasks(_selectedCourseId!);
      
      if (mounted) {
        final successCount = results['success'] as int;
        final failedCount = results['failed'] as int;
        final skippedCount = results['skipped'] as int;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('任务执行完成: 成功$successCount, 失败$failedCount, 跳过$skippedCount'),
            backgroundColor: failedCount > 0 ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('任务执行失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isExecuting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('课程作业'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCourses,
          ),
        ],
      ),
      body: Consumer<CourseProvider>(
        builder: (context, courseProvider, child) {
          if (courseProvider.isLoading) {
            return AppComponents.loadingIndicator(message: '正在加载课程...');
          }
          
          if (courseProvider.errorMessage != null) {
            return AppComponents.errorWidget(
              message: courseProvider.errorMessage!,
              onRetry: _refreshCourses,
            );
          }
          
          if (courseProvider.courses.isEmpty) {
            return AppComponents.emptyState(
              message: '暂无课程',
              icon: Icons.school_outlined,
              action: ElevatedButton(
                onPressed: _refreshCourses,
                child: const Text('刷新'),
              ),
            );
          }
          
          return Column(
            children: [
              // 课程选择区域
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '选择课程',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: courseProvider.courses.length,
                        itemBuilder: (context, index) {
                          final course = courseProvider.courses[index];
                          final isSelected = _selectedCourseId == course.id;
                          
                          return Container(
                            width: 200,
                            margin: const EdgeInsets.only(right: 12),
                            child: AppComponents.customCard(
                              child: InkWell(
                                onTap: () => _loadCourseTasks(course.id),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              course.name,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected ? Colors.blue : null,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isSelected)
                                            const Icon(
                                              Icons.check_circle,
                                              color: Colors.blue,
                                              size: 16,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Expanded(
                                        child: Text(
                                          course.teacher ?? '未知教师',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // 任务列表和执行按钮
              Expanded(
                child: _selectedCourseId == null
                    ? const Center(
                        child: Text(
                          '请先选择一个课程',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : _buildTaskList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTaskList() {
    if (_isLoadingTasks) {
      return AppComponents.loadingIndicator(message: '正在加载作业...');
    }

    if (_courseTasks.isEmpty) {
      return AppComponents.emptyState(
        message: '该课程暂无作业',
        icon: Icons.assignment_outlined,
      );
    }

    return Column(
      children: [
        // 执行按钮和进度显示
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isExecuting ? null : _executeTasks,
                  icon: _isExecuting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(_isExecuting ? '执行中...' : '开始执行作业'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              // 进度显示
              if (_isExecuting && _currentTaskName.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.play_circle_outline, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '正在执行: $_currentTaskName',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _currentTaskProgress,
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(_currentTaskProgress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // 任务列表
        Expanded(
          child: Column(
            children: [
              // 执行结果显示
              if (_executionResults != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getResultColor(_executionResults!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getResultIcon(_executionResults!),
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getResultMessage(_executionResults!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // 任务列表
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _courseTasks.length,
                  itemBuilder: (context, index) {
                    final task = _courseTasks[index];
                    return AppComponents.customCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              _getTaskIcon(task.type),
                              color: task.isCompleted ? Colors.green : Colors.orange,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${task.type.displayName} • ${task.status}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (task.isCompleted)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getTaskIcon(TaskType type) {
    switch (type) {
      case TaskType.video:
        return Icons.video_library;
      case TaskType.document:
        return Icons.description;
      case TaskType.quiz:
        return Icons.quiz;
      case TaskType.reading:
        return Icons.menu_book;
      case TaskType.assignment:
        return Icons.assignment;
      case TaskType.discussion:
        return Icons.forum;
    }
  }

  Color _getResultColor(Map<String, dynamic> results) {
    final failed = results['failed'] as int;
    final success = results['success'] as int;
    
    if (failed > 0) {
      return Colors.orange;
    } else if (success > 0) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  IconData _getResultIcon(Map<String, dynamic> results) {
    final failed = results['failed'] as int;
    final success = results['success'] as int;
    
    if (failed > 0) {
      return Icons.warning;
    } else if (success > 0) {
      return Icons.check_circle;
    } else {
      return Icons.info;
    }
  }

  String _getResultMessage(Map<String, dynamic> results) {
    final success = results['success'] as int;
    final failed = results['failed'] as int;
    final skipped = results['skipped'] as int;
    final total = results['total'] as int;
    
    return '执行完成: 成功$success, 失败$failed, 跳过$skipped, 总计$total';
  }
}