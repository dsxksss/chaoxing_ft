import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

/// API decoder for parsing Chaoxing responses
/// Replicates chaoxing_py decode.py functionality
class ApiDecoder {
  static final Logger _logger = Logger();

  /// Decode course list from HTML response
  /// Replicates decode_course_list from chaoxing_py
  static List<Map<String, dynamic>> decodeCourseList(String htmlText) {
    _logger.d('Decoding course list...');
    
    final document = html_parser.parse(htmlText);
    final rawCourses = document.querySelectorAll('div.course');
    final courseList = <Map<String, dynamic>>[];

    for (final course in rawCourses) {
      // Skip courses that are not open
      if (course.querySelector('a.not-open-tip') != null ||
          course.querySelector('div.not-open-tip') != null) {
        continue;
      }

      final clazzIdInput = course.querySelector('input.clazzId');
      final courseIdInput = course.querySelector('input.courseId');
      final courseLink = course.querySelector('a');
      final courseName = course.querySelector('span.course-name');
      final courseDesc = course.querySelector('p.margint10');
      final teacher = course.querySelector('p.color3');

      if (clazzIdInput == null || courseIdInput == null || courseLink == null) {
        continue;
      }

      final href = courseLink.attributes['href'] ?? '';
      final cpiMatch = RegExp(r'cpi=(.*?)&').firstMatch(href);

      courseList.add({
        'id': course.attributes['id'] ?? '',
        'info': course.attributes['info'] ?? '',
        'roleid': course.attributes['roleid'] ?? '',
        'clazzId': clazzIdInput.attributes['value'] ?? '',
        'courseId': courseIdInput.attributes['value'] ?? '',
        'cpi': cpiMatch?.group(1) ?? '',
        'title': courseName?.attributes['title'] ?? '',
        'desc': courseDesc?.attributes['title'] ?? '',
        'teacher': teacher?.attributes['title'] ?? '',
      });
    }

    _logger.d('Decoded ${courseList.length} courses');
    return courseList;
  }

  /// Decode course folder list
  /// Replicates decode_course_folder from chaoxing_py
  static List<Map<String, dynamic>> decodeCourseFolder(String htmlText) {
    _logger.d('Decoding course folder...');
    
    final document = html_parser.parse(htmlText);
    final rawFolders = document.querySelectorAll('ul.file-list>li');
    final folderList = <Map<String, dynamic>>[];

    for (final folder in rawFolders) {
      final fileId = folder.attributes['fileid'];
      if (fileId == null) continue;

      final renameInput = folder.querySelector('input.rename-input');
      
      folderList.add({
        'id': fileId,
        'rename': renameInput?.attributes['value'] ?? '',
      });
    }

    _logger.d('Decoded ${folderList.length} folders');
    return folderList;
  }

  /// Decode course points (chapters)
  /// Replicates decode_course_point from chaoxing_py
  static Map<String, dynamic> decodeCoursePoint(String htmlText) {
    _logger.d('Decoding course points...');
    
    final document = html_parser.parse(htmlText);
    final coursePoint = {
      'hasLocked': false,
      'points': <Map<String, dynamic>>[],
    };

    final chapterUnits = document.querySelectorAll('div.chapter_unit');
    
    for (final chapterUnit in chapterUnits) {
      final points = _extractPointsFromChapter(chapterUnit);
      
      // Check if any points need unlock
      for (final point in points) {
        if (point['need_unlock'] == true) {
          coursePoint['hasLocked'] = true;
        }
      }
      
      (coursePoint['points'] as List).addAll(points);
    }

    _logger.d('Decoded ${(coursePoint['points'] as List).length} points');
    return coursePoint;
  }

  /// Extract points from chapter unit
  static List<Map<String, dynamic>> _extractPointsFromChapter(Element chapterUnit) {
    final pointList = <Map<String, dynamic>>[];
    final rawPoints = chapterUnit.querySelectorAll('li');

    for (final rawPoint in rawPoints) {
      final point = rawPoint.querySelector('div');
      if (point == null || point.attributes['id'] == null) continue;

      final pointId = point.attributes['id'] ?? '';
      final match = RegExp(r'^cur(\d{1,20})$').firstMatch(pointId);
      if (match == null) continue;

      final id = match.group(1) ?? '';
      final titleElement = point.querySelector('a.clicktitle');
      final title = titleElement?.text.replaceAll('\n', '').trim() ?? '';

      // Extract job count
      var jobCount = '1';
      var needUnlock = false;
      final jobCountInput = point.querySelector('input.knowledgeJobCount');
      final hoverTips = point.querySelector('span.bntHoverTips');

      if (jobCountInput != null) {
        jobCount = jobCountInput.attributes['value'] ?? '1';
      } else if (hoverTips != null && hoverTips.text.contains('解锁')) {
        needUnlock = true;
      }

      // Check if finished
      var isFinished = false;
      if (hoverTips != null && hoverTips.text.contains('已完成')) {
        isFinished = true;
      }

      pointList.add({
        'id': id,
        'title': title,
        'jobCount': jobCount,
        'has_finished': isFinished,
        'need_unlock': needUnlock,
      });
    }

    return pointList;
  }

