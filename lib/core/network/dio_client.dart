import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class DioClient {

  DioClient._internal() {
    _logger = Logger();
    _dio = Dio();
    _setupInterceptors();
  }
  static DioClient? _instance;
  late Dio _dio;
  late Logger _logger;

  static DioClient get instance {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.addAll([
      // Request interceptor
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('Request: ${options.method} ${options.uri}');
          _logger.d('Headers: ${options.headers}');
          _logger.d('Data: ${options.data}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('Response: ${response.statusCode} ${response.requestOptions.uri}');
          _logger.d('Data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('Error: ${error.message}');
          _logger.e('Response: ${error.response?.data}');
          handler.next(error);
        },
      ),
      // Retry interceptor
      RetryInterceptor(
        dio: _dio,
        logPrint: (message) => _logger.d(message),
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    ]);
  }

  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  void updateHeaders(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }

  void updateTimeout(Duration timeout) {
    _dio.options.connectTimeout = timeout;
    _dio.options.receiveTimeout = timeout;
    _dio.options.sendTimeout = timeout;
  }
}

class RetryInterceptor extends Interceptor {

  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ],
    this.logPrint,
  });
  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;
  final void Function(String message)? logPrint;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      
      if (retryCount < retries) {
        logPrint?.call('Retrying request (${retryCount + 1}/$retries)');
        
        await Future.delayed(retryDelays[retryCount]);
        
        err.requestOptions.extra['retryCount'] = retryCount + 1;
        
        try {
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          if (e is DioException) {
            err = e;
          }
        }
      }
    }
    
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}
