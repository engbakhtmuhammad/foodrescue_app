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
        restdata = List.from(result["restdata"]["featurelist"] ?? []);
        storyview = List.from(result["restdata"]["img"] ?? []);
        relatedrest = List.from(result["related_rest"] ?? []);

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
