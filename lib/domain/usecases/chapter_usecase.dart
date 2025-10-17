import 'package:chaoxing_ft/domain/entities/chapter.dart';
import 'package:chaoxing_ft/domain/repositories/chapter_repository.dart';

/// Use case for getting chapters for a course
class GetChaptersForCourseUseCase {

  GetChaptersForCourseUseCase(this.repository);
  final ChapterRepository repository;

  Future<List<Chapter>> call(String courseId) {
    return repository.getChaptersForCourse(courseId);
  }
}

/// Use case for getting chapter details
class GetChapterDetailsUseCase {

  GetChapterDetailsUseCase(this.repository);
  final ChapterRepository repository;

  Future<Chapter> call(String chapterId) {
    return repository.getChapterDetails(chapterId);
  }
}

/// Use case for updating chapter progress
class UpdateChapterProgressUseCase {

  UpdateChapterProgressUseCase(this.repository);
  final ChapterRepository repository;

  Future<void> call(String chapterId, double progress) {
    return repository.updateChapterProgress(chapterId, progress);
  }
}

/// Use case for marking chapter as completed
class MarkChapterAsCompletedUseCase {

  MarkChapterAsCompletedUseCase(this.repository);
  final ChapterRepository repository;

  Future<void> call(String chapterId) {
    return repository.markChapterAsCompleted(chapterId);
  }
}

/// Use case for unlocking chapter
class UnlockChapterUseCase {

  UnlockChapterUseCase(this.repository);
  final ChapterRepository repository;

  Future<void> call(String chapterId) {
    return repository.unlockChapter(chapterId);
  }
}

/// Use case for getting chapter statistics
class GetChapterStatisticsUseCase {

  GetChapterStatisticsUseCase(this.repository);
  final ChapterRepository repository;

  Future<Map<String, dynamic>> call(String chapterId) {
    return repository.getChapterStatistics(chapterId);
  }
}

/// Use case for getting course progress summary
class GetCourseProgressSummaryUseCase {

  GetCourseProgressSummaryUseCase(this.repository);
  final ChapterRepository repository;

  Future<Map<String, dynamic>> call(String courseId) {
    return repository.getCourseProgressSummary(courseId);
  }
}

/// Use case for getting overdue chapters
class GetOverdueChaptersUseCase {

  GetOverdueChaptersUseCase(this.repository);
  final ChapterRepository repository;

  Future<List<Chapter>> call(String courseId) {
    return repository.getOverdueChapters(courseId);
  }
}

/// Use case for getting upcoming chapters
class GetUpcomingChaptersUseCase {

  GetUpcomingChaptersUseCase(this.repository);
  final ChapterRepository repository;

  Future<List<Chapter>> call(String courseId) {
    return repository.getUpcomingChapters(courseId);
  }
}

/// Use case for getting chapter completion timeline
class GetChapterCompletionTimelineUseCase {

  GetChapterCompletionTimelineUseCase(this.repository);
  final ChapterRepository repository;

  Future<List<Map<String, dynamic>>> call(String courseId) {
    return repository.getChapterCompletionTimeline(courseId);
  }
}
