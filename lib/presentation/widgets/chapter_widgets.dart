import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chaoxing_ft/presentation/providers/chapter_provider.dart';
import 'package:chaoxing_ft/domain/entities/chapter.dart';

/// Chapter list widget
class ChapterListWidget extends StatelessWidget {

  const ChapterListWidget({
    super.key,
    required this.courseId,
  });
  final String courseId;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChapterProvider>(
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

        if (chapterProvider.chapters.isEmpty) {
          return const Center(child: Text('没有找到章节'));
        }

        return ListView.builder(
          itemCount: chapterProvider.chapters.length,
          itemBuilder: (context, index) {
            final chapter = chapterProvider.chapters[index];
            return ChapterCard(
              chapter: chapter,
              onTap: () => _navigateToChapter(context, chapter),
            );
          },
        );
      },
    );
  }

  void _navigateToChapter(BuildContext context, Chapter chapter) {
    Navigator.of(context).pushNamed('/chapter', arguments: {'chapterId': chapter.id});
  }
}

/// Chapter card widget
class ChapterCard extends StatelessWidget {

  const ChapterCard({
    super.key,
    required this.chapter,
    required this.onTap,
  });
  final Chapter chapter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: chapter.isUnlocked ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildChapterIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (chapter.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            chapter.description!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildStatusIcon(),
                ],
              ),
              const SizedBox(height: 12),
              _buildProgressBar(),
              const SizedBox(height: 8),
              _buildChapterInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChapterIcon() {
    IconData iconData;
    Color iconColor;

    if (chapter.isCompleted) {
      iconData = Icons.check_circle;
      iconColor = Colors.green;
    } else if (chapter.isInProgress) {
      iconData = Icons.play_circle;
      iconColor = Colors.blue;
    } else if (!chapter.isUnlocked) {
      iconData = Icons.lock;
      iconColor = Colors.grey;
    } else {
      iconData = Icons.folder;
      iconColor = Colors.orange;
    }

    return Icon(iconData, color: iconColor, size: 32);
  }

  Widget _buildStatusIcon() {
    if (chapter.isOverdue) {
      return const Icon(
        Icons.warning,
        color: Colors.red,
        size: 20,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '进度: ${chapter.formattedProgress}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              '${chapter.completedTaskCount}/${chapter.taskCount} 任务',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: chapter.progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            chapter.isCompleted ? Colors.green : Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildChapterInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          chapter.status,
          style: TextStyle(
            fontSize: 12,
            color: chapter.isCompleted ? Colors.green : Colors.grey,
          ),
        ),
        if (chapter.isCompleted) ...[
          Text(
            chapter.completionTime,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ] else if (!chapter.isUnlocked) ...[
          Text(
            chapter.unlockStatus,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ] else if (chapter.isOverdue) ...[
          Text(
            chapter.overdueStatus,
            style: const TextStyle(fontSize: 12, color: Colors.red),
          ),
        ],
      ],
    );
  }
}

/// Chapter progress summary widget
class ChapterProgressSummaryWidget extends StatelessWidget {

  const ChapterProgressSummaryWidget({
    super.key,
    required this.courseId,
  });
  final String courseId;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChapterProvider>(
      builder: (context, chapterProvider, child) {
        if (chapterProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '课程进度总览',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildProgressOverview(chapterProvider),
                const SizedBox(height: 16),
                _buildStatistics(chapterProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressOverview(ChapterProvider chapterProvider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('总体进度'),
            Text(
              chapterProvider.formattedOverallProgress,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: chapterProvider.overallCourseProgress,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ],
    );
  }

  Widget _buildStatistics(ChapterProvider chapterProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          '已完成',
          '${chapterProvider.completedChaptersCount}',
          Colors.green,
        ),
        _buildStatItem(
          '进行中',
          '${chapterProvider.inProgressChapters.length}',
          Colors.blue,
        ),
        _buildStatItem(
          '未开始',
          '${chapterProvider.totalChaptersCount - chapterProvider.completedChaptersCount - chapterProvider.inProgressChapters.length}',
          Colors.grey,
        ),
        _buildStatItem(
          '逾期',
          '${chapterProvider.overdueChapters.length}',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

/// Chapter timeline widget
class ChapterTimelineWidget extends StatelessWidget {

  const ChapterTimelineWidget({
    super.key,
    required this.courseId,
  });
  final String courseId;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChapterProvider>(
      builder: (context, chapterProvider, child) {
        if (chapterProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chapterProvider.completionTimeline.isEmpty) {
          return const Center(child: Text('暂无完成记录'));
        }

        return ListView.builder(
          itemCount: chapterProvider.completionTimeline.length,
          itemBuilder: (context, index) {
            final timelineItem = chapterProvider.completionTimeline[index];
            return _buildTimelineItem(timelineItem);
          },
        );
      },
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> timelineItem) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text(timelineItem['chapterName'] ?? '未知章节'),
        subtitle: Text(timelineItem['completedAt'] ?? '未知时间'),
        trailing: Text(timelineItem['progress'] ?? '0%'),
      ),
    );
  }
}
