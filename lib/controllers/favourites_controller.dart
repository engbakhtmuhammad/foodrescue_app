import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_config.dart';

class FavouritesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  var favourites = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavourites();
  }

  /// Load user's favourites from Firebase
  Future<void> loadFavourites() async {
    try {
      isLoading.value = true;
      
      final user = _auth.currentUser;
      if (user == null) {
        favourites.clear();
        return;
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favourites')
          .orderBy('addedAt', descending: true)
          .get();

      favourites.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

    } catch (e) {
      print('Error loading favourites: $e');
      Get.snackbar(
        "Error",
        "Failed to load favourites",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Add a surprise bag to favourites
  Future<void> addFavourite(Map<String, dynamic> bagData, String restaurantName, String restaurantImage, String restaurantAddress) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar(
          "Error",
          "Please login to add favourites",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final bagId = bagData["id"] ?? DateTime.now().millisecondsSinceEpoch.toString();
      
      // Check if already in favourites
      if (isFavourite(bagId)) {
        Get.snackbar(
          "Already Added",
          "This item is already in your favourites",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final favouriteData = {
        ...bagData,
        'restaurantName': restaurantName,
        'restaurantImage': restaurantImage,
        'restaurantAddress': restaurantAddress,
        'addedAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favourites')
          .doc(bagId)
          .set(favouriteData);

      // Add to local list
      favouriteData['id'] = bagId;
      favouriteData['addedAt'] = Timestamp.now(); // For local display
      favourites.insert(0, favouriteData);

      Get.snackbar(
        "Added to Favourites",
        "Added to your favourites",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
        duration: Duration(seconds: 2),
      );

    } catch (e) {
      print('Error adding favourite: $e');
      Get.snackbar(
        "Error",
        "Failed to add to favourites",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Remove a surprise bag from favourites
  Future<void> removeFavourite(String bagId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favourites')
          .doc(bagId)
          .delete();

      // Remove from local list
      favourites.removeWhere((item) => item['id'] == bagId);

    } catch (e) {
      print('Error removing favourite: $e');
      Get.snackbar(
        "Error",
        "Failed to remove from favourites",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Toggle favourite status
  Future<void> toggleFavourite(Map<String, dynamic> bagData, String restaurantName, String restaurantImage, String restaurantAddress) async {
    final bagId = bagData["id"] ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    if (isFavourite(bagId)) {
      await removeFavourite(bagId);
    } else {
      await addFavourite(bagData, restaurantName, restaurantImage, restaurantAddress);
    }
  }

  /// Check if a bag is in favourites
  bool isFavourite(String bagId) {
    return favourites.any((item) => item['id'] == bagId);
  }

  /// Clear all favourites
  Future<void> clearAllFavourites() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get all favourite documents
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favourites')
          .get();

      // Delete all documents in batch
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Clear local list
      favourites.clear();

    } catch (e) {
      print('Error clearing favourites: $e');
      Get.snackbar(
        "Error",
        "Failed to clear favourites",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Get favourites count
  int get favouritesCount => favourites.length;

  /// Check if favourites list is empty
  bool get isEmpty => favourites.isEmpty;

  /// Check if favourites list is not empty
  bool get isNotEmpty => favourites.isNotEmpty;
}
