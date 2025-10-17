import 'package:logger/logger.dart';
import 'package:logger/logger.dart';

import '../../core/errors/study_result.dart';
import '../../services/task/task_learning_service.dart';
import '../../services/video/video_learning_service.dart';
import '../../domain/entities/task.dart';
import '../../data/datasources/remote/chaoxing_api_datasource.dart';
import '../../domain/repositories/task_repository.dart';

/// Task executor service - handles task execution logic
/// Replicates chaoxing_py process_course and process_chapter flow
class TaskExecutorService {
  TaskExecutorService(
    this._taskLearningService,
    this._videoLearningService,
    this._apiDataSource,
    this._taskRepository,
    this._logger,
  );
  final TaskLearningService _taskLearningService;
  final VideoLearningService _videoLearningService;
  final ChaoxingApiDataSource _apiDataSource;
  final TaskRepository _taskRepository;
  final Logger _logger;

  /// Execute all tasks for a course
  /// Replicates chaoxing_py process_course method
  Future<Map<String, dynamic>> executeCourseTasks({
    required String courseId,
    required List<Task> tasks,
    double speed = 1.0,
    String notOpenAction = 'retry',
    Function(String taskName, double progress)? onProgress,
  }) async {
    _logger.i('开始执行课程任务: $courseId');
    
    final results = {
      'success': 0,
      'failed': 0,
      'skipped': 0,
      'total': tasks.length,
      'details': <Map<String, dynamic>>[],
    };

    try {
      // 获取课程信息
      final courseInfo = await _getCourseInfo(courseId);
      
      // 按章节分组任务
      final tasksByChapter = _groupTasksByChapter(tasks);
      
      // 处理每个章节
      for (final chapterId in tasksByChapter.keys) {
        final chapterTasks = tasksByChapter[chapterId]!;
        _logger.i('处理章节: $chapterId, 任务数量: ${chapterTasks.length}');
        
        final chapterResult = await _executeChapterTasks(
          courseInfo: courseInfo,
          chapterId: chapterId,
          tasks: chapterTasks,
          speed: speed,
          notOpenAction: notOpenAction,
          onProgress: onProgress,
        );
        
        (results['details'] as List<Map<String, dynamic>>).addAll(
          chapterResult['details'] as List<Map<String, dynamic>>
        );
        results['success'] = (results['success'] as int) + (chapterResult['success'] as int);
        results['failed'] = (results['failed'] as int) + (chapterResult['failed'] as int);
        results['skipped'] = (results['skipped'] as int) + (chapterResult['skipped'] as int);
      }
      
      _logger.i('课程任务执行完成: 成功${results['success']}, 失败${results['failed']}, 跳过${results['skipped']}');
      return results;
    } catch (e) {
      _logger.e('课程任务执行失败: $e');
      results['error'] = e.toString();
      return results;
    }
  }

