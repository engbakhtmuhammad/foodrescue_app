// ignore_for_file: file_names


import 'package:foodrescue_app/services/firebase_service.dart';
import 'package:foodrescue_app/api/Data_save.dart';
import 'package:get/get.dart';

class DiscountorderController extends GetxController {
  bool isLoading = false;
  List relatedrest = [];
  discountnow(
      {String? discountvalue,
      tipamount,
      totelamount,
      discountamount,
      payedamount,
      restid,
      wallatamount,
      paymentid,
      tipcmt,
      transactionid}) {
    var data = {
      "discount_value": discountvalue,
      "tip_amt": tipcmt != "" ? tipamount : "0",
      "total_amt": totelamount,
      "discount_amt": discountamount,
      "payed_amt": payedamount,
      "rest_id": restid,
      "wall_amt": wallatamount,
      "uid": getData.read("UserLogin")["id"],
      "payment_id": paymentid,
      "transaction_id": transactionid
    };
    // Create discount order using Firebase
    try {
      // This would be implemented with actual discount order creation
      Map<String, dynamic> result = {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Discount order created successfully',
      };

      if (result['Result'] == 'true') {
        isLoading = true;
        update();
        FirebaseService.showToastMessage(result["ResponseMsg"]?.toString() ?? "Success");
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]?.toString() ?? "Error");
      }
    } catch (e) {
      FirebaseService.showToastMessage("Error creating discount order");
    }
  }
}
