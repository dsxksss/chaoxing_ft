import 'package:flutter/material.dart';
import 'package:chaoxing_ft/presentation/pages/auth/login_page.dart';
import 'package:chaoxing_ft/presentation/pages/course/course_list_page.dart';
import 'package:chaoxing_ft/presentation/pages/task/task_list_page.dart';

/// App routing configuration
class AppRoutes {
  // Route names
  static const String login = '/';
  static const String courseList = '/course_list';
  static const String taskList = '/task_list';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginPage(),
    courseList: (context) => const CourseListPage(),
    taskList: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final courseId = args?['courseId'] as String? ?? '';
      return TaskListPage(courseId: courseId);
    },
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case courseList:
        return MaterialPageRoute(builder: (_) => const CourseListPage());
      case taskList:
        final args = settings.arguments as Map<String, dynamic>?;
        final courseId = args?['courseId'] as String? ?? '';
        return MaterialPageRoute(builder: (_) => TaskListPage(courseId: courseId));
      default:
        return MaterialPageRoute(builder: (_) => const Text('Error: Unknown route'));
    }
  }
}

/// Navigation helper class
class AppNavigation {
  /// Navigate to login screen
  static void goToLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  /// Navigate to course list (replace login page)
  static void goToCourseList(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.courseList);
  }

  /// Navigate to task list
  static void goToTaskList(BuildContext context, {Map<String, dynamic>? arguments}) {
    Navigator.of(context).pushNamed(AppRoutes.taskList, arguments: arguments);
  }

  /// Navigate to course detail
  static void goToCourseDetail(BuildContext context, String courseId) {
    Navigator.of(context).pushNamed(AppRoutes.taskList, arguments: {'courseId': courseId});
  }

  /// Go back
  static void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Push route
  static void push(BuildContext context, String routeName, {Map<String, dynamic>? arguments}) {
    Navigator.of(context).pushNamed(routeName, arguments: arguments);
  }

  /// Replace route
  static void replace(BuildContext context, String routeName, {Map<String, dynamic>? arguments}) {
    Navigator.of(context).pushReplacementNamed(routeName, arguments: arguments);
  }
}
