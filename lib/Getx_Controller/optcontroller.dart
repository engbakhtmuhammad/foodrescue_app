import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:foodrescue_app/services/notification_service.dart';
import 'package:get/get.dart';

class OtpController extends GetxController implements GetxService {

  Future getMsgtype() async {
    try {
      return await NotificationService.getSMSType();
    } catch (e) {
      showToastMessage("Something went wrong!");
      return {'SMS_TYPE': 'Firebase'};
    }
  }

  Future sendOtp({required mobile}) async {
    try {
      var result = await NotificationService.sendOTP(mobile: mobile);

      if (result["Result"] == "true") {
        return result;
      } else {
        showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      showToastMessage("Something went wrong!");
    }
  }

  Future twilloOtp({required mobile}) async {
    try {
      var result = await NotificationService.sendOTP(mobile: mobile);

      if (result["Result"] == "true") {
        return result;
      } else {
        showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      showToastMessage("Something went wrong!");
    }
  }
}