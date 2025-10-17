import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chaoxing_ft/presentation/providers/chapter_provider.dart';
import 'package:chaoxing_ft/presentation/widgets/chapter_widgets.dart';
import 'package:chaoxing_ft/domain/entities/chapter.dart';

/// Chapter list page
class ChapterListPage extends StatefulWidget {
  const ChapterListPage({super.key});

  @override
  State<ChapterListPage> createState() => _ChapterListPageState();
}

class _ChapterListPageState extends State<ChapterListPage> {
  String? _courseId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _courseId = args?['courseId'] as String?;

    if (_courseId != null) {
      Provider.of<ChapterProvider>(context, listen: false).fetchChaptersForCourse(_courseId!);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('错误: 课程ID缺失')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('章节列表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_courseId != null) {
                Provider.of<ChapterProvider>(context, listen: false).fetchChaptersForCourse(_courseId!);
              }
            },
          ),
        ],
      ),
      body: _courseId != null
          ? Column(
              children: [
                ChapterProgressSummaryWidget(courseId: _courseId!),
                Expanded(
                  child: ChapterListWidget(courseId: _courseId!),
                ),
              ],
            )
          : const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '课程ID缺失',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
    );
  }
}

/// Chapter details page
class ChapterDetailsPage extends StatefulWidget {
  const ChapterDetailsPage({super.key});

  @override
  State<ChapterDetailsPage> createState() => _ChapterDetailsPageState();
}

class _ChapterDetailsPageState extends State<ChapterDetailsPage> {
  String? _chapterId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _chapterId = args?['chapterId'] as String?;

    if (_chapterId != null) {
      Provider.of<ChapterProvider>(context, listen: false).getChapterDetails(_chapterId!);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('错误: 章节ID缺失')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('章节详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_chapterId != null) {
                Provider.of<ChapterProvider>(context, listen: false).getChapterDetails(_chapterId!);
              }
            },
          ),
        ],
      ),
      body: Consumer<ChapterProvider>(
        builder: (context, chapterProvider, child) {
          if (chapterProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (chapterProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  chapterProvider.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (chapterProvider.selectedChapter == null) {
            return const Center(child: Text('章节详情加载失败'));
          }

          final chapter = chapterProvider.selectedChapter!;
          return _buildChapterDetails(chapter, chapterProvider);
        },
      ),
    );
  }

  Widget _buildChapterDetails(Chapter chapter, ChapterProvider chapterProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChapterHeader(chapter),
          const SizedBox(height: 24),
          _buildChapterProgress(chapter),
          const SizedBox(height: 24),
          _buildChapterInfo(chapter),
          const SizedBox(height: 24),
          _buildChapterActions(chapter, chapterProvider),
          const SizedBox(height: 24),
          _buildChapterTasks(chapter),
        ],
      ),
    );
  }

  Widget _buildChapterHeader(Chapter chapter) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  chapter.isCompleted ? Icons.check_circle : Icons.folder,
                  color: chapter.isCompleted ? Colors.green : Colors.blue,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    chapter.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (chapter.description != null) ...[
              const SizedBox(height: 8),
              Text(
                chapter.description!,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '第 ${chapter.order} 章',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterProgress(Chapter chapter) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '学习进度',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('进度: ${chapter.formattedProgress}'),
                Text('${chapter.completedTaskCount}/${chapter.taskCount} 任务'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: chapter.progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                chapter.isCompleted ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '状态: ${chapter.status}',
              style: TextStyle(
                color: chapter.isCompleted ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterInfo(Chapter chapter) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '章节信息',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('任务数量', '${chapter.taskCount}'),
            _buildInfoRow('解锁状态', chapter.unlockStatus),
            if (chapter.isCompleted) ...[
              _buildInfoRow('完成时间', chapter.completionTime),
            ],
            if (chapter.isOverdue) ...[
              _buildInfoRow('逾期状态', chapter.overdueStatus),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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

  Widget _buildChapterActions(Chapter chapter, ChapterProvider chapterProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '操作',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (!chapter.isUnlocked) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _unlockChapter(chapterProvider, chapter.id),
                      child: const Text('解锁章节'),
                    ),
                  ),
                ] else if (!chapter.isCompleted) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _startChapter(chapter),
                      child: const Text('开始学习'),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _reviewChapter(chapter),
                      child: const Text('复习章节'),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewChapterStatistics(chapterProvider, chapter.id),
                    child: const Text('查看统计'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterTasks(Chapter chapter) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '章节任务',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (chapter.taskIds.isEmpty) ...[
              const Text('暂无任务'),
            ] else ...[
              ...chapter.taskIds.map((taskId) => ListTile(
                leading: const Icon(Icons.assignment),
                title: Text('任务 $taskId'),
                subtitle: const Text('点击查看详情'),
                onTap: () => _navigateToTask(taskId),
              )),
            ],
          ],
        ),
      ),
    );
  }

  void _unlockChapter(ChapterProvider chapterProvider, String chapterId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('解锁章节'),
        content: const Text('确定要解锁此章节吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              chapterProvider.unlockChapter(chapterId);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _startChapter(Chapter chapter) {
    Navigator.of(context).pushNamed('/task_list', arguments: {'chapterId': chapter.id});
  }

  void _reviewChapter(Chapter chapter) {
    Navigator.of(context).pushNamed('/task_list', arguments: {'chapterId': chapter.id});
  }

  void _viewChapterStatistics(ChapterProvider chapterProvider, String chapterId) {
    Navigator.of(context).pushNamed('/chapter_statistics', arguments: {'chapterId': chapterId});
  }

  void _navigateToTask(String taskId) {
    Navigator.of(context).pushNamed('/task', arguments: {'taskId': taskId});
  }
}
