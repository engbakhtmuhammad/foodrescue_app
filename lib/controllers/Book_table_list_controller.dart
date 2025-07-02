// ignore_for_file: file_names

import 'package:foodrescue_app/services/booking_service.dart';
import 'package:foodrescue_app/services/firebase_service.dart';
import 'package:foodrescue_app/api/Data_save.dart';
import 'package:get/get.dart';

class TablelistsController extends GetxController {
  bool isLoading = false;
  Map tableList = {};
  booktableList({String? tableid}) async {
    try {
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await BookingService.getUserBookings(
        uid: uid,
        tableId: tableid,
      );

      if (result['Result'] == 'true') {
        tableList = result["TableList"] ?? {};
        isLoading = true;
        update();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in booktableList: $e");
      FirebaseService.showToastMessage("Error loading table list");
    }
  }
}
