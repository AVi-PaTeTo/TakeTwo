import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fluttertoast/fluttertoast.dart';

import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    try {
      await ref
          .read(authProvider.notifier)
          .login(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) return;

      final authState = ref.read(authProvider);

      if (authState.hasError) {
        // Clean up the error message string (remove raw 'Exception:' prefix)
        String rawError = authState.error.toString();
        String cleanError = rawError.startsWith('Exception: ')
            ? rawError.replaceFirst('Exception: ', '')
            : rawError;

        // Clean fallback if it's a technical Dio network error
        if (cleanError.contains('DioException') ||
            cleanError.contains('connection')) {
          cleanError = 'Network error. Please check your connection.';
        }

        Fluttertoast.showToast(
          msg: cleanError,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.redAccent, // Red for errors
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }

      // Optional Success Toast (if router doesn't navigate away instantly)
      Fluttertoast.showToast(
        msg: "Welcome back!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87, // Or Colors.green
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      if (!mounted) return;

      Fluttertoast.showToast(
        msg: "An unexpected error occurred. Please try again.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Take Two',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Movies. Opinions. Your take.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  TextFormField(
                    controller: _usernameController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter your username';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    enabled: !isLoading,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your password';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: isLoading ? null : _login,
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Log in'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.push('/register');
                          },
                    child: const Text("Don't have an account? Sign up"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
