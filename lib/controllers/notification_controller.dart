import 'package:get/get.dart';
import '../services/notification_service.dart';
import '../services/firebase_service.dart';
import '../api/Data_save.dart';

class NotificationController extends GetxController {
  var notifications = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Get notifications
  Future<void> getNotifications() async {
    try {
      isLoading.value = true;
      
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await NotificationService.getNotifications(uid: uid);

      if (result['Result'] == 'true') {
        notifications.value = List<Map<String, dynamic>>.from(
          result['NotificationData'] ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in getNotifications: $e");
      FirebaseService.showToastMessage("Error loading notifications");
    } finally {
      isLoading.value = false;
    }
  }

  // Mark notification as read
  Future<void> markAsRead({required String notificationId}) async {
    try {
      var result = await NotificationService.markAsRead(
        notificationId: notificationId,
      );

      if (result['Result'] == 'true') {
        // Update local notification status
        int index = notifications.indexWhere((n) => n['id'] == notificationId);
        if (index != -1) {
          notifications[index]['is_read'] = true;
          notifications.refresh();
        }
      }
    } catch (e) {
      print("Error in markAsRead: $e");
    }
  }
}

class FAQController extends GetxController {
  var faqData = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Get FAQ data
  Future<void> getFAQData() async {
    try {
      isLoading.value = true;
      
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await NotificationService.getFAQData(uid: uid);

      if (result['Result'] == 'true') {
        faqData.value = List<Map<String, dynamic>>.from(
          result['FaqData'] ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in getFAQData: $e");
      FirebaseService.showToastMessage("Error loading FAQ data");
    } finally {
      isLoading.value = false;
    }
  }
}

class PageController extends GetxController {
  var pageList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Get page list
  Future<void> getPageList() async {
    try {
      isLoading.value = true;
      
      var result = await NotificationService.getPageList();

      if (result['Result'] == 'true') {
        pageList.value = List<Map<String, dynamic>>.from(
          result['PageList'] ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in getPageList: $e");
      FirebaseService.showToastMessage("Error loading page list");
    } finally {
      isLoading.value = false;
    }
  }
}

class DiscountController extends GetxController {
  var discountData = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Get discount now data
  Future<void> getDiscountNow() async {
    try {
      isLoading.value = true;
      
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await NotificationService.getDiscountNow(uid: uid);

      if (result['Result'] == 'true') {
        discountData.value = List<Map<String, dynamic>>.from(
          result['DiscountData'] ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in getDiscountNow: $e");
      FirebaseService.showToastMessage("Error loading discount data");
    } finally {
      isLoading.value = false;
    }
  }
}

class SupportController extends GetxController {
  var supportTickets = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Create support ticket
  Future<void> createSupportTicket({
    required String subject,
    required String message,
    String? category,
  }) async {
    try {
      isLoading.value = true;
      
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await NotificationService.createSupportTicket(
        uid: uid,
        subject: subject,
        message: message,
        category: category,
      );

      if (result['Result'] == 'true') {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
        // Refresh support tickets
        await getSupportTickets();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in createSupportTicket: $e");
      FirebaseService.showToastMessage("Error creating support ticket");
    } finally {
      isLoading.value = false;
    }
  }

  // Get support tickets
  Future<void> getSupportTickets() async {
    try {
      isLoading.value = true;
      
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await NotificationService.getSupportTickets(uid: uid);

      if (result['Result'] == 'true') {
        supportTickets.value = List<Map<String, dynamic>>.from(
          result['SupportTickets'] ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in getSupportTickets: $e");
      FirebaseService.showToastMessage("Error loading support tickets");
    } finally {
      isLoading.value = false;
    }
  }
}

class OTPController extends GetxController {
  var isLoading = false.obs;

  // Get SMS type
  Future<Map<String, dynamic>> getMsgType() async {
    try {
      return await NotificationService.getSMSType();
    } catch (e) {
      print("Error in getMsgType: $e");
      return {'SMS_TYPE': 'Firebase'};
    }
  }

  // Send OTP
  Future<Map<String, dynamic>> sendOtp({required String mobile}) async {
    try {
      isLoading.value = true;
      
      return await NotificationService.sendOTP(mobile: mobile);
    } catch (e) {
      print("Error in sendOtp: $e");
      return {
        'Result': 'false',
        'ResponseMsg': 'Error sending OTP',
      };
    } finally {
      isLoading.value = false;
    }
  }

  // Send Twilio OTP
  Future<Map<String, dynamic>> twilloOtp({required String mobile}) async {
    try {
      isLoading.value = true;
      
      return await NotificationService.sendOTP(mobile: mobile);
    } catch (e) {
      print("Error in twilloOtp: $e");
      return {
        'Result': 'false',
        'ResponseMsg': 'Error sending OTP',
      };
    } finally {
      isLoading.value = false;
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String mobile,
    required String otp,
  }) async {
    try {
      isLoading.value = true;
      
      return await NotificationService.verifyOTP(mobile: mobile, otp: otp);
    } catch (e) {
      print("Error in verifyOtp: $e");
      return {
        'Result': 'false',
        'ResponseMsg': 'Error verifying OTP',
      };
    } finally {
      isLoading.value = false;
    }
  }
}
