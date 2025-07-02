// ignore_for_file: file_names

import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../Utils/Custom_widegt.dart';
import '../../api/Data_save.dart';

class PaystackController extends GetxController implements GetxService {

  String randomKey = "";
  String status = "";

  Future getPaystack({required String amount}) async {

    Map body = {
      "email": getData.read("UserLogin")["email"],
      "amount": amount
    };

    var response = await http.post(Uri.parse("https://gomeet.cscodetech.cloud/paystack/index.php"),
        body: jsonEncode(body)
    );

    if(response.statusCode == 200){

      var result = jsonDecode(response.body);

      if(result["status"] == true){
        // ignore: avoid_print
        print("RESULT  K<  $result");
        randomKey = result["data"]["reference"];
        return result;
      } else {
        showToastMessage(result["message"]);
      }
    } else {
      return showToastMessage(jsonDecode(response.body)["message"]);
    }
  }

  Future checkPaystack({required String sKey}) async {

    Map bddy = {
      "reference": randomKey,
      "status": status
    };

    // ignore: unused_local_variable
    var response= await http.post(Uri.parse("https://gomeet.cscodetech.cloud/paystack/callback.php",),
        body: jsonEncode(bddy)
    );
  }
}