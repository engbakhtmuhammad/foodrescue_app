// ignore_for_file: file_names

import 'package:foodrescue_app/services/restaurant_service.dart';
import 'package:foodrescue_app/services/firebase_service.dart';
import 'package:get/get.dart';

class HoteldetailController extends GetxController {
  Map hoteldetails = {};
  List restdata = [];
  List storyview = [];
  bool isLoading = false;
  List relatedrest = [];
  hoteldetail({String? id}) async {
    try {
      if (id == null) {
        FirebaseService.showToastMessage("Restaurant ID is required");
        return;
      }

      var result = await RestaurantService.getRestaurantDetails(
        restaurantId: id,
      );

      if (result['Result'] == 'true') {
        hoteldetails = result["restdata"] ?? {};
        // Safely handle featurelist - could be string or list
        var featurelistData = result["restdata"]["featurelist"];
        if (featurelistData is List) {
          restdata = List.from(featurelistData);
        } else if (featurelistData is String && featurelistData.isNotEmpty) {
          // If it's a string, try to split it or create a single item list
          restdata = [{"title": featurelistData, "image": ""}];
        } else {
          restdata = [];
        }

        // Safely handle img - could be string or list
        var imgData = result["restdata"]["img"];
        if (imgData is List) {
          storyview = List.from(imgData);
        } else if (imgData is String && imgData.isNotEmpty) {
          // If it's a string, create a single item list
          storyview = [{"image": imgData}];
        } else {
          storyview = [];
        }

        // Safely handle related_rest
        var relatedData = result["related_rest"];
        if (relatedData is List) {
          relatedrest = List.from(relatedData);
        } else {
          relatedrest = [];
        }

        isLoading = true;
        update();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in hoteldetail: $e");
      FirebaseService.showToastMessage("Error loading restaurant details");
    }
  }
}
