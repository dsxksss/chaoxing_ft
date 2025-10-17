import 'package:chaoxing_ft/domain/entities/chapter.dart';

/// Repository interface for chapter operations
abstract class ChapterRepository {
  /// Get chapters for a course
  Future<List<Chapter>> getChaptersForCourse(String courseId);

  /// Get chapter details by ID
  Future<Chapter> getChapterDetails(String chapterId);

  /// Update chapter progress
  Future<void> updateChapterProgress(String chapterId, double progress);

  /// Mark chapter as completed
  Future<void> markChapterAsCompleted(String chapterId);

  /// Unlock chapter
  Future<void> unlockChapter(String chapterId);

  /// Get chapter statistics
  Future<Map<String, dynamic>> getChapterStatistics(String chapterId);

  /// Get course progress summary
  Future<Map<String, dynamic>> getCourseProgressSummary(String courseId);

  /// Get overdue chapters
  Future<List<Chapter>> getOverdueChapters(String courseId);

  /// Get upcoming chapters
  Future<List<Chapter>> getUpcomingChapters(String courseId);

  /// Get chapter completion timeline
  Future<List<Map<String, dynamic>>> getChapterCompletionTimeline(String courseId);
}
