import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chaoxing_ft/presentation/providers/auth_provider.dart';
import 'package:chaoxing_ft/presentation/providers/course_provider.dart';
import 'package:chaoxing_ft/presentation/providers/task_provider.dart';
import 'package:chaoxing_ft/services/auth/auth_service.dart';
import 'package:chaoxing_ft/services/course/course_service.dart';
import 'package:chaoxing_ft/services/video/video_service.dart';
import 'package:chaoxing_ft/services/task/task_service.dart';
import 'package:chaoxing_ft/data/repositories/user_repository_impl.dart';
import 'package:chaoxing_ft/data/repositories/course_repository_impl.dart';
import 'package:chaoxing_ft/data/repositories/video_repository_impl.dart';
import 'package:chaoxing_ft/data/repositories/task_repository_impl.dart';
import 'package:chaoxing_ft/data/datasources/local/shared_prefs_datasource.dart';
import 'package:chaoxing_ft/data/datasources/local/hive_datasource.dart';
import 'package:chaoxing_ft/data/datasources/remote/chaoxing_api_datasource.dart';
import 'package:chaoxing_ft/core/session/session_manager.dart';
import 'package:chaoxing_ft/core/crypto/aes_cipher.dart';
import 'package:chaoxing_ft/core/errors/error_handler.dart';

/// Dependency injection container for the app
/// This implements proper dependency injection to comply with constitution requirements
class DependencyInjection {

  DependencyInjection._();
  static DependencyInjection? _instance;
  static DependencyInjection get instance => _instance ??= DependencyInjection._();

  // Core services
  late final SessionManager _sessionManager;
  late final AESCipher _aesCipher;
  late final ErrorHandler _errorHandler;

  // Data sources
  late final SharedPrefsDataSource _sharedPrefsDataSource;
  late final HiveDataSource _hiveDataSource;
  late final ChaoxingApiDataSource _apiDataSource;

  // Repositories
  late final UserRepositoryImpl _userRepository;
  late final CourseRepositoryImpl _courseRepository;
  late final VideoRepositoryImpl _videoRepository;
  late final TaskRepositoryImpl _taskRepository;

  // Services
  late final AuthService _authService;
  late final CourseService _courseService;
  late final VideoService _videoService;
  late final TaskService _taskService;

  /// Initialize all dependencies
  Future<void> initialize() async {
    try {
      // Initialize core services
      _sessionManager = SessionManager.instance;
      await _sessionManager.initialize();
      
      _aesCipher = AESCipher.instance;
      _errorHandler = ErrorHandler.instance;

      // Initialize data sources
      _sharedPrefsDataSource = SharedPrefsDataSource.instance;
      await _sharedPrefsDataSource.initialize();
      
      _hiveDataSource = HiveDataSource.instance;
      await _hiveDataSource.initialize();
      
      _apiDataSource = ChaoxingApiDataSource(
        _sessionManager,
        _aesCipher,
        _errorHandler,
      );

      // Initialize repositories
      _userRepository = UserRepositoryImpl(
        _sharedPrefsDataSource,
        _hiveDataSource,
        _apiDataSource,
        _sessionManager,
        _errorHandler,
      );

      _courseRepository = CourseRepositoryImpl(
        _hiveDataSource,
        _apiDataSource,
        _errorHandler,
      );

      _videoRepository = VideoRepositoryImpl(
        _hiveDataSource,
        _errorHandler,
      );

      _taskRepository = TaskRepositoryImpl(
        _hiveDataSource,
        _apiDataSource,
        _sessionManager,
        _errorHandler,
      );

      // Initialize services
      _authService = AuthService(_userRepository, _errorHandler);
      _courseService = CourseService(_courseRepository, _errorHandler);
      _videoService = VideoService(_videoRepository, _errorHandler);
      _taskService = TaskService(_taskRepository, _errorHandler);

      print('Dependency injection initialized successfully');
    } catch (e) {
      print('Failed to initialize dependency injection: $e');
      rethrow;
    }
  }

  // Getters for services
  SessionManager get sessionManager => _sessionManager;
  AESCipher get aesCipher => _aesCipher;
  ErrorHandler get errorHandler => _errorHandler;
  SharedPrefsDataSource get sharedPrefsDataSource => _sharedPrefsDataSource;
  HiveDataSource get hiveDataSource => _hiveDataSource;
  ChaoxingApiDataSource get apiDataSource => _apiDataSource;
  UserRepositoryImpl get userRepository => _userRepository;
  CourseRepositoryImpl get courseRepository => _courseRepository;
  VideoRepositoryImpl get videoRepository => _videoRepository;
  TaskRepositoryImpl get taskRepository => _taskRepository;
  AuthService get authService => _authService;
  CourseService get courseService => _courseService;
  VideoService get videoService => _videoService;
  TaskService get taskService => _taskService;
}

/// Provider configuration for the app
class AppProviders {
  /// Create all app providers with initialized dependencies
  static Widget createAppProviders({required Widget child}) {
    // Get the initialized DI instance
    final di = DependencyInjection.instance;
    
    return MultiProvider(
      providers: [
        // Auth provider - required for login
        ChangeNotifierProvider(
          create: (_) => AuthProvider(di.authService),
        ),
        // Course provider - for course management
        ChangeNotifierProvider(
          create: (_) => CourseProvider(di.courseService),
        ),
        // Task provider - for task management
        ChangeNotifierProvider(
          create: (_) => TaskProvider(di.taskService),
        ),
        // More providers can be added here as needed
      ],
      child: child,
    );
  }
}

/// Provider extensions for easier access
extension ProviderExtension on BuildContext {
  T read<T>() => Provider.of<T>(this, listen: false);
  T watch<T>() => Provider.of<T>(this);
}
