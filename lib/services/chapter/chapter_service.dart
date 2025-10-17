import 'package:chaoxing_ft/domain/entities/chapter.dart';
import 'package:chaoxing_ft/domain/usecases/chapter_usecase.dart';

/// Service for chapter operations
class ChapterService {

  ChapterService({
    required this.getChaptersForCourseUseCase,
    required this.getChapterDetailsUseCase,
    required this.updateChapterProgressUseCase,
    required this.markChapterAsCompletedUseCase,
    required this.unlockChapterUseCase,
    required this.getChapterStatisticsUseCase,
    required this.getCourseProgressSummaryUseCase,
    required this.getOverdueChaptersUseCase,
    required this.getUpcomingChaptersUseCase,
    required this.getChapterCompletionTimelineUseCase,
  });
  final GetChaptersForCourseUseCase getChaptersForCourseUseCase;
  final GetChapterDetailsUseCase getChapterDetailsUseCase;
  final UpdateChapterProgressUseCase updateChapterProgressUseCase;
  final MarkChapterAsCompletedUseCase markChapterAsCompletedUseCase;
  final UnlockChapterUseCase unlockChapterUseCase;
  final GetChapterStatisticsUseCase getChapterStatisticsUseCase;
  final GetCourseProgressSummaryUseCase getCourseProgressSummaryUseCase;
  final GetOverdueChaptersUseCase getOverdueChaptersUseCase;
  final GetUpcomingChaptersUseCase getUpcomingChaptersUseCase;
  final GetChapterCompletionTimelineUseCase getChapterCompletionTimelineUseCase;

  /// Get chapters for a course
  Future<List<Chapter>> getChaptersForCourse(String courseId) async {
    return await getChaptersForCourseUseCase(courseId);
  }

  /// Get chapter details
  Future<Chapter> getChapterDetails(String chapterId) async {
    return await getChapterDetailsUseCase(chapterId);
  }

  /// Update chapter progress
  Future<void> updateChapterProgress(String chapterId, double progress) async {
    return await updateChapterProgressUseCase(chapterId, progress);
  }

  /// Mark chapter as completed
  Future<void> markChapterAsCompleted(String chapterId) async {
    return await markChapterAsCompletedUseCase(chapterId);
  }

  /// Unlock chapter
  Future<void> unlockChapter(String chapterId) async {
    return await unlockChapterUseCase(chapterId);
  }

  /// Get chapter statistics
  Future<Map<String, dynamic>> getChapterStatistics(String chapterId) async {
    return await getChapterStatisticsUseCase(chapterId);
  }

  /// Get course progress summary
  Future<Map<String, dynamic>> getCourseProgressSummary(String courseId) async {
    return await getCourseProgressSummaryUseCase(courseId);
  }

  /// Get overdue chapters
  Future<List<Chapter>> getOverdueChapters(String courseId) async {
    return await getOverdueChaptersUseCase(courseId);
  }

  /// Get upcoming chapters
  Future<List<Chapter>> getUpcomingChapters(String courseId) async {
    return await getUpcomingChaptersUseCase(courseId);
  }

  /// Get chapter completion timeline
  Future<List<Map<String, dynamic>>> getChapterCompletionTimeline(String courseId) async {
    return await getChapterCompletionTimelineUseCase(courseId);
  }
}
