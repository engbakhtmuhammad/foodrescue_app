// ignore_for_file: file_names

import 'package:foodrescue_app/services/payment_service.dart';
import 'package:foodrescue_app/services/firebase_service.dart';
import 'package:foodrescue_app/api/Data_save.dart';
import 'package:get/get.dart';

class DiscountorderlistController extends GetxController {
  bool isLoading = false;
  List discountorder = [];

  discountorderlist() async {
    try {
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await PaymentService.getDiscountOrders(uid: uid);

      if (result['Result'] == 'true') {
        discountorder = result["DiscountOrders"] ?? [];
        isLoading = true;
        update();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      FirebaseService.showToastMessage("Error loading discount orders");
    }
  }
}