  /// Execute tasks for a specific chapter
  /// Replicates chaoxing_py process_chapter method
  Future<Map<String, dynamic>> _executeChapterTasks({
    required Map<String, dynamic> courseInfo,
    required String chapterId,
    required List<Task> tasks,
    required double speed,
    required String notOpenAction,
    Function(String taskName, double progress)? onProgress,
  }) async {
    final results = {
      'success': 0,
      'failed': 0,
      'skipped': 0,
      'details': <Map<String, dynamic>>[],
    };

    try {
      // 检查章节是否开放
      final chapterInfo = await _getChapterInfo(courseInfo, chapterId);
      if (chapterInfo['notOpen'] == true) {
        _logger.w('章节未开放: $chapterId');
        return _handleNotOpenChapter(notOpenAction, chapterId, tasks, results);
      }

      // 检查章节是否已完成
      if (chapterInfo['hasFinished'] == true) {
        _logger.i('章节已完成: $chapterId');
        for (final task in tasks) {
        (results['details'] as List<Map<String, dynamic>>).add({
          'taskId': task.id,
          'taskName': task.name,
          'status': 'already_completed',
          'message': '章节已完成',
        });
        results['skipped'] = (results['skipped'] as int) + 1;
        }
        return results;
      }

      // 执行章节中的任务
      for (final task in tasks) {
        if (task.isCompleted) {
          (results['details'] as List<Map<String, dynamic>>).add({
            'taskId': task.id,
            'taskName': task.name,
            'status': 'already_completed',
            'message': '任务已完成',
          });
          results['skipped'] = (results['skipped'] as int) + 1;
          continue;
        }

        final taskResult = await _executeSingleTask(
          courseInfo: courseInfo,
          chapterInfo: chapterInfo,
          task: task,
          speed: speed,
          onProgress: onProgress,
        );

        (results['details'] as List<Map<String, dynamic>>).add({
          'taskId': task.id,
          'taskName': task.name,
          'status': taskResult['success'] ? 'success' : 'failed',
          'message': taskResult['message'],
        });

        if (taskResult['success']) {
          results['success'] = (results['success'] as int) + 1;
        } else {
          results['failed'] = (results['failed'] as int) + 1;
        }
      }

      return results;
    } catch (e) {
      _logger.e('章节任务执行失败: $e');
      results['error'] = e.toString();
      return results;
    }
  }

  /// Execute a single task
  /// Replicates chaoxing_py process_job method
  Future<Map<String, dynamic>> _executeSingleTask({
    required Map<String, dynamic> courseInfo,
    required Map<String, dynamic> chapterInfo,
    required Task task,
    required double speed,
    Function(String taskName, double progress)? onProgress,
  }) async {
    try {
      _logger.i('执行任务: ${task.name} (${task.type.displayName})');
      _logger.d('任务元数据: ${task.metadata}');

      // 将Task转换为API需要的格式
      final job = _convertTaskToJob(task);
      final jobInfo = _convertChapterToJobInfo(chapterInfo);
      
      _logger.d('转换后的job: $job');
      _logger.d('转换后的jobInfo: $jobInfo');

      StudyResult result;
      switch (task.type) {
        case TaskType.video:
          result = await _executeVideoTask(courseInfo, job, jobInfo, speed, onProgress);
          break;
        case TaskType.document:
          result = await _executeDocumentTask(courseInfo, job);
          break;
        case TaskType.quiz:
          result = await _executeQuizTask(courseInfo, job, jobInfo);
          break;
        case TaskType.reading:
          result = await _executeReadingTask(courseInfo, job, jobInfo);
          break;
        default:
          _logger.w('未知任务类型: ${task.type}');
          return {'success': false, 'message': '未知任务类型'};
      }

      if (result == StudyResult.success) {
        _logger.i('任务执行成功: ${task.name}');
        
        // 标记任务为已完成
        try {
          await _taskRepository.markTaskAsCompleted(task.id);
          _logger.i('任务状态已更新为完成: ${task.name}');
        } catch (e) {
          _logger.w('更新任务完成状态失败: $e');
        }
        
        return {'success': true, 'message': '任务执行成功'};
      } else {
        _logger.w('任务执行失败: ${task.name}');
        return {'success': false, 'message': '任务执行失败'};
      }
    } catch (e) {
      _logger.e('任务执行异常: ${task.name}, 错误: $e');
      return {'success': false, 'message': '任务执行异常: $e'};
    }
  }

