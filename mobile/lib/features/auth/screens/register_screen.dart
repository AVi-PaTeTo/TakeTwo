import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fluttertoast/fluttertoast.dart';

import '../models/genre.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  List<Genre> _genres = [];
  final Set<int> _selectedGenres = {};

  bool _loadingGenres = true;
  bool _registering = false;

  @override
  void initState() {
    super.initState();
    _loadGenres();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadGenres() async {
    try {
      final genres = await ref.read(authServiceProvider).getGenres();

      if (!mounted) return;

      setState(() {
        _genres = genres;
        _loadingGenres = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingGenres = false;
      });

      Fluttertoast.showToast(
        msg: "Failed to fetch genre list.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM, // BOTTOM, CENTER, or TOP
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black87,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGenres.length < 5) {
      Fluttertoast.showToast(
        msg: "Please select at least 5 genres.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent, // Red for validation warnings
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _registering = true;
    });

    try {
      await ref
          .read(authServiceProvider)
          .register(
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            preferredGenres: _selectedGenres.toList(),
          );

      if (!mounted) return;

      Fluttertoast.showToast(
        msg: "Account created successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87, // Clean dark background for success
        textColor: Colors.white,
        fontSize: 16.0,
      );

      context.go('/login');
    } catch (e) {
      if (!mounted) return;

      // Clean up error message (strip 'Exception:' prefix if present)
      String rawError = e.toString();
      String cleanError = rawError.startsWith('Exception: ')
          ? rawError.replaceFirst('Exception: ', '')
          : rawError;

      // Optional: Handle common Dio network or validation errors gracefully
      if (cleanError.contains('DioException') ||
          cleanError.contains('connection')) {
        cleanError = 'Network error. Please check your connection.';
      }

      Fluttertoast.showToast(
        msg: cleanError,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent, // Red for actual errors
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      if (mounted) {
        setState(() {
          _registering = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: _loadingGenres
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create your account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter a username';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter your email';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      const Text(
                        'What do you like watching?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Select at least 5 genres',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _genres.map((genre) {
                          final selected = _selectedGenres.contains(genre.id);

                          return FilterChip(
                            label: Text(genre.name),
                            selected: selected,
                            onSelected: (value) {
                              setState(() {
                                if (value) {
                                  _selectedGenres.add(genre.id);
                                } else {
                                  _selectedGenres.remove(genre.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      Text('${_selectedGenres.length} / 5 selected'),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: _registering ? null : _register,
                          child: _registering
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Create account'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
