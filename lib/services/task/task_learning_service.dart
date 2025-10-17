import 'package:logger/logger.dart';

import '../../core/session/session_manager.dart';
import '../../core/errors/study_result.dart';

/// Task learning service - handles various task types
/// Replicates chaoxing_py task processing logic
class TaskLearningService {
  TaskLearningService(
    this._sessionManager,
    this._logger,
  );

  final SessionManager _sessionManager;
  final Logger _logger;

  /// Study document task
  /// Replicates chaoxing_py study_document method
  Future<StudyResult> studyDocument({
    required Map<String, dynamic> course,
    required Map<String, dynamic> job,
  }) async {
    try {
      // Extract node ID from otherinfo
      final otherInfo = job['otherinfo'] as String;
      final nodeIdMatch = RegExp(r'nodeId_(.*?)-').firstMatch(otherInfo);
      
      if (nodeIdMatch == null) {
        _logger.e('Failed to extract nodeId from otherinfo');
        return StudyResult.error;
      }

      final knowledgeId = nodeIdMatch.group(1);
      
      const url = 'https://mooc1.chaoxing.com/ananas/job/document';
      final params = {
        'jobid': job['jobid'],
        'knowledgeid': knowledgeId,
        'courseid': course['courseId'],
        'clazzid': course['clazzId'],
        'jtoken': job['jtoken'],
        '_dc': _sessionManager.getTimestamp(),
      };

      final response = await _sessionManager.dio.get(
        url,
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        _logger.i('Document task completed: ${job['title'] ?? 'Unknown'}');
        return StudyResult.success;
      } else {
        _logger.e('Document task failed: ${response.statusCode}');
        return StudyResult.error;
      }
    } catch (e) {
      _logger.e('Document task error: $e');
      return StudyResult.error;
    }
  }

  /// Study reading task
  /// Replicates chaoxing_py study_read method
  Future<StudyResult> studyRead({
    required Map<String, dynamic> course,
    required Map<String, dynamic> job,
    required Map<String, dynamic> jobInfo,
  }) async {
    try {
      const url = 'https://mooc1.chaoxing.com/ananas/job/readv2';
      final params = {
        'jobid': job['jobid'],
        'knowledgeid': jobInfo['knowledgeid'],
        'jtoken': job['jtoken'],
        'courseid': course['courseId'],
        'clazzid': course['clazzId'],
      };

      final response = await _sessionManager.dio.get(
        url,
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        _logger.i('Reading task: ${data['msg'] ?? 'Completed'}');
        return StudyResult.success;
      } else {
        _logger.e('Reading task failed: [${response.statusCode}] ${response.data}');
        return StudyResult.error;
      }
    } catch (e) {
      _logger.e('Reading task error: $e');
      return StudyResult.error;
    }
  }

  /// Study empty page (章节页面无任务点)
  /// Replicates chaoxing_py study_emptypage method
  Future<StudyResult> studyEmptyPage({
    required Map<String, dynamic> course,
    required Map<String, dynamic> point,
  }) async {
    try {
      const url = 'https://mooc1.chaoxing.com/mooc-ans/mycourse/studentstudyAjax';
      final params = {
        'courseId': course['courseId'],
        'clazzid': course['clazzId'],
        'chapterId': point['id'],
        'cpi': course['cpi'],
        'verificationcode': '',
        'mooc2': '1',
        'microTopicId': '0',
        'editorPreview': '0',
      };

      final response = await _sessionManager.dio.get(
        url,
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        _logger.i('Empty page task completed: ${point['title']}');
        return StudyResult.success;
      } else {
        _logger.e('Empty page task failed: [${response.statusCode}] ${point['title']}');
        return StudyResult.error;
      }
    } catch (e) {
      _logger.e('Empty page task error: $e');
      return StudyResult.error;
    }
  }

  /// Process quiz/work task (placeholder - requires question bank integration)
  /// Replicates chaoxing_py study_work method
  Future<StudyResult> studyWork({
    required Map<String, dynamic> course,
    required Map<String, dynamic> job,
    required Map<String, dynamic> jobInfo,
    bool submitAnswers = false,
  }) async {
    try {
      _logger.w('Quiz task processing not fully implemented yet');
      _logger.w('This requires question bank integration');
      
      // TODO: Implement full quiz processing with question bank
      // For now, just fetch the quiz data
      
      const url = 'https://mooc1.chaoxing.com/mooc-ans/api/work';
      final workId = (job['jobid'] as String).replaceAll('work-', '');
      
      final params = {
        'api': '1',
        'workId': workId,
        'jobid': job['jobid'],
        'originJobId': job['jobid'],
        'needRedirect': 'true',
        'skipHeader': 'true',
        'knowledgeid': jobInfo['knowledgeid'].toString(),
        'ktoken': jobInfo['ktoken'],
        'cpi': jobInfo['cpi'],
        'ut': 's',
        'clazzId': course['clazzId'],
        'type': '',
        'enc': job['enc'],
        'mooc2': '1',
        'courseid': course['courseId'],
      };

      final response = await _sessionManager.dio.get(
        url,
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        _logger.i('Quiz fetched successfully (not submitted)');
        // TODO: Parse questions, query answers from question bank, submit
        return StudyResult.success;
      } else {
        _logger.e('Quiz fetch failed: ${response.statusCode}');
        return StudyResult.error;
      }
    } catch (e) {
      _logger.e('Quiz task error: $e');
      return StudyResult.error;
    }
  }
}
