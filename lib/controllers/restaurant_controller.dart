import 'package:get/get.dart';
import '../services/restaurant_service.dart';
import '../services/firebase_service.dart';


class RestaurantController extends GetxController {
  var restaurantDetails = Rxn<Map<String, dynamic>>();
  var relatedRestaurants = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Get restaurant details
  Future<void> getRestaurantDetails({required String restaurantId}) async {
    try {
      isLoading.value = true;
      
      var result = await RestaurantService.getRestaurantDetails(
        restaurantId: restaurantId,
      );

      if (result['Result'] == 'true') {
        restaurantDetails.value = result['restdata'];
        relatedRestaurants.value = List<Map<String, dynamic>>.from(
          result['related_rest'] ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in getRestaurantDetails: $e");
      FirebaseService.showToastMessage("Error loading restaurant details");
    } finally {
      isLoading.value = false;
    }
  }

  // Get nearby restaurants
  Future<void> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      isLoading.value = true;
      
      var result = await RestaurantService.getNearbyRestaurants(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );

      if (result['Result'] == 'true') {
        relatedRestaurants.value = List<Map<String, dynamic>>.from(
          result['Nearbyrestlist'] ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in getNearbyRestaurants: $e");
      FirebaseService.showToastMessage("Error loading nearby restaurants");
    } finally {
      isLoading.value = false;
    }
  }

  // Get restaurants by cuisine
  Future<void> getRestaurantsByCuisine({
    required String cuisineId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      isLoading.value = true;
      
      var result = await RestaurantService.getRestaurantsByCuisine(
        cuisineId: cuisineId,
        latitude: latitude,
        longitude: longitude,
      );

      if (result['Result'] == 'true') {
        relatedRestaurants.value = List<Map<String, dynamic>>.from(
          result['Cuisinerestlist'] ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in getRestaurantsByCuisine: $e");
      FirebaseService.showToastMessage("Error loading cuisine restaurants");
    } finally {
      isLoading.value = false;
    }
  }
}

class MenuController extends GetxController {
  var menuItems = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Get restaurant menu
  Future<void> getRestaurantMenu({required String restaurantId}) async {
    try {
      isLoading.value = true;
      
      var result = await RestaurantService.getRestaurantMenu(
        restaurantId: restaurantId,
      );

      if (result['Result'] == 'true') {
        menuItems.value = List<Map<String, dynamic>>.from(
          result['menudata'] ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in getRestaurantMenu: $e");
      FirebaseService.showToastMessage("Error loading menu");
    } finally {
      isLoading.value = false;
    }
  }
}

class GalleryController extends GetxController {
  var galleryData = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var currentIndex = 0.obs;
  var imagePaths = <String>[].obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  // Get restaurant gallery
  Future<void> galleryView({required String restaurantId}) async {
    try {
      isLoading.value = true;
      
      var result = await RestaurantService.getRestaurantGallery(
        restaurantId: restaurantId,
      );

      if (result['Result'] == 'true') {
        galleryData.value = List<Map<String, dynamic>>.from(
          result['gallerydata'] ?? []
        );
        
        // Flatten all images for easy viewing
        imagePaths.clear();
        for (var category in galleryData) {
          if (category['imglist'] != null) {
            imagePaths.addAll(List<String>.from(category['imglist']));
          }
        }
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in galleryView: $e");
      FirebaseService.showToastMessage("Error loading gallery");
    } finally {
      isLoading.value = false;
    }
  }
}

class NearByController extends GetxController {
  var nearbyRestaurants = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Get nearby restaurants
  Future<void> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      isLoading.value = true;
      
      var result = await RestaurantService.getNearbyRestaurants(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );

      if (result['Result'] == 'true') {
        nearbyRestaurants.value = List<Map<String, dynamic>>.from(
          result['Nearbyrestlist'] ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in getNearbyRestaurants: $e");
      FirebaseService.showToastMessage("Error loading nearby restaurants");
    } finally {
      isLoading.value = false;
    }
  }
}

class CuisineController extends GetxController {
  var cuisineRestaurants = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Get restaurants by cuisine
  Future<void> getCuisineRestaurants({
    required String cuisineId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      isLoading.value = true;
      
      var result = await RestaurantService.getRestaurantsByCuisine(
        cuisineId: cuisineId,
        latitude: latitude,
        longitude: longitude,
      );

      if (result['Result'] == 'true') {
        cuisineRestaurants.value = List<Map<String, dynamic>>.from(
          result['Cuisinerestlist'] ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in getCuisineRestaurants: $e");
      FirebaseService.showToastMessage("Error loading cuisine restaurants");
    } finally {
      isLoading.value = false;
    }
  }
}
