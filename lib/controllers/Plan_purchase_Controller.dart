// ignore_for_file: file_names

import 'package:foodrescue_app/controllers/home_controller.dart';
import 'package:foodrescue_app/services/payment_service.dart';
import 'package:foodrescue_app/services/firebase_service.dart';
import 'package:foodrescue_app/api/Data_save.dart';
import 'package:get/get.dart';

class PlanpurchaseController extends GetxController {
  HomeController homeController = Get.find<HomeController>();
  bool isLoading = false;
  planpurchase({String? planid, transactionid, pname}) async {
    try {
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await PaymentService.purchasePlan(
        uid: uid,
        planId: planid ?? "",
        paymentMethod: "card",
        transactionId: transactionid?.toString() ?? "",
        amount: 0.0, // This should be passed as parameter
      );

      if (result['Result'] == 'true') {
        isLoading = true;
        homeController.homeDataApi();
        FirebaseService.showToastMessage(result["ResponseMsg"]);
        update();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      FirebaseService.showToastMessage("Error purchasing plan");
    }
  }
}
