import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import '../config/app_config.dart';
import '../models/surprise_bag_order_model.dart';
import '../services/error_handling_service.dart';
import '../services/payment_verification_service.dart';

class ReservationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = false.obs;
  var reservations = <Map<String, dynamic>>[].obs;
  var orders = <SurpriseBagOrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserReservations();
    loadUserOrders();
  }

  // Computed properties for different order states
  List<SurpriseBagOrderModel> get activeOrders => orders.where((order) =>
    order.status == 'pending' || order.status == 'confirmed' || order.status == 'ready').toList();

  List<SurpriseBagOrderModel> get completedOrders => orders.where((order) =>
    order.status == 'completed').toList();

  List<SurpriseBagOrderModel> get cancelledOrders => orders.where((order) =>
    order.status == 'cancelled').toList();

  // For backward compatibility with existing UI
  List<Map<String, dynamic>> get activeReservations => activeOrders.map((order) => _orderToReservationMap(order)).toList();
  List<Map<String, dynamic>> get completedReservations => completedOrders.map((order) => _orderToReservationMap(order)).toList();
  List<Map<String, dynamic>> get cancelledReservations => cancelledOrders.map((order) => _orderToReservationMap(order)).toList();

  // Convert order model to reservation map for backward compatibility
  Map<String, dynamic> _orderToReservationMap(SurpriseBagOrderModel order) {
    return {
      'id': order.id,
      'userId': order.userId,
      'bagId': order.surpriseBagId,
      'restaurantId': order.restaurantId,
      'status': order.status,
      'paymentStatus': order.paymentStatus,
      'reservationTime': order.orderDate.toIso8601String(),
      'pickupDate': order.pickupDate.toIso8601String().split('T')[0],
      'pickupStartTime': order.pickupTimeSlot.split('-').first,
      'pickupEndTime': order.pickupTimeSlot.split('-').last,
      'price': order.discountedPrice.toString(),
      'originalPrice': order.originalPrice.toString(),
      'reservationCode': order.id.substring(0, 8).toUpperCase(),
      'paymentMethod': order.paymentMethod,
      'transactionId': order.paymentId,
      'bagData': {
        'title': order.surpriseBagTitle,
        'restaurantName': order.restaurantName,
        'discountedPrice': order.discountedPrice,
        'originalPrice': order.originalPrice,
      },
      'restaurantData': {
        'title': order.restaurantName,
      },
    };
  }

  Future<bool> reserveSurpriseBag({
    required String bagId,
    required String restaurantId,
    required Map<String, dynamic> bagData,
    required Map<String, dynamic> restaurantData,
  }) async {
    try {
      isLoading.value = true;
      
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar("Error", "Please login to make a reservation");
        return false;
      }

      // Check if bag is still available
      final bagDoc = await _firestore.collection(AppConfig.surpriseBagsCollection).doc(bagId).get();
      if (!bagDoc.exists) {
        Get.snackbar("Error", "Surprise bag not found");
        return false;
      }

      final bagInfo = bagDoc.data()!;
      // Handle both new and legacy field names for quantity
      final currentQuantity = int.tryParse(
        bagInfo[FieldConstants.bagItemsLeft]?.toString() ??
        bagInfo[FieldConstants.bagQuantity]?.toString() ?? '0'
      ) ?? 0;
      
      if (currentQuantity <= 0) {
        Get.snackbar("Error", "This surprise bag is no longer available");
        return false;
      }

      // Generate reservation document reference first
      final reservationRef = _firestore.collection(AppConfig.surpriseBagOrdersCollection).doc();

      // Create reservation data using constants
      final reservationData = {
        FieldConstants.reservationId: reservationRef.id,
        FieldConstants.reservationUserId: user.uid,
        FieldConstants.reservationBagId: bagId,
        FieldConstants.reservationRestaurantId: restaurantId,
        FieldConstants.reservationBagData: bagData,
        FieldConstants.reservationRestaurantData: restaurantData,
        FieldConstants.reservationStatus: FieldConstants.statusConfirmed,
        FieldConstants.reservationTime: FieldValue.serverTimestamp(),
        // Handle both new and legacy field names for pickup times
        FieldConstants.reservationPickupStartTime: bagData[FieldConstants.bagTodayPickupStart] ??
                                                   bagData[FieldConstants.bagPickupStartTime] ?? '18:00',
        FieldConstants.reservationPickupEndTime: bagData[FieldConstants.bagTodayPickupEnd] ??
                                                 bagData[FieldConstants.bagPickupEndTime] ?? '20:00',
        FieldConstants.reservationPickupDate: DateTime.now().toIso8601String().split('T')[0],
        FieldConstants.reservationPrice: bagData[FieldConstants.bagDiscountedPrice] ??
                                        bagData['price'] ?? '9.99',
        FieldConstants.reservationOriginalPrice: bagData[FieldConstants.bagOriginalPrice] ?? '29.99',
        FieldConstants.reservationPaymentStatus: FieldConstants.paymentPending,
        FieldConstants.reservationCode: _generateReservationCode(),
        FieldConstants.reservationPaymentMethod: '', // Will be set during payment
        FieldConstants.reservationTransactionId: '', // Will be set during payment
      };

      // Save reservation using the reference we created
      await reservationRef.set(reservationData);

      // Update bag quantity using constants
      await _firestore.collection(AppConfig.surpriseBagsCollection).doc(bagId).update({
        FieldConstants.bagItemsLeft: (currentQuantity - 1).toString(),
        FieldConstants.bagUpdatedAt: FieldValue.serverTimestamp(),
      });

      // Reload user reservations
      await loadUserReservations();

      Get.snackbar(
        "Success",
        "Surprise bag reserved successfully! Your reservation code is ${reservationData[FieldConstants.reservationCode]}",
        duration: Duration(seconds: 4),
      );
      
      return true;
    } catch (e) {
      final error = ErrorHandlingService.handleFirebaseError(e);
      await ErrorHandlingService.recordError(e, StackTrace.current);
      ErrorHandlingService.showErrorToUser(error);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Reserve surprise bag with payment integration using new order model
  Future<bool> reserveSurpriseBagWithPayment({
    required String bagId,
    required String restaurantId,
    required Map<String, dynamic> bagData,
    required Map<String, dynamic> restaurantData,
    required String paymentMethod,
    required String transactionId,
  }) async {
    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar("Error", "Please login to make a reservation");
        return false;
      }

      // Get user data for the order
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      // Check for fraudulent patterns
      final totalAmount = double.tryParse(bagData[FieldConstants.bagDiscountedPrice]?.toString() ?? '0') ?? 0.0;
      final isFraudulent = await PaymentVerificationService.checkFraudulentPatterns(
        userId: user.uid,
        amount: totalAmount,
        paymentMethod: paymentMethod,
      );

      if (isFraudulent) {
        Get.snackbar("Security Alert", "Order flagged for review. Please contact support.");
        return false;
      }

      // Verify payment if transaction ID is provided
      if (transactionId.isNotEmpty) {
        final verificationResult = await PaymentVerificationService.verifyStripePayment(
          paymentIntentId: transactionId,
          expectedAmount: totalAmount,
          orderId: '', // Will be set after order creation
        );

        if (!verificationResult['success']) {
          Get.snackbar("Payment Error", verificationResult['error'] ?? 'Payment verification failed');
          return false;
        }
      }

      // Check if bag is still available
      final bagDoc = await _firestore.collection(AppConfig.surpriseBagsCollection).doc(bagId).get();
      if (!bagDoc.exists) {
        Get.snackbar("Error", "Surprise bag not found");
        return false;
      }

      final bagInfo = bagDoc.data()!;
      final currentQuantity = int.tryParse(
        bagInfo[FieldConstants.bagItemsLeft]?.toString() ??
        bagInfo[FieldConstants.bagQuantity]?.toString() ?? '0'
      ) ?? 0;

      if (currentQuantity <= 0) {
        Get.snackbar("Error", "This surprise bag is no longer available");
        return false;
      }

      // Create order using the new model
      final now = DateTime.now();
      final pickupDate = now.add(Duration(days: 1)); // Default to tomorrow
      final pickupStartTime = bagData[FieldConstants.bagTodayPickupStart] ?? '18:00';
      final pickupEndTime = bagData[FieldConstants.bagTodayPickupEnd] ?? '20:00';

      final order = SurpriseBagOrderModel(
        id: '', // Will be set by Firestore
        userId: user.uid,
        userName: userData['name'] ?? user.displayName ?? 'Unknown User',
        userEmail: userData['email'] ?? user.email ?? '',
        userPhone: userData['mobile'] ?? user.phoneNumber ?? '',
        surpriseBagId: bagId,
        surpriseBagTitle: bagData['title'] ?? 'Surprise Bag',
        restaurantId: restaurantId,
        restaurantName: restaurantData['title'] ?? 'Unknown Restaurant',
        originalPrice: double.tryParse(bagData[FieldConstants.bagOriginalPrice]?.toString() ?? '0') ?? 0.0,
        discountedPrice: double.tryParse(bagData[FieldConstants.bagDiscountedPrice]?.toString() ?? '0') ?? 0.0,
        totalAmount: double.tryParse(bagData[FieldConstants.bagDiscountedPrice]?.toString() ?? '0') ?? 0.0,
        quantity: 1,
        status: 'pending', // Will be confirmed by restaurant
        paymentStatus: 'paid',
        paymentMethod: paymentMethod,
        paymentId: transactionId,
        pickupDate: pickupDate,
        pickupTimeSlot: '$pickupStartTime-$pickupEndTime',
        pickupInstructions: bagData['pickupInstructions'] ?? '',
        orderDate: now,
        createdAt: now,
        updatedAt: now,
      );

      // Save order to Firestore
      final orderRef = await _firestore.collection(AppConfig.surpriseBagOrdersCollection).add(order.toMap());

      // Update bag quantity
      await _firestore.collection(AppConfig.surpriseBagsCollection).doc(bagId).update({
        FieldConstants.bagItemsLeft: (currentQuantity - 1).toString(),
        FieldConstants.bagUpdatedAt: FieldValue.serverTimestamp(),
      });

      // Reload user orders and reservations
      await loadUserOrders();
      await loadUserReservations();

      Get.snackbar(
        "Success",
        "Surprise bag reserved and paid successfully! Order ID: ${orderRef.id.substring(0, 8).toUpperCase()}",
        duration: Duration(seconds: 4),
      );

      return true;
    } catch (e) {
      debugPrint("Error reserving surprise bag with payment: $e");
      Get.snackbar("Error", "Failed to reserve surprise bag. Please try again.");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Load user orders using the new order model
  Future<void> loadUserOrders() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      isLoading.value = true;

      final querySnapshot = await _firestore
          .collection(AppConfig.surpriseBagOrdersCollection)
          .where('userId', isEqualTo: user.uid)
          .orderBy('orderDate', descending: true)
          .get();

      orders.value = querySnapshot.docs.map((doc) =>
        SurpriseBagOrderModel.fromFirestore(doc)).toList();

    } catch (e) {
      debugPrint("Error loading orders: $e");
      Get.snackbar("Error", "Failed to load your orders");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserReservations() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final querySnapshot = await _firestore
          .collection(AppConfig.surpriseBagOrdersCollection)
          .where(FieldConstants.reservationUserId, isEqualTo: user.uid)
          .orderBy(FieldConstants.reservationTime, descending: true)
          .get();

      reservations.value = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint("Error loading reservations: $e");
    }
  }

  Future<bool> cancelReservation(String reservationId) async {
    try {
      isLoading.value = true;

      final reservationDoc = await _firestore.collection('reservations').doc(reservationId).get();
      if (!reservationDoc.exists) {
        Get.snackbar("Error", "Reservation not found");
        return false;
      }

      final reservationData = reservationDoc.data()!;
      
      // Check if reservation can be cancelled (not picked up)
      if (reservationData['status'] == 'picked_up') {
        Get.snackbar("Error", "Cannot cancel a reservation that has already been picked up");
        return false;
      }

      // Update reservation status
      await _firestore.collection('reservations').doc(reservationId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      // Restore bag quantity
      final bagId = reservationData['bagId'];
      final bagDoc = await _firestore.collection('surprise_bags').doc(bagId).get();
      if (bagDoc.exists) {
        final bagData = bagDoc.data()!;
        final currentQuantity = int.tryParse(bagData['itemsLeft']?.toString() ?? '0') ?? 0;
        
        await _firestore.collection('surprise_bags').doc(bagId).update({
          'itemsLeft': (currentQuantity + 1).toString(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Reload reservations
      await loadUserReservations();

      Get.snackbar("Success", "Reservation cancelled successfully");
      return true;
    } catch (e) {
      final error = ErrorHandlingService.handleFirebaseError(e);
      await ErrorHandlingService.recordError(e, StackTrace.current);
      ErrorHandlingService.showErrorToUser(error);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> markAsPickedUp(String reservationId) async {
    try {
      isLoading.value = true;

      await _firestore.collection('reservations').doc(reservationId).update({
        'status': 'picked_up',
        'pickedUpAt': FieldValue.serverTimestamp(),
        'paymentStatus': 'paid',
      });

      await loadUserReservations();

      Get.snackbar("Success", "Marked as picked up successfully");
      return true;
    } catch (e) {
      final error = ErrorHandlingService.handleFirebaseError(e);
      await ErrorHandlingService.recordError(e, StackTrace.current);
      ErrorHandlingService.showErrorToUser(error);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String _generateReservationCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    
    for (int i = 0; i < 6; i++) {
      code += chars[(random + i) % chars.length];
    }
    
    return code;
  }

  // Get reservations by status
  List<Map<String, dynamic>> getReservationsByStatus(String status) {
    return reservations.where((reservation) => reservation['status'] == status).toList();
  }

  // Legacy getters removed - using the new order-based getters defined earlier

  // Check if user has already reserved a specific bag
  bool hasReservedBag(String bagId) {
    return reservations.any((reservation) => 
      reservation['bagId'] == bagId && 
      reservation['status'] == 'confirmed'
    );
  }
}
