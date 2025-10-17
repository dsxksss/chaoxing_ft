import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chaoxing_ft/presentation/widgets/app_components.dart';
import 'package:chaoxing_ft/presentation/providers/auth_provider.dart';
import 'package:chaoxing_ft/app/routes.dart';

/// Login page UI
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _usernameController.text = '19807974919';
    _passwordController.text = 'dsxk2546650292';
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      AppNavigation.goToCourseList(context);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        centerTitle: true,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              // Logo or title
              const Icon(
                Icons.school,
                size: 80,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 32),
              
              // App title
              const Text(
                '超星学习通',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 48),

              // Username field
              AppComponents.customTextField(
                label: '用户名',
                hintText: '请输入用户名',
                controller: _usernameController,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入用户名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password field
              AppComponents.customTextField(
                label: '密码',
                hintText: '请输入密码',
                controller: _passwordController,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入密码';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

                  // Error message
                  if (authProvider.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.errorColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authProvider.errorMessage!,
                              style: const TextStyle(
                                color: AppTheme.errorColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Login button
                  AppComponents.customButton(
                    text: '登录',
                    isLoading: authProvider.isLoading,
                    onPressed: authProvider.isLoading ? null : _handleLogin,
                    width: double.infinity,
                  ),
              const SizedBox(height: 16),

              // Additional options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('忘记密码功能暂未实现')),
                      );
                    },
                    child: const Text('忘记密码？'),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement register
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('注册功能暂未实现')),
                      );
                    },
                    child: const Text('注册账号'),
                  ),
                ],
              ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}