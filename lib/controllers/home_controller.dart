import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/restaurant_service.dart';
import '../services/firebase_service.dart';
import '../models/restaurant_model.dart';
import '../models/banner_model.dart';
import '../models/cuisine_model.dart';
import '../models/surprise_bag_model.dart';
import '../config/app_config.dart';
import 'dart:math';
import '../api/Data_save.dart';

// Global variables for compatibility
double lat = 0.0;
double long = 0.0;
bool checkvalue = false;

class HomeController extends GetxController {
  // Observable properties for reactive UI
  var homeDataList = {}.obs;
  var _sliderimage = <dynamic>[].obs;
  var _cuisineList = <dynamic>[].obs;
  var _latestrest = <dynamic>[].obs;
  var _allrest = <dynamic>[].obs;
  var _viewmenu = <dynamic>[].obs;
  var _galleryimg = <dynamic>[].obs;
  var _faq = <dynamic>[].obs;
  var _planData = <dynamic>[].obs;
  var _cuisinerestlist = <dynamic>[].obs;
  var _surpriseBags = <dynamic>[].obs;
  var _categories = <dynamic>[].obs;

  var currentIndex = 0.obs;
  var isLoading = false.obs;

  // Location-related variables
  RxDouble currentLatitude = 0.0.obs;
  RxDouble currentLongitude = 0.0.obs;
  RxString currentAddress = "".obs;
  RxBool isLocationLoading = false.obs;
  RxBool isGettingLocation = false.obs;
  RxInt selectedRadius = AppConfig.defaultRadius.obs;

  // Getters for backward compatibility (non-observable access)
  List get sliderimage => _sliderimage;
  List get CuisineList => _cuisineList;
  List get latestrest => _latestrest;
  List get allrest => _allrest;
  List get viewmenu => _viewmenu;
  List get galleryimg => _galleryimg;
  List get FAQ => _faq;
  List get PlanData => _planData;
  List get cuisinerestlist => _cuisinerestlist;
  List get surpriseBags => _surpriseBags;
  List get categories => _categories;

  // Location getters
  double get latitude => currentLatitude.value;
  double get longitude => currentLongitude.value;
  String get address => currentAddress.value;

  // Public method to refresh location (can be called after login)
  Future<void> refreshLocation() async {
    print("Refreshing location...");
    await getCurrentLocation(forceRefresh: true);
  }

  // Update location and radius from location radius page
  void updateLocationAndRadius(double lat, double lng, String address, int radius) {
    currentLatitude.value = lat;
    currentLongitude.value = lng;
    currentAddress.value = address;
    selectedRadius.value = radius;

    // Save to storage for persistence
    getData.write('selectedRadius', radius);
    getData.write('selectedLocation', {
      'latitude': lat,
      'longitude': lng,
      'address': address,
    });

    // Refresh data with new location and radius
    refreshDataWithNewLocation();
  }

