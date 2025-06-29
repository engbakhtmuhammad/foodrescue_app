import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:math';

class RestaurantService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
          .where('status', isEqualTo: 'active')
          .orderBy('order')
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
          .where('status', isEqualTo: 'active')
          .orderBy('name')
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
          .where('status', isEqualTo: 'active')
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
    double radiusKm = 10.0,
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
}
