import 'package:get/get.dart';
import '../services/booking_service.dart';
import '../services/firebase_service.dart';
import '../api/Data_save.dart';

class BookingController extends GetxController {
  var isLoading = false.obs;
  var bookings = <Map<String, dynamic>>[].obs;
  var currentBooking = Rxn<Map<String, dynamic>>();

  // Book a table
  Future<void> bookTable({
    required String restaurantId,
    required String bookFor,
    required String bookTime,
    required String bookDate,
    required String numberOfPeople,
    String? fullname,
    String? emailaddress,
    String? mobile,
  }) async {
    try {
      isLoading.value = true;
      
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];
      String name = fullname ?? userData["name"];
      String email = emailaddress ?? userData["email"];
      String phone = mobile ?? userData["mobile"];
      String ccode = userData["ccode"];

      var result = await BookingService.bookTable(
        uid: uid,
        restaurantId: restaurantId,
        name: name,
        email: email,
        mobile: phone,
        ccode: ccode,
        bookFor: bookFor,
        bookTime: bookTime,
        bookDate: bookDate,
        numberOfPeople: numberOfPeople,
      );

      if (result['Result'] == 'true') {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
        // Refresh bookings list
        await getUserBookings();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in bookTable: $e");
      FirebaseService.showToastMessage("Error booking table");
    } finally {
      isLoading.value = false;
    }
  }

  // Get user's bookings
  Future<void> getUserBookings({String? tableId}) async {
    try {
      isLoading.value = true;
      
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await BookingService.getUserBookings(
        uid: uid,
        tableId: tableId,
      );

      if (result['Result'] == 'true') {
        bookings.value = List<Map<String, dynamic>>.from(
          result['BookingsList'] ?? []
        );
        
        if (tableId != null && result['TableList'] != null) {
          currentBooking.value = result['TableList'];
        }
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in getUserBookings: $e");
      FirebaseService.showToastMessage("Error loading bookings");
    } finally {
      isLoading.value = false;
    }
  }

  // Cancel booking
  Future<void> cancelBooking({required String bookingId}) async {
    try {
      isLoading.value = true;
      
      var result = await BookingService.cancelBooking(bookingId: bookingId);

      if (result['Result'] == 'true') {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
        // Refresh bookings list
        await getUserBookings();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in cancelBooking: $e");
      FirebaseService.showToastMessage("Error cancelling booking");
    } finally {
      isLoading.value = false;
    }
  }
}

class TableStatusController extends GetxController {
  var statusWiseBookings = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Get bookings by status
  Future<void> getTableStatusWise({String? status}) async {
    try {
      isLoading.value = true;
      
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await BookingService.getTableStatusWise(
        uid: uid,
        status: status,
      );

      if (result['Result'] == 'true') {
        statusWiseBookings.value = List<Map<String, dynamic>>.from(
          result['TableStatusList'] ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in getTableStatusWise: $e");
      FirebaseService.showToastMessage("Error loading status wise bookings");
    } finally {
      isLoading.value = false;
    }
  }
}

class BookTableListController extends GetxController {
  var tableList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Get booking list
  Future<void> bookTableList({String? tableId}) async {
    try {
      isLoading.value = true;
      
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await BookingService.getUserBookings(
        uid: uid,
        tableId: tableId,
      );

      if (result['Result'] == 'true') {
        tableList.value = List<Map<String, dynamic>>.from(
          result['BookingsList'] ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in bookTableList: $e");
      FirebaseService.showToastMessage("Error loading table list");
    } finally {
      isLoading.value = false;
    }
  }
}
