import 'package:html/parser.dart' as html_parser;
import 'package:logger/logger.dart';
import 'dart:convert';

/// HTML parser for Chaoxing platform responses
/// Strictly replicates chaoxing_py decode functions
class ChaoxingHtmlParser {
  ChaoxingHtmlParser._internal();
  static ChaoxingHtmlParser? _instance;
  static ChaoxingHtmlParser get instance {
    _instance ??= ChaoxingHtmlParser._internal();
    return _instance!;
  }

  final Logger _logger = Logger();

  /// Parse course list from HTML response
  /// Strictly replicates chaoxing_py decode_course_list function
  List<Map<String, dynamic>> parseCourseList(String htmlText) {
    _logger.d('开始解析课程列表HTML...');
    
    try {
      final document = html_parser.parse(htmlText);
      final courseElements = document.querySelectorAll('div.course');
      final courseList = <Map<String, dynamic>>[];
      
      for (final courseElement in courseElements) {
        // Skip courses that are not open - exactly like chaoxing_py
        if (courseElement.querySelector('a.not-open-tip') != null ||
            courseElement.querySelector('div.not-open-tip') != null) {
          continue;
        }
        
        try {
          // Extract course information - exactly like chaoxing_py
          // Prefer exact selectors used in chaoxing_py, but add robust fallbacks
          final titleElement = courseElement.querySelector('span.course-name')
              ?? courseElement.querySelector('a.course-name')
              ?? courseElement.querySelector('h3')
              ?? courseElement.querySelector('span.line2');
          final descElement = courseElement.querySelector('p.margint10')
              ?? courseElement.querySelector('p.margint10.line2')
              ?? courseElement.querySelector('p');
          final teacherElement = courseElement.querySelector('p.color3')
              ?? courseElement.querySelector('p.teacher')
              ?? courseElement.querySelector('span.teacher');

          final courseDetail = {
            'id': courseElement.attributes['id'] ?? '',
            'info': courseElement.attributes['info'] ?? '',
            'roleid': courseElement.attributes['roleid'] ?? '',
            'clazzId': courseElement.querySelector('input.clazzId')?.attributes['value'] ?? '',
            'courseId': courseElement.querySelector('input.courseId')?.attributes['value'] ?? '',
            'cpi': _extractCpi(courseElement.querySelector('a')?.attributes['href'] ?? ''),
            // Fallback to text when title attribute is missing
            'title': _attrOrText(titleElement, 'title'),
            'desc': _attrOrText(descElement, 'title'),
            'teacher': _attrOrText(teacherElement, 'title'),
          };

          if ((courseDetail['title'] as String).trim().isEmpty) {
            final preview = courseElement.outerHtml;
            _logger.w('课程标题为空，原始节点预览: '
                '${preview.substring(0, preview.length > 300 ? 300 : preview.length)}...');
          }
          
          courseList.add(courseDetail);
          _logger.d('解析到课程: ${courseDetail['title']} (ID: ${courseDetail['courseId']})');
          
        } catch (e) {
          _logger.w('解析课程元素时出错: $e');
          continue;
        }
      }
      
      _logger.i('课程列表解析完成，共解析到 ${courseList.length} 门课程');
      return courseList;
      
    } catch (e) {
      _logger.e('解析课程列表HTML时出错: $e');
      return [];
    }
  }

  /// Extract CPI from href - exactly like chaoxing_py regex
  String _extractCpi(String href) {
    // First try when followed by '&', then fallback to end-of-string
    final withAmp = RegExp(r'cpi=([^&]+)&').firstMatch(href)?.group(1);
    if (withAmp != null) return withAmp;
    final toEnd = RegExp(r'cpi=([^&]+)$').firstMatch(href)?.group(1);
    return toEnd ?? '';
  }

