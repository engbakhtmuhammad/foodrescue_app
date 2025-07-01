import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/controllers/home_controller.dart';
import 'package:foodrescue_app/Utils/dark_light_mode.dart';
import 'package:foodrescue_app/HomeScreen/SurpriseBagDetails.dart';
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
  final TextEditingController searchController = TextEditingController();
  String selectedSortBy = "Relevance";
  bool isListView = true;
  List<Map<String, dynamic>> filteredBags = [];
  List<Map<String, dynamic>> filteredRestaurants = [];
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  LatLng currentLocation = LatLng(37.7749, -122.4194); // Default to San Francisco
  String selectedCategory = "all";

  @override
  void initState() {
    super.initState();
    _initializeData();
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
    if (!isListView) {
      _updateMapMarkers();
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
      if (!isListView) {
        _updateMapMarkers();
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
                          // Update map markers when switching to map view
                          Future.delayed(Duration(milliseconds: 100), () {
                            _updateMapMarkers();
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
        if (item["type"] == "bag") {
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
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
            _updateMapMarkers();
          },
          initialCameraPosition: CameraPosition(
            target: currentLocation,
            zoom: 14.0,
          ),
          markers: markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
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
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                    ),
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
    markers.clear();

    // Add markers for surprise bags
    for (int i = 0; i < filteredBags.length; i++) {
      final bag = filteredBags[i];
      // Generate random coordinates around current location for demo
      final lat = currentLocation.latitude + (i * 0.01) - 0.02;
      final lng = currentLocation.longitude + (i * 0.01) - 0.02;

      markers.add(
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

    // Add markers for restaurants
    for (int i = 0; i < filteredRestaurants.length; i++) {
      final restaurant = filteredRestaurants[i];
      // Generate random coordinates around current location for demo
      final lat = currentLocation.latitude + ((i + filteredBags.length) * 0.01) - 0.02;
      final lng = currentLocation.longitude + ((i + filteredBags.length) * 0.01) - 0.02;

      markers.add(
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

    if (mounted) {
      setState(() {});
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

      mapController?.animateCamera(
        CameraUpdate.newLatLng(currentLocation),
      );

      _updateMapMarkers();
    } catch (e) {
      Get.snackbar("Error", "Failed to get current location");
    }
  }
}
