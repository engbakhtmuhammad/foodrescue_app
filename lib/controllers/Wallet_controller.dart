// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, prefer_typing_uninitialized_variables, file_names

import 'package:foodrescue_app/controllers/home_controller.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:foodrescue_app/services/payment_service.dart';
import 'package:foodrescue_app/services/firebase_service.dart';
import 'package:foodrescue_app/api/Data_save.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletController extends GetxController implements GetxService {
  HomeController hdata = Get.find<HomeController>();

  // WalletInfo? walletInfo;
  bool isLoading = false;

  TextEditingController amount = TextEditingController();

  String results = "";
  String walletMsg = "";

  String rCode = "";
  String signupcredit = "";
  String refercredit = "";
  int tex = 0;
  List wallet = [];
  getWalletReportData() async {
    try {
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await PaymentService.getWalletReport(uid: uid);

      if (result['Result'] == 'true') {
        wallet = result["WalletData"]["transactions"] ?? [];
        isLoading = true;
        update();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in getWalletReportData: $e");
      FirebaseService.showToastMessage("Error loading wallet data");
    }
  }

  getWalletUpdateData() async {
    try {
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];
      double walletAmount = double.tryParse(amount.text) ?? 0.0;

      var result = await PaymentService.updateWallet(
        uid: uid,
        amount: walletAmount,
        type: 'credit',
        description: 'Wallet top-up',
      );

      results = result["Result"];
      walletMsg = result["ResponseMsg"];

      if (results == "true") {
        getWalletReportData();
        hdata.homeDataApi();
        Get.back();
        showToastMessage(walletMsg);
      } else {
        FirebaseService.showToastMessage(walletMsg);
      }
    } catch (e) {
      print("Error in getWalletUpdateData: $e");
      FirebaseService.showToastMessage("Error updating wallet");
    }
  }

  getReferData() async {
    try {
      isLoading = false;
      update();

      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await PaymentService.getReferralData(uid: uid);

      print(result.toString());

      if (result['Result'] == 'true') {
        var referralData = result['ReferralData'];
        rCode = referralData["referral_code"];
        signupcredit = "10"; // Default values
        refercredit = "5";
        tex = 0;
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }

      isLoading = true;
      update();
    } catch (e) {
      print("Error in getReferData: $e");
      FirebaseService.showToastMessage("Error loading referral data");
    }
  }

  addAmount({String? price}) {
    amount.text = price ?? "";
    update();
  }
}
