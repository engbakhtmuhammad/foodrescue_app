import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import '../config/stripe_config.dart';
import 'error_handling_service.dart';

class StripeService {
  static const String _publishableKey = StripeConfig.publishableKey;

  static Future<void> init() async {
    Stripe.publishableKey = _publishableKey;
    await Stripe.instance.applySettings();
  }

  /// Create payment intent (Mock implementation for testing)
  /// In production, this should be done on your backend server
  static Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // For testing purposes, create a mock payment intent
      // In production, you would call your backend API

      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      // Generate mock payment intent
      final paymentIntentId = 'pi_test_${DateTime.now().millisecondsSinceEpoch}';
      final clientSecret = '${paymentIntentId}_secret_${DateTime.now().microsecondsSinceEpoch}';

      return {
        'success': true,
        'client_secret': clientSecret,
        'payment_intent_id': paymentIntentId,
        'amount': (amount * 100).round(),
        'currency': currency.toLowerCase(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Process payment with Stripe (Mock implementation for testing)
  static Future<Map<String, dynamic>> processPayment({
    required double amount,
    required String currency,
    Map<String, dynamic>? billingDetails,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // For testing purposes, simulate payment processing
      // In production, you would use real Stripe payment sheet

      // Show a mock payment dialog
      bool paymentConfirmed = await _showMockPaymentDialog(amount, currency);

      if (!paymentConfirmed) {
        return {
          'success': false,
          'error': 'Payment cancelled by user',
        };
      }

      // Simulate payment processing delay
      await Future.delayed(Duration(seconds: 2));

      // Generate mock payment result
      final paymentIntentId = 'pi_test_${DateTime.now().millisecondsSinceEpoch}';

      return {
        'success': true,
        'payment_intent_id': paymentIntentId,
        'transaction_id': 'stripe_$paymentIntentId',
        'amount': amount,
        'currency': currency,
        'status': 'succeeded',
      };
    } catch (e) {
      final error = ErrorHandlingService.handlePaymentError(e, paymentMethod: 'stripe');
      await ErrorHandlingService.recordError(e, StackTrace.current);
      return {
        'success': false,
        'error': error.message,
      };
    }
  }

  /// Show mock payment dialog for testing
  static Future<bool> _showMockPaymentDialog(double amount, String currency) async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: Text('Mock Stripe Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Amount: \$${amount.toStringAsFixed(2)} $currency'),
            SizedBox(height: 16),
            Text('This is a test payment. In production, this would show the real Stripe payment sheet.'),
            SizedBox(height: 16),
            Text('Test Card: 4242 4242 4242 4242'),
            Text('Expiry: 12/34 | CVC: 123'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text('Pay Now'),
          ),
        ],
      ),
    ) ?? false;
  }





  /// Create customer (for future use)
  static Future<Map<String, dynamic>> createCustomer({
    required String email,
    String? name,
    String? phone,
  }) async {
    try {
      // In a real app, this would be a backend call
      await Future.delayed(Duration(milliseconds: 500));

      final customerId = 'cus_${DateTime.now().millisecondsSinceEpoch}';

      return {
        'success': true,
        'customer_id': customerId,
        'email': email,
        'name': name,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get payment methods for customer (for future use)
  static Future<List<Map<String, dynamic>>> getPaymentMethods(String customerId) async {
    try {
      // In a real app, this would be a backend call
      await Future.delayed(Duration(milliseconds: 300));

      // Return mock payment methods
      return [
        {
          'id': 'pm_1234567890',
          'type': 'card',
          'card': {
            'brand': 'visa',
            'last4': '4242',
            'exp_month': 12,
            'exp_year': 2025,
          }
        }
      ];
    } catch (e) {
      return [];
    }
  }
}
