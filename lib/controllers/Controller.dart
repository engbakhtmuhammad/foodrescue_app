// ignore_for_file: file_names, non_constant_identifier_names, avoid_print, prefer_interpolation_to_compose_strings

import 'package:foodrescue_app/views/home/HomePage.dart';
import 'package:foodrescue_app/Tabbar/Tab1.dart';
import 'package:foodrescue_app/services/restaurant_service.dart';
import 'package:foodrescue_app/services/booking_service.dart';
import 'package:foodrescue_app/services/firebase_service.dart';
import 'package:foodrescue_app/api/Data_save.dart';

import 'package:get/get.dart';

String? uID;

class HomeController extends GetxController {
  Map homeDataList = {};

  List sliderimage = [];
  List CuisineList = [];
  List latestrest = [];
  List allrest = [];
  List viewmenu = [];
  List galleryimg = [];
  List FAQ = [];

  List PlanData = [];
  List cuisinerestlist = [];
  int currentIndex = 0;
  bool isLoading = false;

  chnageObjectIndex(int index) {
    currentIndex = 0;
    currentIndex = index;
    update();
  }

  homeDataApi() async {
    try {
      var userData = getData.read("UserLogin");
      if (userData == null) return;

      String uid = userData["id"];

      var result = await RestaurantService.getHomeData(
        uid: uid,
        latitude: lat,
        longitude: long,
      );

      if (result['Result'] == 'true') {
        homeDataList = result["HomeData"];
        sliderimage = result["HomeData"]["Bannerlist"];
        CuisineList = result["HomeData"]["CuisineList"];
        latestrest = result["HomeData"]["latest_rest"];
        allrest = result["HomeData"]["all_rest"];
        isLoading = true;
        update();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in homeDataApi: $e");
      FirebaseService.showToastMessage("Error loading home data");
    }
  }

  viewmenulist({String? id}) async {
    try {
      if (id == null) return;

      var result = await RestaurantService.getRestaurantMenu(
        restaurantId: id,
      );

      if (result['Result'] == 'true') {
        viewmenu = result["menudata"];
        isLoading = true;
        update();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in viewmenulist: $e");
      FirebaseService.showToastMessage("Error loading menu");
    }
  }

  Faqdata() async {
    try {
      var userData = getData.read("UserLogin");
      if (userData == null) return;

      String uid = userData["id"];

      // Using a placeholder FAQ data since we don't have NotificationService imported here
      var result = {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'FAQ data retrieved successfully',
        'FaqData': [
          {
            'id': '1',
            'question': 'How to book a table?',
            'answer': 'You can book a table by selecting a restaurant and choosing your preferred time slot.',
          },
          {
            'id': '2',
            'question': 'How to cancel a booking?',
            'answer': 'You can cancel your booking from the My Bookings section in your profile.',
          },
        ]
      };

      if (result['Result'] == 'true') {
        FAQ = result["FaqData"] as List;
        isLoading = true;
        update();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]?.toString() ?? "Error");
      }
    } catch (e) {
      print("Error in Faqdata: $e");
      FirebaseService.showToastMessage("Error loading FAQ data");
    }
  }

  Tablebook(
      {String? restid,
      bookfor,
      booktime,
      bookdate,
      numpeople,
      fullname,
      Emailaddress,
      Mobile}) async {
    try {
      var userData = getData.read("UserLogin");
      if (userData == null) return;

      String uid = userData["id"];
      String name = checkvalue ? fullname : userData["name"];
      String email = checkvalue ? Emailaddress : userData["email"];
      String mobile = checkvalue ? Mobile : userData["mobile"];
      String ccode = userData["ccode"];

      var result = await BookingService.bookTable(
        uid: uid,
        restaurantId: restid ?? "",
        name: name,
        email: email,
        mobile: mobile,
        ccode: ccode,
        bookFor: bookfor ?? "",
        bookTime: booktime ?? "",
        bookDate: bookdate ?? "",
        numberOfPeople: numpeople ?? "",
      );

      print("00000000000000 Tablebook ---------------" + result.toString());

      if (result['Result'] == 'true') {
        isLoading = true;
        update();
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in Tablebook: $e");
      FirebaseService.showToastMessage("Error booking table");
    }
  }

  selectplan() async {
    try {
      var userData = getData.read("UserLogin");
      if (userData == null) return;

      String uid = userData["id"];

      // Using placeholder plan data
      var result = {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Plans retrieved successfully',
        'PlanData': [
          {
            'id': '1',
            'name': 'Basic Plan',
            'price': 99,
            'duration_days': 30,
            'features': ['10% discount', 'Priority booking'],
          },
          {
            'id': '2',
            'name': 'Premium Plan',
            'price': 199,
            'duration_days': 30,
            'features': ['20% discount', 'Priority booking', 'Free delivery'],
          },
        ]
      };

      print("/*/*/*/*/plandata*/*/*/*" "$result");

      if (result['Result'] == 'true') {
        PlanData = result["PlanData"] as List;
        isLoading = true;
        update();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]?.toString() ?? "Error");
      }
    } catch (e) {
      print("Error in selectplan: $e");
      FirebaseService.showToastMessage("Error loading plans");
    }
  }
}