  /// Execute video task
  Future<StudyResult> _executeVideoTask(
    Map<String, dynamic> courseInfo,
    Map<String, dynamic> job,
    Map<String, dynamic> jobInfo,
    double speed,
    Function(String taskName, double progress)? onProgress,
  ) async {
    try {
      _logger.i('执行视频任务: ${job['title'] ?? 'Unknown'}');
      _logger.d('视频任务参数 - courseInfo: $courseInfo');
      _logger.d('视频任务参数 - job: $job');
      _logger.d('视频任务参数 - jobInfo: $jobInfo');
      
      // 通知开始执行
      onProgress?.call(job['title'] ?? 'Unknown', 0.0);
      
      // 首先尝试视频任务
      var result = await _videoLearningService.studyVideo(
        course: courseInfo,
        job: job,
        jobInfo: jobInfo,
        speed: speed,
        type: 'Video',
        onProgress: onProgress,
      );
      
      // 如果视频任务失败（非403错误），尝试音频任务（与Python版本一致）
      // 403错误不应该触发Audio重试，因为这是会话问题，不是类型问题
      if (result == StudyResult.error) {
        _logger.w('视频任务失败，尝试音频任务: ${job['title'] ?? 'Unknown'}');
        result = await _videoLearningService.studyVideo(
          course: courseInfo,
          job: job,
          jobInfo: jobInfo,
          speed: speed,
          type: 'Audio',
          onProgress: onProgress,
        );
      }
      
      // 通知执行完成
      onProgress?.call(job['title'] ?? 'Unknown', 1.0);
      
      if (result == StudyResult.success) {
        _logger.i('视频任务执行成功: ${job['title'] ?? 'Unknown'}');
      } else if (result == StudyResult.forbidden) {
        _logger.w('视频任务被禁止: ${job['title'] ?? 'Unknown'}');
      } else {
        _logger.w('视频任务执行失败: ${job['title'] ?? 'Unknown'}');
      }
      
      return result;
    } catch (e) {
      _logger.e('视频任务执行异常: $e');
      return StudyResult.error;
    }
  }

  /// Execute document task
  Future<StudyResult> _executeDocumentTask(
    Map<String, dynamic> courseInfo,
    Map<String, dynamic> job,
  ) async {
    try {
      return await _taskLearningService.studyDocument(
        course: courseInfo,
        job: job,
      );
    } catch (e) {
      _logger.e('文档任务执行失败: $e');
      return StudyResult.error;
    }
  }

  /// Execute quiz task
  Future<StudyResult> _executeQuizTask(
    Map<String, dynamic> courseInfo,
    Map<String, dynamic> job,
    Map<String, dynamic> jobInfo,
  ) async {
    try {
      return await _taskLearningService.studyWork(
        course: courseInfo,
        job: job,
        jobInfo: jobInfo,
        submitAnswers: false, // TODO: 根据配置决定是否提交答案
      );
    } catch (e) {
      _logger.e('测验任务执行失败: $e');
      return StudyResult.error;
    }
  }

  /// Execute reading task
  Future<StudyResult> _executeReadingTask(
    Map<String, dynamic> courseInfo,
    Map<String, dynamic> job,
    Map<String, dynamic> jobInfo,
  ) async {
    try {
      return await _taskLearningService.studyRead(
        course: courseInfo,
        job: job,
        jobInfo: jobInfo,
      );
    } catch (e) {
      _logger.e('阅读任务执行失败: $e');
      return StudyResult.error;
    }
  }

  /// Handle not open chapter
  Map<String, dynamic> _handleNotOpenChapter(
    String notOpenAction,
    String chapterId,
    List<Task> tasks,
    Map<String, dynamic> results,
  ) {
    switch (notOpenAction) {
      case 'retry':
        _logger.w('章节未开放，重试模式');
        // TODO: 实现重试逻辑
        break;
      case 'ask':
        _logger.w('章节未开放，询问模式');
        // TODO: 实现询问用户逻辑
        break;
      case 'continue':
        _logger.w('章节未开放，跳过模式');
        break;
    }

    // 标记所有任务为跳过
    for (final task in tasks) {
      (results['details'] as List<Map<String, dynamic>>).add({
        'taskId': task.id,
        'taskName': task.name,
        'status': 'skipped',
        'message': '章节未开放',
      });
      results['skipped'] = (results['skipped'] as int) + 1;
    }

    return results;
  }

