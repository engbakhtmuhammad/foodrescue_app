import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import '../config/app_config.dart';

class ReservationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  var isLoading = false.obs;
  var reservations = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserReservations();
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
      final reservationRef = _firestore.collection(AppConfig.reservationsCollection).doc();

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
      print("Error reserving surprise bag: $e");
      Get.snackbar("Error", "Failed to reserve surprise bag. Please try again.");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Reserve surprise bag with payment integration
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
      final reservationRef = _firestore.collection(AppConfig.reservationsCollection).doc();

      // Create reservation data using constants with payment info
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
        FieldConstants.reservationPaymentStatus: FieldConstants.paymentPaid, // Mark as paid
        FieldConstants.reservationCode: _generateReservationCode(),
        FieldConstants.reservationPaymentMethod: paymentMethod,
        FieldConstants.reservationTransactionId: transactionId,
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
        "Surprise bag reserved and paid successfully! Your reservation code is ${reservationData[FieldConstants.reservationCode]}",
        duration: Duration(seconds: 4),
      );

      return true;
    } catch (e) {
      print("Error reserving surprise bag with payment: $e");
      Get.snackbar("Error", "Failed to reserve surprise bag. Please try again.");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserReservations() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final querySnapshot = await _firestore
          .collection(AppConfig.reservationsCollection)
          .where(FieldConstants.reservationUserId, isEqualTo: user.uid)
          .orderBy(FieldConstants.reservationTime, descending: true)
          .get();

      reservations.value = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Error loading reservations: $e");
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
      print("Error cancelling reservation: $e");
      Get.snackbar("Error", "Failed to cancel reservation. Please try again.");
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
      print("Error marking as picked up: $e");
      Get.snackbar("Error", "Failed to update status. Please try again.");
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

  // Get active reservations (confirmed)
  List<Map<String, dynamic>> get activeReservations {
    return getReservationsByStatus('confirmed');
  }

  // Get completed reservations (picked up)
  List<Map<String, dynamic>> get completedReservations {
    return getReservationsByStatus('picked_up');
  }

  // Get cancelled reservations
  List<Map<String, dynamic>> get cancelledReservations {
    return getReservationsByStatus('cancelled');
  }

  // Check if user has already reserved a specific bag
  bool hasReservedBag(String bagId) {
    return reservations.any((reservation) => 
      reservation['bagId'] == bagId && 
      reservation['status'] == 'confirmed'
    );
  }
}
