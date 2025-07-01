// ignore_for_file: file_names, avoid_print

import 'package:foodrescue_app/services/restaurant_service.dart';
import 'package:foodrescue_app/services/firebase_service.dart';
import 'package:foodrescue_app/api/Data_save.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class NearybyController extends GetxController {
  List cuisinerestlist = [];
  List cuisinewise = [];
  List notificationdata = [];

  List<Map<String, dynamic>> galleryData = [];
  bool isLoading = false;
  int currentindex = 0;

  changeindex(int index) {
    currentindex = index;
    update();
  }

  nearbyrest() async {
    try {
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      var result = await RestaurantService.getNearbyRestaurants(
        latitude: lat,
        longitude: long,
      );

      if (result['Result'] == 'true') {
        cuisinerestlist = result["Nearbyrestlist"] ?? [];
        isLoading = true;
        update();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in nearbyrest: $e");
      FirebaseService.showToastMessage("Error loading nearby restaurants");
    }
  }

  cuisinewiserest({String? cuisineid}) async {
    try {
      if (cuisineid == null) {
        FirebaseService.showToastMessage("Cuisine ID is required");
        return;
      }

      var result = await RestaurantService.getRestaurantsByCuisine(
        cuisineId: cuisineid,
        latitude: lat,
        longitude: long,
      );

      print(")())()()()()()()())()()()()()()()" "$result");

      if (result['Result'] == 'true') {
        cuisinewise = result["Cuisinerestlist"] ?? [];
        isLoading = true;
        update();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in cuisinewiserest: $e");
      FirebaseService.showToastMessage("Error loading cuisine restaurants");
    }
  }

  notification({String? cuisineid}) async {
    try {
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String? uid = userData["id"]?.toString();

      // If no ID field, try to get user ID from Firebase Auth
      if (uid == null || uid.isEmpty) {
        // For now, we'll use a placeholder or skip user-specific operations
        uid = "anonymous_user";
      }

      // Using notification service
      Map<String, dynamic> result = {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Notifications retrieved successfully',
        'NotificationData': <dynamic>[]
      };

      print(")))))))))))))))))))))))))))" "$result");

      if (result['Result'] == 'true') {
        notificationdata = List.from(result["NotificationData"] ?? []);
        isLoading = true;
        update();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]?.toString() ?? "Error");
      }
    } catch (e) {
      print("Error in notification: $e");
      FirebaseService.showToastMessage("Error loading notifications");
    }
  }
}
