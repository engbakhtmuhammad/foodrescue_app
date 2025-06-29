// ignore_for_file: file_names

import 'package:foodrescue_app/services/booking_service.dart';
import 'package:foodrescue_app/services/firebase_service.dart';
import 'package:foodrescue_app/api/Data_save.dart';
import 'package:get/get.dart';

class TableStatusController extends GetxController {
  bool isLoading = false;
  List tableStatusList = [];
  tableStatus({String? status}) async {
    try {
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await BookingService.getTableStatusWise(
        uid: uid,
        status: status,
      );

      if (result['Result'] == 'true') {
        tableStatusList = result["TableStatusList"] ?? [];
        isLoading = true;
        update();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in tableStatus: $e");
      FirebaseService.showToastMessage("Error loading table status");
    }
  }
}