  /// Decode course cards (tasks)
  /// Replicates decode_course_card from chaoxing_py
  static Map<String, dynamic> decodeCourseCard(String htmlText) {
    _logger.d('Decoding course cards...');
    
    // Check if chapter is not open
    if (htmlText.contains('章节未开放')) {
      return {
        'jobList': <Map<String, dynamic>>[],
        'jobInfo': {'notOpen': true},
      };
    }

    // Extract mArg parameter
    final mArgMatch = RegExp(r'mArg=\{(.*?)\};').firstMatch(htmlText.replaceAll(' ', ''));
    if (mArgMatch == null) {
      return {
        'jobList': <Map<String, dynamic>>[],
        'jobInfo': <String, dynamic>{},
      };
    }

    try {
      final cardsData = jsonDecode('{${mArgMatch.group(1)}}');
      
      // Extract job info
      final jobInfo = _extractJobInfo(cardsData);
      
      // Process attachments
      final cards = cardsData['attachments'] ?? [];
      final jobList = _processAttachmentCards(List<Map<String, dynamic>>.from(cards));

      return {
        'jobList': jobList,
        'jobInfo': jobInfo,
      };
    } catch (e) {
      _logger.e('Error decoding course card: $e');
      return {
        'jobList': <Map<String, dynamic>>[],
        'jobInfo': <String, dynamic>{},
      };
    }
  }

  /// Extract job info from cards data
  static Map<String, dynamic> _extractJobInfo(Map<String, dynamic> cardsData) {
    final defaults = cardsData['defaults'] ?? {};
    
    return {
      'ktoken': defaults['ktoken'] ?? '',
      'mtEnc': defaults['mtEnc'] ?? '',
      'reportTimeInterval': defaults['reportTimeInterval'] ?? 60,
      'defenc': defaults['defenc'] ?? '',
      'cardid': defaults['cardid'] ?? '',
      'cpi': defaults['cpi'] ?? '',
      'qnenc': defaults['qnenc'] ?? '',
      'knowledgeid': defaults['knowledgeid'] ?? '',
    };
  }

  /// Process attachment cards
  static List<Map<String, dynamic>> _processAttachmentCards(List<Map<String, dynamic>> cards) {
    final jobList = <Map<String, dynamic>>[];

    for (final card in cards) {
      // Skip passed tasks
      if (card['isPassed'] == true) continue;

      // Fix otherInfo
      if (card.containsKey('otherInfo')) {
        card['otherInfo'] = (card['otherInfo'] as String).split('&')[0];
      }

      // Process by card type
      final cardType = card['type'] ?? '';
      
      if (card['job'] == null) {
        // Read task
        final readJob = _processReadTask(card);
        if (readJob != null) jobList.add(readJob);
        continue;
      }

      switch (cardType) {
        case 'video':
          final videoJob = _processVideoTask(card);
          if (videoJob != null) jobList.add(videoJob);
          break;
        case 'document':
          final docJob = _processDocumentTask(card);
          jobList.add(docJob);
          break;
        case 'workid':
          final workJob = _processWorkTask(card);
          jobList.add(workJob);
          break;
        default:
          _logger.w('Unknown card type: $cardType');
      }
    }

    return jobList;
  }

  /// Process read task
  static Map<String, dynamic>? _processReadTask(Map<String, dynamic> card) {
    if (card['type'] != 'read') return null;
    
    final property = card['property'] ?? {};
    if (property['read'] == true) return null;

    return {
      'title': property['title'] ?? '',
      'type': 'read',
      'id': property['id'] ?? '',
      'jobid': card['jobid'] ?? '',
      'jtoken': card['jtoken'] ?? '',
      'mid': card['mid'] ?? '',
      'otherinfo': card['otherInfo'] ?? '',
      'enc': card['enc'] ?? '',
      'aid': card['aid'] ?? '',
    };
  }

  /// Process video task
  static Map<String, dynamic>? _processVideoTask(Map<String, dynamic> card) {
    try {
      final property = card['property'] ?? {};
      
      return {
        'type': 'video',
        'jobid': card['jobid'] ?? '',
        'name': property['name'] ?? '',
        'otherinfo': card['otherInfo'] ?? '',
        'mid': card['mid'],
        'objectid': card['objectId'] ?? '',
        'aid': card['aid'] ?? '',
        'playTime': card['playTime'] ?? 0,
        'rt': property['rt'] ?? '',
        'attDuration': card['attDuration'] ?? '',
        'attDurationEnc': card['attDurationEnc'] ?? '',
        'videoFaceCaptureEnc': card['videoFaceCaptureEnc'] ?? '',
      };
    } catch (e) {
      _logger.w('Failed to process video task: $e');
      return null;
    }
  }

  /// Process document task
  static Map<String, dynamic> _processDocumentTask(Map<String, dynamic> card) {
    final property = card['property'] ?? {};
    
    return {
      'type': 'document',
      'jobid': card['jobid'] ?? '',
      'otherinfo': card['otherInfo'] ?? '',
      'jtoken': card['jtoken'] ?? '',
      'mid': card['mid'] ?? '',
      'enc': card['enc'] ?? '',
      'aid': card['aid'] ?? '',
      'objectid': property['objectid'] ?? '',
    };
  }

  /// Process work (quiz) task
  static Map<String, dynamic> _processWorkTask(Map<String, dynamic> card) {
    return {
      'type': 'workid',
      'jobid': card['jobid'] ?? '',
      'otherinfo': card['otherInfo'] ?? '',
      'mid': card['mid'] ?? '',
      'enc': card['enc'] ?? '',
      'aid': card['aid'] ?? '',
    };
  }
}
