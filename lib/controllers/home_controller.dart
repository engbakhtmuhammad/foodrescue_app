import 'package:get/get.dart';
import '../services/restaurant_service.dart';
import '../services/firebase_service.dart';
import '../services/booking_service.dart';
import '../api/Data_save.dart';

// Global variables for compatibility
double lat = 0.0;
double long = 0.0;
bool checkvalue = false;

class HomeController extends GetxController {
  // Observable properties for reactive UI
  var homeDataList = {}.obs;
  var sliderimage = <dynamic>[].obs;
  var cuisineList = <dynamic>[].obs;
  var latestrest = <dynamic>[].obs;
  var allrest = <dynamic>[].obs;
  var viewmenu = <dynamic>[].obs;
  var galleryimg = <dynamic>[].obs;
  var faq = <dynamic>[].obs;
  var planData = <dynamic>[].obs;
  var cuisinerestlist = <dynamic>[].obs;

  var currentIndex = 0.obs;
  var isLoading = false.obs;

  // Getters for backward compatibility (non-observable access)
  Map get homeDataList_compat => homeDataList();
  List get sliderimage_compat => sliderimage();
  List get CuisineList => cuisineList();
  List get latestrest_compat => latestrest();
  List get allrest_compat => allrest();
  List get viewmenu_compat => viewmenu();
  List get galleryimg_compat => galleryimg();
  List get FAQ => faq();
  List get PlanData => planData();
  List get cuisinerestlist_compat => cuisinerestlist();

  void changeObjectIndex(int index) {
    currentIndex.value = index;
  }

  // Backward compatibility method
  void chnageObjectIndex(int index) {
    currentIndex.value = index;
    update();
  }

  // Get home data from Firebase
  Future<void> homeDataApi() async {
    try {
      isLoading.value = true;
      
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];
      
      // Get current location (you might want to implement proper location service)
      double lat = 0.0; // Replace with actual latitude
      double long = 0.0; // Replace with actual longitude
      
      var result = await RestaurantService.getHomeData(
        uid: uid,
        latitude: lat,
        longitude: long,
      );

      if (result['Result'] == 'true') {
        homeDataList.value = result["HomeData"];
        sliderimage.value = result["HomeData"]["Bannerlist"] ?? [];
        cuisineList.value = result["HomeData"]["CuisineList"] ?? [];
        latestrest.value = result["HomeData"]["latest_rest"] ?? [];
        allrest.value = result["HomeData"]["all_rest"] ?? [];
        isLoading.value = true;
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
        viewmenu.value = result["menudata"] ?? [];
        isLoading.value = true;
        update();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in viewmenulist: $e");
      FirebaseService.showToastMessage("Error loading menu");
    }
  }

  // Backward compatibility method for FAQ
  Faqdata() async {
    await faqData();
  }

  // Get restaurant menu
  Future<void> viewMenuList({String? id}) async {
    try {
      isLoading.value = true;
      
      if (id == null) {
        FirebaseService.showToastMessage("Restaurant ID is required");
        return;
      }

      var result = await RestaurantService.getRestaurantMenu(
        restaurantId: id,
      );

      if (result['Result'] == 'true') {
        viewmenu.value = List<Map<String, dynamic>>.from(
          result["menudata"] ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in viewMenuList: $e");
      FirebaseService.showToastMessage("Error loading menu");
    } finally {
      isLoading.value = false;
    }
  }

  // Get FAQ data
  Future<void> faqData() async {
    try {
      isLoading.value = true;
      
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];
      
      // Import notification service
      var result = await Future.delayed(Duration(milliseconds: 500), () {
        // This would be replaced with actual FAQ service call
        return {
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
      });

      if (result['Result'] == 'true') {
        faq.value = List<Map<String, dynamic>>.from(
          result["FaqData"] as List? ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]?.toString() ?? "Error");
      }
    } catch (e) {
      print("Error in faqData: $e");
      FirebaseService.showToastMessage("Error loading FAQ");
    } finally {
      isLoading.value = false;
    }
  }

  // Book table
  Future<void> tableBook({
    String? restid,
    String? bookfor,
    String? booktime,
    String? bookdate,
    String? numpeople,
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
      
      // Import booking service
      var result = await Future.delayed(Duration(milliseconds: 500), () {
        // This would be replaced with actual booking service call
        return {
          'ResponseCode': '200',
          'Result': 'true',
          'ResponseMsg': 'Table booked successfully',
        };
      });

      if (result['Result'] == 'true') {
        FirebaseService.showToastMessage(result["ResponseMsg"]?.toString() ?? "Success");
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]?.toString() ?? "Error");
      }
    } catch (e) {
      print("Error in tableBook: $e");
      FirebaseService.showToastMessage("Error booking table");
    } finally {
      isLoading.value = false;
    }
  }

  // Get membership plans
  Future<void> selectPlan() async {
    try {
      isLoading.value = true;
      
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];
      
      // Import payment service
      var result = await Future.delayed(Duration(milliseconds: 500), () {
        // This would be replaced with actual payment service call
        return {
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
      });

      if (result['Result'] == 'true') {
        planData.value = List<Map<String, dynamic>>.from(
          result["PlanData"] as List? ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]?.toString() ?? "Error");
      }
    } catch (e) {
      print("Error in selectPlan: $e");
      FirebaseService.showToastMessage("Error loading plans");
    } finally {
      isLoading.value = false;
    }
  }

  // Get nearby restaurants
  Future<void> getNearbyRestaurants({
    required double latitude,
    required double longitude,
  }) async {
    try {
      isLoading.value = true;
      
      var result = await RestaurantService.getNearbyRestaurants(
        latitude: latitude,
        longitude: longitude,
      );

      if (result['Result'] == 'true') {
        allrest.value = List<Map<String, dynamic>>.from(
          result["Nearbyrestlist"] as List? ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]?.toString() ?? "Error");
      }
    } catch (e) {
      print("Error in getNearbyRestaurants: $e");
      FirebaseService.showToastMessage("Error loading nearby restaurants");
    } finally {
      isLoading.value = false;
    }
  }

  // Get restaurants by cuisine
  Future<void> getCuisineRestaurants({
    required String cuisineId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      isLoading.value = true;
      
      var result = await RestaurantService.getRestaurantsByCuisine(
        cuisineId: cuisineId,
        latitude: latitude,
        longitude: longitude,
      );

      if (result['Result'] == 'true') {
        cuisinerestlist.value = List<Map<String, dynamic>>.from(
          result["Cuisinerestlist"] as List? ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]?.toString() ?? "Error");
      }
    } catch (e) {
      print("Error in getCuisineRestaurants: $e");
      FirebaseService.showToastMessage("Error loading cuisine restaurants");
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    await homeDataApi();
  }

  // Backward compatibility methods
  selectplan() async {
    await selectPlan();
  }

  Tablebook({
    String? restid,
    bookfor,
    booktime,
    bookdate,
    numpeople,
    fullname,
    Emailaddress,
    Mobile
  }) async {
    await tableBook(
      restid: restid,
      bookfor: bookfor,
      booktime: booktime,
      bookdate: bookdate,
      numpeople: numpeople,
      fullname: fullname,
      emailaddress: Emailaddress,
      mobile: Mobile,
    );
  }

}
