// ignore_for_file: avoid_print, file_names

import 'dart:developer';

import 'package:foodrescue_app/services/payment_service.dart';
import 'package:foodrescue_app/services/firebase_service.dart';
import 'package:get/get.dart';

class PaymentgatewayController extends GetxController {
  List paymentGetway = [];
  bool isLoading = false;
  paymentgateway() async {
    try {
      var result = await PaymentService.getPaymentGateways();

      print("/*/*/*/*/paymentdata*/*/*/*" "$result");

      if (result['Result'] == 'true') {
        paymentGetway = result["paymentdata"] ?? [];
        log(paymentGetway.length.toString(), name: "payment deta :: ");
        isLoading = true;
        update();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in paymentgateway: $e");
      FirebaseService.showToastMessage("Error loading payment gateways");
    }
  }
}
