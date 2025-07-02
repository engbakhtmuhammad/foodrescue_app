import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../config/app_config.dart';
import '../config/stripe_config.dart';
import 'error_handling_service.dart';
import 'network_service.dart';

class PaymentVerificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Verify payment with Stripe
  static Future<Map<String, dynamic>> verifyStripePayment({
    required String paymentIntentId,
    required double expectedAmount,
    required String orderId,
  }) async {
    try {
      // Get payment intent from Stripe
      final response = await NetworkService.get(
        '${StripeConfig.baseUrl}/payment_intents/$paymentIntentId',
        headers: {
          'Authorization': 'Bearer ${StripeConfig.secretKey}',
        },
      );

      final paymentIntent = json.decode(response.body);

      // Verify payment status
      if (paymentIntent['status'] != 'succeeded') {
        return {
          'success': false,
          'error': 'Payment not completed',
          'status': paymentIntent['status'],
        };
      }

      // Verify amount (convert to cents for comparison)
      final paidAmount = paymentIntent['amount'] / 100.0;
      if ((paidAmount - expectedAmount).abs() > 0.01) {
        await _recordSuspiciousActivity(
          'Amount mismatch',
          {
            'paymentIntentId': paymentIntentId,
            'expectedAmount': expectedAmount,
            'paidAmount': paidAmount,
            'orderId': orderId,
          },
        );
        
        return {
          'success': false,
          'error': 'Payment amount mismatch',
          'expectedAmount': expectedAmount,
          'paidAmount': paidAmount,
        };
      }

      // Verify payment hasn't been used before
      final existingOrder = await _checkPaymentAlreadyUsed(paymentIntentId);
      if (existingOrder != null) {
        await _recordSuspiciousActivity(
          'Duplicate payment attempt',
          {
            'paymentIntentId': paymentIntentId,
            'existingOrderId': existingOrder,
            'newOrderId': orderId,
          },
        );
        
        return {
          'success': false,
          'error': 'Payment already used for another order',
        };
      }

      // Record successful verification
      await _recordPaymentVerification(
        paymentIntentId: paymentIntentId,
        orderId: orderId,
        amount: expectedAmount,
        status: 'verified',
      );

      return {
        'success': true,
        'paymentIntentId': paymentIntentId,
        'amount': paidAmount,
        'status': paymentIntent['status'],
      };

    } catch (e) {
      await ErrorHandlingService.recordError(e, StackTrace.current);
      return {
        'success': false,
        'error': 'Payment verification failed: ${e.toString()}',
      };
    }
  }

  // Check if payment has already been used
  static Future<String?> _checkPaymentAlreadyUsed(String paymentIntentId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConfig.surpriseBagOrdersCollection)
          .where('paymentId', isEqualTo: paymentIntentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      debugPrint('Error checking payment usage: $e');
      return null;
    }
  }

  // Record payment verification
  static Future<void> _recordPaymentVerification({
    required String paymentIntentId,
    required String orderId,
    required double amount,
    required String status,
  }) async {
    try {
      await _firestore.collection('payment_verifications').add({
        'paymentIntentId': paymentIntentId,
        'orderId': orderId,
        'amount': amount,
        'status': status,
        'verifiedAt': FieldValue.serverTimestamp(),
        'userId': _auth.currentUser?.uid,
      });
    } catch (e) {
      debugPrint('Error recording payment verification: $e');
    }
  }

  // Record suspicious activity
  static Future<void> _recordSuspiciousActivity(
    String type,
    Map<String, dynamic> details,
  ) async {
    try {
      await _firestore.collection('suspicious_activities').add({
        'type': type,
        'details': details,
        'userId': _auth.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'severity': 'high',
      });
      
      debugPrint('Suspicious activity recorded: $type');
    } catch (e) {
      debugPrint('Error recording suspicious activity: $e');
    }
  }

  // Generate secure order reference
  static String generateSecureOrderReference() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    final combined = '$timestamp$random';
    
    // Create hash for additional security
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    
    return digest.toString().substring(0, 16).toUpperCase();
  }

  // Validate order integrity
  static Future<bool> validateOrderIntegrity({
    required String orderId,
    required Map<String, dynamic> orderData,
  }) async {
    try {
      // Check if order exists in database
      final orderDoc = await _firestore
          .collection(AppConfig.surpriseBagOrdersCollection)
          .doc(orderId)
          .get();

      if (!orderDoc.exists) {
        await _recordSuspiciousActivity(
          'Order not found',
          {'orderId': orderId, 'orderData': orderData},
        );
        return false;
      }

      final dbOrderData = orderDoc.data()!;

      // Verify critical fields haven't been tampered with
      final criticalFields = ['userId', 'totalAmount', 'paymentStatus', 'surpriseBagId'];
      
      for (final field in criticalFields) {
        if (orderData[field] != dbOrderData[field]) {
          await _recordSuspiciousActivity(
            'Order data mismatch',
            {
              'orderId': orderId,
              'field': field,
              'expectedValue': dbOrderData[field],
              'providedValue': orderData[field],
            },
          );
          return false;
        }
      }

      return true;
    } catch (e) {
      await ErrorHandlingService.recordError(e, StackTrace.current);
      return false;
    }
  }

  // Process refund
  static Future<Map<String, dynamic>> processRefund({
    required String paymentIntentId,
    required String orderId,
    required double amount,
    String? reason,
  }) async {
    try {
      // Create refund via Stripe API
      final response = await NetworkService.post(
        '${StripeConfig.baseUrl}/refunds',
        headers: {
          'Authorization': 'Bearer ${StripeConfig.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'payment_intent': paymentIntentId,
          'amount': (amount * 100).round().toString(), // Convert to cents
          'reason': reason ?? 'requested_by_customer',
          'metadata[order_id]': orderId,
        }.entries.map((e) => '${e.key}=${e.value}').join('&'),
      );

      final refundData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Record refund in database
        await _recordRefund(
          paymentIntentId: paymentIntentId,
          orderId: orderId,
          refundId: refundData['id'],
          amount: amount,
          reason: reason,
          status: refundData['status'],
        );

        return {
          'success': true,
          'refundId': refundData['id'],
          'status': refundData['status'],
          'amount': amount,
        };
      } else {
        return {
          'success': false,
          'error': refundData['error']?['message'] ?? 'Refund failed',
        };
      }
    } catch (e) {
      await ErrorHandlingService.recordError(e, StackTrace.current);
      return {
        'success': false,
        'error': 'Refund processing failed: ${e.toString()}',
      };
    }
  }

  // Record refund
  static Future<void> _recordRefund({
    required String paymentIntentId,
    required String orderId,
    required String refundId,
    required double amount,
    String? reason,
    required String status,
  }) async {
    try {
      await _firestore.collection('refunds').add({
        'paymentIntentId': paymentIntentId,
        'orderId': orderId,
        'refundId': refundId,
        'amount': amount,
        'reason': reason,
        'status': status,
        'processedAt': FieldValue.serverTimestamp(),
        'userId': _auth.currentUser?.uid,
      });

      // Update order status
      await _firestore
          .collection(AppConfig.surpriseBagOrdersCollection)
          .doc(orderId)
          .update({
        'paymentStatus': 'refunded',
        'refundId': refundId,
        'refundAmount': amount,
        'refundedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error recording refund: $e');
    }
  }

  // Check for fraudulent patterns
  static Future<bool> checkFraudulentPatterns({
    required String userId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(Duration(hours: 1));

      // Check for multiple orders in short time
      final recentOrders = await _firestore
          .collection(AppConfig.surpriseBagOrdersCollection)
          .where('userId', isEqualTo: userId)
          .where('orderDate', isGreaterThan: Timestamp.fromDate(oneHourAgo))
          .get();

      if (recentOrders.docs.length > 5) {
        await _recordSuspiciousActivity(
          'Multiple orders in short time',
          {
            'userId': userId,
            'orderCount': recentOrders.docs.length,
            'timeframe': '1 hour',
          },
        );
        return true;
      }

      // Check for unusually high amounts
      if (amount > 100) {
        await _recordSuspiciousActivity(
          'Unusually high amount',
          {
            'userId': userId,
            'amount': amount,
            'paymentMethod': paymentMethod,
          },
        );
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking fraudulent patterns: $e');
      return false;
    }
  }
}