  /// Get course information
  /// 从API获取真实的课程数据（包括clazzId和cpi）
  /// clazzId和courseId是不同的值，必须从课程列表HTML中解析获取，不能混用
  Future<Map<String, dynamic>> _getCourseInfo(String courseId) async {
    try {
      _logger.d('获取课程信息: courseId=$courseId');
      
      // 从API获取完整的课程列表
      final courses = await _apiDataSource.getCourseList();
      _logger.d('课程列表获取成功，共${courses.length}门课程');
      
      // 查找匹配的课程（支持通过courseId或id查找）
      final course = courses.firstWhere(
        (c) => c['courseId'] == courseId || c['id'] == courseId,
        orElse: () {
          _logger.e('课程未找到: $courseId');
          _logger.e('可用的课程: ${courses.map((c) => '${c['id']}:${c['courseId']}').join(', ')}');
          throw Exception('Course not found: $courseId');
        },
      );
      
      _logger.i('找到课程: ${course['title']} (courseId: ${course['courseId']}, clazzId: ${course['clazzId']}, cpi: ${course['cpi']})');
      
      // 返回包含正确clazzId和cpi的课程信息
      return {
        'courseId': course['courseId'],
        'clazzId': course['clazzId'],
        'cpi': course['cpi'],
        'title': course['title'],
        'teacher': course['teacher'],
      };
    } catch (e) {
      _logger.e('获取课程信息失败: $e');
      rethrow;
    }
  }

  /// Get chapter information
  Future<Map<String, dynamic>> _getChapterInfo(
    Map<String, dynamic> courseInfo,
    String chapterId,
  ) async {
    // 从任务数据中提取章节信息
    // 这里需要从实际的章节数据中获取，暂时使用默认值
    return {
      'id': chapterId,
      'title': '示例章节',
      'notOpen': false,
      'hasFinished': false,
      'knowledgeid': chapterId, // 使用章节ID作为knowledgeid
      'ktoken': '8fa33fc784712e4104a43eef0a2015f7', // 从日志中看到的ktoken
      'cpi': courseInfo['cpi'],
    };
  }

  /// Group tasks by chapter
  Map<String, List<Task>> _groupTasksByChapter(List<Task> tasks) {
    final Map<String, List<Task>> grouped = {};
    
    for (final task in tasks) {
      final chapterId = task.chapterId ?? 'default';
      grouped.putIfAbsent(chapterId, () => []).add(task);
    }
    
    return grouped;
  }

  /// Convert Task to job format
  Map<String, dynamic> _convertTaskToJob(Task task) {
    final job = {
      'jobid': task.id,
      'name': task.name,
      'title': task.name,
      'type': task.type.name,
      'otherinfo': task.metadata?['otherinfo'] ?? '',
      'jtoken': task.metadata?['jtoken'] ?? '',
      'enc': task.metadata?['enc'] ?? '',
      'objectid': task.metadata?['objectid'] ?? '',
      'playTime': task.metadata?['playTime'] ?? 0,
      'attDuration': task.metadata?['attDuration'] ?? 0,
      'attDurationEnc': task.metadata?['attDurationEnc'] ?? '',
      'videoFaceCaptureEnc': task.metadata?['videoFaceCaptureEnc'] ?? '',
      'rt': task.metadata?['rt'] ?? '',
      'mid': task.metadata?['mid'] ?? '',
      'aid': task.metadata?['aid'] ?? '',
    };
    
    _logger.d('转换Task到job - 原始metadata: ${task.metadata}');
    _logger.d('转换后的job: $job');
    
    return job;
  }

  /// Convert chapter info to job info format
  Map<String, dynamic> _convertChapterToJobInfo(Map<String, dynamic> chapterInfo) {
    return {
      'knowledgeid': chapterInfo['knowledgeid'],
      'ktoken': chapterInfo['ktoken'],
      'cpi': chapterInfo['cpi'],
    };
  }
}
