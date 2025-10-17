import 'package:chaoxing_ft/domain/entities/chapter.dart';
import 'package:chaoxing_ft/presentation/providers/base_provider.dart';
import 'package:chaoxing_ft/services/chapter/chapter_service.dart';

/// Provider for chapter state management
class ChapterProvider extends BaseProvider {

  ChapterProvider(this.chapterService);
  final ChapterService chapterService;

  List<Chapter> _chapters = [];
  Chapter? _selectedChapter;
  Map<String, dynamic> _courseProgressSummary = {};
  List<Chapter> _overdueChapters = [];
  List<Chapter> _upcomingChapters = [];
  List<Map<String, dynamic>> _completionTimeline = [];

  List<Chapter> get chapters => _chapters;
  Chapter? get selectedChapter => _selectedChapter;
  Map<String, dynamic> get courseProgressSummary => _courseProgressSummary;
  List<Chapter> get overdueChapters => _overdueChapters;
  List<Chapter> get upcomingChapters => _upcomingChapters;
  List<Map<String, dynamic>> get completionTimeline => _completionTimeline;

  /// Get chapters for a course
  Future<void> fetchChaptersForCourse(String courseId) async {
    setLoading(true);
    setError(null);
    try {
      _chapters = await chapterService.getChaptersForCourse(courseId);
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Get chapter details
  Future<void> getChapterDetails(String chapterId) async {
    setLoading(true);
    setError(null);
    try {
      _selectedChapter = await chapterService.getChapterDetails(chapterId);
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Update chapter progress
  Future<void> updateChapterProgress(String chapterId, double progress) async {
    setLoading(true);
    setError(null);
    try {
      await chapterService.updateChapterProgress(chapterId, progress);
      
      // Update local state
      final index = _chapters.indexWhere((chapter) => chapter.id == chapterId);
      if (index != -1) {
        _chapters[index] = _chapters[index].copyWith(progress: progress);
        notifyListeners();
      }
      
      if (_selectedChapter?.id == chapterId) {
        _selectedChapter = _selectedChapter!.copyWith(progress: progress);
      }
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Mark chapter as completed
  Future<void> markChapterAsCompleted(String chapterId) async {
    setLoading(true);
    setError(null);
    try {
      await chapterService.markChapterAsCompleted(chapterId);
      
      // Update local state
      final index = _chapters.indexWhere((chapter) => chapter.id == chapterId);
      if (index != -1) {
        _chapters[index] = _chapters[index].copyWith(
          isCompleted: true,
          progress: 1.0,
          completedAt: DateTime.now(),
        );
        notifyListeners();
      }
      
      if (_selectedChapter?.id == chapterId) {
        _selectedChapter = _selectedChapter!.copyWith(
          isCompleted: true,
          progress: 1.0,
          completedAt: DateTime.now(),
        );
      }
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Unlock chapter
  Future<void> unlockChapter(String chapterId) async {
    setLoading(true);
    setError(null);
    try {
      await chapterService.unlockChapter(chapterId);
      
      // Update local state
      final index = _chapters.indexWhere((chapter) => chapter.id == chapterId);
      if (index != -1) {
        _chapters[index] = _chapters[index].copyWith(isUnlocked: true);
        notifyListeners();
      }
      
      if (_selectedChapter?.id == chapterId) {
        _selectedChapter = _selectedChapter!.copyWith(isUnlocked: true);
      }
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Get course progress summary
  Future<void> getCourseProgressSummary(String courseId) async {
    setLoading(true);
    setError(null);
    try {
      _courseProgressSummary = await chapterService.getCourseProgressSummary(courseId);
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Get overdue chapters
  Future<void> getOverdueChapters(String courseId) async {
    setLoading(true);
    setError(null);
    try {
      _overdueChapters = await chapterService.getOverdueChapters(courseId);
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Get upcoming chapters
  Future<void> getUpcomingChapters(String courseId) async {
    setLoading(true);
    setError(null);
    try {
      _upcomingChapters = await chapterService.getUpcomingChapters(courseId);
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Get chapter completion timeline
  Future<void> getChapterCompletionTimeline(String courseId) async {
    setLoading(true);
    setError(null);
    try {
      _completionTimeline = await chapterService.getChapterCompletionTimeline(courseId);
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Get chapter statistics
  Future<Map<String, dynamic>> getChapterStatistics(String chapterId) async {
    setLoading(true);
    setError(null);
    try {
      return await chapterService.getChapterStatistics(chapterId);
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Select chapter
  void selectChapter(Chapter chapter) {
    _selectedChapter = chapter;
    notifyListeners();
  }

  /// Clear selected chapter
  void clearSelectedChapter() {
    _selectedChapter = null;
    notifyListeners();
  }

  /// Get completed chapters count
  int get completedChaptersCount {
    return _chapters.where((chapter) => chapter.isCompleted).length;
  }

  /// Get total chapters count
  int get totalChaptersCount {
    return _chapters.length;
  }

  /// Get overall course progress
  double get overallCourseProgress {
    if (_chapters.isEmpty) return 0.0;
    final totalProgress = _chapters.fold<double>(0.0, (sum, chapter) => sum + chapter.progress);
    return totalProgress / _chapters.length;
  }

  /// Get formatted overall progress
  String get formattedOverallProgress {
    return '${(overallCourseProgress * 100).toInt()}%';
  }

  /// Get chapters by status
  List<Chapter> getChaptersByStatus(String status) {
    return _chapters.where((chapter) => chapter.status == status).toList();
  }

  /// Get unlocked chapters
  List<Chapter> get unlockedChapters {
    return _chapters.where((chapter) => chapter.isUnlocked).toList();
  }

  /// Get locked chapters
  List<Chapter> get lockedChapters {
    return _chapters.where((chapter) => !chapter.isUnlocked).toList();
  }

  /// Get in-progress chapters
  List<Chapter> get inProgressChapters {
    return _chapters.where((chapter) => chapter.isInProgress).toList();
  }

  /// Reset chapter state
  void resetChapterState() {
    _chapters = [];
    _selectedChapter = null;
    _courseProgressSummary = {};
    _overdueChapters = [];
    _upcomingChapters = [];
    _completionTimeline = [];
    notifyListeners();
  }
}
