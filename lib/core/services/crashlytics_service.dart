import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._internal();

  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  factory CrashlyticsService() {
    return _instance;
  }

  CrashlyticsService._internal();

  Future<void> init({bool debugMode = false}) async {
    FlutterError.onError = (details) {
      _crashlytics.recordFlutterFatalError(details);
    };
    await _crashlytics.setCrashlyticsCollectionEnabled(!debugMode);
  }

  Future<void> recordException({
    required Object exception,
    StackTrace? stackTrace,
    String? reason,
    Map<String, dynamic>? context,
  }) async {
    try {
      await _crashlytics.recordError(
        exception,
        stackTrace ?? StackTrace.current,
        reason: reason,
        printDetails: true,
      );

      if (context != null) {
        context.forEach((key, value) {
          _crashlytics.setCustomKey(key, value.toString());
        });
      }
    } catch (e) {
      debugPrint('Error recording exception to Crashlytics: $e');
    }
  }

  Future<void> recordMessage({
    required String message,
    Severity severity = Severity.info,
  }) async {
    try {
      _crashlytics.log('[$severity] $message');
    } catch (e) {
      debugPrint('Error recording message to Crashlytics: $e');
    }
  }

  Future<void> setUserId(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
    } catch (e) {
      debugPrint('Error setting user ID in Crashlytics: $e');
    }
  }

  void setCustomKey(String key, dynamic value) {
    try {
      _crashlytics.setCustomKey(key, value.toString());
    } catch (e) {
      debugPrint('Error setting custom key in Crashlytics: $e');
    }
  }

  Future<void> clearCustomKeys() async {
    try {
      _crashlytics.setCustomKey('cleared', DateTime.now().toString());
    } catch (e) {
      debugPrint('Error clearing custom keys: $e');
    }
  }

  void crash() {
    _crashlytics.crash();
  }

  Future<void> recordNetworkError({
    required String url,
    required String method,
    required int? statusCode,
    required String error,
  }) async {
    await recordException(
      exception: Exception('Network Error: $method $url'),
      reason: 'HTTP $statusCode: $error',
      context: {
        'url': url,
        'method': method,
        'statusCode': statusCode,
        'error': error,
      },
    );
  }

  Future<void> recordPaymentError({
    required String paymentMethod,
    required String error,
    required String orderId,
  }) async {
    await recordException(
      exception: Exception('Payment Error'),
      reason: 'Payment method: $paymentMethod',
      context: {
        'paymentMethod': paymentMethod,
        'error': error,
        'orderId': orderId,
      },
    );
  }

  Future<void> recordAuthError({
    required String authMethod,
    required String error,
  }) async {
    await recordException(
      exception: Exception('Auth Error'),
      reason: 'Auth method: $authMethod',
      context: {
        'authMethod': authMethod,
        'error': error,
      },
    );
  }
}

enum Severity { info, warning, error }
