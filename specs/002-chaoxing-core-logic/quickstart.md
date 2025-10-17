# Quickstart Guide: Chaoxing Core Logic Implementation

**Created**: 2025-01-27  
**Purpose**: Quick setup and usage guide for Chaoxing Flutter implementation

## Prerequisites

- Flutter 3.9.2 or higher
- Dart 3.9.2 or higher
- Android Studio / Xcode / Visual Studio Code
- Valid Chaoxing account credentials

## Project Setup

### 1. Clone and Initialize
```bash
git clone <repository-url>
cd chaoxing_ft
flutter pub get
```

### 2. Platform Configuration

#### Android Setup
```bash
flutter config --enable-android
flutter doctor --android-licenses
```

#### iOS Setup (macOS only)
```bash
flutter config --enable-ios
cd ios && pod install && cd ..
```

#### Windows Setup
```bash
flutter config --enable-windows
```

### 3. Dependencies Installation
```bash
flutter pub add dio provider shared_preferences hive hive_flutter
flutter pub add --dev flutter_test mockito integration_test
```

## Configuration

### 1. Create Configuration File
Create `lib/config/app_config.dart`:
```dart
class AppConfig {
  static const String aesKey = "u2oh6Vu^HWe4_AES";
  static const String baseUrl = "https://mooc2-ans.chaoxing.com";
  static const String authUrl = "https://passport2.chaoxing.com";
  static const Duration requestTimeout = Duration(seconds: 5);
  static const Duration rateLimitDelay = Duration(milliseconds: 400);
}
```

### 2. Initialize Hive Storage
```dart
// In main.dart
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(CourseAdapter());
  Hive.registerAdapter(ChapterAdapter());
  Hive.registerAdapter(TaskAdapter());
  
  runApp(MyApp());
}
```

## Basic Usage

### 1. Authentication
```dart
import 'package:chaoxing_ft/services/auth_service.dart';

final authService = AuthService();

// Login with credentials
final result = await authService.login(
  username: 'your_phone_number',
  password: 'your_password',
);

if (result.isSuccess) {
  print('Login successful');
} else {
  print('Login failed: ${result.error}');
}
```

### 2. Get Course List
```dart
import 'package:chaoxing_ft/services/course_service.dart';

final courseService = CourseService();

final courses = await courseService.getCourseList();
for (final course in courses) {
  print('Course: ${course.title}');
  print('Teacher: ${course.teacher}');
  print('Status: ${course.status}');
}
```

### 3. Start Learning
```dart
import 'package:chaoxing_ft/services/learning_service.dart';

final learningService = LearningService();

// Select a course
final course = courses.first;

// Get course chapters
final chapters = await learningService.getCourseChapters(course);

// Process chapters
for (final chapter in chapters) {
  if (chapter.isOpen) {
    await learningService.processChapter(chapter);
  }
}
```

### 4. Configuration Management
```dart
import 'package:chaoxing_ft/services/config_service.dart';

final configService = ConfigService();

// Set playback speed
await configService.setPlaybackSpeed(1.5);

// Set retry behavior
await configService.setRetryBehavior(RetryBehavior.retry);

// Enable question bank
await configService.enableQuestionBank(QuestionBankType.tikuYanxi);
```

## Testing

### 1. Unit Tests
```bash
flutter test test/unit/
```

### 2. Widget Tests
```bash
flutter test test/widget/
```

### 3. Integration Tests
```bash
flutter test integration_test/
```

### 4. Test Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Platform-Specific Features

### Android
- Video playback using ExoPlayer
- Background task processing
- Notification support
- File system access for cache

### iOS
- Video playback using AVPlayer
- Background app refresh
- Local notifications
- Keychain for secure storage

### Windows
- Video playback using Windows Media Foundation
- Desktop notifications
- File system integration
- Windows-specific UI adaptations

## Error Handling

### Common Error Scenarios
1. **Network Errors**: Automatic retry with exponential backoff
2. **Authentication Failures**: Clear error messages and re-login prompts
3. **Rate Limiting**: Automatic delay and retry
4. **Session Expiry**: Automatic re-authentication
5. **Task Failures**: Retry logic with user notification

### Error Recovery
```dart
try {
  await learningService.processTask(task);
} on NetworkException catch (e) {
  // Handle network errors
  await Future.delayed(Duration(seconds: 5));
  await learningService.processTask(task);
} on AuthenticationException catch (e) {
  // Handle auth errors
  await authService.reLogin();
  await learningService.processTask(task);
} catch (e) {
  // Handle unexpected errors
  logger.error('Unexpected error: $e');
}
```

## Performance Optimization

### 1. Memory Management
- Dispose controllers properly
- Clear unused data from memory
- Implement efficient caching strategies

### 2. Network Optimization
- Implement request caching
- Use connection pooling
- Batch API requests when possible

### 3. UI Performance
- Use const constructors
- Implement lazy loading
- Optimize widget rebuilds

## Debugging

### 1. Enable Debug Logging
```dart
// In main.dart
import 'package:chaoxing_ft/core/logger.dart';

void main() {
  Logger.setLevel(LogLevel.debug);
  runApp(MyApp());
}
```

### 2. Network Monitoring
```dart
// Enable Dio logging
final dio = Dio();
dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
  logPrint: (log) => debugPrint(log.toString()),
));
```

### 3. State Inspection
```dart
// Use Provider debug tools
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => LearningProvider()),
      ],
      child: MaterialApp(
        home: HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

## Troubleshooting

### Common Issues

1. **Build Failures**
   - Run `flutter clean && flutter pub get`
   - Check Flutter and Dart versions
   - Verify platform-specific dependencies

2. **Authentication Issues**
   - Verify credentials format
   - Check network connectivity
   - Ensure proper AES encryption

3. **Performance Issues**
   - Monitor memory usage
   - Check network request frequency
   - Optimize video playback settings

4. **Platform-Specific Issues**
   - Android: Check permissions and ProGuard rules
   - iOS: Verify Info.plist configurations
   - Windows: Check Windows SDK version

### Getting Help
- Check logs for detailed error messages
- Review API documentation
- Consult chaoxing_py reference implementation
- Create issue with detailed reproduction steps
