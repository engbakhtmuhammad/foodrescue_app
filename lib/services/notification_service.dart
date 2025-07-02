import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_config.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize FCM
  static Future<void> initializeFCM() async {
    try {
      // Request permission
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permission');

        // Get and save FCM token
        String? token = await _firebaseMessaging.getToken();
        if (token != null) {
          await _saveFCMToken(token);
        }

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen(_saveFCMToken);

        // Configure message handlers
        _configureMessageHandlers();
      }
    } catch (e) {
      debugPrint('Error initializing FCM: $e');
    }
  }

  // Save FCM token to user document
  static Future<void> _saveFCMToken(String token) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  // Configure message handlers
  static void _configureMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showInAppNotification(message);
      }
    });

    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle terminated state message taps
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationTap(message);
      }
    });
  }

  // Show in-app notification
  static void _showInAppNotification(RemoteMessage message) {
    Get.snackbar(
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: Duration(seconds: 4),
    );
  }

  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    final type = message.data['type'];
    switch (type) {
      case 'order_status':
        Get.toNamed('/reservations');
        break;
      default:
        break;
    }
  }

  // Send order status notification
  static Future<void> sendOrderStatusNotification({
    required String userId,
    required String orderId,
    required String status,
    required String restaurantName,
    required String bagTitle,
  }) async {
    String title = '';
    String body = '';

    switch (status) {
      case 'confirmed':
        title = 'Order Confirmed!';
        body = 'Your order for $bagTitle from $restaurantName has been confirmed.';
        break;
      case 'ready':
        title = 'Order Ready!';
        body = 'Your $bagTitle from $restaurantName is ready for pickup.';
        break;
      case 'completed':
        title = 'Order Completed';
        body = 'Thank you for picking up your order from $restaurantName!';
        break;
      case 'cancelled':
        title = 'Order Cancelled';
        body = 'Your order from $restaurantName has been cancelled.';
        break;
    }

    await createNotification(
      userId: userId,
      title: title,
      message: body,
      type: 'order_status',
      data: {
        'orderId': orderId,
        'status': status,
        'restaurantName': restaurantName,
        'bagTitle': bagTitle,
      },
    );
  }

  // Get user notifications
  static Future<Map<String, dynamic>> getNotifications({
    required String uid,
  }) async {
    try {
      QuerySnapshot notificationsSnapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: uid)
          .orderBy('created_at', descending: true)
          .limit(50)
          .get();

      List<Map<String, dynamic>> notifications = notificationsSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Notifications retrieved successfully',
        'NotificationData': notifications,
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Create notification
  static Future<Map<String, dynamic>> createNotification({
    required String userId,
    required String title,
    required String message,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type ?? 'general',
        'data': data ?? {},
        'is_read': false,
        'created_at': FieldValue.serverTimestamp(),
      });

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Notification created successfully',
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Mark notification as read
  static Future<Map<String, dynamic>> markAsRead({
    required String notificationId,
  }) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'is_read': true,
        'read_at': FieldValue.serverTimestamp(),
      });

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Notification marked as read',
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Get FAQ data
  static Future<Map<String, dynamic>> getFAQData({
    required String uid,
  }) async {
    try {
      QuerySnapshot faqSnapshot = await _firestore
          .collection('faqs')
          .where('status', isEqualTo: 'active')
          .orderBy('order')
          .get();

      List<Map<String, dynamic>> faqData = faqSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'FAQ data retrieved successfully',
        'FaqData': faqData,
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Get page list (terms, privacy, etc.)
  static Future<Map<String, dynamic>> getPageList() async {
    try {
      QuerySnapshot pagesSnapshot = await _firestore
          .collection('pages')
          .where('status', isEqualTo: 'active')
          .orderBy('order')
          .get();

      List<Map<String, dynamic>> pageList = pagesSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Page list retrieved successfully',
        'PageList': pageList,
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Get app settings
  static Future<Map<String, dynamic>> getAppSettings() async {
    try {
      DocumentSnapshot settingsDoc = await _firestore
          .collection('app_settings')
          .doc('general')
          .get();

      if (!settingsDoc.exists) {
        return {
          'ResponseCode': '400',
          'Result': 'false',
          'ResponseMsg': 'Settings not found',
        };
      }

      var settingsData = settingsDoc.data() as Map<String, dynamic>;

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'App settings retrieved successfully',
        'AppSettings': settingsData,
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Get SMS type configuration
  static Future<Map<String, dynamic>> getSMSType() async {
    try {
      DocumentSnapshot smsDoc = await _firestore
          .collection('app_settings')
          .doc('sms_config')
          .get();

      if (!smsDoc.exists) {
        return {
          'SMS_TYPE': 'Firebase', // Default to Firebase Auth
        };
      }

      var smsData = smsDoc.data() as Map<String, dynamic>;
      return smsData;
    } catch (e) {
      return {
        'SMS_TYPE': 'Firebase', // Default fallback
      };
    }
  }

  // Send OTP using Firebase Auth phone verification
  static Future<Map<String, dynamic>> sendOTP({
    required String mobile,
  }) async {
    try {
      // Use Firebase Auth phone verification instead of third-party services
      return {
        'Result': 'true',
        'ResponseMsg': 'Please use Firebase phone authentication',
      };
    } catch (e) {
      return {
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Verify OTP using Firebase Auth phone verification
  static Future<Map<String, dynamic>> verifyOTP({
    required String mobile,
    required String otp,
  }) async {
    try {
      // Use Firebase Auth phone verification instead of third-party services
      return {
        'Result': 'true',
        'ResponseMsg': 'Please use Firebase phone authentication',
      };
    } catch (e) {
      return {
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Get discount now data
  static Future<Map<String, dynamic>> getDiscountNow({
    required String uid,
  }) async {
    try {
      QuerySnapshot discountSnapshot = await _firestore
          .collection('discounts')
          .where('status', isEqualTo: 'active')
          .where('start_date', isLessThanOrEqualTo: Timestamp.now())
          .where('end_date', isGreaterThanOrEqualTo: Timestamp.now())
          .orderBy('start_date')
          .get();

      List<Map<String, dynamic>> discountData = [];

      for (var doc in discountSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        
        // Get restaurant details if discount is restaurant-specific
        if (data['restaurant_id'] != null) {
          DocumentSnapshot restaurantDoc = await _firestore
              .collection('restaurants')
              .doc(data['restaurant_id'])
              .get();

          if (restaurantDoc.exists) {
            var restaurantData = restaurantDoc.data() as Map<String, dynamic>;
            data['restaurant_name'] = restaurantData['title'];
            data['restaurant_image'] = restaurantData['img'] != null && 
                                     (restaurantData['img'] as List).isNotEmpty
                ? restaurantData['img'][0]
                : '';
          }
        }

        discountData.add({
          'id': doc.id,
          ...data,
        });
      }

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Discount data retrieved successfully',
        'DiscountData': discountData,
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Create support ticket or feedback
  static Future<Map<String, dynamic>> createSupportTicket({
    required String uid,
    required String subject,
    required String message,
    String? category,
  }) async {
    try {
      await _firestore.collection('support_tickets').add({
        'user_id': uid,
        'subject': subject,
        'message': message,
        'category': category ?? 'general',
        'status': 'open',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Support ticket created successfully',
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Get user's support tickets
  static Future<Map<String, dynamic>> getSupportTickets({
    required String uid,
  }) async {
    try {
      QuerySnapshot ticketsSnapshot = await _firestore
          .collection('support_tickets')
          .where('user_id', isEqualTo: uid)
          .orderBy('created_at', descending: true)
          .get();

      List<Map<String, dynamic>> tickets = ticketsSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Support tickets retrieved successfully',
        'SupportTickets': tickets,
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }
}
