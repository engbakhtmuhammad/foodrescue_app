import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Book a table
  static Future<Map<String, dynamic>> bookTable({
    required String uid,
    required String restaurantId,
    required String name,
    required String email,
    required String mobile,
    required String ccode,
    required String bookFor,
    required String bookTime,
    required String bookDate,
    required String numberOfPeople,
  }) async {
    try {
      // Create booking document
      DocumentReference bookingRef = await _firestore.collection('bookings').add({
        'user_id': uid,
        'restaurant_id': restaurantId,
        'name': name,
        'email': email,
        'mobile': mobile,
        'ccode': ccode,
        'book_for': bookFor,
        'book_time': bookTime,
        'book_date': bookDate,
        'number_of_people': numberOfPeople,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Table booked successfully',
        'booking_id': bookingRef.id,
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Get user's booking list
  static Future<Map<String, dynamic>> getUserBookings({
    required String uid,
    String? tableId,
  }) async {
    try {
      Query query = _firestore
          .collection('bookings')
          .where('user_id', isEqualTo: uid)
          .orderBy('created_at', descending: true);

      if (tableId != null) {
        query = query.where('id', isEqualTo: tableId);
      }

      QuerySnapshot bookingsSnapshot = await query.get();

      List<Map<String, dynamic>> bookingsList = [];

      for (var doc in bookingsSnapshot.docs) {
        var bookingData = doc.data() as Map<String, dynamic>;
        
        // Get restaurant details
        DocumentSnapshot restaurantDoc = await _firestore
            .collection('restaurants')
            .doc(bookingData['restaurant_id'])
            .get();

        var restaurantData = restaurantDoc.exists 
            ? restaurantDoc.data() as Map<String, dynamic>
            : {};

        bookingsList.add({
          'id': doc.id,
          ...bookingData,
          'restaurant_name': restaurantData['title'] ?? 'Unknown Restaurant',
          'restaurant_image': restaurantData['img'] != null && 
                             (restaurantData['img'] as List).isNotEmpty
              ? restaurantData['img'][0]
              : '',
        });
      }

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Bookings retrieved successfully',
        'TableList': bookingsList.isNotEmpty ? bookingsList[0] : {},
        'BookingsList': bookingsList,
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Get table status wise bookings
  static Future<Map<String, dynamic>> getTableStatusWise({
    required String uid,
    String? status,
  }) async {
    try {
      Query query = _firestore
          .collection('bookings')
          .where('user_id', isEqualTo: uid);

      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }

      QuerySnapshot bookingsSnapshot = await query
          .orderBy('created_at', descending: true)
          .get();

      List<Map<String, dynamic>> statusWiseBookings = [];

      for (var doc in bookingsSnapshot.docs) {
        var bookingData = doc.data() as Map<String, dynamic>;
        
        // Get restaurant details
        DocumentSnapshot restaurantDoc = await _firestore
            .collection('restaurants')
            .doc(bookingData['restaurant_id'])
            .get();

        var restaurantData = restaurantDoc.exists 
            ? restaurantDoc.data() as Map<String, dynamic>
            : {};

        statusWiseBookings.add({
          'id': doc.id,
          ...bookingData,
          'restaurant_name': restaurantData['title'] ?? 'Unknown Restaurant',
          'restaurant_image': restaurantData['img'] != null && 
                             (restaurantData['img'] as List).isNotEmpty
              ? restaurantData['img'][0]
              : '',
          'restaurant_address': restaurantData['address'] ?? '',
        });
      }

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Status wise bookings retrieved successfully',
        'TableStatusList': statusWiseBookings,
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Update booking status
  static Future<Map<String, dynamic>> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Booking status updated successfully',
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Cancel booking
  static Future<Map<String, dynamic>> cancelBooking({
    required String bookingId,
  }) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
        'cancelled_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Booking cancelled successfully',
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Get restaurant's bookings (for restaurant owners)
  static Future<Map<String, dynamic>> getRestaurantBookings({
    required String restaurantId,
    String? status,
    String? date,
  }) async {
    try {
      Query query = _firestore
          .collection('bookings')
          .where('restaurant_id', isEqualTo: restaurantId);

      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }

      if (date != null && date.isNotEmpty) {
        query = query.where('book_date', isEqualTo: date);
      }

      QuerySnapshot bookingsSnapshot = await query
          .orderBy('created_at', descending: true)
          .get();

      List<Map<String, dynamic>> restaurantBookings = [];

      for (var doc in bookingsSnapshot.docs) {
        var bookingData = doc.data() as Map<String, dynamic>;
        
        // Get user details
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(bookingData['user_id'])
            .get();

        var userData = userDoc.exists 
            ? userDoc.data() as Map<String, dynamic>
            : {};

        restaurantBookings.add({
          'id': doc.id,
          ...bookingData,
          'user_name': userData['name'] ?? bookingData['name'],
          'user_email': userData['email'] ?? bookingData['email'],
        });
      }

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Restaurant bookings retrieved successfully',
        'RestaurantBookings': restaurantBookings,
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Get booking statistics
  static Future<Map<String, dynamic>> getBookingStats({
    required String uid,
    String? restaurantId,
  }) async {
    try {
      Query query = _firestore.collection('bookings');
      
      if (restaurantId != null) {
        query = query.where('restaurant_id', isEqualTo: restaurantId);
      } else {
        query = query.where('user_id', isEqualTo: uid);
      }

      QuerySnapshot allBookings = await query.get();
      QuerySnapshot pendingBookings = await query.where('status', isEqualTo: 'pending').get();
      QuerySnapshot confirmedBookings = await query.where('status', isEqualTo: 'confirmed').get();
      QuerySnapshot completedBookings = await query.where('status', isEqualTo: 'completed').get();
      QuerySnapshot cancelledBookings = await query.where('status', isEqualTo: 'cancelled').get();

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Booking statistics retrieved successfully',
        'BookingStats': {
          'total_bookings': allBookings.docs.length,
          'pending_bookings': pendingBookings.docs.length,
          'confirmed_bookings': confirmedBookings.docs.length,
          'completed_bookings': completedBookings.docs.length,
          'cancelled_bookings': cancelledBookings.docs.length,
        }
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
