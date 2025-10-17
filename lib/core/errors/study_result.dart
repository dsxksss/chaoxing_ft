/// Study result enumeration
/// Replicates chaoxing_py StudyResult enum
enum StudyResult {
  success,
  forbidden,  // 403
  error,
  timeout;

  bool get isSuccess => this == StudyResult.success;
  bool get isFailure => this != StudyResult.success;
  
  /// Create StudyResult from HTTP status code
  factory StudyResult.fromStatusCode(int statusCode) {
    switch (statusCode) {
      case 200:
        return StudyResult.success;
      case 403:
        return StudyResult.forbidden;
      case 408:
      case 504:
        return StudyResult.timeout;
      default:
        return StudyResult.error;
    }
  }
}

/// Maximum retry exception
class MaxRetryExceededException implements Exception {
  MaxRetryExceededException(this.message);
  
  final String message;

  @override
  String toString() => 'MaxRetryExceededException: $message';
}

/// Study result with metadata
class StudyTaskResult {
  StudyTaskResult({
    required this.result,
    this.message,
    this.data,
  });
  
  final StudyResult result;
  final String? message;
  final Map<String, dynamic>? data;

  bool get isSuccess => result.isSuccess;
  bool get isFailure => result.isFailure;
}
