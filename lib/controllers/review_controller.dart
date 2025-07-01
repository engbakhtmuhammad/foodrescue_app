import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  var isLoading = false.obs;
  var reviews = <Map<String, dynamic>>[].obs;

  Future<bool> addReview({
    required String restaurantId,
    required double rating,
    required String comment,
  }) async {
    try {
      isLoading.value = true;
      
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar("Error", "Please login to add a review");
        return false;
      }

      // Check if user already reviewed this restaurant
      final existingReview = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: user.uid)
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      if (existingReview.docs.isNotEmpty) {
        Get.snackbar("Info", "You have already reviewed this restaurant");
        return false;
      }

      // Add new review
      final reviewData = {
        'id': _firestore.collection('reviews').doc().id,
        'userId': user.uid,
        'restaurantId': restaurantId,
        'rating': rating,
        'comment': comment,
        'userName': user.displayName ?? 'Anonymous',
        'userEmail': user.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('reviews').doc(reviewData['id'] as String).set(reviewData);

      // Update restaurant average rating
      await _updateRestaurantRating(restaurantId);

      Get.snackbar("Success", "Review added successfully!");
      return true;
    } catch (e) {
      print("Error adding review: $e");
      Get.snackbar("Error", "Failed to add review. Please try again.");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadRestaurantReviews(String restaurantId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('restaurantId', isEqualTo: restaurantId)
          .orderBy('createdAt', descending: true)
          .get();

      reviews.value = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Error loading reviews: $e");
    }
  }

  Future<void> _updateRestaurantRating(String restaurantId) async {
    try {
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      if (reviewsSnapshot.docs.isEmpty) return;

      double totalRating = 0;
      int reviewCount = reviewsSnapshot.docs.length;

      for (var doc in reviewsSnapshot.docs) {
        totalRating += (doc.data()['rating'] as num).toDouble();
      }

      double averageRating = totalRating / reviewCount;

      // Update restaurant document
      await _firestore.collection('restaurants').doc(restaurantId).update({
        'rating': averageRating.toStringAsFixed(1),
        'reviewCount': reviewCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error updating restaurant rating: $e");
    }
  }

  Future<Map<String, dynamic>> getRestaurantRatingInfo(String restaurantId) async {
    try {
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      if (reviewsSnapshot.docs.isEmpty) {
        return {
          'averageRating': 0.0,
          'reviewCount': 0,
          'ratingDistribution': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        };
      }

      double totalRating = 0;
      Map<int, int> ratingDistribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

      for (var doc in reviewsSnapshot.docs) {
        double rating = (doc.data()['rating'] as num).toDouble();
        totalRating += rating;
        int ratingInt = rating.round();
        ratingDistribution[ratingInt] = (ratingDistribution[ratingInt] ?? 0) + 1;
      }

      double averageRating = totalRating / reviewsSnapshot.docs.length;

      return {
        'averageRating': averageRating,
        'reviewCount': reviewsSnapshot.docs.length,
        'ratingDistribution': ratingDistribution,
      };
    } catch (e) {
      print("Error getting restaurant rating info: $e");
      return {
        'averageRating': 0.0,
        'reviewCount': 0,
        'ratingDistribution': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      };
    }
  }

  Future<bool> updateReview({
    required String reviewId,
    required double rating,
    required String comment,
  }) async {
    try {
      isLoading.value = true;

      await _firestore.collection('reviews').doc(reviewId).update({
        'rating': rating,
        'comment': comment,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Get restaurant ID to update rating
      final reviewDoc = await _firestore.collection('reviews').doc(reviewId).get();
      if (reviewDoc.exists) {
        final restaurantId = reviewDoc.data()!['restaurantId'];
        await _updateRestaurantRating(restaurantId);
      }

      Get.snackbar("Success", "Review updated successfully!");
      return true;
    } catch (e) {
      print("Error updating review: $e");
      Get.snackbar("Error", "Failed to update review. Please try again.");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      isLoading.value = true;

      // Get restaurant ID before deleting
      final reviewDoc = await _firestore.collection('reviews').doc(reviewId).get();
      String? restaurantId;
      if (reviewDoc.exists) {
        restaurantId = reviewDoc.data()!['restaurantId'];
      }

      await _firestore.collection('reviews').doc(reviewId).delete();

      // Update restaurant rating
      if (restaurantId != null) {
        await _updateRestaurantRating(restaurantId);
      }

      // Reload reviews
      if (restaurantId != null) {
        await loadRestaurantReviews(restaurantId);
      }

      Get.snackbar("Success", "Review deleted successfully!");
      return true;
    } catch (e) {
      print("Error deleting review: $e");
      Get.snackbar("Error", "Failed to delete review. Please try again.");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get user's review for a specific restaurant
  Future<Map<String, dynamic>?> getUserReview(String restaurantId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final querySnapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: user.uid)
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        data['id'] = querySnapshot.docs.first.id;
        return data;
      }

      return null;
    } catch (e) {
      print("Error getting user review: $e");
      return null;
    }
  }

  // Calculate average rating from reviews list
  double calculateAverageRating(List<Map<String, dynamic>> reviewsList) {
    if (reviewsList.isEmpty) return 0.0;
    
    double total = 0;
    for (var review in reviewsList) {
      total += (review['rating'] as num).toDouble();
    }
    
    return total / reviewsList.length;
  }
}
