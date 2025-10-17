import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../core/session/session_manager.dart';
import '../../core/network/rate_limiter.dart';
import '../../core/errors/study_result.dart';

/// Video learning service - handles video task completion
/// Replicates chaoxing_py video learning logic
class VideoLearningService {
  VideoLearningService(
    this._sessionManager,
    this._logger,
  ) {
    _rateLimiter = RateLimiter(const Duration(milliseconds: 400));
    // 增加限流时间到3秒，降低被识别的风险
    _videoLogLimiter = RateLimiter(const Duration(seconds: 3));
  }

  final SessionManager _sessionManager;
  final Logger _logger;
  late final RateLimiter _rateLimiter;
  late final RateLimiter _videoLogLimiter;

  /// Get MD5 encryption for video progress
  /// Replicates chaoxing_py get_enc method
  String getEnc(
    String clazzId,
    String jobid,
    String objectId,
    int playingTime,
    int duration,
    String userid,
  ) {
    final input = '[$clazzId][$userid][$jobid][$objectId]'
        '[${playingTime * 1000}][d_yHJ!\$pdA~5]'
        '[${duration * 1000}][0_$duration]';
    return md5.convert(utf8.encode(input)).toString();
  }

  /// Upload video progress log
  /// Replicates chaoxing_py video_progress_log method
  Future<Map<String, dynamic>> videoProgressLog({
    required Map<String, dynamic> course,
    required Map<String, dynamic> job,
    required Map<String, dynamic> jobInfo,
    required String dtoken,
    required int duration,
    required int playingTime,
    String type = 'Video',
    Map<String, String>? headers,
  }) async {
    await _videoLogLimiter.limitRate(
      randomTime: true,
      randomMax: 2.0,
    );

    final uid = _sessionManager.getUid();
    if (uid == null) {
      _logger.e('无法获取UID,Session可能已失效');
      return {'isPassed': false, 'statusCode': 401};
    }

    final enc = getEnc(
      course['clazzId'],
      job['jobid'],
      job['objectid'],
      playingTime,
      duration,
      uid,
    );

    // 根据浏览器实际行为：当视频完成时 isdrag=4，播放中时 isdrag=3
    final isdrag = (playingTime >= duration) ? '4' : '3';
    
    final params = {
      'clazzId': course['clazzId'].toString(),
      'playingTime': playingTime.toString(),
      'duration': duration.toString(),
      'clipTime': '0_$duration',
      'objectId': job['objectid'],
      'otherInfo': job['otherinfo'],
      'courseId': course['courseId'].toString(),
      'jobid': job['jobid'].toString(),
      'userid': uid.toString(),
      'isdrag': isdrag,
      'view': 'pc',
      'enc': enc,
      'dtype': type,
    };

    // Add optional parameters - exactly as Python version
    final faceCaptureEnc = job['videoFaceCaptureEnc'];
    final attDuration = job['attDuration'];
    final attDurationEnc = job['attDurationEnc'];

    if (faceCaptureEnc != null && faceCaptureEnc.toString().isNotEmpty) {
      params['videoFaceCaptureEnc'] = faceCaptureEnc.toString();
    }
    if (attDuration != null && attDuration.toString().isNotEmpty) {
      params['attDuration'] = attDuration.toString();
    }
    if (attDurationEnc != null && attDurationEnc.toString().isNotEmpty) {
      params['attDurationEnc'] = attDurationEnc.toString();
    }

    // Handle rt parameter - exactly as Python version
    var rt = job['rt'];
    if (rt == null || rt.toString().isEmpty) {
      final rtSearch = RegExp(r'-rt_([1d])').firstMatch(job['otherinfo'] ?? '');
      if (rtSearch != null) {
        final rtChar = rtSearch.group(1);
        rt = rtChar == 'd' ? '0.9' : '1';
        _logger.d('Got rt from otherinfo: $rt');
      }
    }

    // Python版本中:requests.Session会自动合并全局headers和方法参数headers
    // 这里需要手动合并,确保包含所有必要的浏览器特征头
    final requestHeaders = {
      'Referer': headers?['Referer'] ?? 
        (type == 'Video' 
          ? 'https://mooc1.chaoxing.com/ananas/modules/video/index.html?v=2025-0725-1842'
          : 'https://mooc1.chaoxing.com/ananas/modules/audio/index_new.html?v=2025-0725-1842'),
      // 完全按照浏览器的请求头，包括Content-Type
      'Connection': 'keep-alive',
      'Content-Type': 'application/json',
    };
    // 不添加Origin,完全按照Python版本
    
    final url = 'https://mooc1.chaoxing.com/mooc-ans/multimedia/log/a/'
        '${course['cpi']}/$dtoken';
    
    // 确保Cookie在请求前是最新的
    _sessionManager.updateCookies({});
    
    _logger.d('准备发送进度上报请求...');
    _logger.d('URL: $url');
    _logger.d('Params: $params');
    _logger.d('Headers: $requestHeaders');
    // 打印当前完整的Cookie状态
    final currentCookie = _sessionManager.dio.options.headers['Cookie'];
    _logger.d('当前Cookie: $currentCookie');
    
    // 检查关键Cookie字段
    final allCookies = _sessionManager.getAllCookies();
    final criticalCookies = ['_uid', 'UID', 'fid', 'jrose', 'JSESSIONID'];
    for (final key in criticalCookies) {
      if (allCookies.containsKey(key)) {
        _logger.d('✓ Cookie[$key] = ${allCookies[key]}');
      } else {
        _logger.w('✗ Cookie[$key] 缺失');
      }
    }

    Response? response;

    // 完全复制Python版本的逻辑
    if (rt != null && rt.toString().isNotEmpty) {
      _logger.d('Got rt: $rt');
      params['rt'] = rt.toString();
      params['_t'] = _sessionManager.getTimestamp();

      try {
        response = await _sessionManager.dio.get(
          url,
          queryParameters: params,
          options: Options(
            headers: requestHeaders,
            validateStatus: (status) => status != null && status < 500,
            // 确保不删除默认headers
            extra: {'merge_headers': true},
          ),
        );
        
        _logger.d('请求完成 - statusCode: ${response.statusCode}');
      } catch (e) {
        _logger.e('Request failed with rt=$rt: $e');
        return {'isPassed': false, 'statusCode': 0};
      }
    } else {
      // 完全复制Python版本：尝试0.9和1.0
      _logger.w('Failed to get rt');
      
      for (final tryRt in [0.9, 1.0]) {
        params['rt'] = tryRt.toString();
        params['_t'] = _sessionManager.getTimestamp();

        try {
          response = await _sessionManager.dio.get(
            url,
            queryParameters: params,
            options: Options(
              headers: requestHeaders,
              validateStatus: (status) => status != null && status < 500,
              // 确保不删除默认headers
              extra: {'merge_headers': true},
            ),
          );

          if (response.statusCode == 200) {
            _logger.d(response.data.toString());
            final data = response.data as Map<String, dynamic>;
            return {
              'isPassed': data['isPassed'] ?? false,
              'statusCode': 200,
            };
          } else if (response.statusCode == 403) {
            _logger.w('出现403报错, 正常尝试切换rt');
          } else {
            _logger.w(
              '未知错误 jobid=${job['jobid']}, status_code=${response.statusCode}',
            );
            break;
          }
        } catch (e) {
          _logger.e('Request failed with rt=$tryRt: $e');
          continue;
        }
      }
    }

    // 处理最终响应 - exactly as Python version
    if (response == null) {
      return {'isPassed': false, 'statusCode': 0};
    }

    if (response.statusCode == 200) {
      _logger.d(response.data.toString());
      final data = response.data as Map<String, dynamic>;
      return {
        'isPassed': data['isPassed'] ?? false,
        'statusCode': 200,
      };
    } else if (response.statusCode == 403) {
      _logger.e(
        '视频进度上报返回403, jobid=${job['jobid']}, '
        '摘要=${response.data.toString().substring(0, min(200, response.data.toString().length))}',
      );

      // Python版本中: 若出现两个rt参数都返回403的情况, 则跳过当前任务
      _logger.e('出现403报错, 尝试修复无效, 正在跳过当前任务点...');
      _logger.e('请求url: ${response.requestOptions.uri}');
      final headersToLog = {..._sessionManager.dio.options.headers, ...requestHeaders};
      _logger.e('请求头: $headersToLog');
      
      // 打印当前cookie状态，检查是否包含jrose
      final cookieHeader = _sessionManager.dio.options.headers['Cookie'];
      _logger.e('当前Cookie头: $cookieHeader');
      
      return {'isPassed': false, 'statusCode': 403};
    }

    _logger.e('未知错误: ${response.statusCode}');
    _logger.e('请求url: ${response.requestOptions.uri}');
    final headersToLog = {..._sessionManager.dio.options.headers, ...requestHeaders};
    _logger.e('请求头: $headersToLog');
    
    // 打印当前cookie状态
    final cookieHeader = _sessionManager.dio.options.headers['Cookie'];
    _logger.e('当前Cookie头: $cookieHeader');
    
    return {'isPassed': false, 'statusCode': response.statusCode};
  }

