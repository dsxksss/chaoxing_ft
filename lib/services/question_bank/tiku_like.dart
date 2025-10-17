import 'package:dio/dio.dart';
import 'question_bank_base.dart';

/// TikuLike question bank implementation
/// Replicates chaoxing_py TikuLike class
class TikuLike extends QuestionBankBase {
  String? _token;
  String? _model;
  bool _enableSearch = false;
  int _remainingTimes = -1;
  int _queryCount = 0;

  @override
  String get name => 'Like知识库';

  @override
  String get apiUrl => 'https://api.datam.site/search';

  String get balanceApiUrl => 'https://api.datam.site/balance';
  String get homepage => 'https://www.datam.site';
  String get version => '1.0.8';

  /// Initialize with token and options
  Future<void> initializeWithConfig({
    required String token,
    String? model,
    bool enableSearch = false,
  }) async {
    _token = token;
    _model = model;
    _enableSearch = enableSearch;
    
    await updateRemainingTimes();
  }

  @override
  Future<void> initializeCustom() async {
    // Configuration will be loaded separately via initializeWithConfig
  }

  /// Update remaining query times
  Future<void> updateRemainingTimes() async {
    if (_token == null) return;

    try {
      final response = await dio.post(
        balanceApiUrl,
        data: {'token': _token},
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        _remainingTimes = data['data']?['balance'] ?? _remainingTimes;
        logger.i('$name remaining queries: $_remainingTimes');
      } else {
        logger.e('Failed to get balance: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Failed to update remaining times: $e');
    }
  }

  @override
  Future<String?> queryFromBank(QuestionInfo question) async {
    if (_token == null) {
      logger.e('No token available');
      return null;
    }

    try {
      // Map question types to API parameters
      final questionTypeMap = {
        QuestionType.single: '【单选题】',
        QuestionType.multiple: '【多选题】',
        QuestionType.completion: '【填空题】',
        QuestionType.judgement: '【判断题】',
      };

      final prefix = questionTypeMap[question.type] ?? '【其他类型题目】';
      final formattedQuestion = '$prefix${question.title}\n${question.options}';

      final response = await dio.post(
        apiUrl,
        data: {
          'query': formattedQuestion,
          'token': _token,
          'model': _model ?? '',
          'search': _enableSearch,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final responseType = data['data']?['type'] ?? 0;
        
        String answer = '';
        
        switch (responseType) {
          case 1: // Choose (single/multiple)
            final answers = data['data']?['choose'];
            if (answers is List) {
              final optionMap = {
                'A': 0, 'B': 1, 'C': 2, 'D': 3,
                'E': 4, 'F': 5, 'G': 6, 'H': 7,
                'a': 0, 'b': 1, 'c': 2, 'd': 3,
                'e': 4, 'f': 5, 'g': 6, 'h': 7,
              };
              
              final optionsList = question.options.split('\n');
              for (final ans in answers) {
                final index = optionMap[ans.toString()];
                if (index != null && index < optionsList.length) {
                  answer += '${optionsList[index]}\n';
                }
              }
            }
            break;
            
          case 2: // Fill in blank
            final fills = data['data']?['fills'];
            if (fills is List) {
              answer = fills.join('\n');
            }
            break;
            
          case 3: // Judgement
            final judge = data['data']?['judge'];
            answer = judge == 1 ? '正确' : '错误';
            break;
            
          case 0: // Others
            answer = data['data']?['others']?.toString() ?? '';
            break;
        }

        _remainingTimes--;
        _queryCount = (_queryCount + 1) % 10;
        
        // Update remaining times every 10 queries
        if (_queryCount == 0) {
          await updateRemainingTimes();
        }

        return answer.trim();
      } else {
        logger.e('$name query failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.e('$name query error: $e');
      return null;
    }
  }
}
