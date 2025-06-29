// ignore_for_file: file_names, avoid_print

import 'package:foodrescue_app/controllers/home_controller.dart';
import 'package:foodrescue_app/services/payment_service.dart';
import 'package:foodrescue_app/services/firebase_service.dart';
import 'package:foodrescue_app/api/Data_save.dart';
import 'package:get/get.dart';

class MembershipController extends GetxController {
  HomeController homeController = Get.find<HomeController>();
  bool isLoading = false;
  Map member = {};
  membership() async {
    try {
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await PaymentService.getMembershipData(uid: uid);

      print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&$result");

      if (result['Result'] == 'true') {
        member = result;
        isLoading = true;
        update();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in membership: $e");
      FirebaseService.showToastMessage("Error loading membership data");
    }
  }
}