  // Helper: prefer attribute value, then fallback to text
  String _attrOrText(dynamic element, String attr) {
    if (element == null) return '';
    final attrVal = (element.attributes?[attr] ?? '').toString().trim();
    if (attrVal.isNotEmpty) return attrVal;
    try {
      return element.text?.toString().trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Parse course folder from HTML response
  /// Strictly replicates chaoxing_py decode_course_folder function
  List<Map<String, dynamic>> parseCourseFolder(String htmlText) {
    _logger.d('开始解析课程文件夹HTML...');
    
    try {
      final document = html_parser.parse(htmlText);
      final folderElements = document.querySelectorAll('ul.file-list>li');
      final folderList = <Map<String, dynamic>>[];
      
      for (final folderElement in folderElements) {
        try {
          final fileId = folderElement.attributes['fileid'];
          if (fileId == null) continue;
          
          final renameInput = folderElement.querySelector('input.rename-input');
          if (renameInput == null) continue;
          
          final folderDetail = {
            'id': fileId,
            'rename': renameInput.attributes['value'] ?? '',
          };
          
          folderList.add(folderDetail);
          _logger.d('解析到文件夹: ${folderDetail['rename']} (ID: $fileId)');
          
        } catch (e) {
          _logger.w('解析文件夹元素时出错: $e');
          continue;
        }
      }
      
      _logger.i('课程文件夹解析完成，共解析到 ${folderList.length} 个文件夹');
      return folderList;
      
    } catch (e) {
      _logger.e('解析课程文件夹HTML时出错: $e');
      return [];
    }
  }

  /// Parse course points (chapters) from HTML response
  /// Strictly replicates chaoxing_py decode_course_point function
  Map<String, dynamic> parseCoursePoint(String htmlText) {
    _logger.d('开始解析课程章节HTML...');
    
    try {
      final document = html_parser.parse(htmlText);
      final coursePoint = {
        'hasLocked': false,
        'points': <Map<String, dynamic>>[],
      };

      // Debug: Log HTML content preview
      _logger.d('HTML内容预览: ${htmlText.substring(0, htmlText.length > 500 ? 500 : htmlText.length)}...');
      
      // Try multiple selectors for chapter units
      final chapterUnits = <dynamic>[];
      chapterUnits.addAll(document.querySelectorAll('div.chapter_unit'));
      chapterUnits.addAll(document.querySelectorAll('div.chapter'));
      chapterUnits.addAll(document.querySelectorAll('div.unit'));
      chapterUnits.addAll(document.querySelectorAll('ul.chapter-list'));
      
      _logger.d('找到 ${chapterUnits.length} 个章节单元');
      
      if (chapterUnits.isEmpty) {
        // Try to find any div with chapter-related content
        final allDivs = document.querySelectorAll('div');
        _logger.d('页面总共有 ${allDivs.length} 个div元素');
        
        for (int i = 0; i < allDivs.length && i < 10; i++) {
          final div = allDivs[i];
          final className = div.className;
          final id = div.attributes['id'] ?? '';
          _logger.d('Div $i: class="$className", id="$id"');
        }
      }
      
      for (final chapterUnit in chapterUnits) {
        final points = _extractPointsFromChapter(chapterUnit);
        
        // Check if there are locked contents
        for (final point in points) {
          if (point['need_unlock'] == true) {
            coursePoint['hasLocked'] = true;
          }
        }
        
        (coursePoint['points'] as List<Map<String, dynamic>>).addAll(points);
      }
      
      _logger.i('课程章节解析完成，共解析到 ${(coursePoint['points'] as List).length} 个章节');
      return coursePoint;
      
    } catch (e) {
      _logger.e('解析课程章节HTML时出错: $e');
      return {
        'hasLocked': false,
        'points': <Map<String, dynamic>>[],
      };
    }
  }

  /// Extract points from chapter unit - robust selectors compatible with chaoxing_py
  List<Map<String, dynamic>> _extractPointsFromChapter(dynamic chapterUnit) {
    final pointList = <Map<String, dynamic>>[];

    try {
      // Prefer official item container
      final List<dynamic> pointElements = [
        ...chapterUnit.querySelectorAll('div.chapter_item'),
        ...chapterUnit.querySelectorAll('li'),
        ...chapterUnit.querySelectorAll('div.item'),
        ...chapterUnit.querySelectorAll('div.knowledge'),
      ];

      _logger.d('章节单元中找到 ${pointElements.length} 个潜在任务点');

      for (final pointElement in pointElements) {
        try {
          // Extract knowledge id from multiple sources
          String rawId = pointElement.attributes['id'] ?? '';
          String knowledgeId = '';
          if (rawId.isNotEmpty) {
            final m = RegExp(r'(\d{3,})').firstMatch(rawId);
            if (m != null) knowledgeId = m.group(1) ?? '';
          }

          if (knowledgeId.isEmpty) {
            final href = pointElement.querySelector('a')?.attributes['href'] ?? '';
            final m = RegExp(r'knowledgeid=(\d{3,})').firstMatch(href);
            if (m != null) knowledgeId = m.group(1) ?? '';
          }

          // Extract title from multiple fallbacks
          String title =
              pointElement.querySelector('h3')?.text.trim() ??
              pointElement.querySelector('span.chapter_item_title')?.text.trim() ??
              pointElement.querySelector('span.chapter-title')?.text.trim() ??
              pointElement.querySelector('span.catalog_title')?.text.trim() ??
              pointElement.querySelector('a')?.text.trim() ??
              pointElement.text.trim() ??
              '';

          // Flags
          final needUnlock =
              pointElement.className.contains('locked') ||
              pointElement.querySelector('i.icon_lock') != null;
          final hasFinished =
              pointElement.className.contains('finished') ||
              pointElement.querySelector('i.icon_finish') != null ||
              pointElement.querySelector('i.icon_score_finish') != null;

          final pointDetail = <String, dynamic>{
            'id': knowledgeId,
            'title': title,
            'need_unlock': needUnlock,
            'has_finished': hasFinished,
          };

          _logger.d('处理任务点: rawId="$rawId", knowledgeId="$knowledgeId", title="$title"');

          if (pointDetail['id'].toString().isNotEmpty && pointDetail['title'].toString().isNotEmpty) {
            pointList.add(pointDetail);
            _logger.d('解析到章节: ${pointDetail['title']} (ID: ${pointDetail['id']})');
          } else {
            _logger.d('跳过无效任务点: ID或标题为空');
          }
        } catch (e) {
          _logger.w('解析章节元素时出错: $e');
          continue;
        }
      }
    } catch (e) {
      _logger.w('解析章节单元时出错: $e');
    }

    return pointList;
  }

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

      // Try multiple patterns for mArg extraction
      String? mArgContent;
      
      // Pattern 1: mArg={...};
      var mArgMatch = RegExp(r'mArg=\{(.*?)\};').firstMatch(htmlText.replaceAll(' ', ''));
      if (mArgMatch != null) {
        mArgContent = mArgMatch.group(1);
        _logger.d('找到mArg (模式1): ${mArgContent?.substring(0, mArgContent.length > 200 ? 200 : mArgContent.length)}...');
      }
      
      // Pattern 2: var mArg = {...};
      if (mArgContent == null) {
        mArgMatch = RegExp(r'var\s+mArg\s*=\s*\{(.*?)\};').firstMatch(htmlText.replaceAll(' ', ''));
        if (mArgMatch != null) {
          mArgContent = mArgMatch.group(1);
          _logger.d('找到mArg (模式2): ${mArgContent?.substring(0, mArgContent.length > 200 ? 200 : mArgContent.length)}...');
        }
      }
      
      // Pattern 3: mArg: {...}
      if (mArgContent == null) {
        mArgMatch = RegExp(r'mArg:\s*\{(.*?)\}').firstMatch(htmlText.replaceAll(' ', ''));
        if (mArgMatch != null) {
          mArgContent = mArgMatch.group(1);
          _logger.d('找到mArg (模式3): ${mArgContent?.substring(0, mArgContent.length > 200 ? 200 : mArgContent.length)}...');
        }
      }
      
      if (mArgContent == null) {
        _logger.w('未找到mArg参数，尝试查找其他任务数据...');
        
        // Try to find attachments directly in script tags
        final scriptMatch = RegExp(r'<script[^>]*>(.*?)</script>', multiLine: true).firstMatch(htmlText);
        if (scriptMatch != null) {
          final scriptContent = scriptMatch.group(1) ?? '';
          _logger.d('脚本内容预览: ${scriptContent.substring(0, scriptContent.length > 500 ? 500 : scriptContent.length)}...');
          
          // Look for attachments array
          final attachmentsMatch = RegExp(r'attachments:\s*\[(.*?)\]').firstMatch(scriptContent);
          if (attachmentsMatch != null) {
            _logger.d('找到attachments数组');
            // Try to parse attachments directly
            try {
              final attachmentsStr = '[' + attachmentsMatch.group(1)! + ']';
              final attachments = jsonDecode(attachmentsStr) as List<dynamic>;
              _logger.d('解析到 ${attachments.length} 个attachments');
              
              if (attachments.isNotEmpty) {
                final jobList = _processAttachmentCards(attachments.cast<Map<String, dynamic>>());
                return {
                  'jobList': jobList,
                  'jobInfo': <String, dynamic>{},
                };
              }
            } catch (e) {
              _logger.w('解析attachments失败: $e');
            }
          }
        }
        
        return {
          'jobList': <Map<String, dynamic>>[],
          'jobInfo': <String, dynamic>{},
        };
      }

      // Parse JSON data - exactly like chaoxing_py
      final cardsData = jsonDecode('{' + mArgContent + '}') as Map<String, dynamic>;
      
      if (cardsData.isEmpty) {
        return {
          'jobList': <Map<String, dynamic>>[],
          'jobInfo': <String, dynamic>{},
        };
      }

      // Extract job info - exactly like chaoxing_py
      final jobInfo = _extractJobInfo(cardsData);

      // Process all attachment cards - exactly like chaoxing_py
      final cards = cardsData['attachments'] as List<dynamic>? ?? [];
      final jobList = _processAttachmentCards(cards);

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
      'clazzId': defaults['clazzId'] ?? '',
      'courseId': defaults['courseId'] ?? '',
      'knowledgeid': defaults['knowledgeid'] ?? '',
      'cpi': defaults['cpi'] ?? '',
    };
  }

