import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Question types
enum QuestionType {
  single,      // 单选题
  multiple,    // 多选题
  completion,  // 填空题
  judgement,   // 判断题
  shortAnswer; // 简答题
}

/// Question info
class QuestionInfo {
  QuestionInfo({
    required this.id,
    required this.title,
    required this.type,
    required this.options,
  });

  final String id;
  final String title;
  final QuestionType type;
  final String options;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type.name,
    'options': options,
  };
}

/// Question bank cache using SharedPreferences
class QuestionBankCache {

  QuestionBankCache._();
  static const String _cacheKey = 'question_bank_cache';
  static QuestionBankCache? _instance;
  final Logger _logger = Logger();

  static Future<QuestionBankCache> getInstance() async {
    _instance ??= QuestionBankCache._();
    return _instance!;
  }

  /// Get cached answer
  Future<String?> getCache(String question) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString(_cacheKey);
      
      if (cacheJson == null) return null;
      
      final cache = jsonDecode(cacheJson) as Map<String, dynamic>;
      return cache[question] as String?;
    } catch (e) {
      _logger.e('Failed to get cache: $e');
      return null;
    }
  }

  /// Add answer to cache
  Future<void> addCache(String question, String answer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString(_cacheKey);
      
      final cache = cacheJson != null 
          ? jsonDecode(cacheJson) as Map<String, dynamic>
          : <String, dynamic>{};
      
      cache[question] = answer;
      
      await prefs.setString(_cacheKey, jsonEncode(cache));
      _logger.d('Answer cached for question: ${question.substring(0, 20)}...');
    } catch (e) {
      _logger.e('Failed to add cache: $e');
    }
  }

  /// Clear cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      _logger.i('Question bank cache cleared');
    } catch (e) {
      _logger.e('Failed to clear cache: $e');
    }
  }
}

/// Base class for question bank
/// Replicates chaoxing_py Tiku class
abstract class QuestionBankBase {
  QuestionBankBase() {
    logger = Logger();
    dio = Dio();
    _cache = QuestionBankCache.getInstance();
  }

  late Logger logger;
  late Dio dio;
  late Future<QuestionBankCache> _cache;
  
  bool isDisabled = false;
  bool autoSubmit = false;
  double coverageRate = 0.8;
  List<String> trueList = ['正确', '对', '√', 'true', 'T', 'TRUE'];
  List<String> falseList = ['错误', '错', '×', 'false', 'F', 'FALSE'];

  String get name;
  String get apiUrl;

  /// Initialize question bank
  Future<void> initialize({
    bool autoSubmit = false,
    double coverageRate = 0.8,
    List<String>? trueList,
    List<String>? falseList,
  }) async {
    this.autoSubmit = autoSubmit;
    this.coverageRate = coverageRate;
    if (trueList != null) this.trueList = trueList;
    if (falseList != null) this.falseList = falseList;
    
    await initializeCustom();
  }

  /// Custom initialization (override in subclass)
  Future<void> initializeCustom() async {}

  /// Query answer for question
  /// Replicates chaoxing_py query method
  Future<String?> query(QuestionInfo question) async {
    if (isDisabled) return null;

    // Preprocess question title
    var processedTitle = question.title;
    processedTitle = processedTitle.replaceAll(RegExp(r'^\d+'), '');
    processedTitle = processedTitle.replaceAll(RegExp(r'（\d+\.\d+分）$'), '');
    
    logger.d('Original title: ${question.title}');
    logger.d('Processed title: $processedTitle');

    // Check cache first
    final cache = await _cache;
    final cachedAnswer = await cache.getCache(processedTitle);
    if (cachedAnswer != null) {
      logger.i('Answer from cache: $processedTitle -> $cachedAnswer');
      return cachedAnswer.trim();
    }

    // Query from question bank
    final answer = await queryFromBank(question);
    if (answer != null && answer.isNotEmpty) {
      final trimmedAnswer = answer.trim();
      await cache.addCache(processedTitle, trimmedAnswer);
      logger.i('Answer from $name: $processedTitle -> $trimmedAnswer');
      
      if (checkAnswer(trimmedAnswer, question.type)) {
        return trimmedAnswer;
      } else {
        logger.i('Answer type mismatch, discarding');
        return null;
      }
    }

    logger.e('Failed to get answer from $name: $processedTitle');
    return null;
  }

  /// Query from question bank (override in subclass)
  Future<String?> queryFromBank(QuestionInfo question);

  /// Check if answer matches question type
  bool checkAnswer(String answer, QuestionType type) {
    switch (type) {
      case QuestionType.single:
        // Single choice should be A-H
        return RegExp(r'^[A-Ha-h]$').hasMatch(answer);
      
      case QuestionType.multiple:
        // Multiple choice should be multiple letters
        final cleaned = answer.replaceAll(RegExp(r'[^A-Ha-h]'), '');
        return cleaned.length >= 2;
      
      case QuestionType.judgement:
        // Judgement should be in true/false list
        return trueList.contains(answer) || falseList.contains(answer);
      
      case QuestionType.completion:
      case QuestionType.shortAnswer:
        // Fill in blank and short answer should not be empty
        return answer.isNotEmpty;
    }
  }

  /// Convert answer to boolean (for judgement questions)
  /// Replicates chaoxing_py judgement_select method
  bool judgementSelect(String answer) {
    final trimmed = answer.trim();
    
    if (trueList.contains(trimmed)) {
      return true;
    } else if (falseList.contains(trimmed)) {
      return false;
    } else {
      logger.e('Cannot determine answer -> $answer, choosing randomly');
      return DateTime.now().millisecond % 2 == 0;
    }
  }

  /// Get submit parameter
  /// Replicates chaoxing_py get_submit_params method
  String getSubmitParams() {
    // Return empty string to submit, "1" to save but not submit
    return autoSubmit ? '' : '1';
  }
}