  /// Refresh video status
  /// Replicates chaoxing_py _refresh_video_status method
  Future<Map<String, dynamic>?> refreshVideoStatus(
    Map<String, dynamic> job,
    String type,
  ) async {
    await _rateLimiter.limitRate(randomTime: true, randomMax: 0.2);

    final headers = type == 'Video'
        ? {'Referer': 'https://mooc1.chaoxing.com/ananas/modules/video/index.html?v=2025-0725-1842'}
        : {'Referer': 'https://mooc1.chaoxing.com/ananas/modules/audio/index_new.html?v=2025-0725-1842'};

    final fid = _sessionManager.getFid();
    final infoUrl = 'https://mooc1.chaoxing.com/ananas/status/${job['objectid']}'
        '?k=$fid&flag=normal';

    try {
      final response = await _sessionManager.dio.get(
        infoUrl,
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      if (response.statusCode != 200) {
        _logger.d('Refresh video status returned: ${response.statusCode}');
        return null;
      }

      final data = response.data as Map<String, dynamic>;
      if (data['status'] == 'success') {
        return data;
      }

      return null;
    } catch (e) {
      _logger.d('Failed to refresh video status: $e');
      return null;
    }
  }

  /// Recover after 403 forbidden error
  /// Replicates chaoxing_py _recover_after_forbidden method
  Future<Map<String, dynamic>?> recoverAfterForbidden(
    Map<String, dynamic> job,
    String type,
  ) async {
    _logger.i('尝试从403错误中恢复...');
    
    // Python版本中SessionManager.update_cookies()是从文件重新读取
    // Dart版本中,cookies通过拦截器自动更新,不需要重新加载
    
    // 直接刷新视频状态,获取新的dtoken
    final refreshed = await refreshVideoStatus(job, type);
    if (refreshed != null) {
      _logger.i('视频状态刷新成功');
      return refreshed;
    }

    _logger.w('视频状态刷新失败');
    return null;
  }

  /// Study video task
  /// Replicates chaoxing_py study_video method
  Future<StudyResult> studyVideo({
    required Map<String, dynamic> course,
    required Map<String, dynamic> job,
    required Map<String, dynamic> jobInfo,
    double speed = 1.0,
    String type = 'Video',
    Function(String taskName, double progress)? onProgress,
  }) async {
    final headers = type == 'Video'
        ? {'Referer': 'https://mooc1.chaoxing.com/ananas/modules/video/index.html?v=2025-0725-1842'}
        : {'Referer': 'https://mooc1.chaoxing.com/ananas/modules/audio/index_new.html?v=2025-0725-1842'};

    // 从cookies中获取fid，与Python版本一致
    final fid = _sessionManager.getFid();
    if (fid == null || fid.isEmpty) {
      _logger.e('无法获取FID，任务执行失败');
      return StudyResult.error;
    }
    
    // 验证uid是否存在
    final uid = _sessionManager.getUid();
    if (uid == null || uid.isEmpty) {
      _logger.e('无法获取UID，Session可能已失效');
      return StudyResult.error;
    }
    
    _logger.d('当前Session - FID: $fid, UID: $uid');
    
    final infoUrl = 'https://mooc1.chaoxing.com/ananas/status/${job['objectid']}'
        '?k=$fid&flag=normal';

    _logger.d('获取视频状态 - URL: $infoUrl');
    _logger.d('获取视频状态 - fid: $fid');
    _logger.d('获取视频状态 - objectid: ${job['objectid']}');

    try {
      final infoResponse = await _sessionManager.dio.get(
        infoUrl,
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      _logger.d('视频状态响应 - Status: ${infoResponse.statusCode}');
      _logger.d('视频状态响应 - Data: ${infoResponse.data}');

      if (infoResponse.statusCode != 200) {
        _logger.e('视频状态获取失败: ${infoResponse.statusCode}');
        return StudyResult.error;
      }

      final videoInfo = infoResponse.data as Map<String, dynamic>;

      if (videoInfo['status'] != 'success') {
        _logger.e('视频状态获取失败: ${videoInfo['status']}');
        _logger.e('完整响应: $videoInfo');
        return StudyResult.error;
      }

      var dtoken = videoInfo['dtoken'];
      final duration = int.parse(videoInfo['duration'].toString());
      // Python版本：play_time = int(_job["playTime"]) // 1000
      var playTime = int.parse(job['playTime'].toString()) ~/ 1000;
      var lastLogTime = 0;
      var lastIter = DateTime.now().millisecondsSinceEpoch / 1000.0;
      var waitTime = Random().nextDouble() * 60 + 30; // 30-90秒随机

      _logger.i('开始任务: ${job['name']}, 总时长: ${duration}s, 已进行: ${playTime}s');

      var passed = false;
      var forbiddenRetry = 0;
      const maxForbiddenRetry = 2;

      // Python版本：尝试瞬间完成，但如果触发403就放弃
      // 由于瞬间完成可能触发反爬机制，我们直接跳过，使用渐进式完成
      _logger.d('跳过瞬间完成尝试，直接使用渐进式完成');
      
      // 如果想尝试瞬间完成，取消注释以下代码：
      /*
      var result = await videoProgressLog(
        course: course,
        job: job,
        jobInfo: jobInfo,
        dtoken: dtoken,
        duration: duration,
        playingTime: 0,
        type: type,
        headers: headers,
      );
      
      result = await videoProgressLog(
        course: course,
        job: job,
        jobInfo: jobInfo,
        dtoken: dtoken,
        duration: duration,
        playingTime: duration,
        type: type,
        headers: headers,
      );
      passed = result['isPassed'] ?? false;

      if (passed) {
        _logger.i('任务瞬间完成: ${job['name']}');
        return StudyResult.success;
      }
      */

      // Progressive completion - exactly like Python version
      while (!passed) {
        // Sometimes the last request needs to be sent several times to complete the task
        // Python: if play_time - last_log_time >= wait_time or play_time == duration:
        _logger.d('循环检查 - playTime: $playTime, lastLogTime: $lastLogTime, waitTime: $waitTime, duration: $duration');
        
        if (playTime - lastLogTime >= waitTime || playTime == duration) {
          _logger.i('准备上报进度 - 当前: ${playTime}s / ${duration}s');
          
          final result = await videoProgressLog(
            course: course,
            job: job,
            jobInfo: jobInfo,
            dtoken: dtoken,
            duration: duration,
            playingTime: playTime, // playTime现在是int类型
            type: type,
            headers: headers,
          );

          final statusCode = result['statusCode'] as int;
          passed = result['isPassed'] as bool;
          
          _logger.i('上报结果 - statusCode: $statusCode, isPassed: $passed');

          if (statusCode == 403) {
            if (forbiddenRetry >= maxForbiddenRetry) {
              _logger.w('403重试失败, 跳过当前任务');
              return StudyResult.forbidden;
            }
            forbiddenRetry++;
            _logger.w(
              '出现403报错, 正在尝试刷新会话状态 (第$forbiddenRetry次)',
            );
            
            // Python: time.sleep(random.uniform(2, 4))
            // 增加等待时间到5-10秒，给服务器更多缓冲时间
            final delayMs = (Random().nextDouble() * 5000 + 5000).toInt();
            _logger.d('等待 ${delayMs}ms 后重试...');
            await Future.delayed(Duration(milliseconds: delayMs));
            
            // Python: refreshed_meta = self._recover_after_forbidden(_session, _job, _type)
            final refreshedMeta = await recoverAfterForbidden(job, type);
            if (refreshedMeta != null) {
              // FIXME: Maybe it should be considered an error if those keys aren't present
              dtoken = refreshedMeta['dtoken'] ?? dtoken;
              final refreshedDuration = refreshedMeta['duration'];
              final refreshedPlayTime = refreshedMeta['playTime'];
              
              if (refreshedDuration != null) {
                // _duration = refreshedMeta.get("duration", duration)
              }
              if (refreshedPlayTime != null) {
                // Python: play_time = refreshed_meta.get("playTime", play_time)
                // refreshedPlayTime是毫秒值，需要转换为秒
                playTime = int.parse(refreshedPlayTime.toString()) ~/ 1000;
              }
              
              _logger.d('Refreshed token: $dtoken, duration: $duration, play time: $playTime');
              
              // 重置waitTime，确保下次上报有足够的间隔
              waitTime = Random().nextDouble() * 60 + 60; // 60-120秒，增加间隔
              lastLogTime = playTime; // 重置上次上报时间
              _logger.d('重置waitTime为: $waitTime 秒');
              
              continue;
            }
          } else if (!passed && statusCode != 200) {
            return StudyResult.error;
          }

          // Python: wait_time = int(random.uniform(30, 90))
          waitTime = Random().nextDouble() * 60 + 30;
          lastLogTime = playTime;
        }

        // Python: dt = (time.time() - last_iter) * _speed
        // Since uploading the progress takes time, we assume that the video is still playing in the background
        final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
        final dt = (currentTime - lastIter) * speed;
        lastIter = currentTime;
        // Python: play_time = min(duration, play_time+dt)
        playTime = min(duration, playTime + dt.toInt());
        
        // 💡 更新playTime后，实时更新UI进度条（每秒更新）
        if (onProgress != null) {
          final currentProgress = duration > 0 ? playTime / duration : 0.0;
          onProgress(job['name'] ?? 'Unknown Video', currentProgress);
        }

        // Python: time.sleep(gc.THRESHOLD) - THRESHOLD = 1 second
        await Future.delayed(const Duration(seconds: 1));
      }

      _logger.i('任务完成: ${job['name']}');
      return StudyResult.success;
    } catch (e) {
      _logger.e('视频任务执行异常: $e');
      return StudyResult.error;
    }
  }
}
