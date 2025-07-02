import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

enum ErrorType {
  network,
  authentication,
  payment,
  firestore,
  validation,
  unknown,
}

enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

class AppError {
  final String code;
  final String message;
  final String? details;
  final ErrorType type;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final Map<String, dynamic>? context;

  AppError({
    required this.code,
    required this.message,
    this.details,
    required this.type,
    required this.severity,
    DateTime? timestamp,
    this.context,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'message': message,
      'details': details,
      'type': type.toString(),
      'severity': severity.toString(),
      'timestamp': timestamp.toIso8601String(),
      'context': context,
    };
  }
}

class ErrorHandlingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Initialize error handling
  static Future<void> initialize() async {
    // Set up Flutter error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      recordError(
        details.exception,
        details.stack,
        context: {
          'library': details.library,
          'context': details.context?.toString(),
        },
      );
    };

    // Set up platform dispatcher error handling
    PlatformDispatcher.instance.onError = (error, stack) {
      recordError(error, stack);
      return true;
    };
  }

  // Record error to Firebase Crashlytics and local storage
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    Map<String, dynamic>? context,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) async {
    try {
      // Log to console in debug mode
      if (kDebugMode) {
        debugPrint('Error recorded: $exception');
        if (stackTrace != null) {
          debugPrint('Stack trace: $stackTrace');
        }
      }

      // Record to Firebase Crashlytics if available
      if (!kDebugMode) {
        await FirebaseCrashlytics.instance.recordError(
          exception,
          stackTrace,
          information: [context?.toString() ?? ''],
        );
      }

      // Store error locally for offline analysis
      await _storeErrorLocally(exception, stackTrace, context, severity);

    } catch (e) {
      debugPrint('Failed to record error: $e');
    }
  }

  // Store error in local Firestore for analysis
  static Future<void> _storeErrorLocally(
    dynamic exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    ErrorSeverity severity,
  ) async {
    try {
      final user = _auth.currentUser;
      final errorData = {
        'exception': exception.toString(),
        'stackTrace': stackTrace?.toString(),
        'context': context,
        'severity': severity.toString(),
        'userId': user?.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem,
        'appVersion': '1.0.0', // You can get this from package_info
      };

      await _firestore.collection('error_logs').add(errorData);
    } catch (e) {
      debugPrint('Failed to store error locally: $e');
    }
  }

  // Handle specific error types
  static AppError handleFirebaseError(dynamic error) {
    if (error is FirebaseAuthException) {
      return _handleAuthError(error);
    } else if (error is FirebaseException) {
      return _handleFirestoreError(error);
    } else {
      return AppError(
        code: 'unknown_firebase_error',
        message: 'An unexpected Firebase error occurred',
        details: error.toString(),
        type: ErrorType.unknown,
        severity: ErrorSeverity.medium,
      );
    }
  }

  static AppError _handleAuthError(FirebaseAuthException error) {
    String message;
    ErrorSeverity severity = ErrorSeverity.medium;

    switch (error.code) {
      case 'user-not-found':
        message = 'No account found with this email address';
        break;
      case 'wrong-password':
        message = 'Incorrect password';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email';
        break;
      case 'weak-password':
        message = 'Password is too weak';
        break;
      case 'invalid-email':
        message = 'Invalid email address';
        break;
      case 'user-disabled':
        message = 'This account has been disabled';
        severity = ErrorSeverity.high;
        break;
      case 'too-many-requests':
        message = 'Too many failed attempts. Please try again later';
        severity = ErrorSeverity.high;
        break;
      default:
        message = 'Authentication failed: ${error.message}';
    }

    return AppError(
      code: error.code,
      message: message,
      details: error.message,
      type: ErrorType.authentication,
      severity: severity,
    );
  }

  static AppError _handleFirestoreError(FirebaseException error) {
    String message;
    ErrorSeverity severity = ErrorSeverity.medium;

    switch (error.code) {
      case 'permission-denied':
        message = 'You don\'t have permission to perform this action';
        severity = ErrorSeverity.high;
        break;
      case 'unavailable':
        message = 'Service is currently unavailable. Please try again';
        severity = ErrorSeverity.high;
        break;
      case 'deadline-exceeded':
        message = 'Request timed out. Please check your connection';
        break;
      case 'resource-exhausted':
        message = 'Service quota exceeded. Please try again later';
        severity = ErrorSeverity.high;
        break;
      default:
        message = 'Database error: ${error.message}';
    }

    return AppError(
      code: error.code,
      message: message,
      details: error.message,
      type: ErrorType.firestore,
      severity: severity,
    );
  }

  // Handle network errors
  static AppError handleNetworkError(dynamic error) {
    String message = 'Network error occurred';
    ErrorSeverity severity = ErrorSeverity.medium;

    if (error is SocketException) {
      message = 'No internet connection. Please check your network';
      severity = ErrorSeverity.high;
    } else if (error.toString().contains('timeout')) {
      message = 'Request timed out. Please try again';
    }

    return AppError(
      code: 'network_error',
      message: message,
      details: error.toString(),
      type: ErrorType.network,
      severity: severity,
    );
  }

  // Handle payment errors
  static AppError handlePaymentError(dynamic error, {String? paymentMethod}) {
    String message = 'Payment failed. Please try again';
    ErrorSeverity severity = ErrorSeverity.high;

    if (error.toString().contains('card_declined')) {
      message = 'Your card was declined. Please try a different payment method';
    } else if (error.toString().contains('insufficient_funds')) {
      message = 'Insufficient funds. Please try a different payment method';
    } else if (error.toString().contains('expired_card')) {
      message = 'Your card has expired. Please try a different payment method';
    } else if (error.toString().contains('incorrect_cvc')) {
      message = 'Incorrect security code. Please check and try again';
    }

    return AppError(
      code: 'payment_error',
      message: message,
      details: error.toString(),
      type: ErrorType.payment,
      severity: severity,
      context: {'paymentMethod': paymentMethod},
    );
  }

  // Show user-friendly error message
  static void showErrorToUser(AppError error) {
    Color backgroundColor;
    IconData icon;

    switch (error.severity) {
      case ErrorSeverity.low:
        backgroundColor = Colors.blue;
        icon = Icons.info;
        break;
      case ErrorSeverity.medium:
        backgroundColor = Colors.orange;
        icon = Icons.warning;
        break;
      case ErrorSeverity.high:
      case ErrorSeverity.critical:
        backgroundColor = Colors.red;
        icon = Icons.error;
        break;
    }

    Get.snackbar(
      'Error',
      error.message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      duration: Duration(seconds: error.severity == ErrorSeverity.critical ? 10 : 5),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // Retry mechanism for failed operations
  static Future<T> retryOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempts++;
        
        if (attempts >= maxRetries || (shouldRetry != null && !shouldRetry(error))) {
          rethrow;
        }
        
        await Future.delayed(delay * attempts); // Exponential backoff
      }
    }
    
    throw Exception('Max retry attempts exceeded');
  }
}
