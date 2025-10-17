import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Core
import 'package:chaoxing_ft/core/di/dependency_injection.dart';

// App
import 'package:chaoxing_ft/presentation/widgets/app_components.dart';
import 'package:chaoxing_ft/app/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize dependency injection
  await DependencyInjection.instance.initialize();
  
  runApp(const ChaoxingApp());
}

class ChaoxingApp extends StatelessWidget {
  const ChaoxingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders.createAppProviders(
      child: MaterialApp(
        title: '超星学习通',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}