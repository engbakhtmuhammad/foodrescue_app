// ignore_for_file: file_names

import 'package:foodrescue_app/services/restaurant_service.dart';
import 'package:foodrescue_app/services/firebase_service.dart';
import 'package:get/get.dart';

class GalleryController extends GetxController {
  List<Map<String, dynamic>> galleryData = [];
  bool isLoading = false;
  int currentindex = 0;
  List<String> imagePaths = [];

  changeindex(int index) {
    currentindex = index;
    update();
  }

  galleryview({String? id}) async {
    try {
      if (id == null) {
        FirebaseService.showToastMessage("Restaurant ID is required");
        return;
      }

      var result = await RestaurantService.getRestaurantGallery(
        restaurantId: id,
      );

      if (result['Result'] == 'true') {
        galleryData = List<Map<String, dynamic>>.from(
          result['gallerydata'] ?? []
        );

        // Flatten all images for easy viewing
        imagePaths.clear();
        for (var category in galleryData) {
          if (category['imglist'] != null) {
            imagePaths.addAll(List<String>.from(category['imglist']));
          }
        }

        isLoading = true;
        update();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in galleryview: $e");
      FirebaseService.showToastMessage("Error loading gallery");
    }
  }
}
