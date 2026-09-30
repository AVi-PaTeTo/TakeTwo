import 'package:flutter/material.dart';

class AppErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const AppErrorView({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    // 1. Convert raw error to string and clean up prefixes
    String rawError = error.toString();
    String cleanError = rawError.startsWith('Exception: ')
        ? rawError.replaceFirst('Exception: ', '')
        : rawError;

    // 2. Translate technical Dio / connection errors into friendly messages
    if (cleanError.contains('DioException') ||
        cleanError.contains('connection error') ||
        cleanError.contains('Connection refused') ||
        cleanError.contains('Network is unreachable')) {
      cleanError = 'Unable to connect to the server. Please check your internet connection and try again.';
    }

    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 56,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Connection Issue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cleanError,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
