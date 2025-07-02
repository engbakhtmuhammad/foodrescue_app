// ignore_for_file: avoid_print, file_names

import 'package:foodrescue_app/controllers/auth_controller.dart';
import 'package:foodrescue_app/services/firebase_service.dart';
import 'package:foodrescue_app/api/Data_save.dart';
import 'package:get/get.dart';

import '../views/auth/Login_In.dart';

class DeleteAccountController extends GetxController {
  bool isLoading = false;
  List delete = [];
  deleteaccount({String? cuisineid}) async {
    try {
      AuthController authController = Get.find<AuthController>();

      var result = await authController.deleteAccount();

      print("===============accountdelete====================" "$result");
      print("one1");

      if (result['Result'] == 'true') {
        isLoading = true;
        print("one2");
        getData.remove('Firstuser');
        getData.remove('Remember');
        getData.remove("UserLogin");
        print("one3");

        update();
        print("one4");
        Get.to(() => const LoginPage());
      } else {
        print("one5");
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
      print("one6");
    } catch (e) {
      print("Error in deleteaccount: $e");
      FirebaseService.showToastMessage("Error deleting account");
    }
  }
}
