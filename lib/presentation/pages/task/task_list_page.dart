import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chaoxing_ft/presentation/providers/task_provider.dart';
import 'package:chaoxing_ft/presentation/widgets/app_components.dart';
import 'package:chaoxing_ft/domain/entities/task.dart';

/// Task list page UI
class TaskListPage extends StatefulWidget {

  const TaskListPage({
    super.key,
    required this.courseId,
    this.chapterId,
  });
  final String courseId;
  final String? chapterId;

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  TaskType? _selectedTaskType;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  /// Load tasks
  Future<void> _loadTasks() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    if (widget.chapterId != null) {
      await taskProvider.getTasksByChapterId(widget.chapterId!);
    } else {
      await taskProvider.getTasksByCourseId(widget.courseId);
    }
  }

  /// Refresh tasks
  Future<void> _refreshTasks() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    if (widget.chapterId != null) {
      await taskProvider.getTasksByChapterId(widget.chapterId!);
    } else {
      await taskProvider.getTasksByCourseId(widget.courseId);
    }
  }

  /// Filter tasks by type
  void _filterTasksByType(TaskType? type) {
    setState(() {
      _selectedTaskType = type;
    });
  }

  /// Search tasks
  void _searchTasks(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  /// Get filtered tasks
  List<Task> _getFilteredTasks(List<Task> tasks) {
    var filteredTasks = tasks;
    
    // Filter by type
    if (_selectedTaskType != null) {
      filteredTasks = filteredTasks.where((task) => task.type == _selectedTaskType).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredTasks = filteredTasks.where((task) => 
        task.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (task.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
    
    return filteredTasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapterId != null ? '章节任务' : '课程任务'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTasks,
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
            return AppComponents.loadingIndicator(message: '加载任务中...');
          }

          if (taskProvider.errorMessage != null && taskProvider.tasks.isEmpty) {
            return AppComponents.errorWidget(
              message: taskProvider.errorMessage!,
              onRetry: _refreshTasks,
            );
          }

          if (taskProvider.tasks.isEmpty) {
            return AppComponents.emptyState(
              message: '暂无任务',
              icon: Icons.assignment_outlined,
              action: ElevatedButton(
                onPressed: _refreshTasks,
                child: const Text('刷新'),
              ),
            );
          }

          final filteredTasks = _getFilteredTasks(taskProvider.tasks);

          return Column(
            children: [
              // Search and filter bar
              _buildSearchAndFilterBar(),
              
              // Task statistics
              _buildTaskStatistics(taskProvider),
              
              // Task list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshTasks,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return _buildTaskCard(task, taskProvider);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build search and filter bar
  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: const InputDecoration(
              hintText: '搜索任务...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _searchTasks,
          ),
          
          const SizedBox(height: 16),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('全部', null),
                const SizedBox(width: 8),
                _buildFilterChip('视频', TaskType.video),
                const SizedBox(width: 8),
                _buildFilterChip('文档', TaskType.document),
                const SizedBox(width: 8),
                _buildFilterChip('测验', TaskType.quiz),
                const SizedBox(width: 8),
                _buildFilterChip('作业', TaskType.assignment),
                const SizedBox(width: 8),
                _buildFilterChip('讨论', TaskType.discussion),
                const SizedBox(width: 8),
                _buildFilterChip('阅读', TaskType.reading),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build filter chip
  Widget _buildFilterChip(String label, TaskType? type) {
    final isSelected = _selectedTaskType == type;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        _filterTasksByType(selected ? type : null);
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  /// Build task statistics
  Widget _buildTaskStatistics(TaskProvider taskProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              '总任务',
              '${taskProvider.totalTasksCount}',
              Icons.assignment,
              AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              '已完成',
              '${taskProvider.completedTasksCount}',
              Icons.check_circle,
              AppTheme.successColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              '进度',
              '${(taskProvider.completionPercentage * 100).toInt()}%',
              Icons.trending_up,
              AppTheme.warningColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Build stat card
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// Build task card
  Widget _buildTaskCard(Task task, TaskProvider taskProvider) {
    return AppComponents.customCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToTask(task),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task header
            Row(
              children: [
                // Task type icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getTaskTypeColor(task.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTaskTypeIcon(task.type),
                    color: _getTaskTypeColor(task.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Task info
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (task.description != null)
                        Text(
                          task.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                
                // Progress indicator
                Column(
                  children: [
                    CircularProgressIndicator(
                      value: task.progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(_getTaskTypeColor(task.type)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(task.progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Task details
            Row(
              children: [
                _buildInfoChip('类型', _getTaskTypeName(task.type)),
                const SizedBox(width: 8),
                if (task.duration != null)
                  _buildInfoChip('时长', _formatDuration(task.duration!)),
                const SizedBox(width: 8),
                _buildInfoChip('状态', task.isCompleted ? '已完成' : '进行中'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress bar
            LinearProgressIndicator(
              value: task.progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getTaskTypeColor(task.type)),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _navigateToTask(task),
                    child: const Text('查看详情'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _navigateToTask(task),
                    child: Text(task.isCompleted ? '重新学习' : '开始学习'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build info chip
  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  /// Navigate to task
  void _navigateToTask(Task task) {
    // TODO: Implement task navigation
    // This is a placeholder implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('导航到任务: ${task.name}')),
    );
  }

  /// Get task type icon
  IconData _getTaskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.video:
        return Icons.play_circle_outline;
      case TaskType.document:
        return Icons.description;
      case TaskType.quiz:
        return Icons.quiz;
      case TaskType.assignment:
        return Icons.assignment;
      case TaskType.discussion:
        return Icons.forum;
      case TaskType.reading:
        return Icons.menu_book;
    }
  }

  /// Get task type color
  Color _getTaskTypeColor(TaskType type) {
    switch (type) {
      case TaskType.video:
        return AppTheme.primaryColor;
      case TaskType.document:
        return AppTheme.secondaryColor;
      case TaskType.quiz:
        return AppTheme.warningColor;
      case TaskType.assignment:
        return AppTheme.errorColor;
      case TaskType.discussion:
        return AppTheme.successColor;
      case TaskType.reading:
        return Colors.purple;
    }
  }

  /// Get task type name
  String _getTaskTypeName(TaskType type) {
    switch (type) {
      case TaskType.video:
        return '视频';
      case TaskType.document:
        return '文档';
      case TaskType.quiz:
        return '测验';
      case TaskType.assignment:
        return '作业';
      case TaskType.discussion:
        return '讨论';
      case TaskType.reading:
        return '阅读';
    }
  }

  /// Format duration
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
