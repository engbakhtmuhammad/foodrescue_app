import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';
import '../models/banner_model.dart';
import '../models/cuisine_model.dart';
import '../models/surprise_bag_model.dart';
import 'dart:math';

class RestaurantService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch real restaurants from Firebase using RestaurantModel
  static Future<List<RestaurantModel>> getRestaurants() async {
    try {
      print("Starting to fetch restaurants from Firebase...");

      QuerySnapshot querySnapshot = await _firestore
          .collection('restaurants')
          .where('status', isEqualTo: 'active')
          // Remove orderBy to avoid index requirement
          .get()
          .timeout(Duration(seconds: 30));

      List<RestaurantModel> restaurants = [];
      int successCount = 0;
      int errorCount = 0;

      for (var doc in querySnapshot.docs) {
        try {
          // Validate document data exists
          if (doc.data() == null) {
            print("Warning: Restaurant ${doc.id} has null data, skipping");
            errorCount++;
            continue;
          }

          RestaurantModel restaurant = RestaurantModel.fromFirestore(doc);
          restaurants.add(restaurant);
          successCount++;

          if (successCount % 10 == 0) {
            print("Processed $successCount restaurants so far...");
          }
        } catch (e, stackTrace) {
          errorCount++;
          print("Error parsing restaurant ${doc.id}: $e");
          print("Stack trace: $stackTrace");
          // Continue with other restaurants - don't let one bad document break everything
        }
      }

      print("Restaurant fetch completed: $successCount successful, $errorCount errors");
      print("Total restaurants fetched: ${restaurants.length}");
      return restaurants;
    } catch (e, stackTrace) {
      print("Critical error fetching restaurants: $e");
      print("Stack trace: $stackTrace");
      return [];
    }
  }

  // Get restaurants as Map for backward compatibility
  static Future<List<Map<String, dynamic>>> getRestaurantsAsMap() async {
    try {
      List<RestaurantModel> restaurants = await getRestaurants();
      return restaurants.map((restaurant) => restaurant.toMap()).toList();
    } catch (e) {
      print("Error converting restaurants to map: $e");
      return [];
    }
  }

  // Fetch banners from Firebase using BannerModel
  static Future<List<BannerModel>> getBanners() async {
    try {
      print("Starting to fetch banners from Firebase...");

      QuerySnapshot querySnapshot = await _firestore
          .collection('banners')
          .where('status', isEqualTo: 'active')
          // Remove orderBy to avoid index requirement
          .limit(20) // Limit banners for better performance
          .get()
          .timeout(Duration(seconds: 15));

      List<BannerModel> banners = [];
      int successCount = 0;
      int errorCount = 0;

      for (var doc in querySnapshot.docs) {
        try {
          if (doc.data() == null) {
            print("Warning: Banner ${doc.id} has null data, skipping");
            errorCount++;
            continue;
          }

          BannerModel banner = BannerModel.fromFirestore(doc);
          banners.add(banner);
          successCount++;
        } catch (e, stackTrace) {
          errorCount++;
          print("Error parsing banner ${doc.id}: $e");
          print("Stack trace: $stackTrace");
          // Continue with other banners
        }
      }

      print("Banner fetch completed: $successCount successful, $errorCount errors");
      print("Total banners fetched: ${banners.length}");
      return banners;
    } catch (e, stackTrace) {
      print("Critical error fetching banners: $e");
      print("Stack trace: $stackTrace");
      // Return empty list instead of crashing
      return [];
    }
  }

  // Get banners as Map for backward compatibility
  static Future<List<Map<String, dynamic>>> getBannersAsMap() async {
    try {
      List<BannerModel> banners = await getBanners();
      return banners.map((banner) => banner.toMap()).toList();
    } catch (e) {
      print("Error converting banners to map: $e");
      return [];
    }
  }

  // Fetch cuisines from Firebase using CuisineModel
  static Future<List<CuisineModel>> getCuisines() async {
    try {
      print("Starting to fetch cuisines from Firebase...");

      QuerySnapshot querySnapshot = await _firestore
          .collection('cuisines')
          .where('status', isEqualTo: 'active')
          // Remove orderBy to avoid index requirement
          .limit(50) // Limit cuisines for better performance
          .get()
          .timeout(Duration(seconds: 15));

      List<CuisineModel> cuisines = [];
      int successCount = 0;
      int errorCount = 0;

      for (var doc in querySnapshot.docs) {
        try {
          if (doc.data() == null) {
            print("Warning: Cuisine ${doc.id} has null data, skipping");
            errorCount++;
            continue;
          }

          CuisineModel cuisine = CuisineModel.fromFirestore(doc);
          cuisines.add(cuisine);
          successCount++;
        } catch (e, stackTrace) {
          errorCount++;
          print("Error parsing cuisine ${doc.id}: $e");
          print("Stack trace: $stackTrace");
          // Continue with other cuisines
        }
      }

      print("Cuisine fetch completed: $successCount successful, $errorCount errors");
      print("Total cuisines fetched: ${cuisines.length}");
      return cuisines;
    } catch (e, stackTrace) {
      print("Critical error fetching cuisines: $e");
      print("Stack trace: $stackTrace");
      return [];
    }
  }

  // Get cuisines as Map for backward compatibility
  static Future<List<Map<String, dynamic>>> getCuisinesAsMap() async {
    try {
      List<CuisineModel> cuisines = await getCuisines();
      return cuisines.map((cuisine) => cuisine.toMap()).toList();
    } catch (e) {
      print("Error converting cuisines to map: $e");
      return [];
    }
  }

  // Fetch surprise bags from Firebase using SurpriseBagModel
  static Future<List<SurpriseBagModel>> getSurpriseBags() async {
    try {
      print("Starting to fetch surprise bags from Firebase...");

      QuerySnapshot querySnapshot = await _firestore
          .collection('surprise_bags')
          .where('status', isEqualTo: 'active')
          .where('isAvailable', isEqualTo: true)
          // Remove complex where and orderBy to avoid index requirement
          .limit(50) // Limit for performance
          .get()
          .timeout(Duration(seconds: 30));

      print("Received ${querySnapshot.docs.length} surprise bag documents from Firebase");

      List<SurpriseBagModel> surpriseBags = [];
      int successCount = 0;
      int errorCount = 0;

      for (var doc in querySnapshot.docs) {
        try {
          // Validate document data exists
          if (doc.data() == null) {
            print("Warning: Surprise bag ${doc.id} has null data, skipping");
            errorCount++;
            continue;
          }

          SurpriseBagModel surpriseBag = SurpriseBagModel.fromFirestore(doc);
          surpriseBags.add(surpriseBag);
          successCount++;

          if (successCount % 10 == 0) {
            print("Processed $successCount surprise bags so far...");
          }
        } catch (e, stackTrace) {
          errorCount++;
          print("Error parsing surprise bag ${doc.id}: $e");
          print("Stack trace: $stackTrace");
          // Continue with other surprise bags - don't let one bad document break everything
        }
      }

      print("Surprise bag fetch completed: $successCount successful, $errorCount errors");
      print("Total surprise bags fetched: ${surpriseBags.length}");
      return surpriseBags;
    } catch (e, stackTrace) {
      print("Critical error fetching surprise bags: $e");
      print("Stack trace: $stackTrace");
      return [];
    }
  }

  // Get surprise bags as Map for backward compatibility
  static Future<List<Map<String, dynamic>>> getSurpriseBagsAsMap() async {
    try {
      List<SurpriseBagModel> surpriseBags = await getSurpriseBags();
      return surpriseBags.map((bag) => bag.toMap()).toList();
    } catch (e) {
      print("Error converting surprise bags to map: $e");
      return [];
    }
  }

  // Fetch categories from Firebase
  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .get();

      List<Map<String, dynamic>> categories = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        categories.add(data);
      }

      print("Fetched ${categories.length} categories from Firebase");
      return categories;
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }

  // Initialize sample data for testing (fallback)
  static Future<void> initializeSampleData() async {
    try {
      // Check if real data already exists
      QuerySnapshot existingRestaurants = await _firestore
          .collection('restaurants')
          .limit(1)
          .get();

      if (existingRestaurants.docs.isNotEmpty) {
        print("Real data already exists, skipping sample data");
        return;
      }

      // Add sample restaurants
      List<Map<String, dynamic>> sampleRestaurants = [
        {
          'title': 'Pizza Palace',
          'description': 'Best pizza in town with fresh ingredients',
          'latitude': '37.7749',
          'longitude': '-122.4194',
          'rate': '4.5',
          'landmark': 'Downtown',
          'address': '123 Main St, San Francisco, CA',
          'cuisines': ['Italian', 'Pizza'],
          'status': 'active',
          'image': 'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Pizza+Palace',
          'delivery_time': '30-45 min',
          'delivery_fee': '2.99',
          'minimum_order': '15.00',
          'phone': '+1-555-0123',
          'email': 'info@pizzapalace.com',
          'opening_hours': {
            'monday': '11:00-22:00',
            'tuesday': '11:00-22:00',
            'wednesday': '11:00-22:00',
            'thursday': '11:00-22:00',
            'friday': '11:00-23:00',
            'saturday': '11:00-23:00',
            'sunday': '12:00-21:00',
          },
        },
        {
          'title': 'Burger Barn',
          'description': 'Juicy burgers and crispy fries',
          'latitude': '37.7849',
          'longitude': '-122.4094',
          'rate': '4.2',
          'landmark': 'Mission District',
          'address': '456 Oak Ave, San Francisco, CA',
          'cuisines': ['American', 'Burgers'],
          'status': 'active',
          'image': 'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Burger+Barn',
          'delivery_time': '25-35 min',
          'delivery_fee': '1.99',
          'minimum_order': '12.00',
          'phone': '+1-555-0124',
          'email': 'info@burgerbarn.com',
          'opening_hours': {
            'monday': '10:00-22:00',
            'tuesday': '10:00-22:00',
            'wednesday': '10:00-22:00',
            'thursday': '10:00-22:00',
            'friday': '10:00-23:00',
            'saturday': '10:00-23:00',
            'sunday': '11:00-21:00',
          },
        },
        {
          'title': 'Sushi Zen',
          'description': 'Fresh sushi and Japanese cuisine',
          'latitude': '37.7649',
          'longitude': '-122.4294',
          'rate': '4.8',
          'landmark': 'Japantown',
          'address': '789 Pine St, San Francisco, CA',
          'cuisines': ['Japanese', 'Sushi'],
          'status': 'active',
          'image': 'https://via.placeholder.com/300x200/45B7D1/FFFFFF?text=Sushi+Zen',
          'delivery_time': '35-50 min',
          'delivery_fee': '3.99',
          'minimum_order': '20.00',
          'phone': '+1-555-0125',
          'email': 'info@sushizen.com',
          'opening_hours': {
            'monday': '17:00-22:00',
            'tuesday': '17:00-22:00',
            'wednesday': '17:00-22:00',
            'thursday': '17:00-22:00',
            'friday': '17:00-23:00',
            'saturday': '17:00-23:00',
            'sunday': 'closed',
          },
        },
      ];

      // Add sample cuisines
      List<Map<String, dynamic>> sampleCuisines = [
        {
          'title': 'Italian',
          'name': 'Italian',
          'image': 'https://via.placeholder.com/100x100/FF6B6B/FFFFFF?text=IT',
          'status': 'active',
        },
        {
          'title': 'American',
          'name': 'American',
          'image': 'https://via.placeholder.com/100x100/4ECDC4/FFFFFF?text=US',
          'status': 'active',
        },
        {
          'title': 'Japanese',
          'name': 'Japanese',
          'image': 'https://via.placeholder.com/100x100/45B7D1/FFFFFF?text=JP',
          'status': 'active',
        },
      ];

      // Add sample banners
      List<Map<String, dynamic>> sampleBanners = [
        {
          'title': 'Welcome to Food Rescue',
          'description': 'Discover amazing restaurants near you',
          'image': 'https://via.placeholder.com/400x200/96CEB4/FFFFFF?text=Welcome',
          'status': 'active',
          'order': 1,
        },
        {
          'title': 'Free Delivery',
          'description': 'Free delivery on orders over \$25',
          'image': 'https://via.placeholder.com/400x200/FFEAA7/FFFFFF?text=Free+Delivery',
          'status': 'active',
          'order': 2,
        },
      ];

      // Add restaurants to Firestore
      for (var restaurant in sampleRestaurants) {
        await _firestore.collection('restaurants').add(restaurant);
      }

      // Add cuisines to Firestore
      for (var cuisine in sampleCuisines) {
        await _firestore.collection('cuisines').add(cuisine);
      }

      // Add banners to Firestore
      for (var banner in sampleBanners) {
        await _firestore.collection('banners').add(banner);
      }

      print("Sample data initialized successfully");
    } catch (e) {
      print("Error initializing sample data: $e");
    }
  }

  // Get home data including banners, cuisines, and restaurants
  static Future<Map<String, dynamic>> getHomeData({
    required String uid,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Get banners
      QuerySnapshot bannersSnapshot = await _firestore
          .collection('banners')
          .get();

      List<Map<String, dynamic>> bannerList = bannersSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();

      // Get cuisines
      QuerySnapshot cuisinesSnapshot = await _firestore
          .collection('cuisines')
          .get();

      List<Map<String, dynamic>> cuisineList = cuisinesSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();

      // Get restaurants
      QuerySnapshot restaurantsSnapshot = await _firestore
          .collection('restaurants')
          .limit(20)
          .get();

      List<Map<String, dynamic>> allRestaurants = [];
      List<Map<String, dynamic>> latestRestaurants = [];

      for (var doc in restaurantsSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        var restaurant = {
          'id': doc.id,
          ...data,
        };

        // Calculate distance if location is provided
        if (data['latitude'] != null && data['longitude'] != null) {
          try {
            double? restLat = double.tryParse(data['latitude'].toString());
            double? restLng = double.tryParse(data['longitude'].toString());

            if (restLat != null && restLng != null) {
              double distance = _calculateDistance(
                latitude,
                longitude,
                restLat,
                restLng,
              );
              restaurant['rest_distance'] = distance.toStringAsFixed(2);
            } else {
              restaurant['rest_distance'] = "0.0";
            }
          } catch (e) {
            restaurant['rest_distance'] = "0.0";
          }
        } else {
          restaurant['rest_distance'] = "0.0";
        }

        allRestaurants.add(restaurant);

        // Add to latest if created within last 30 days
        if (data['created_at'] != null) {
          Timestamp createdAt = data['created_at'];
          DateTime createdDate = createdAt.toDate();
          DateTime thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
          if (createdDate.isAfter(thirtyDaysAgo)) {
            latestRestaurants.add(restaurant);
          }
        }
      }

      // Sort by distance
      allRestaurants.sort((a, b) {
        double distanceA = double.tryParse(a['rest_distance'] ?? '0') ?? 0;
        double distanceB = double.tryParse(b['rest_distance'] ?? '0') ?? 0;
        return distanceA.compareTo(distanceB);
      });

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Data retrieved successfully',
        'HomeData': {
          'Bannerlist': bannerList,
          'CuisineList': cuisineList,
          'latest_rest': latestRestaurants,
          'all_rest': allRestaurants,
          'currency': 'USD', // You can make this dynamic
        }
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Get restaurant details
  static Future<Map<String, dynamic>> getRestaurantDetails({
    required String restaurantId,
  }) async {
    try {
      DocumentSnapshot restaurantDoc = await _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .get();

      if (!restaurantDoc.exists) {
        return {
          'ResponseCode': '400',
          'Result': 'false',
          'ResponseMsg': 'Restaurant not found',
        };
      }

      var restaurantData = restaurantDoc.data() as Map<String, dynamic>;

      // Get related restaurants (same cuisine)
      List<String> cuisines = List<String>.from(restaurantData['cuisines'] ?? []);
      QuerySnapshot relatedSnapshot = await _firestore
          .collection('restaurants')
          .where('cuisines', arrayContainsAny: cuisines)
          .where('status', isEqualTo: 'active')
          .limit(5)
          .get();

      List<Map<String, dynamic>> relatedRestaurants = relatedSnapshot.docs
          .where((doc) => doc.id != restaurantId)
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Restaurant details retrieved successfully',
        'restdata': {
          'id': restaurantDoc.id,
          ...restaurantData,
        },
        'related_rest': relatedRestaurants,
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Get restaurant menu
  static Future<Map<String, dynamic>> getRestaurantMenu({
    required String restaurantId,
  }) async {
    try {
      QuerySnapshot menuSnapshot = await _firestore
          .collection('menus')
          .where('restaurant_id', isEqualTo: restaurantId)
          .where('status', isEqualTo: 'active')
          .orderBy('category')
          .orderBy('name')
          .get();

      List<Map<String, dynamic>> menuData = menuSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Menu retrieved successfully',
        'menudata': menuData,
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Get restaurant gallery
  static Future<Map<String, dynamic>> getRestaurantGallery({
    required String restaurantId,
  }) async {
    try {
      QuerySnapshot gallerySnapshot = await _firestore
          .collection('galleries')
          .where('restaurant_id', isEqualTo: restaurantId)
          .orderBy('category')
          .get();

      Map<String, List<String>> groupedGallery = {};
      
      for (var doc in gallerySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String category = data['category'] ?? 'General';
        List<String> images = List<String>.from(data['images'] ?? []);
        
        if (groupedGallery.containsKey(category)) {
          groupedGallery[category]!.addAll(images);
        } else {
          groupedGallery[category] = images;
        }
      }

      List<Map<String, dynamic>> galleryData = groupedGallery.entries
          .map((entry) => {
                'title': entry.key,
                'imglist': entry.value,
              })
          .toList();

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Gallery retrieved successfully',
        'gallerydata': galleryData,
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Get nearby restaurants
  static Future<Map<String, dynamic>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double radiusKm = 50000.0,
  }) async {
    try {
      QuerySnapshot restaurantsSnapshot = await _firestore
          .collection('restaurants')
          .where('status', isEqualTo: 'active')
          .get();

      List<Map<String, dynamic>> nearbyRestaurants = [];

      for (var doc in restaurantsSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        
        if (data['latitude'] != null && data['longitude'] != null) {
          try {
            double? restLat = double.tryParse(data['latitude'].toString());
            double? restLng = double.tryParse(data['longitude'].toString());

            if (restLat != null && restLng != null) {
              double distance = _calculateDistance(
                latitude,
                longitude,
                restLat,
                restLng,
              );

              if (distance <= radiusKm) {
                nearbyRestaurants.add({
                  'id': doc.id,
                  ...data,
                  'rest_distance': distance.toStringAsFixed(2),
                });
              }
            }
          } catch (e) {
            print('Error calculating distance for restaurant ${doc.id}: $e');
          }
        }
      }

      // Sort by distance
      nearbyRestaurants.sort((a, b) {
        double distanceA = double.parse(a['rest_distance']);
        double distanceB = double.parse(b['rest_distance']);
        return distanceA.compareTo(distanceB);
      });

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Nearby restaurants retrieved successfully',
        'Nearbyrestlist': nearbyRestaurants,
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Get restaurants by cuisine
  static Future<Map<String, dynamic>> getRestaurantsByCuisine({
    required String cuisineId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      QuerySnapshot restaurantsSnapshot = await _firestore
          .collection('restaurants')
          .where('cuisines', arrayContains: cuisineId)
          .where('status', isEqualTo: 'active')
          .get();

      List<Map<String, dynamic>> cuisineRestaurants = [];

      for (var doc in restaurantsSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        var restaurant = {
          'id': doc.id,
          ...data,
        };

        // Calculate distance
        if (data['latitude'] != null && data['longitude'] != null) {
          try {
            double? restLat = double.tryParse(data['latitude'].toString());
            double? restLng = double.tryParse(data['longitude'].toString());

            if (restLat != null && restLng != null) {
              double distance = _calculateDistance(
                latitude,
                longitude,
                restLat,
                restLng,
              );
              restaurant['rest_distance'] = distance.toStringAsFixed(2);
            } else {
              restaurant['rest_distance'] = "0.0";
            }
          } catch (e) {
            restaurant['rest_distance'] = "0.0";
          }
        } else {
          restaurant['rest_distance'] = "0.0";
        }

        cuisineRestaurants.add(restaurant);
      }

      // Sort by distance
      cuisineRestaurants.sort((a, b) {
        double distanceA = double.tryParse(a['rest_distance'] ?? '0') ?? 0;
        double distanceB = double.tryParse(b['rest_distance'] ?? '0') ?? 0;
        return distanceA.compareTo(distanceB);
      });

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Cuisine restaurants retrieved successfully',
        'Cuisinerestlist': cuisineRestaurants,
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Calculate distance between two points using Haversine formula
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
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

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Note: Timestamp conversion is now handled by the models themselves
}