  // Refresh data when location or radius changes
  void refreshDataWithNewLocation() {
    // Reload restaurants and surprise bags with new location/radius
    homeDataApi();
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  @override
  void onInit() {
    super.onInit();
    print("HomeController onInit() called");
    // Initialize sample data and home data when controller is created
    // Run initialization in background to avoid blocking UI
    Future.delayed(Duration(milliseconds: 100), () async {
      print("Starting delayed initialization...");
      try {
        await initializeSampleData();
        print("Sample data initialized, now loading ALL restaurants...");

        // Get location in background (optional for showing all restaurants)
        getCurrentLocation().catchError((e) {
          print("Location service failed, but continuing with all restaurants: $e");
        });

        print("Loading ALL restaurants without location requirement...");
        await homeDataApi();
        print("HomeDataApi completed in onInit - ALL restaurants loaded");
      } catch (e) {
        print("Error in onInit delayed execution: $e");
      }
    });
  }

  // Initialize sample data for testing
  Future<void> initializeSampleData() async {
    try {
      await RestaurantService.initializeSampleData();
    } catch (e) {
      print("Error initializing sample data: $e");
    }
  }

  // Load real data from Firebase collections with optional radius filtering
  Future<void> loadRealFirebaseData() async {
    try {
      // Check if we should use radius filtering
      bool useRadiusFiltering = currentLatitude.value != 0.0 &&
                               currentLongitude.value != 0.0 &&
                               selectedRadius.value > 0;

      if (useRadiusFiltering) {
        print("Loading restaurants with radius filtering: ${selectedRadius.value} km from ${currentAddress.value}");
      } else {
        print("Loading ALL restaurants from Firebase (no location filtering)...");
      }

      // Fetch restaurants based on filtering preference
      List<RestaurantModel> restaurants;
      try {
        if (useRadiusFiltering) {
          // Use nearby restaurants with radius filtering
          var result = await RestaurantService.getNearbyRestaurants(
            latitude: currentLatitude.value,
            longitude: currentLongitude.value,
            radiusKm: selectedRadius.value.toDouble(),
          );

          if (result['Result'] == 'true') {
            List<Map<String, dynamic>> nearbyData = List<Map<String, dynamic>>.from(
              result["Nearbyrestlist"] as List? ?? []
            );
            restaurants = nearbyData.map((data) => RestaurantModel.fromMap(data)).toList();
            print("✅ Received ${restaurants.length} restaurants within ${selectedRadius.value} km");
          } else {
            print("❌ Error fetching nearby restaurants: ${result['ResponseMsg']}");
            restaurants = [];
          }
        } else {
          // Fetch ALL restaurants
          restaurants = await RestaurantService.getRestaurants();
          print("✅ Received ${restaurants.length} restaurants from service");
        }
      } catch (e, stackTrace) {
        print("❌ Error fetching restaurants from service: $e");
        print("Stack trace: $stackTrace");
        throw e;
      }

      _allrest.clear();
      _latestrest.clear();

      for (int i = 0; i < restaurants.length; i++) {
        RestaurantModel restaurant = restaurants[i];
        print("Processing restaurant $i: ${restaurant.id} - ${restaurant.title}");

        try {
          // Convert RestaurantModel to app format for backward compatibility
          // NO LOCATION FILTERING - Show all restaurants
          Map<String, dynamic> restaurantData = {
            "id": restaurant.id,
            "title": restaurant.title.isNotEmpty ? restaurant.title : "Restaurant ${i + 1}",
            "description": restaurant.shortDescription.isNotEmpty
                ? restaurant.shortDescription
                : restaurant.mondayThursdayOfferDesc.isNotEmpty
                    ? restaurant.mondayThursdayOfferDesc
                    : "Delicious food available",
            "image": restaurant.img.isNotEmpty ? restaurant.img : "https://picsum.photos/300/200",
            "rate": restaurant.rating.toString(),
            "address": restaurant.fullAddress.isNotEmpty ? restaurant.fullAddress : "Address not available",
            "area": restaurant.area.isNotEmpty ? restaurant.area : "Area not available",
            "latitude": restaurant.latitude.toString(),
            "longitude": restaurant.longitude.toString(),
            "delivery_time": "30-45 min", // Default value
            "delivery_fee": "2.99", // Default value
            "minimum_order": "15.00", // Default value
            "phone": restaurant.mobile,
            "email": restaurant.email,
            "status": restaurant.status,
            "cuisines": restaurant.cuisines,
            "openTime": restaurant.openTime,
            "closeTime": restaurant.closeTime,
            "mondayThursdayOffer": restaurant.mondayThursdayOffer,
            "mondayThursdayOfferDesc": restaurant.mondayThursdayOfferDesc,
            "fridaySundayOffer": restaurant.fridaySundayOffer,
            "fridaySundayOfferDesc": restaurant.fridaySundayOfferDesc,
            "facilities": restaurant.facilities,
            "approxPrice": restaurant.approxPrice.toString(),
            "popularDishes": restaurant.popularDishes,
            "pincode": restaurant.pincode,
            "showRadius": restaurant.showRadius.toString(),
            "tShow": restaurant.tShow,
            "totalReviews": restaurant.totalReviews.toString(),
            "averageRating": restaurant.averageRating.toString(),
            "ratingBreakdown": restaurant.ratingBreakdown,
            "ownerId": restaurant.ownerId,
            "createdAt": restaurant.createdAt.toIso8601String(),
            "updatedAt": restaurant.updatedAt.toIso8601String(),
          };

          // Add ALL restaurants without any location-based filtering
          _allrest.add(restaurantData);
          _latestrest.add(restaurantData);
          print("✅ Added restaurant: ${restaurantData["title"]} (${restaurantData["address"]})");
        } catch (e, stackTrace) {
          print("❌ Error processing restaurant $i: $e");
          print("Stack trace: $stackTrace");
          print("Restaurant ID: ${restaurant.id}");
          print("Restaurant title: ${restaurant.title}");
          // Continue with other restaurants
        }
      }

      // Fetch banners using BannerModel
      print("Fetching banners from Firebase...");
      List<BannerModel> banners = await RestaurantService.getBanners();
      print("Received ${banners.length} banners from service");
      _sliderimage.clear();

      for (int i = 0; i < banners.length; i++) {
        BannerModel banner = banners[i];
        print("Processing banner $i: ${banner.id}");

        try {
          Map<String, dynamic> bannerData = {
            "id": banner.id,
            "title": banner.title,
            "image": banner.img.isNotEmpty ? banner.img : "https://picsum.photos/400/200",
            "link": banner.link ?? "",
            "status": banner.status,
            "sortOrder": banner.sortOrder.toString(),
            "createdAt": banner.createdAt.toIso8601String(),
            "updatedAt": banner.updatedAt.toIso8601String(),
          };
          _sliderimage.add(bannerData);
          print("Successfully processed banner: ${bannerData["title"]}");
        } catch (e) {
          print("Error processing banner $i: $e");
          print("Banner: ${banner.toString()}");
        }
      }

      // Fetch cuisines using CuisineModel
      print("Fetching cuisines from Firebase...");
      List<CuisineModel> cuisines = await RestaurantService.getCuisines();
      print("Received ${cuisines.length} cuisines from service");
      _cuisineList.clear();

      for (int i = 0; i < cuisines.length; i++) {
        CuisineModel cuisine = cuisines[i];
        print("Processing cuisine $i: ${cuisine.id}");

        try {
          Map<String, dynamic> cuisineData = {
            "id": cuisine.id,
            "title": cuisine.title.isNotEmpty ? cuisine.title : "Cuisine",
            "image": cuisine.img.isNotEmpty ? cuisine.img : "https://picsum.photos/100/100",
            "status": cuisine.status,
            "color": "#FF5722", // Default color
            "createdAt": cuisine.createdAt.toIso8601String(),
            "updatedAt": cuisine.updatedAt.toIso8601String(),
          };
          _cuisineList.add(cuisineData);
          print("Successfully processed cuisine: ${cuisineData["title"]}");
        } catch (e) {
          print("Error processing cuisine $i: $e");
          print("Cuisine: ${cuisine.toString()}");
        }
      }

      // Load categories for filtering (use cuisines as categories)
      print("Loading categories from cuisines...");
      _categories.clear();

      // Add "All" category first
      _categories.add({
        "id": "all",
        "title": "All",
        "image": "",
        "status": "active",
      });

      // Add cuisines as categories
      for (var cuisine in _cuisineList) {
        _categories.add({
          "id": cuisine["id"],
          "title": cuisine["title"],
          "image": cuisine["image"],
          "status": cuisine["status"],
        });
      }

      print("Successfully loaded ${_categories.length} categories");

      // Fetch surprise bags using SurpriseBagModel with optional radius filtering
      print("Fetching surprise bags from Firebase...");
      List<SurpriseBagModel> surpriseBags = await RestaurantService.getSurpriseBags();
      print("Received ${surpriseBags.length} surprise bags from service");
      _surpriseBags.clear();

      // Filter surprise bags by radius if location filtering is enabled
      if (useRadiusFiltering) {
        print("Filtering surprise bags by radius: ${selectedRadius.value} km");
        List<SurpriseBagModel> filteredBags = [];

        for (SurpriseBagModel bag in surpriseBags) {
          if (bag.pickupLatitude != 0.0 && bag.pickupLongitude != 0.0) {
            double distance = _calculateDistance(
              currentLatitude.value,
              currentLongitude.value,
              bag.pickupLatitude,
              bag.pickupLongitude,
            );

            if (distance <= selectedRadius.value.toDouble()) {
              // Update the bag's distance for display
              SurpriseBagModel updatedBag = bag.copyWith(distance: distance);
              filteredBags.add(updatedBag);
            }
          }
        }

        surpriseBags = filteredBags;
        print("Filtered to ${surpriseBags.length} surprise bags within radius");
      }

      for (int i = 0; i < surpriseBags.length; i++) {
        SurpriseBagModel bag = surpriseBags[i];
        print("Processing surprise bag $i: ${bag.id}");

        try {
          Map<String, dynamic> bagData = {
            "id": bag.id,
            "restaurantId": bag.restaurantId,
            "restaurantName": bag.restaurantName,
            "title": bag.title.isNotEmpty ? bag.title : "Surprise Bag",
            "description": bag.description,
            "img": bag.img.isNotEmpty ? bag.img : "https://picsum.photos/300/200",
            "originalPrice": bag.originalPrice.toString(),
            "discountedPrice": bag.discountedPrice.toString(),
            "discountPercentage": bag.calculatedDiscountPercentage.toString(),
            "itemsLeft": bag.itemsLeft.toString(),
            "totalItems": bag.totalItems.toString(),
            "category": bag.category,
            "isAvailable": bag.isAvailable,
            "status": bag.status,
            "pickupType": bag.pickupType,
            "todayPickupStart": bag.todayPickupStart,
            "todayPickupEnd": bag.todayPickupEnd,
            "tomorrowPickupStart": bag.tomorrowPickupStart,
            "tomorrowPickupEnd": bag.tomorrowPickupEnd,
            "pickupInstructions": bag.pickupInstructions,
            "distance": bag.distance.toString(),
            "pickupAddress": bag.pickupAddress,
            "pickupLatitude": bag.pickupLatitude.toString(),
            "pickupLongitude": bag.pickupLongitude.toString(),
            "possibleItems": bag.possibleItems,
            "allergens": bag.allergens,
            "isVegetarian": bag.isVegetarian,
            "isVegan": bag.isVegan,
            "isGlutenFree": bag.isGlutenFree,
            "dietaryInfo": bag.dietaryInfo,
            "rating": bag.rating.toString(),
            "totalReviews": bag.totalReviews.toString(),
            "totalSold": bag.totalSold.toString(),
            "createdAt": bag.createdAt.toIso8601String(),
            "updatedAt": bag.updatedAt.toIso8601String(),
          };
          _surpriseBags.add(bagData);
          print("Successfully processed surprise bag: ${bagData["title"]}");
        } catch (e) {
          print("Error processing surprise bag $i: $e");
          print("Surprise bag: ${bag.toString()}");
        }
      }

      print("Successfully loaded ${_allrest.length} restaurants, ${_sliderimage.length} banners, ${_cuisineList.length} cuisines, ${_surpriseBags.length} surprise bags");
      update(); // Notify UI to refresh
    } catch (e) {
      print("Error in loadRealFirebaseData: $e");
      print("Stack trace: ${e.toString()}");
      FirebaseService.showToastMessage("Error loading data: ${e.toString()}");
    }
  }

  void changeObjectIndex(int index) {
    currentIndex.value = index;
  }

  // Backward compatibility method
  void chnageObjectIndex(int index) {
    currentIndex.value = index;
    update();
  }

  // Location Services - Enhanced version
  Future<void> getCurrentLocation({bool forceRefresh = false}) async {
    try {
      isLocationLoading.value = true;
      print("=== STARTING LOCATION SERVICE ===");
      print("Force refresh: $forceRefresh");

      // If we already have location and not forcing refresh, use cached location
      if (!forceRefresh && currentLatitude.value != 0.0 && currentLongitude.value != 0.0) {
        print("Using cached location: ${currentLatitude.value}, ${currentLongitude.value}");
        isLocationLoading.value = false;
        return;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print("Location services enabled: $serviceEnabled");

      if (!serviceEnabled) {
        print("Location services are disabled - requesting user to enable");
        // Try to open location settings
        try {
          await Geolocator.openLocationSettings();
          // Wait a bit and check again
          await Future.delayed(Duration(seconds: 2));
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
          print("Location services enabled after settings: $serviceEnabled");
        } catch (e) {
          print("Could not open location settings: $e");
        }

        if (!serviceEnabled) {
          print("Location services still disabled - using default location");
          _setDefaultLocation();
          return;
        }
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      print("Current permission status: $permission");

      if (permission == LocationPermission.denied) {
        print("Requesting location permission...");
        permission = await Geolocator.requestPermission();
        print("Permission after request: $permission");

        if (permission == LocationPermission.denied) {
          print("Location permission denied by user");
          _setDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("Location permission denied forever - opening app settings");
        try {
          await Geolocator.openAppSettings();
        } catch (e) {
          print("Could not open app settings: $e");
        }
        _setDefaultLocation();
        return;
      }

      // Try to get location with multiple accuracy levels
      Position? position;

      try {
        print("Attempting to get high accuracy location...");
        position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        ).timeout(Duration(seconds: 15));
      } catch (e) {
        print("High accuracy failed: $e, trying medium accuracy...");
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 8),
            ),
          ).timeout(Duration(seconds: 12));
        } catch (e2) {
          print("Medium accuracy failed: $e2, trying low accuracy...");
          try {
            position = await Geolocator.getCurrentPosition(
              locationSettings: LocationSettings(
                accuracy: LocationAccuracy.low,
                timeLimit: Duration(seconds: 5),
              ),
            ).timeout(Duration(seconds: 8));
          } catch (e3) {
            print("All accuracy levels failed: $e3");
            throw e3;
          }
        }
      }

      // Position should not be null at this point, but let's be safe
      currentLatitude.value = position.latitude;
      currentLongitude.value = position.longitude;

      // Update global variables for backward compatibility
      lat = position.latitude;
      long = position.longitude;

      print("=== LOCATION RETRIEVED SUCCESSFULLY ===");
      print("Latitude: ${position.latitude}");
      print("Longitude: ${position.longitude}");
      print("Accuracy: ${position.accuracy} meters");
      print("Timestamp: ${position.timestamp}");

      // Get address from coordinates
      await _getAddressFromCoordinates(position.latitude, position.longitude);

      // Save location to storage for future use
      await _saveLocationToStorage(position);

    } catch (e) {
      print("=== LOCATION SERVICE ERROR ===");
      print("Error getting location: $e");
      print("Falling back to default location");
      _setDefaultLocation();
    } finally {
      isLocationLoading.value = false;
      print("=== LOCATION SERVICE COMPLETED ===");
    }
  }

  void _setDefaultLocation() {
    // Set default location (San Francisco) if location service fails
    currentLatitude.value = 30.2525;
    currentLongitude.value = 67.0574;
    lat = 30.2525;
    long = 67.0574;
    currentAddress.value = "San Francisco, CA (Default)";
    print("Using default location: San Francisco");
    print("Default location set - lat: ${currentLatitude.value}, lng: ${currentLongitude.value}");
  }

  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> addressParts = [
          place.street ?? '',
          place.subLocality ?? '',
          place.locality ?? '',
          place.administrativeArea ?? ''
        ].where((part) => part.isNotEmpty).toList();
        currentAddress.value = addressParts.isNotEmpty ? addressParts.join(', ') : "Location found";
        print("Address: ${currentAddress.value}");
      }
    } catch (e) {
      print("Error getting address: $e");
      currentAddress.value = "Location found";
    }
  }

  Future<void> _saveLocationToStorage(Position position) async {
    try {
      Map<String, dynamic> locationData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': position.timestamp?.toIso8601String(),
        'address': currentAddress.value,
      };

      await getData.write('LastKnownLocation', locationData);
      print("Location saved to storage: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("Error saving location to storage: $e");
    }
  }

  Future<void> _loadLocationFromStorage() async {
    try {
      var savedLocation = getData.read('LastKnownLocation');
      if (savedLocation != null) {
        currentLatitude.value = savedLocation['latitude'] ?? 0.0;
        currentLongitude.value = savedLocation['longitude'] ?? 0.0;
        currentAddress.value = savedLocation['address'] ?? "Saved location";

        // Update global variables for backward compatibility
        lat = currentLatitude.value;
        long = currentLongitude.value;

        print("Loaded location from storage: ${currentLatitude.value}, ${currentLongitude.value}");
        return;
      }
    } catch (e) {
      print("Error loading location from storage: $e");
    }

    // If no saved location, use default
    _setDefaultLocation();
  }

  // Get home data from Firebase - Show ALL restaurants without location requirements
  Future<void> homeDataApi() async {
    print("homeDataApi called - Loading ALL restaurants without location filtering!");
    try {
      isLoading.value = true;
      print("Loading started...");

      var userData = getData.read("UserLogin");
      print("User data: $userData");

      // Allow loading restaurants even without login for browsing
      if (userData == null) {
        print("User not logged in - loading restaurants for browsing");
        // Continue without user ID - restaurants can be viewed without login
      } else {
        String? uid = userData["id"]?.toString();
        print("User ID: $uid");
      }

      // Skip location requirement - we're showing ALL restaurants
      print("Skipping location requirement - showing ALL restaurants...");

      // Fetch ALL real data from Firebase collections
      try {
        print("About to call loadRealFirebaseData...");
        await loadRealFirebaseData();
        print("loadRealFirebaseData completed successfully");
      } catch (e, stackTrace) {
        print("❌ Error in loadRealFirebaseData: $e");
        print("Stack trace: $stackTrace");
        throw e; // Re-throw to be caught by outer catch
      }

      // Set home data with default location (location not required for showing all restaurants)
      homeDataList.value = {
        "currency": "\$",
        "delivery_charge": "2.99",
        "tax": "8.5",
        "latitude": currentLatitude.value.toString(),
        "longitude": currentLongitude.value.toString(),
        "address": currentAddress.value.isNotEmpty ? currentAddress.value : "All Locations",
      };

      print("✅ Firebase data loading completed successfully - ${_allrest.length} restaurants loaded");
      FirebaseService.showToastMessage("${_allrest.length} restaurants loaded successfully");
      update();
    } catch (e) {
      print("❌ Error in homeDataApi: $e");
      FirebaseService.showToastMessage("Error loading restaurant data");
    } finally {
      isLoading.value = false;
      print("Loading finished.");
    }
  }

  viewmenulist({String? id}) async {
    try {
      if (id == null) return;

      var result = await RestaurantService.getRestaurantMenu(
        restaurantId: id,
      );

      if (result['Result'] == 'true') {
        _viewmenu.value = result["menudata"] ?? [];
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
        _viewmenu.value = List<Map<String, dynamic>>.from(
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

      String? uid = userData["id"]?.toString();

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
        _faq.value = List<Map<String, dynamic>>.from(
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

      String? uid = userData["id"]?.toString();

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

  // Plan functionality removed as requested

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
        _allrest.value = List<Map<String, dynamic>>.from(
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
        _cuisinerestlist.value = List<Map<String, dynamic>>.from(
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
    // Plan functionality removed as requested
    print("Plan functionality has been removed");
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
