import 'package:dio/dio.dart';
import 'question_bank_base.dart';

/// TikuYanxi question bank implementation
/// Replicates chaoxing_py TikuYanxi class
class TikuYanxi extends QuestionBankBase {
  String? _token;
  int _tokenIndex = 0;
  List<String> _tokens = [];
  int _remainingTimes = 100;

  @override
  String get name => '言溪题库';

  @override
  String get apiUrl => 'https://tk.enncy.cn/query';

  /// Initialize with tokens
  Future<void> initializeWithTokens(List<String> tokens) async {
    _tokens = tokens;
    if (_tokens.isNotEmpty) {
      _token = _tokens[_tokenIndex];
    } else {
      isDisabled = true;
      throw Exception('No tokens provided for TikuYanxi');
    }
  }

  @override
  Future<void> initializeCustom() async {
    // Token will be loaded separately via initializeWithTokens
  }

  /// Load next token
  void _loadNextToken() {
    _tokenIndex++;
    if (_tokenIndex >= _tokens.length) {
      throw Exception('All tokens exhausted for $name');
    }
    _token = _tokens[_tokenIndex];
    logger.i('Switched to next token (index: $_tokenIndex)');
  }

  @override
  Future<String?> queryFromBank(QuestionInfo question) async {
    if (_token == null) {
      logger.e('No token available');
      return null;
    }

    try {
      final response = await dio.get(
        apiUrl,
        queryParameters: {
          'question': question.title,
          'token': _token,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        if (data['code'] != 0) {
          // Check if token is exhausted
          if (_remainingTimes == 0 || 
              (data['data']?['answer']?.toString().contains('次数不足') ?? false)) {
            logger.i('Token query limit reached, switching token');
            _loadNextToken();
            return queryFromBank(question); // Retry with new token
          }
          
          logger.e('$name query failed: ${data['message']}');
          return null;
        }

        _remainingTimes = data['data']?['times'] ?? _remainingTimes;
        final answer = data['data']?['answer']?.toString().trim();
        return answer;
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
