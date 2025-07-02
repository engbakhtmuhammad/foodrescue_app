import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/controllers/home_controller.dart';
import 'package:foodrescue_app/controllers/favourites_controller.dart';
import 'package:foodrescue_app/Utils/dark_light_mode.dart';
import 'package:foodrescue_app/views/bags/SurpriseBagDetails.dart';
import 'package:foodrescue_app/views/restaurant/Hotel_Details.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final HomeController homeController = Get.find<HomeController>();
  final FavouritesController favouritesController = Get.put(FavouritesController());
  final TextEditingController searchController = TextEditingController();
  String selectedSortBy = "Relevance";
  bool isListView = true;
  List<Map<String, dynamic>> filteredBags = [];
  List<Map<String, dynamic>> filteredRestaurants = [];
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  LatLng currentLocation = LatLng(37.7749, -122.4194); // Default to San Francisco
  String selectedCategory = "all";
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    // Clean up map resources
    _isMapReady = false;
    if (mapController != null) {
      try {
        mapController?.dispose();
      } catch (e) {
        // Ignore disposal errors
      }
      mapController = null;
    }
    markers.clear();
    searchController.dispose();
    super.dispose();
  }

  void _filterByCategory() {
    if (selectedCategory == "all") {
      filteredBags = homeController.surpriseBags.cast<Map<String, dynamic>>();
      filteredRestaurants = homeController.allrest.cast<Map<String, dynamic>>();
    } else {
      // Filter surprise bags by restaurant cuisine
      filteredBags = homeController.surpriseBags.where((bag) {
        final restaurant = homeController.allrest.firstWhere(
          (r) => r["id"] == bag["restaurantId"],
          orElse: () => {},
        );

        if (restaurant.isNotEmpty && restaurant["cuisines"] != null) {
          List<String> cuisines = restaurant["cuisines"].toString().split(',');
          return cuisines.any((cuisine) =>
            cuisine.trim().toLowerCase().contains(selectedCategory.toLowerCase())
          );
        }
        return false;
      }).cast<Map<String, dynamic>>().toList();

      // Filter restaurants by cuisine
      filteredRestaurants = homeController.allrest.where((restaurant) {
        if (restaurant["cuisines"] != null) {
          List<String> cuisines = restaurant["cuisines"].toString().split(',');
          return cuisines.any((cuisine) =>
            cuisine.trim().toLowerCase().contains(selectedCategory.toLowerCase())
          );
        }
        return false;
      }).cast<Map<String, dynamic>>().toList();
    }

    // Update map markers when category changes
    if (!isListView && _isMapReady) {
      Future.delayed(Duration(milliseconds: 100), () {
        _updateMapMarkers();
      });
    }

    setState(() {});
  }

  void _initializeData() {
    filteredBags = List.from(homeController.surpriseBags);
    filteredRestaurants = List.from(homeController.allrest);
  }

  void _performSearch(String query) {
    setState(() {
      List<Map<String, dynamic>> allBags = List.from(homeController.surpriseBags);
      List<Map<String, dynamic>> allRestaurants = List.from(homeController.allrest);

      // Apply search filter
      if (query.isNotEmpty) {
        allBags = allBags.where((bag) {
          final title = bag["title"]?.toString().toLowerCase() ?? "";
          final category = bag["category"]?.toString().toLowerCase() ?? "";
          return title.contains(query.toLowerCase()) ||
                 category.contains(query.toLowerCase());
        }).cast<Map<String, dynamic>>().toList();

        allRestaurants = allRestaurants.where((restaurant) {
          final title = restaurant["title"]?.toString().toLowerCase() ?? "";
          final cuisines = restaurant["cuisines"]?.toString().toLowerCase() ?? "";
          return title.contains(query.toLowerCase()) ||
                 cuisines.contains(query.toLowerCase());
        }).cast<Map<String, dynamic>>().toList();
      }

      // Apply category filter
      if (selectedCategory != "all") {
        allBags = allBags.where((bag) {
          final restaurant = homeController.allrest.firstWhere(
            (r) => r["id"] == bag["restaurantId"],
            orElse: () => {},
          );

          if (restaurant.isNotEmpty && restaurant["cuisines"] != null) {
            List<String> cuisines = restaurant["cuisines"].toString().split(',');
            return cuisines.any((cuisine) =>
              cuisine.trim().toLowerCase().contains(selectedCategory.toLowerCase())
            );
          }
          return false;
        }).toList();

        allRestaurants = allRestaurants.where((restaurant) {
          if (restaurant["cuisines"] != null) {
            List<String> cuisines = restaurant["cuisines"].toString().split(',');
            return cuisines.any((cuisine) =>
              cuisine.trim().toLowerCase().contains(selectedCategory.toLowerCase())
            );
          }
          return false;
        }).toList();
      }

      filteredBags = allBags;
      filteredRestaurants = allRestaurants;

      // Update map markers when search results change
      if (!isListView && _isMapReady) {
        Future.delayed(Duration(milliseconds: 100), () {
          _updateMapMarkers();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorNotifier notifier = Provider.of<ColorNotifier>(context, listen: true);
    
    return Scaffold(
      backgroundColor: notifier.background,
      appBar: AppBar(
        backgroundColor: notifier.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: notifier.textColor),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: notifier.containerColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: TextField(
            controller: searchController,
            onChanged: _performSearch,
            decoration: InputDecoration(
              hintText: "Search",
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
            style: TextStyle(color: notifier.textColor),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Filter functionality
            },
            icon: Icon(Icons.tune, color: notifier.textColor),
          ),
          IconButton(
            onPressed: () {
              // Location functionality
            },
            icon: Icon(Icons.location_on, color: orangeColor),
          ),
        ],
      ),
      body: Column(
        children: [
          // List/Map toggle and Sort
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // List/Map toggle
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isListView = true),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isListView ? orangeColor : notifier.containerColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            "List",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isListView ? Colors.white : notifier.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => isListView = false);
                          // Update markers after a short delay
                          Future.delayed(Duration(milliseconds: 200), () {
                            if (mounted && _isMapReady) {
                              _updateMapMarkers();
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isListView ? orangeColor : notifier.containerColor,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Map",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !isListView ? Colors.white : notifier.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Category and Sort filters
                Row(
                  children: [
                    // Category filter
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            "Category: ",
                            style: TextStyle(
                              color: notifier.textColor,
                              fontSize: 14,
                            ),
                          ),
                          GetBuilder<HomeController>(
                            builder: (controller) {
                              if (controller.categories.isEmpty) {
                                return Text("Loading...", style: TextStyle(color: Colors.grey));
                              }

                              return DropdownButton<String>(
                                value: selectedCategory,
                                underline: SizedBox(),
                                icon: Icon(Icons.keyboard_arrow_down, color: notifier.textColor),
                                style: TextStyle(color: notifier.textColor, fontWeight: FontWeight.w600),
                                dropdownColor: notifier.containerColor,
                                items: controller.categories.map<DropdownMenuItem<String>>((category) {
                                  return DropdownMenuItem<String>(
                                    value: category["id"]?.toString() ?? "",
                                    child: Text(category["title"]?.toString() ?? ""),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedCategory = newValue!;
                                  });
                                  _filterByCategory();
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 16),

                    // Sort by
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            "Sort: ",
                            style: TextStyle(
                              color: notifier.textColor,
                              fontSize: 14,
                            ),
                          ),
                          DropdownButton<String>(
                            value: selectedSortBy,
                            underline: SizedBox(),
                            icon: Icon(Icons.keyboard_arrow_down, color: notifier.textColor),
                            style: TextStyle(color: notifier.textColor, fontWeight: FontWeight.w600),
                            dropdownColor: notifier.containerColor,
                            items: ["Relevance", "Distance", "Price", "Rating"]
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedSortBy = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Results
          Expanded(
            child: isListView ? _buildListView(notifier) : _buildMapView(notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(ColorNotifier notifier) {
    List<Map<String, dynamic>> allItems = [];

    // Add restaurants
    for (var restaurant in filteredRestaurants) {
      allItems.add({
        "type": "restaurant",
        "data": restaurant,
      });
    }

    // Add surprise bags
    for (var bag in filteredBags) {
      var restaurant = homeController.allrest.firstWhere(
        (r) => r["id"] == bag["restaurantId"],
        orElse: () => {
          "title": "Unknown Restaurant",
          "image": "",
          "address": "Address not available",
        },
      );

      allItems.add({
        "type": "bag",
        "data": bag,
        "restaurant": restaurant,
      });
    }

    if (allItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No results found",
              style: TextStyle(
                color: notifier.textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Try adjusting your search or filters",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        final item = allItems[index];
        if (item["type"] == "restaurant") {
          return _buildRestaurantCard(item["data"], notifier);
        } else if (item["type"] == "bag") {
          return _buildSurpriseBagCard(item["data"], item["restaurant"], notifier);
        }
        return SizedBox();
      },
    );
  }

  Widget _buildMapView(ColorNotifier notifier) {
    // For web, show a fallback message since Google Maps may not work properly
    if (kIsWeb) {
      return Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Map View",
                style: TextStyle(
                  color: notifier.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Map functionality is optimized for mobile devices",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isListView = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeColor,
                ),
                child: Text(
                  "Switch to List View",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Optimized Google Map with minimal features to prevent rendering issues
        GoogleMap(
          key: ValueKey('search_map_optimized'),
          onMapCreated: (GoogleMapController controller) {
            // Prevent multiple controller assignments
            if (mapController == null) {
              mapController = controller;
              _isMapReady = true;

              // Delayed marker update to prevent rendering conflicts
              Future.delayed(Duration(milliseconds: 500), () {
                if (mounted && _isMapReady && mapController != null) {
                  _updateMapMarkers();
                }
              });
            }
          },
          initialCameraPosition: CameraPosition(
            target: currentLocation,
            zoom: 13.0, // Reduced zoom for better performance
          ),
          markers: markers,
          // Minimal configuration to reduce rendering load
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          rotateGesturesEnabled: false,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: false,
          zoomGesturesEnabled: true,
          mapType: MapType.normal,
          buildingsEnabled: false,
          trafficEnabled: false,
          indoorViewEnabled: false,
          liteModeEnabled: true, // Enable lite mode for better performance
        ),
        // Custom location button
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _getCurrentLocation,
            child: Icon(Icons.my_location, color: orangeColor),
          ),
        ),
        // Results overlay at bottom
        if (filteredBags.isNotEmpty || filteredRestaurants.isNotEmpty)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filteredBags.length + filteredRestaurants.length,
                itemBuilder: (context, index) {
                  if (index < filteredBags.length) {
                    return _buildMapCard(filteredBags[index], notifier, true);
                  } else {
                    return _buildMapCard(filteredRestaurants[index - filteredBags.length], notifier, false);
                  }
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRestaurantCard(Map<String, dynamic> restaurantData, ColorNotifier notifier) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: notifier.containerColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          String? restaurantId = restaurantData["id"]?.toString();
          if (restaurantId != null && restaurantId.isNotEmpty) {
            Get.to(() => HotelDetails(detailId: restaurantId));
          } else {
            Get.snackbar("Error", "Restaurant ID not found");
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Restaurant Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: restaurantData["image"]?.toString() ?? "https://picsum.photos/300/200",
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: Icon(Icons.restaurant, color: Colors.grey[600]),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: Icon(Icons.restaurant, color: Colors.grey[600]),
                  ),
                ),
              ),

              SizedBox(width: 16),

              // Restaurant Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurantData["title"]?.toString() ?? "Restaurant",
                      style: TextStyle(
                        color: notifier.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          restaurantData["rating"]?.toString() ?? "0.0",
                          style: TextStyle(
                            color: notifier.textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.location_on, color: Colors.grey, size: 16),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            restaurantData["fullAddress"]?.toString() ?? "No address",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    Text(
                      restaurantData["shortDescription"]?.toString() ?? "No description",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurpriseBagCard(Map<String, dynamic> bag, Map<String, dynamic> restaurant, ColorNotifier notifier) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: notifier.containerColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Get.to(() => SurpriseBagDetails(
            bagData: bag,
            restaurantName: restaurant["title"] ?? "Unknown Restaurant",
            restaurantImage: restaurant["image"] ?? "",
            restaurantAddress: restaurant["address"] ?? "Address not available",
          ));
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badges
            Container(
              height: 200,
              width: double.infinity,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: bag["image"] ?? restaurant["image"] ?? "https://picsum.photos/400/200",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.restaurant, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                  // Quantity badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getBagAvailabilityColor(bag),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${bag["quantity"] ?? 1} left",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Obx(() {
                      final bagId = bag["id"] ?? DateTime.now().millisecondsSinceEpoch.toString();
                      final isFav = favouritesController.isFavourite(bagId);

                      return GestureDetector(
                        onTap: () {
                          favouritesController.toggleFavourite(
                            bag,
                            restaurant["title"] ?? "Unknown Restaurant",
                            restaurant["image"] ?? "",
                            restaurant["address"] ?? "Address not available",
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: isFav ? Colors.red : Colors.grey[600],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant info
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: orangeColor,
                        ),
                        child: Center(
                          child: Text(
                            restaurant["title"]?.toString().substring(0, 1).toUpperCase() ?? "R",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${restaurant["title"] ?? "Unknown Restaurant"} • ${restaurant["area"] ?? "Unknown Area"}",
                          style: TextStyle(
                            color: notifier.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Bag title
                  Text(
                    bag["title"] ?? "Surprise Bag",
                    style: TextStyle(
                      color: notifier.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  // Pickup time
                  Text(
                    "Pick up today: ${bag["pickupStartTime"] ?? "18:00"} - ${bag["pickupEndTime"] ?? "20:00"}",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 12),
                  // Rating and distance
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        "4.5",
                        style: TextStyle(
                          color: notifier.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        "1.2 km",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      Spacer(),
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "\$${bag["originalPrice"] ?? "29.99"}",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            "\$${bag["discountedPrice"] ?? "9.99"}",
                            style: TextStyle(
                              color: orangeColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBagAvailabilityColor(Map<String, dynamic> bag) {
    int quantity = int.tryParse(bag["quantity"]?.toString() ?? "0") ?? 0;
    if (quantity > 5) return Colors.green;
    if (quantity > 0) return Colors.orange;
    return Colors.red;
  }

  Widget _buildMapCard(Map<String, dynamic> item, ColorNotifier notifier, bool isBag) {
    return Container(
      width: 280,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: notifier.containerColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (isBag) {
            // Find restaurant data for this bag
            final restaurant = homeController.allrest.firstWhere(
              (r) => r["id"] == item["restaurantId"],
              orElse: () => {
                "title": "Unknown Restaurant",
                "image": "",
                "address": "Address not available",
              },
            );

            Get.to(() => SurpriseBagDetails(
              bagData: item,
              restaurantName: restaurant["title"] ?? "Unknown Restaurant",
              restaurantImage: restaurant["image"] ?? "",
              restaurantAddress: restaurant["address"] ?? "Address not available",
            ));
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: item["image"] ?? "https://picsum.photos/60/60",
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: Icon(Icons.restaurant, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: Icon(Icons.restaurant, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item["title"] ?? "Unknown",
                      style: TextStyle(
                        color: notifier.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    if (isBag) ...[
                      Text(
                        "Pick up today: ${item["pickupStartTime"] ?? "18:00"} - ${item["pickupEndTime"] ?? "20:00"}",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "\$${item["discountedPrice"] ?? "9.99"}",
                            style: TextStyle(
                              color: orangeColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "\$${item["originalPrice"] ?? "29.99"}",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        item["cuisine"] ?? "Restaurant",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            item["rating"] ?? "4.5",
                            style: TextStyle(
                              color: notifier.textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateMapMarkers() {
    // Only update markers if map is ready and widget is mounted
    if (!_isMapReady || !mounted || mapController == null) {
      return;
    }

    try {
      // Clear existing markers
      final newMarkers = <Marker>{};

      // Limit markers to prevent performance issues (max 8 total)
      final maxBagMarkers = 4;
      final maxRestaurantMarkers = 4;

      // Add markers for surprise bags (limited)
      final bagsToShow = filteredBags.take(maxBagMarkers).toList();
      for (int i = 0; i < bagsToShow.length; i++) {
        final bag = bagsToShow[i];
        // Generate coordinates around current location for demo
        final lat = currentLocation.latitude + (i * 0.005) - 0.01;
        final lng = currentLocation.longitude + (i * 0.005) - 0.01;

        newMarkers.add(
          Marker(
            markerId: MarkerId('bag_$i'),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            infoWindow: InfoWindow(
              title: bag["title"] ?? "Surprise Bag",
              snippet: "\$${bag["discountedPrice"] ?? "9.99"}",
            ),
          ),
        );
      }

      // Add markers for restaurants (limited)
      final restaurantsToShow = filteredRestaurants.take(maxRestaurantMarkers).toList();
      for (int i = 0; i < restaurantsToShow.length; i++) {
        final restaurant = restaurantsToShow[i];
        // Generate coordinates around current location for demo
        final lat = currentLocation.latitude + ((i + bagsToShow.length) * 0.005) - 0.01;
        final lng = currentLocation.longitude + ((i + bagsToShow.length) * 0.005) - 0.01;

        newMarkers.add(
          Marker(
            markerId: MarkerId('restaurant_$i'),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: restaurant["title"] ?? "Restaurant",
              snippet: restaurant["cuisine"] ?? "Restaurant",
            ),
          ),
        );
      }

      // Update markers in a single setState call
      if (mounted) {
        setState(() {
          markers = newMarkers;
        });
      }
    } catch (e) {
      print("Error updating map markers: $e");
    }
  }

  void _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar("Location", "Location services are disabled");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar("Location", "Location permissions are denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar("Location", "Location permissions are permanently denied");
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      currentLocation = LatLng(position.latitude, position.longitude);

      if (mapController != null && _isMapReady) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(currentLocation),
        );

        // Update markers after camera animation
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted && _isMapReady) {
            _updateMapMarkers();
          }
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to get current location");
    }
  }
}
