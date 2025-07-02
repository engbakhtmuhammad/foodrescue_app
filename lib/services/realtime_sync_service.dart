import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_config.dart';
import '../models/surprise_bag_order_model.dart';
import '../controllers/reservation_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/favourites_controller.dart';

class RealtimeSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static StreamSubscription<QuerySnapshot>? _ordersSubscription;
  static StreamSubscription<QuerySnapshot>? _bagsSubscription;
  static StreamSubscription<QuerySnapshot>? _notificationsSubscription;
  
  static bool _isInitialized = false;

  // Initialize real-time synchronization
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Listen to user's orders
      await _listenToUserOrders(user.uid);
      
      // Listen to surprise bags updates
      await _listenToSurpriseBags();
      
      // Listen to notifications
      await _listenToNotifications(user.uid);
      
      _isInitialized = true;
      debugPrint('RealtimeSyncService initialized');
    } catch (e) {
      debugPrint('Error initializing RealtimeSyncService: $e');
    }
  }

  // Stop all listeners
  static Future<void> dispose() async {
    await _ordersSubscription?.cancel();
    await _bagsSubscription?.cancel();
    await _notificationsSubscription?.cancel();
    
    _ordersSubscription = null;
    _bagsSubscription = null;
    _notificationsSubscription = null;
    _isInitialized = false;
    
    debugPrint('RealtimeSyncService disposed');
  }

  // Listen to user's orders for real-time updates
  static Future<void> _listenToUserOrders(String userId) async {
    try {
      _ordersSubscription = _firestore
          .collection(AppConfig.surpriseBagOrdersCollection)
          .where('userId', isEqualTo: userId)
          .snapshots()
          .listen(
        (snapshot) {
          _handleOrdersUpdate(snapshot);
        },
        onError: (error) {
          debugPrint('Error listening to orders: $error');
        },
      );
    } catch (e) {
      debugPrint('Error setting up orders listener: $e');
    }
  }

  // Listen to surprise bags for availability updates
  static Future<void> _listenToSurpriseBags() async {
    try {
      _bagsSubscription = _firestore
          .collection(AppConfig.surpriseBagsCollection)
          .where('isAvailable', isEqualTo: true)
          .where('status', isEqualTo: 'active')
          .snapshots()
          .listen(
        (snapshot) {
          _handleSurpriseBagsUpdate(snapshot);
        },
        onError: (error) {
          debugPrint('Error listening to surprise bags: $error');
        },
      );
    } catch (e) {
      debugPrint('Error setting up surprise bags listener: $e');
    }
  }

  // Listen to user notifications
  static Future<void> _listenToNotifications(String userId) async {
    try {
      _notificationsSubscription = _firestore
          .collection(AppConfig.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots()
          .listen(
        (snapshot) {
          _handleNotificationsUpdate(snapshot);
        },
        onError: (error) {
          debugPrint('Error listening to notifications: $error');
        },
      );
    } catch (e) {
      debugPrint('Error setting up notifications listener: $e');
    }
  }

  // Handle orders updates
  static void _handleOrdersUpdate(QuerySnapshot snapshot) {
    try {
      final reservationController = Get.find<ReservationController>();
      
      // Convert documents to order models
      final orders = snapshot.docs.map((doc) => 
        SurpriseBagOrderModel.fromFirestore(doc)).toList();
      
      // Update the controller's orders
      reservationController.orders.value = orders;
      
      // Check for status changes and show notifications
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          final order = SurpriseBagOrderModel.fromFirestore(change.doc);
          _handleOrderStatusChange(order);
        }
      }
      
      debugPrint('Orders updated: ${orders.length} orders');
    } catch (e) {
      debugPrint('Error handling orders update: $e');
    }
  }

  // Handle surprise bags updates
  static void _handleSurpriseBagsUpdate(QuerySnapshot snapshot) {
    try {
      final homeController = Get.find<HomeController>();
      final favouritesController = Get.find<FavouritesController>();

      // Update surprise bags in home controller
      final bags = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      // Clear and update the surprise bags list
      homeController.surpriseBags.clear();
      homeController.surpriseBags.addAll(bags);
      
      // Sync favorites with updated availability
      favouritesController.syncFavoritesWithAvailability(bags);
      
      // Check for new bags or availability changes
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final bagData = change.doc.data() as Map<String, dynamic>;
          bagData['id'] = change.doc.id;
          _handleNewSurpriseBag(bagData);
        } else if (change.type == DocumentChangeType.modified) {
          final bagData = change.doc.data() as Map<String, dynamic>;
          bagData['id'] = change.doc.id;
          _handleSurpriseBagUpdate(bagData);
        }
      }
      
      debugPrint('Surprise bags updated: ${bags.length} bags');
    } catch (e) {
      debugPrint('Error handling surprise bags update: $e');
    }
  }

  // Handle notifications updates
  static void _handleNotificationsUpdate(QuerySnapshot snapshot) {
    try {
      // Show new notifications to user
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final notificationData = change.doc.data() as Map<String, dynamic>;
          _showRealtimeNotification(notificationData);
        }
      }
      
      debugPrint('Notifications updated: ${snapshot.docs.length} unread');
    } catch (e) {
      debugPrint('Error handling notifications update: $e');
    }
  }

  // Handle order status changes
  static void _handleOrderStatusChange(SurpriseBagOrderModel order) {
    String message = '';
    
    switch (order.status) {
      case 'confirmed':
        message = 'Your order for ${order.surpriseBagTitle} has been confirmed!';
        break;
      case 'ready':
        message = 'Your order for ${order.surpriseBagTitle} is ready for pickup!';
        break;
      case 'completed':
        message = 'Thank you for picking up your order!';
        break;
      case 'cancelled':
        message = 'Your order for ${order.surpriseBagTitle} has been cancelled.';
        break;
    }
    
    if (message.isNotEmpty) {
      Get.snackbar(
        'Order Update',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: _getStatusColor(order.status),
        colorText: Colors.white,
        duration: Duration(seconds: 5),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
      );
    }
  }

  // Handle new surprise bag
  static void _handleNewSurpriseBag(Map<String, dynamic> bagData) {
    // Check if user has this restaurant in favorites
    final favouritesController = Get.find<FavouritesController>();
    final restaurantId = bagData['restaurantId'];
    
    final hasFavoriteFromRestaurant = favouritesController.favourites.any(
      (fav) => fav['restaurantId'] == restaurantId
    );
    
    if (hasFavoriteFromRestaurant) {
      Get.snackbar(
        'New Surprise Bag!',
        'A new surprise bag is available from ${bagData['restaurantName']}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
      );
    }
  }

  // Handle surprise bag updates
  static void _handleSurpriseBagUpdate(Map<String, dynamic> bagData) {
    final favouritesController = Get.find<FavouritesController>();
    final bagId = bagData['id'];
    
    // Check if this bag is in user's favorites
    final isFavorite = favouritesController.isFavourite(bagId);
    
    if (isFavorite) {
      final itemsLeft = int.tryParse(bagData['itemsLeft']?.toString() ?? '0') ?? 0;
      
      if (itemsLeft <= 3 && itemsLeft > 0) {
        Get.snackbar(
          'Limited Stock!',
          'Only $itemsLeft ${bagData['title']} left at ${bagData['restaurantName']}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          margin: EdgeInsets.all(16),
          borderRadius: 8,
        );
      } else if (itemsLeft == 0) {
        Get.snackbar(
          'Sold Out',
          '${bagData['title']} at ${bagData['restaurantName']} is now sold out',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
          margin: EdgeInsets.all(16),
          borderRadius: 8,
        );
      }
    }
  }

  // Show real-time notification
  static void _showRealtimeNotification(Map<String, dynamic> notificationData) {
    final title = notificationData['title'] ?? 'Notification';
    final message = notificationData['message'] ?? '';
    
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 4),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // Get color for order status
  static Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'completed':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Restart listeners (useful after auth state changes)
  static Future<void> restart() async {
    await dispose();
    await initialize();
  }
}
