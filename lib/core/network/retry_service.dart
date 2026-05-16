import 'package:flutter/foundation.dart';

/// Configuration for retry logic
class RetryConfig {
  /// Maximum number of retry attempts
  final int maxRetries;

  /// Initial delay before first retry
  final Duration initialDelay;

  /// Maximum delay between retries
  final Duration maxDelay;

  /// Multiplier for exponential backoff
  final double backoffMultiplier;

  /// Whether to show debug logs
  final bool debugLogging;

  const RetryConfig({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.debugLogging = false,
  });
}

/// Service to handle retry logic with exponential backoff
class RetryService {
  static const RetryConfig defaultConfig = RetryConfig();

  /// Execute a function with retry logic
  static Future<T> executeWithRetry<T>({
    required Future<T> Function() operation,
    required bool Function(Object exception) shouldRetry,
    RetryConfig config = defaultConfig,
  }) async {
    int attempt = 0;
    Duration delay = config.initialDelay;

    while (true) {
      try {
        if (config.debugLogging) {
          debugPrint('RetryService: Attempt ${attempt + 1}');
        }
        return await operation();
      } catch (e) {
        attempt++;

        if (attempt >= config.maxRetries || !shouldRetry(e)) {
          if (config.debugLogging) {
            debugPrint(
                'RetryService: Failed after $attempt attempts. Error: $e');
          }
          rethrow;
        }

        if (config.debugLogging) {
          debugPrint(
              'RetryService: Attempt failed. Retrying after ${delay.inMilliseconds}ms');
        }

        await Future.delayed(delay);

        // Calculate next delay with exponential backoff
        final nextDelay = Duration(
          milliseconds: (delay.inMilliseconds * config.backoffMultiplier)
              .toInt()
              .clamp(0, config.maxDelay.inMilliseconds),
        );
        delay = nextDelay;
      }
    }
  }

  /// Default retry predicate - retries on network errors
  static bool isRetryableError(Object exception) {
    final message = exception.toString().toLowerCase();
    return message.contains('network') ||
        message.contains('timeout') ||
        message.contains('socket') ||
        message.contains('connection') ||
        message.contains('failed host lookup');
  }
}
