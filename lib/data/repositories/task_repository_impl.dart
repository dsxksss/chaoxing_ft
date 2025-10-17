import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';
import '../datasources/local/hive_datasource.dart';
import '../datasources/remote/chaoxing_api_datasource.dart';
import '../../core/session/session_manager.dart';
import '../../core/errors/error_handler.dart';

/// Task repository implementation
class TaskRepositoryImpl implements TaskRepository {

  TaskRepositoryImpl(
    this._hive,
    this._apiDataSource,
    this._sessionManager,
    this._errorHandler,
  );
  final HiveDataSource _hive;
  final ChaoxingApiDataSource _apiDataSource;
  final SessionManager _sessionManager;
  final ErrorHandler _errorHandler;

  @override
  Future<Task?> getTaskById(String taskId) async {
    try {
      if (taskId.isEmpty) {
        throw _errorHandler.createDataParsingError('Task ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching task: $taskId');

      // Check if session is valid
      if (!await _sessionManager.validateSession()) {
        throw _errorHandler.createNetworkError('Session is not valid');
      }

      // Try to get from local storage first
      final localData = _hive.getTask(taskId);
      if (localData != null) {
        final task = TaskModel.fromJson(localData);
        _errorHandler.logInfo('Task found in local storage: ${task.name}');
        return task.toEntity();
      }

      // If not found locally, fetch from API
      final taskData = await _makeGetTaskRequest(taskId);
      if (taskData != null) {
        final task = TaskModel.fromJson(taskData);
        await _hive.saveTask(taskId, taskData);
        _errorHandler.logInfo('Task fetched from API: ${task.name}');
        return task.toEntity();
      }

      _errorHandler.logWarning('Task not found: $taskId');
      return null;
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskRepositoryImpl.getTaskById');
      return null;
    }
  }

  @override
  Future<List<Task>> getTasksByCourseId(String courseId) async {
    try {
      if (courseId.isEmpty) {
        throw _errorHandler.createDataParsingError('Course ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching tasks for course: $courseId');

      // Check if session is valid
      if (!_sessionManager.isActive) {
        throw _errorHandler.createNetworkError('Session is not valid');
      }

      // Replicates chaoxing_py process_course flow:
      // 1. Get course list to find the course with courseId
      // 2. Get course points (chapters) for this course
      // 3. Get job list (tasks) for each chapter
      
      final courses = await _apiDataSource.getCourseList();
      _errorHandler.logInfo('Available courses: ${courses.map((c) => '${c['id']}:${c['courseId']}').join(', ')}');
      _errorHandler.logInfo('Looking for courseId: $courseId');
      
      final course = courses.firstWhere(
        (c) => c['courseId'] == courseId || c['id'] == courseId,
        orElse: () => throw _errorHandler.createDataParsingError('Course not found: $courseId'),
      );
      
      _errorHandler.logInfo('Found course: ${course['id']}, courseId: ${course['courseId']}, clazzId: ${course['clazzId']}, cpi: ${course['cpi']}');

      // Get course points (chapters) - replicates chaoxing_py get_course_point
      _errorHandler.logInfo('Getting course points for courseId: ${course['courseId']}, clazzId: ${course['clazzId']}, cpi: ${course['cpi']}');
      final coursePoints = await _apiDataSource.getCoursePoint(
        course['courseId'],
        course['clazzId'],
        course['cpi'],
      );

      _errorHandler.logInfo('Course points response: $coursePoints');
      
      if (!coursePoints['success']) {
        _errorHandler.logWarning('Failed to get course points for course: $courseId');
        return [];
      }

      final points = coursePoints['points'] as List<Map<String, dynamic>>;
      _errorHandler.logInfo('Found ${points.length} course points');
      final allTasks = <Task>[];

      // Get tasks for each chapter - replicates chaoxing_py process_chapter
      for (final point in points) {
        try {
          _errorHandler.logInfo('Getting job list for point: ${point['id']}, title: ${point['title']}');
          final jobList = await _apiDataSource.getJobList(
            course: course,
            point: point,
          );

          _errorHandler.logInfo('Job list response for point ${point['id']}: $jobList');
          
          final jobListData = jobList['jobList'] as List<Map<String, dynamic>>;
          final jobInfo = jobList['jobInfo'] as Map<String, dynamic>;

          _errorHandler.logInfo('Found ${jobListData.length} jobs for point ${point['id']}');

          // Convert job data to Task entities
          for (final jobData in jobListData) {
            _errorHandler.logInfo('Processing job: ${jobData['name']}, type: ${jobData['type']}');
            final task = _mapJobDataToTask(jobData, courseId, point['id'], jobInfo);
            allTasks.add(task);
            
            // Save task to local storage
            await _hive.saveTask(task.id, TaskModel.fromEntity(task).toJson());
          }
        } catch (e) {
          _errorHandler.logWarning('Failed to get tasks for chapter ${point['id']}: $e');
          continue;
        }
      }

      _errorHandler.logInfo('Retrieved ${allTasks.length} tasks for course: $courseId');
      return allTasks;
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskRepositoryImpl.getTasksByCourseId');
      return [];
    }
  }

  @override
  Future<List<Task>> getTasksByChapterId(String chapterId) async {
    try {
      if (chapterId.isEmpty) {
        throw _errorHandler.createDataParsingError('Chapter ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching tasks for chapter: $chapterId');

      // Check if session is valid
      if (!await _sessionManager.validateSession()) {
        throw _errorHandler.createNetworkError('Session is not valid');
      }

      // Make API request to get tasks
      final tasksData = await _makeGetTasksByChapterRequest(chapterId);

      final tasks = <Task>[];
      for (final taskData in tasksData) {
        final task = TaskModel.fromJson(taskData);
        tasks.add(task.toEntity());
        
        // Save task to local storage
        await _hive.saveTask(task.id, taskData);
      }

      _errorHandler.logInfo('Retrieved ${tasks.length} tasks');
      return tasks;
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskRepositoryImpl.getTasksByChapterId');
      return [];
    }
  }

  Future<List<Task>> getTasksByType(TaskType type) async {
    try {
      _errorHandler.logInfo('Fetching tasks by type: ${type.name}');

      // Check if session is valid
      if (!await _sessionManager.validateSession()) {
        throw _errorHandler.createNetworkError('Session is not valid');
      }

      // Make API request to get tasks by type
      final tasksData = await _makeGetTasksByTypeRequest(type);

      final tasks = <Task>[];
      for (final taskData in tasksData) {
        final task = TaskModel.fromJson(taskData);
        tasks.add(task.toEntity());
        
        // Save task to local storage
        await _hive.saveTask(task.id, taskData);
      }

      _errorHandler.logInfo('Retrieved ${tasks.length} tasks of type ${type.name}');
      return tasks;
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskRepositoryImpl.getTasksByType');
      return [];
    }
  }

  @override
  Future<void> updateTaskProgress(String taskId, double progress) async {
    try {
      if (taskId.isEmpty) {
        throw _errorHandler.createDataParsingError('Task ID cannot be empty');
      }

      if (progress < 0.0 || progress > 1.0) {
        throw _errorHandler.createDataParsingError('Progress must be between 0.0 and 1.0');
      }

      _errorHandler.logInfo('Updating progress for task $taskId: $progress');

      // Check if session is valid
      if (!await _sessionManager.validateSession()) {
        throw _errorHandler.createNetworkError('Session is not valid');
      }

      // Make API request to update progress
      await _makeUpdateTaskProgressRequest(taskId, progress);

      // Update local storage
      final taskData = _hive.getTask(taskId);
      if (taskData != null) {
        taskData['progress'] = progress;
        taskData['updatedAt'] = DateTime.now().toIso8601String();
        await _hive.saveTask(taskId, taskData);
      }

      _errorHandler.logInfo('Task progress updated successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskRepositoryImpl.updateTaskProgress');
      rethrow;
    }
  }

  @override
  Future<void> markTaskAsCompleted(String taskId) async {
    try {
      if (taskId.isEmpty) {
        throw _errorHandler.createDataParsingError('Task ID cannot be empty');
      }

      _errorHandler.logInfo('Marking task as completed: $taskId');

      // Check if session is valid
      if (!await _sessionManager.validateSession()) {
        throw _errorHandler.createNetworkError('Session is not valid');
      }

      // Make API request to mark task as completed
      await _makeMarkTaskCompletedRequest(taskId);

      // Update local storage
      final taskData = _hive.getTask(taskId);
      if (taskData != null) {
        taskData['isCompleted'] = true;
        taskData['progress'] = 1.0;
        taskData['updatedAt'] = DateTime.now().toIso8601String();
        await _hive.saveTask(taskId, taskData);
      }

      _errorHandler.logInfo('Task marked as completed');
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskRepositoryImpl.markTaskAsCompleted');
      rethrow;
    }
  }

  @override
  Future<void> saveTaskProgress(String taskId, double progress) async {
    try {
      if (taskId.isEmpty) {
        throw _errorHandler.createDataParsingError('Task ID cannot be empty');
      }

      _errorHandler.logInfo('Saving task progress: $taskId, progress: $progress');

      // Check if session is valid
      if (!_sessionManager.isActive) {
        throw _errorHandler.createNetworkError('Session is not valid');
      }

      // Make API request to save task progress
      await _makeSaveTaskProgressRequest(taskId, progress);

      // Update local storage
      final taskData = _hive.getTask(taskId);
      if (taskData != null) {
        taskData['progress'] = progress;
        taskData['updatedAt'] = DateTime.now().toIso8601String();
        await _hive.saveTask(taskId, taskData);
      }

      _errorHandler.logInfo('Task progress saved: $taskId');
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskRepositoryImpl.saveTaskProgress');
      rethrow;
    }
  }

  Future<void> updateTaskMetadata(String taskId, Map<String, dynamic> metadata) async {
    try {
      if (taskId.isEmpty) {
        throw _errorHandler.createDataParsingError('Task ID cannot be empty');
      }

      _errorHandler.logInfo('Updating metadata for task: $taskId');

      // Check if session is valid
      if (!await _sessionManager.validateSession()) {
        throw _errorHandler.createNetworkError('Session is not valid');
      }

      // Make API request to update metadata
      await _makeUpdateTaskMetadataRequest(taskId, metadata);

      // Update local storage
      final taskData = _hive.getTask(taskId);
      if (taskData != null) {
        taskData['metadata'] = metadata;
        taskData['updatedAt'] = DateTime.now().toIso8601String();
        await _hive.saveTask(taskId, taskData);
      }

      _errorHandler.logInfo('Task metadata updated successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskRepositoryImpl.updateTaskMetadata');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getTaskStatistics(String taskId) async {
    try {
      if (taskId.isEmpty) {
        throw _errorHandler.createDataParsingError('Task ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching statistics for task: $taskId');

      // Check if session is valid
      if (!await _sessionManager.validateSession()) {
        throw _errorHandler.createNetworkError('Session is not valid');
      }

      // Make API request to get statistics
      final statisticsData = await _makeGetTaskStatisticsRequest(taskId);

      _errorHandler.logInfo('Task statistics retrieved');
      return statisticsData;
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskRepositoryImpl.getTaskStatistics');
      return {};
    }
  }

  Future<void> saveTaskProgressToServer(String taskId, double progress) async {
    try {
      if (taskId.isEmpty) {
        throw _errorHandler.createDataParsingError('Task ID cannot be empty');
      }

      if (progress < 0.0 || progress > 1.0) {
        throw _errorHandler.createDataParsingError('Progress must be between 0.0 and 1.0');
      }

      _errorHandler.logInfo('Saving task progress to server: $taskId');

      // Check if session is valid
      if (!await _sessionManager.validateSession()) {
        throw _errorHandler.createNetworkError('Session is not valid');
      }

      // Make API request to save progress
      await _makeSaveTaskProgressRequest(taskId, progress);

      _errorHandler.logInfo('Task progress saved to server successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskRepositoryImpl.saveTaskProgressToServer');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTaskCompletionHistory(String taskId) async {
    try {
      if (taskId.isEmpty) {
        throw _errorHandler.createDataParsingError('Task ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching completion history for task: $taskId');

      // Check if session is valid
      if (!await _sessionManager.validateSession()) {
        throw _errorHandler.createNetworkError('Session is not valid');
      }

      // Make API request to get completion history
      final historyData = await _makeGetTaskCompletionHistoryRequest(taskId);

      _errorHandler.logInfo('Retrieved ${historyData.length} completion records');
      return historyData;
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskRepositoryImpl.getTaskCompletionHistory');
      return [];
    }
  }

  Future<void> addTaskCompletionRecord(String taskId, DateTime completedAt, double progress) async {
    try {
      if (taskId.isEmpty) {
        throw _errorHandler.createDataParsingError('Task ID cannot be empty');
      }

      if (progress < 0.0 || progress > 1.0) {
        throw _errorHandler.createDataParsingError('Progress must be between 0.0 and 1.0');
      }

      _errorHandler.logInfo('Adding completion record for task: $taskId');

      // Check if session is valid
      if (!await _sessionManager.validateSession()) {
        throw _errorHandler.createNetworkError('Session is not valid');
      }

      // Make API request to add completion record
      await _makeAddTaskCompletionRecordRequest(taskId, completedAt, progress);

      _errorHandler.logInfo('Task completion record added successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskRepositoryImpl.addTaskCompletionRecord');
      rethrow;
    }
  }

  Future<Task?> getTaskByUrl(String url) async {
    try {
      if (url.isEmpty) {
        throw _errorHandler.createDataParsingError('URL cannot be empty');
      }

      _errorHandler.logInfo('Fetching task by URL: $url');

      // Check if session is valid
      if (!await _sessionManager.validateSession()) {
        throw _errorHandler.createNetworkError('Session is not valid');
      }

      // Make API request to get task by URL
      final taskData = await _makeGetTaskByUrlRequest(url);
      if (taskData != null) {
        final task = TaskModel.fromJson(taskData);
        await _hive.saveTask(task.id, taskData);
        _errorHandler.logInfo('Task found by URL: ${task.name}');
        return task.toEntity();
      }

      _errorHandler.logWarning('Task not found by URL: $url');
      return null;
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskRepositoryImpl.getTaskByUrl');
      return null;
    }
  }

  Future<void> refreshTaskData(String taskId) async {
    try {
      if (taskId.isEmpty) {
        throw _errorHandler.createDataParsingError('Task ID cannot be empty');
      }

      _errorHandler.logInfo('Refreshing data for task: $taskId');

      // Check if session is valid
      if (!await _sessionManager.validateSession()) {
        throw _errorHandler.createNetworkError('Session is not valid');
      }

      // Fetch fresh data from API
      final taskData = await _makeGetTaskRequest(taskId);
      if (taskData != null) {
        await _hive.saveTask(taskId, taskData);
      }

      _errorHandler.logInfo('Task data refreshed successfully');
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskRepositoryImpl.refreshTaskData');
      rethrow;
    }
  }

  Future<void> clearTaskCache(String taskId) async {
    try {
      if (taskId.isEmpty) {
        throw _errorHandler.createDataParsingError('Task ID cannot be empty');
      }

      _errorHandler.logInfo('Clearing cache for task: $taskId');
      await _hive.clearCourseData(taskId);
      _errorHandler.logInfo('Task cache cleared');
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskRepositoryImpl.clearTaskCache');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTaskDependencies(String taskId) async {
    try {
      if (taskId.isEmpty) {
        throw _errorHandler.createDataParsingError('Task ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching dependencies for task: $taskId');

      // Check if session is valid
      if (!await _sessionManager.validateSession()) {
        throw _errorHandler.createNetworkError('Session is not valid');
      }

      // Make API request to get dependencies
      final dependenciesData = await _makeGetTaskDependenciesRequest(taskId);

      final dependencies = <Map<String, dynamic>>[];
      for (final depData in dependenciesData) {
        dependencies.add(depData);
      }

      _errorHandler.logInfo('Retrieved ${dependencies.length} dependencies');
      return dependencies;
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskRepositoryImpl.getTaskDependencies');
      return [];
    }
  }

  Future<bool> hasTaskDependencies(String taskId) async {
    try {
      final dependencies = await getTaskDependencies(taskId);
      return dependencies.isNotEmpty;
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskRepositoryImpl.hasTaskDependencies');
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTaskPrerequisites(String taskId) async {
    try {
      if (taskId.isEmpty) {
        throw _errorHandler.createDataParsingError('Task ID cannot be empty');
      }

      _errorHandler.logInfo('Fetching prerequisites for task: $taskId');

      // Check if session is valid
      if (!await _sessionManager.validateSession()) {
        throw _errorHandler.createNetworkError('Session is not valid');
      }

      // Make API request to get prerequisites
      final prerequisitesData = await _makeGetTaskPrerequisitesRequest(taskId);

      final prerequisites = <Map<String, dynamic>>[];
      for (final prereqData in prerequisitesData) {
        prerequisites.add(prereqData);
      }

      _errorHandler.logInfo('Retrieved ${prerequisites.length} prerequisites');
      return prerequisites;
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskRepositoryImpl.getTaskPrerequisites');
      return [];
    }
  }

  Future<bool> areTaskPrerequisitesMet(String taskId) async {
    try {
      final prerequisites = await getTaskPrerequisites(taskId);
      
      for (final prereq in prerequisites) {
        if (prereq['isCompleted'] != true) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      _errorHandler.handleError(e, context: 'TaskRepositoryImpl.areTaskPrerequisitesMet');
      return false;
    }
  }

  // Placeholder API methods (to be implemented with actual chaoxing_py logic)
  Future<Map<String, dynamic>?> _makeGetTaskRequest(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'id': taskId,
      'name': 'Test Task $taskId',
      'type': 'video',
      'description': 'This is a test task',
      'courseId': 'course_1',
      'chapterId': 'chapter_1',
      'url': 'https://example.com/task/$taskId',
      'duration': 3600, // seconds
      'isCompleted': false,
      'progress': 0.0,
      'metadata': {},
      'createdAt': '2023-10-01T00:00:00Z',
      'updatedAt': '2023-10-01T00:00:00Z',
    };
  }


  Future<List<Map<String, dynamic>>> _makeGetTasksByChapterRequest(String chapterId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'id': 'task_1',
        'name': 'Task 1',
        'type': 'video',
        'description': 'This is task 1',
        'courseId': 'course_1',
        'chapterId': chapterId,
        'url': 'https://example.com/task/1',
        'duration': 3600,
        'isCompleted': false,
        'progress': 0.0,
        'metadata': {},
        'createdAt': '2023-10-01T00:00:00Z',
        'updatedAt': '2023-10-01T00:00:00Z',
      },
    ];
  }

  Future<List<Map<String, dynamic>>> _makeGetTasksByTypeRequest(TaskType type) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'id': 'task_1',
        'name': 'Task 1',
        'type': type.name,
        'description': 'This is a ${type.name} task',
        'courseId': 'course_1',
        'chapterId': 'chapter_1',
        'url': 'https://example.com/task/1',
        'duration': 3600,
        'isCompleted': false,
        'progress': 0.0,
        'metadata': {},
        'createdAt': '2023-10-01T00:00:00Z',
        'updatedAt': '2023-10-01T00:00:00Z',
      },
    ];
  }

  Future<void> _makeUpdateTaskProgressRequest(String taskId, double progress) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _makeMarkTaskCompletedRequest(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _makeUpdateTaskMetadataRequest(String taskId, Map<String, dynamic> metadata) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<Map<String, dynamic>> _makeGetTaskStatisticsRequest(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'totalViews': 10,
      'totalTime': 3600,
      'completionRate': 0.8,
      'lastAccessed': '2023-10-01T00:00:00Z',
    };
  }

  Future<void> _makeSaveTaskProgressRequest(String taskId, double progress) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<List<Map<String, dynamic>>> _makeGetTaskCompletionHistoryRequest(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {
        'id': 'completion_1',
        'taskId': taskId,
        'completedAt': '2023-10-01T00:00:00Z',
        'progress': 1.0,
      },
    ];
  }

  Future<void> _makeAddTaskCompletionRecordRequest(String taskId, DateTime completedAt, double progress) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<Map<String, dynamic>?> _makeGetTaskByUrlRequest(String url) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'id': 'task_by_url',
      'name': 'Task by URL',
      'type': 'video',
      'description': 'This is a task found by URL',
      'courseId': 'course_1',
      'chapterId': 'chapter_1',
      'url': url,
      'duration': 3600,
      'isCompleted': false,
      'progress': 0.0,
      'metadata': {},
      'createdAt': '2023-10-01T00:00:00Z',
      'updatedAt': '2023-10-01T00:00:00Z',
    };
  }

  Future<List<Map<String, dynamic>>> _makeGetTaskDependenciesRequest(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  Future<List<Map<String, dynamic>>> _makeGetTaskPrerequisitesRequest(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  /// Map job data to Task entity
  /// Replicates chaoxing_py job processing logic
  Task _mapJobDataToTask(
    Map<String, dynamic> jobData,
    String courseId,
    String chapterId,
    Map<String, dynamic> jobInfo,
  ) {
    // Map job type to TaskType
    TaskType taskType;
    switch (jobData['type']?.toString().toLowerCase()) {
      case 'video':
        taskType = TaskType.video;
        break;
      case 'document':
        taskType = TaskType.document;
        break;
      case 'workid':
        taskType = TaskType.quiz;
        break;
      case 'read':
        taskType = TaskType.reading;
        break;
      default:
        taskType = TaskType.reading; // Default to reading
    }

    return Task(
      id: jobData['jobid']?.toString() ?? '',
      name: jobData['name']?.toString() ?? '未知任务',
      type: taskType,
      description: jobData['desc']?.toString() ?? '',
      courseId: courseId,
      chapterId: chapterId,
      url: jobData['url']?.toString() ?? '',
      duration: _parseDuration(jobData['duration']),
      isCompleted: jobData['isPassed'] == true,
      progress: jobData['progress']?.toDouble() ?? 0.0,
      metadata: {
        'otherinfo': jobData['otherinfo']?.toString() ?? '',
        'jtoken': jobData['jtoken']?.toString() ?? '',
        'enc': jobData['enc']?.toString() ?? '',
        'objectid': jobData['objectid']?.toString() ?? '',
        'playTime': jobData['playTime']?.toString() ?? '0',
        'attDuration': jobData['attDuration']?.toString() ?? '0',
        'attDurationEnc': jobData['attDurationEnc']?.toString() ?? '',
        'videoFaceCaptureEnc': jobData['videoFaceCaptureEnc']?.toString() ?? '',
        'rt': jobData['rt']?.toString() ?? '',
        'mid': jobData['mid']?.toString() ?? '',
        'aid': jobData['aid']?.toString() ?? '',
        ...jobInfo,
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Parse duration from various formats
  Duration _parseDuration(dynamic duration) {
    if (duration == null) return const Duration(minutes: 0);
    
    if (duration is int) {
      return Duration(seconds: duration);
    } else if (duration is double) {
      return Duration(milliseconds: (duration * 1000).round());
    } else if (duration is String) {
      final seconds = int.tryParse(duration);
      if (seconds != null) {
        return Duration(seconds: seconds);
      }
    }
    
    return const Duration(minutes: 0);
  }
}