  /// Process attachment cards - replicates chaoxing_py _process_attachment_cards
  List<Map<String, dynamic>> _processAttachmentCards(List<dynamic> cards) {
    final jobList = <Map<String, dynamic>>[];
    
    for (final card in cards) {
      try {
        final cardMap = card as Map<String, dynamic>;
        
        // Skip passed tasks - exactly like chaoxing_py
        if (cardMap['isPassed'] == true) {
          continue;
        }
        
        // Handle different task types - exactly like chaoxing_py
        if (cardMap['job'] == null) {
          // Handle read type tasks
          final readJob = _processReadTask(cardMap);
          if (readJob != null) {
            jobList.add(readJob);
          }
          continue;
        }

        // Fix otherInfo - exactly like chaoxing_py
        if (cardMap.containsKey('otherInfo')) {
          _logger.d('Fixing other info...');
          final otherInfo = cardMap['otherInfo'] as String;
          cardMap['otherInfo'] = otherInfo.split('&')[0];
          _logger.d('New info: ${cardMap['otherInfo']}');
        }

        // Process based on task type - exactly like chaoxing_py
        final cardType = cardMap['type'] as String? ?? '';
        Map<String, dynamic>? job;
        
        switch (cardType) {
          case 'video':
            job = _processVideoTask(cardMap);
            break;
          case 'document':
            job = _processDocumentTask(cardMap);
            break;
          case 'workid':
            job = _processWorkTask(cardMap);
            break;
          default:
            _logger.w('Unknown card type: $cardType');
            _logger.w(cardMap);
        }
        
        if (job != null) {
          jobList.add(job);
        }
        
      } catch (e) {
        _logger.w('处理任务卡片时出错: $e');
        continue;
      }
    }
    
    return jobList;
  }

  /// Process read task - placeholder for chaoxing_py _process_read_task
  Map<String, dynamic>? _processReadTask(Map<String, dynamic> card) {
    // TODO: Implement read task processing
    return null;
  }

  /// Process video task - placeholder for chaoxing_py _process_video_task
  Map<String, dynamic>? _processVideoTask(Map<String, dynamic> card) {
    // TODO: Implement video task processing
    return null;
  }

  /// Process document task - placeholder for chaoxing_py _process_document_task
  Map<String, dynamic>? _processDocumentTask(Map<String, dynamic> card) {
    // TODO: Implement document task processing
    return null;
  }

  /// Process work task - placeholder for chaoxing_py _process_work_task
  Map<String, dynamic>? _processWorkTask(Map<String, dynamic> card) {
    // TODO: Implement work task processing
    return null;
  }
}