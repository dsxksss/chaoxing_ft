import 'dart:convert';
import 'package:logger/logger.dart';

/// Fixed HTML parser that strictly replicates chaoxing_py logic
class ChaoxingHtmlParserFixed {
  static final ChaoxingHtmlParserFixed _instance = ChaoxingHtmlParserFixed._internal();
  factory ChaoxingHtmlParserFixed() => _instance;
  ChaoxingHtmlParserFixed._internal();

  static ChaoxingHtmlParserFixed get instance => _instance;
  final Logger _logger = Logger();

  /// Parse job list (task cards) from HTML response
  /// Strictly replicates chaoxing_py decode_course_card function
  Map<String, dynamic> parseJobList(String htmlText) {
    _logger.d('开始解析任务点列表...');
    
    try {
      // Debug: Log HTML content preview
      _logger.d('任务页面HTML预览: ${htmlText.substring(0, htmlText.length > 1000 ? 1000 : htmlText.length)}...');
      
      // Check if chapter is not open - exactly like chaoxing_py
      if (htmlText.contains('章节未开放')) {
        _logger.d('检测到章节未开放');
        return {
          'jobList': <Map<String, dynamic>>[],
          'jobInfo': {'notOpen': true},
        };
      }

      // Exactly replicate chaoxing_py: temp = re.findall(r"mArg=\{(.*?)\};", html_text.replace(" ", ""))
      final cleanedHtml = htmlText.replaceAll(' ', '');
      final mArgMatches = RegExp(r'mArg=\{(.*?)\};').allMatches(cleanedHtml);
      
      if (mArgMatches.isEmpty) {
        _logger.w('未找到mArg参数');
        return {
          'jobList': <Map<String, dynamic>>[],
          'jobInfo': <String, dynamic>{},
        };
      }

      // Parse JSON data - exactly like chaoxing_py: cards_data = json.loads("{" + temp[0] + "}")
      final mArgContent = mArgMatches.first.group(1)!;
      _logger.d('找到mArg: ${mArgContent.substring(0, mArgContent.length > 200 ? 200 : mArgContent.length)}...');
      
      final cardsData = jsonDecode('{' + mArgContent + '}') as Map<String, dynamic>;
      
      if (cardsData.isEmpty) {
        _logger.w('cardsData为空');
        return {
          'jobList': <Map<String, dynamic>>[],
          'jobInfo': <String, dynamic>{},
        };
      }

      // Extract job info - exactly like chaoxing_py
      final jobInfo = _extractJobInfo(cardsData);

      // Process all attachment cards - exactly like chaoxing_py
      final cards = cardsData['attachments'] as List<dynamic>? ?? [];
      _logger.d('找到 ${cards.length} 个attachments');
      
      final jobList = _processAttachmentCards(cards.cast<Map<String, dynamic>>());

      _logger.i('任务点列表解析完成，共解析到 ${jobList.length} 个任务');
      return {
        'jobList': jobList,
        'jobInfo': jobInfo,
      };
      
    } catch (e) {
      _logger.e('解析任务点列表时出错: $e');
      return {
        'jobList': <Map<String, dynamic>>[],
        'jobInfo': <String, dynamic>{},
      };
    }
  }

  /// Extract job info from cards data - replicates chaoxing_py _extract_job_info
  Map<String, dynamic> _extractJobInfo(Map<String, dynamic> cardsData) {
    final defaults = cardsData['defaults'] as Map<String, dynamic>? ?? {};
    if (defaults.isEmpty) {
      return {};
    }

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

  /// Process all attachment cards - replicates chaoxing_py _process_attachment_cards
  List<Map<String, dynamic>> _processAttachmentCards(List<Map<String, dynamic>> cards) {
    final jobList = <Map<String, dynamic>>[];
    
    for (final card in cards) {
      // Skip passed tasks - exactly like chaoxing_py
      if (card['isPassed'] == true) {
        continue;
      }
      
      // Handle null job (reading tasks) - exactly like chaoxing_py
      if (card['job'] == null) {
        final readJob = _processReadTask(card);
        if (readJob != null) {
          jobList.add(readJob);
        }
        continue;
      }

      // Fix otherInfo - exactly like chaoxing_py
      if (card.containsKey('otherInfo')) {
        _logger.d('Fixing other info...');
        card['otherInfo'] = (card['otherInfo'] as String).split('&')[0];
        _logger.d('New info: ${card['otherInfo']}');
      }

      // Process by card type - exactly like chaoxing_py
      final cardType = card['type']?.toString() ?? '';
      if (cardType == 'video') {
        final videoJob = _processVideoTask(card);
        if (videoJob != null) {
          jobList.add(videoJob);
        }
      } else if (cardType == 'document') {
        final docJob = _processDocumentTask(card);
        if (docJob != null) {
          jobList.add(docJob);
        }
      } else if (cardType == 'workid') {
        final workJob = _processWorkTask(card);
        if (workJob != null) {
          jobList.add(workJob);
        }
      } else {
        _logger.w('Unknown card type: $cardType');
        _logger.w(card);
      }
    }

    return jobList;
  }

  /// Process read task - replicates chaoxing_py _process_read_task
  Map<String, dynamic>? _processReadTask(Map<String, dynamic> card) {
    if (!(card['type'] == 'read' && !(card['property'] as Map<String, dynamic>?)?['read'] == true)) {
      return null;
    }
    
    final property = card['property'] as Map<String, dynamic>? ?? {};
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

  /// Process video task - replicates chaoxing_py _process_video_task
  Map<String, dynamic>? _processVideoTask(Map<String, dynamic> card) {
    try {
      final property = card['property'] as Map<String, dynamic>? ?? {};
      return {
        'type': 'video',
        'jobid': card['jobid'] ?? '',
        'name': property['name'] ?? '',
        'otherinfo': card['otherInfo'] ?? '',
        'mid': card['mid'], // Required field
        'objectid': card['objectId'] ?? '',
        'aid': card['aid'] ?? '',
        'playTime': card['playTime'] ?? 0,
        'rt': property['rt'] ?? '',
        'attDuration': card['attDuration'] ?? '',
        'attDurationEnc': card['attDurationEnc'] ?? '',
        'videoFaceCaptureEnc': card['videoFaceCaptureEnc'] ?? '',
      };
    } catch (e) {
      _logger.w('出现转码失败视频，已跳过...');
      return null;
    }
  }

  /// Process document task - replicates chaoxing_py _process_document_task
  Map<String, dynamic>? _processDocumentTask(Map<String, dynamic> card) {
    final property = card['property'] as Map<String, dynamic>? ?? {};
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

  /// Process work task - replicates chaoxing_py _process_work_task
  Map<String, dynamic>? _processWorkTask(Map<String, dynamic> card) {
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
