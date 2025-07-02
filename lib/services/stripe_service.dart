import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class StripeService {
  static const String _publishableKey = 'pk_test_51234567890abcdef'; // Replace with your publishable key
  static const String _secretKey = 'sk_test_51234567890abcdef'; // Replace with your secret key
  static const String _baseUrl = 'https://api.stripe.com/v1';

  static Future<void> init() async {
    Stripe.publishableKey = _publishableKey;
    await Stripe.instance.applySettings();
  }

  /// Create payment intent on backend (simulated)
  static Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Convert amount to cents
      int amountInCents = (amount * 100).round();

      // In a real app, this would be a call to your backend
      // For now, we'll simulate the backend call
      final response = await _simulateBackendCall({
        'amount': amountInCents,
        'currency': currency.toLowerCase(),
        'customer': customerId,
        'metadata': metadata ?? {},
        'automatic_payment_methods': {'enabled': true},
      });

      if (response['success'] == true) {
        return {
          'success': true,
          'client_secret': response['client_secret'],
          'payment_intent_id': response['id'],
        };
      } else {
        return {
          'success': false,
          'error': response['error'] ?? 'Failed to create payment intent',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Process payment with Stripe
  static Future<Map<String, dynamic>> processPayment({
    required double amount,
    required String currency,
    Map<String, dynamic>? billingDetails,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Step 1: Create payment intent
      final paymentIntentResult = await createPaymentIntent(
        amount: amount,
        currency: currency,
        metadata: metadata,
      );

      if (paymentIntentResult['success'] != true) {
        return paymentIntentResult;
      }

      // Step 2: Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentResult['client_secret'],
          merchantDisplayName: 'Food Rescue App',
          style: ThemeMode.system,
          billingDetails: billingDetails != null
              ? BillingDetails(
                  email: billingDetails['email'],
                  name: billingDetails['name'],
                  phone: billingDetails['phone'],
                  address: billingDetails['address'] != null
                      ? Address(
                          city: billingDetails['address']['city'],
                          country: billingDetails['address']['country'],
                          line1: billingDetails['address']['line1'],
                          line2: billingDetails['address']['line2'],
                          postalCode: billingDetails['address']['postal_code'],
                          state: billingDetails['address']['state'],
                        )
                      : null,
                )
              : null,
        ),
      );

      // Step 3: Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Step 4: Verify payment on backend (simulated)
      final verificationResult = await _verifyPayment(
        paymentIntentResult['payment_intent_id'],
      );

      return {
        'success': true,
        'payment_intent_id': paymentIntentResult['payment_intent_id'],
        'transaction_id': 'stripe_${paymentIntentResult['payment_intent_id']}',
        'amount': amount,
        'currency': currency,
        'status': verificationResult['status'],
      };
    } on StripeException catch (e) {
      return {
        'success': false,
        'error': _handleStripeError(e),
        'error_code': e.error.code,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Payment failed: ${e.toString()}',
      };
    }
  }

  /// Simulate backend payment intent creation
  static Future<Map<String, dynamic>> _simulateBackendCall(
      Map<String, dynamic> data) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    // Simulate success/failure (90% success rate)
    if (DateTime.now().millisecond % 10 == 0) {
      return {
        'success': false,
        'error': 'Payment declined by bank',
      };
    }

    // Generate mock payment intent
    final paymentIntentId = 'pi_${DateTime.now().millisecondsSinceEpoch}';
    final clientSecret = '${paymentIntentId}_secret_${DateTime.now().microsecondsSinceEpoch}';

    return {
      'success': true,
      'id': paymentIntentId,
      'client_secret': clientSecret,
      'amount': data['amount'],
      'currency': data['currency'],
      'status': 'requires_payment_method',
    };
  }

  /// Verify payment on backend (simulated)
  static Future<Map<String, dynamic>> _verifyPayment(String paymentIntentId) async {
    // Simulate backend verification
    await Future.delayed(Duration(milliseconds: 500));

    return {
      'success': true,
      'status': 'succeeded',
      'payment_intent_id': paymentIntentId,
    };
  }

  /// Handle Stripe errors with user-friendly messages
  static String _handleStripeError(StripeException error) {
    // Use the error message directly or provide a generic message
    final errorMessage = error.error.localizedMessage;
    if (errorMessage != null && errorMessage.isNotEmpty) {
      return errorMessage;
    }

    // Fallback to generic error message
    return 'Payment failed. Please try again with a different payment method.';
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
