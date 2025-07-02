import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:get/get.dart';

class RazorPayService {
  static const String _keyId = 'rzp_test_1234567890'; // Replace with your key ID
  static const String _keySecret = 'YOUR_RAZORPAY_SECRET'; // Replace with your secret
  
  static Razorpay? _razorpay;
  static Function(Map<String, dynamic>)? _onSuccess;
  static Function(String)? _onError;

  /// Initialize RazorPay
  static void init() {
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// Process RazorPay payment
  static Future<Map<String, dynamic>> processPayment({
    required double amount,
    required String currency,
    required String description,
    Map<String, dynamic>? userInfo,
    Function(Map<String, dynamic>)? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      // Initialize if not already done
      if (_razorpay == null) {
        init();
      }

      // Set callbacks
      _onSuccess = onSuccess;
      _onError = onError;

      // Convert amount to paise (smallest currency unit)
      int amountInPaise = (amount * 100).round();

      // Create order on backend (simulated)
      final orderResult = await _createOrder(
        amount: amountInPaise,
        currency: currency,
        description: description,
      );

      if (orderResult['success'] != true) {
        return orderResult;
      }

      // Configure payment options
      var options = {
        'key': _keyId,
        'amount': amountInPaise,
        'currency': currency.toUpperCase(),
        'name': 'Food Rescue App',
        'description': description,
        'order_id': orderResult['order_id'],
        'prefill': {
          'contact': userInfo?['phone'] ?? '',
          'email': userInfo?['email'] ?? '',
          'name': userInfo?['name'] ?? '',
        },
        'theme': {
          'color': '#FF6B35', // Orange color matching app theme
        },
        'modal': {
          'ondismiss': () {
            _onError?.call('Payment cancelled by user');
          }
        },
        'notes': {
          'app_name': 'Food Rescue App',
          'order_type': 'surprise_bag',
        }
      };

      // Open RazorPay checkout
      _razorpay!.open(options);

      // Return pending status (actual result will come through callbacks)
      return {
        'success': true,
        'status': 'pending',
        'order_id': orderResult['order_id'],
        'message': 'Payment initiated. Please complete the payment.',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'RazorPay initialization failed: ${e.toString()}',
      };
    }
  }

  /// Create order on backend (simulated)
  static Future<Map<String, dynamic>> _createOrder({
    required int amount,
    required String currency,
    required String description,
  }) async {
    try {
      // Simulate backend API call
      await Future.delayed(Duration(seconds: 1));

      // Simulate failure (5% chance)
      if (DateTime.now().millisecond % 20 == 0) {
        return {
          'success': false,
          'error': 'Failed to create order. Please try again.',
        };
      }

      // Generate mock order
      final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';

      return {
        'success': true,
        'order_id': orderId,
        'amount': amount,
        'currency': currency,
        'status': 'created',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Order creation failed: ${e.toString()}',
      };
    }
  }

  /// Handle payment success
  static void _handlePaymentSuccess(PaymentSuccessResponse response) {
    final result = {
      'success': true,
      'payment_id': response.paymentId,
      'order_id': response.orderId,
      'signature': response.signature,
      'transaction_id': 'razorpay_${response.paymentId}',
      'status': 'success',
      'payment_method': 'razorpay',
      'created_time': DateTime.now().toIso8601String(),
    };

    _onSuccess?.call(result);
  }

  /// Handle payment error
  static void _handlePaymentError(PaymentFailureResponse response) {
    String errorMessage = _getErrorMessage(response.code, response.message);
    _onError?.call(errorMessage);
  }

  /// Handle external wallet
  static void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar(
      'External Wallet',
      'Selected wallet: ${response.walletName}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Get user-friendly error message
  static String _getErrorMessage(int? code, String? message) {
    switch (code) {
      case Razorpay.PAYMENT_CANCELLED:
        return 'Payment was cancelled by user';
      case Razorpay.NETWORK_ERROR:
        return 'Network error. Please check your internet connection';
      default:
        return message ?? 'Payment failed. Please try again';
    }
  }

  /// Verify payment signature (backend call)
  static Future<Map<String, dynamic>> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      // In a real app, this would verify the signature on your backend
      await Future.delayed(Duration(milliseconds: 500));

      // Simulate verification
      // In production, you would use HMAC SHA256 to verify:
      // generated_signature = hmac_sha256(order_id + "|" + payment_id, secret);
      // if (generated_signature == signature) { verified = true; }

      return {
        'success': true,
        'verified': true,
        'payment_id': paymentId,
        'order_id': orderId,
        'status': 'captured',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Payment verification failed: ${e.toString()}',
      };
    }
  }

  /// Capture payment (for authorized payments)
  static Future<Map<String, dynamic>> capturePayment({
    required String paymentId,
    required int amount,
  }) async {
    try {
      // In a real app, this would capture the payment via RazorPay API
      await Future.delayed(Duration(milliseconds: 300));

      return {
        'success': true,
        'payment_id': paymentId,
        'amount': amount,
        'status': 'captured',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Payment capture failed: ${e.toString()}',
      };
    }
  }

  /// Refund payment
  static Future<Map<String, dynamic>> refundPayment({
    required String paymentId,
    required int amount,
    String? reason,
  }) async {
    try {
      // In a real app, this would process refund via RazorPay API
      await Future.delayed(Duration(seconds: 1));

      final refundId = 'rfnd_${DateTime.now().millisecondsSinceEpoch}';

      return {
        'success': true,
        'refund_id': refundId,
        'payment_id': paymentId,
        'amount': amount,
        'status': 'processed',
        'reason': reason,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Refund failed: ${e.toString()}',
      };
    }
  }

  /// Get payment details
  static Future<Map<String, dynamic>> getPaymentDetails(String paymentId) async {
    try {
      // In a real app, this would fetch from RazorPay API
      await Future.delayed(Duration(milliseconds: 300));

      return {
        'success': true,
        'payment_id': paymentId,
        'amount': 999, // Amount in paise
        'currency': 'INR',
        'status': 'captured',
        'method': 'card',
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to get payment details: ${e.toString()}',
      };
    }
  }

  /// Dispose RazorPay instance
  static void dispose() {
    _razorpay?.clear();
    _razorpay = null;
    _onSuccess = null;
    _onError = null;
  }

  /// Check if RazorPay is available
  static bool isAvailable() {
    return _razorpay != null;
  }

  /// Get supported payment methods
  static List<String> getSupportedMethods() {
    return [
      'card',
      'netbanking',
      'wallet',
      'upi',
      'emi',
      'cardless_emi',
      'paylater',
    ];
  }
}
