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
  MapType currentMapType = MapType.hybrid; // Default to satellite view

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
    print("Filtering by category: $selectedCategory");
    
    if (selectedCategory == "all") {
      filteredBags = List<Map<String, dynamic>>.from(homeController.surpriseBags);
      filteredRestaurants = List<Map<String, dynamic>>.from(homeController.allrest);
      print("Showing all items: ${filteredBags.length} bags, ${filteredRestaurants.length} restaurants");
    } else {
      // Find the selected category object to get the title for comparison
      final selectedCategoryData = homeController.categories.firstWhere(
        (cat) => cat["id"] == selectedCategory,
        orElse: () => {"title": selectedCategory},
      );
      final categoryTitle = selectedCategoryData["title"]?.toString().toLowerCase() ?? selectedCategory.toLowerCase();
      
      print("Filtering by category title: $categoryTitle");

      // Filter surprise bags by restaurant cuisine
      filteredBags = homeController.surpriseBags.where((bag) {
        final restaurant = homeController.allrest.firstWhere(
          (r) => r["id"] == bag["restaurantId"],
          orElse: () => {},
        );

        if (restaurant.isNotEmpty) {
          // Check restaurant category field first
          if (restaurant["category"] != null) {
            String restaurantCategory = restaurant["category"].toString().toLowerCase();
            if (restaurantCategory.contains(categoryTitle)) {
              return true;
            }
          }
          
          // Then check cuisines field
          if (restaurant["cuisines"] != null) {
            List<String> cuisines = restaurant["cuisines"].toString().split(',');
            bool matches = cuisines.any((cuisine) =>
              cuisine.trim().toLowerCase().contains(categoryTitle)
            );
            if (matches) {
              return true;
            }
          }
          
          // Also check if bag has direct category
          if (bag["category"] != null) {
            String bagCategory = bag["category"].toString().toLowerCase();
            return bagCategory.contains(categoryTitle);
          }
        }
        return false;
      }).cast<Map<String, dynamic>>().toList();

      // Filter restaurants by cuisine and category
      filteredRestaurants = homeController.allrest.where((restaurant) {
        // Check restaurant category field first
        if (restaurant["category"] != null) {
          String restaurantCategory = restaurant["category"].toString().toLowerCase();
          if (restaurantCategory.contains(categoryTitle)) {
            return true;
          }
        }
        
        // Then check cuisines field
        if (restaurant["cuisines"] != null) {
          List<String> cuisines = restaurant["cuisines"].toString().split(',');
          return cuisines.any((cuisine) =>
            cuisine.trim().toLowerCase().contains(categoryTitle)
          );
        }
        
        return false;
      }).cast<Map<String, dynamic>>().toList();

      print("Filtered results: ${filteredBags.length} bags, ${filteredRestaurants.length} restaurants");
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
    // Initialize with all data first
    filteredBags = List.from(homeController.surpriseBags);
    filteredRestaurants = List.from(homeController.allrest);
    
    // Apply initial category filter (should be "all" by default)
    _filterByCategory();
    
    print("Initialized with ${filteredBags.length} bags and ${filteredRestaurants.length} restaurants");
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
          final description = bag["description"]?.toString().toLowerCase() ?? "";
          
          return title.contains(query.toLowerCase()) ||
                 category.contains(query.toLowerCase()) ||
                 description.contains(query.toLowerCase());
        }).cast<Map<String, dynamic>>().toList();

        allRestaurants = allRestaurants.where((restaurant) {
          final title = restaurant["title"]?.toString().toLowerCase() ?? "";
          final cuisines = restaurant["cuisines"]?.toString().toLowerCase() ?? "";
          final category = restaurant["category"]?.toString().toLowerCase() ?? "";
          final address = restaurant["address"]?.toString().toLowerCase() ?? "";
          
          return title.contains(query.toLowerCase()) ||
                 cuisines.contains(query.toLowerCase()) ||
                 category.contains(query.toLowerCase()) ||
                 address.contains(query.toLowerCase());
        }).cast<Map<String, dynamic>>().toList();
      }

      // Apply category filter
      if (selectedCategory != "all") {
        // Find the selected category object to get the title for comparison
        final selectedCategoryData = homeController.categories.firstWhere(
          (cat) => cat["id"] == selectedCategory,
          orElse: () => {"title": selectedCategory},
        );
        final categoryTitle = selectedCategoryData["title"]?.toString().toLowerCase() ?? selectedCategory.toLowerCase();

        allBags = allBags.where((bag) {
          final restaurant = homeController.allrest.firstWhere(
            (r) => r["id"] == bag["restaurantId"],
            orElse: () => {},
          );

          if (restaurant.isNotEmpty) {
            // Check restaurant category field first
            if (restaurant["category"] != null) {
              String restaurantCategory = restaurant["category"].toString().toLowerCase();
              if (restaurantCategory.contains(categoryTitle)) {
                return true;
              }
            }
            
            // Then check cuisines field
            if (restaurant["cuisines"] != null) {
              List<String> cuisines = restaurant["cuisines"].toString().split(',');
              bool matches = cuisines.any((cuisine) =>
                cuisine.trim().toLowerCase().contains(categoryTitle)
              );
              if (matches) {
                return true;
              }
            }
            
            // Also check if bag has direct category
            if (bag["category"] != null) {
              String bagCategory = bag["category"].toString().toLowerCase();
              return bagCategory.contains(categoryTitle);
            }
          }
          return false;
        }).toList();

        allRestaurants = allRestaurants.where((restaurant) {
          // Check restaurant category field first
          if (restaurant["category"] != null) {
            String restaurantCategory = restaurant["category"].toString().toLowerCase();
            if (restaurantCategory.contains(categoryTitle)) {
              return true;
            }
          }
          
          // Then check cuisines field
          if (restaurant["cuisines"] != null) {
            List<String> cuisines = restaurant["cuisines"].toString().split(',');
            return cuisines.any((cuisine) =>
              cuisine.trim().toLowerCase().contains(categoryTitle)
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
        // Enhanced Google Map with satellite view and proper styling
        GoogleMap(
          key: ValueKey('search_map_enhanced'),
          onMapCreated: (GoogleMapController controller) {
            // Prevent multiple controller assignments
            if (mapController == null) {
              mapController = controller;
              _isMapReady = true;

              // Apply custom map styling for better visibility
              _applyMapStyle(controller);

              // Delayed marker update to prevent rendering conflicts
              Future.delayed(Duration(milliseconds: 500), () {
                if (mounted && _isMapReady && mapController != null) {
                  _updateMapMarkers();
                }
              });
            }
          },
          onCameraMove: (position) {
            // Handle camera movement if needed
          },
          onCameraIdle: () {
            // Handle camera idle if needed
          },
          initialCameraPosition: CameraPosition(
            target: currentLocation,
            zoom: 14.0, // Optimal zoom for city view
          ),
          markers: markers, // Use regular markers
          // Enhanced map configuration for better user experience
          myLocationEnabled: true,
          myLocationButtonEnabled: false, // We'll use custom button
          zoomControlsEnabled: false, // Custom controls
          mapToolbarEnabled: false,
          compassEnabled: true,
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          zoomGesturesEnabled: true,
          mapType: currentMapType, // Use dynamic map type
          buildingsEnabled: true,
          trafficEnabled: false,
          indoorViewEnabled: false,
          liteModeEnabled: false, // Disable lite mode for full features
        ),
        // Map type toggle button
        Positioned(
          top: 20,
          right: 70,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _toggleMapType,
            child: Icon(
              currentMapType == MapType.hybrid 
                ? Icons.map_outlined 
                : Icons.satellite_alt,
              color: orangeColor,
            ),
          ),
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
            restaurantData: restaurant,
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
              restaurantData: restaurant,
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

  // Toggle between map types
  void _toggleMapType() {
    setState(() {
      currentMapType = currentMapType == MapType.hybrid 
        ? MapType.normal 
        : MapType.hybrid;
    });
    
    // Reapply map style for the new map type
    if (mapController != null && _isMapReady) {
      Future.delayed(Duration(milliseconds: 100), () {
        _applyMapStyle(mapController!);
      });
    }
  }

  // Apply custom map style for better visibility and professional appearance
  void _applyMapStyle(GoogleMapController controller) {
    try {
      // Apply a custom map style for a more professional look
      String mapStyle = '''
      [
        {
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#f5f5f5"
            }
          ]
        },
        {
          "elementType": "labels.icon",
          "stylers": [
            {
              "visibility": "off"
            }
          ]
        },
        {
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#616161"
            }
          ]
        },
        {
          "elementType": "labels.text.stroke",
          "stylers": [
            {
              "color": "#f5f5f5"
            }
          ]
        },
        {
          "featureType": "administrative.land_parcel",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#bdbdbd"
            }
          ]
        },
        {
          "featureType": "poi",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#eeeeee"
            }
          ]
        },
        {
          "featureType": "poi",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#757575"
            }
          ]
        },
        {
          "featureType": "poi.park",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#e5e5e5"
            }
          ]
        },
        {
          "featureType": "poi.park",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#9e9e9e"
            }
          ]
        },
        {
          "featureType": "road",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#ffffff"
            }
          ]
        },
        {
          "featureType": "road.arterial",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#757575"
            }
          ]
        },
        {
          "featureType": "road.highway",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#dadada"
            }
          ]
        },
        {
          "featureType": "road.highway",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#616161"
            }
          ]
        },
        {
          "featureType": "road.local",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#9e9e9e"
            }
          ]
        },
        {
          "featureType": "transit.line",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#e5e5e5"
            }
          ]
        },
        {
          "featureType": "transit.station",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#eeeeee"
            }
          ]
        },
        {
          "featureType": "water",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#c9c9c9"
            }
          ]
        },
        {
          "featureType": "water",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#9e9e9e"
            }
          ]
        }
      ]
      ''';
      
      // Apply the custom style only if we're not in satellite mode
      if (currentMapType == MapType.normal) {
        controller.setMapStyle(mapStyle);
      } else {
        // Clear style for satellite view
        controller.setMapStyle(null);
      }
    } catch (e) {
      print("Error applying map style: $e");
    }
  }

  // Enhanced marker creation with custom icons and branding
  Future<BitmapDescriptor> _createCustomMarker(String type) async {
    try {
      // Create custom marker icons for different types with brand colors
      switch (type) {
        case 'restaurant':
          // Use a distinctive blue color for restaurants
          return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
        case 'surprise_bag':
          // Use orange/red color for surprise bags to match the app theme
          return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
        case 'current_location':
          // Use green for current location
          return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
        default:
          return BitmapDescriptor.defaultMarker;
      }
    } catch (e) {
      print("Error creating custom marker: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }

  void _updateMapMarkers() async {
    // Only update markers if map is ready and widget is mounted
    if (!_isMapReady || !mounted || mapController == null) {
      return;
    }

    try {
      // Clear existing markers
      final newMarkers = <Marker>{};

      // Get custom marker icons
      final bagIcon = await _createCustomMarker('surprise_bag');
      final restaurantIcon = await _createCustomMarker('restaurant');
      final currentLocationIcon = await _createCustomMarker('current_location');

      // Add current location marker
      newMarkers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: currentLocation,
          icon: currentLocationIcon,
          infoWindow: InfoWindow(
            title: "Your Location",
            snippet: "Current position",
          ),
        ),
      );

      // Limit markers to prevent performance issues (max 50 total)
      final maxBagMarkers = 25;
      final maxRestaurantMarkers = 25;

      // Add markers for surprise bags with real or realistic coordinates
      final bagsToShow = filteredBags.take(maxBagMarkers).toList();
      for (int i = 0; i < bagsToShow.length; i++) {
        final bag = bagsToShow[i];
        
        // Try to get real coordinates from bag data or restaurant
        double lat = currentLocation.latitude;
        double lng = currentLocation.longitude;
        
        // Find the restaurant for this bag to get coordinates
        final restaurant = homeController.allrest.firstWhere(
          (r) => r["id"] == bag["restaurantId"],
          orElse: () => {},
        );
        
        if (restaurant.isNotEmpty) {
          // Try to get real coordinates from restaurant
          try {
            if (restaurant["latitude"] != null && restaurant["longitude"] != null) {
              lat = double.parse(restaurant["latitude"].toString());
              lng = double.parse(restaurant["longitude"].toString());
            } else {
              // Generate realistic coordinates around current location
              lat = currentLocation.latitude + (i * 0.003) - 0.015 + (i % 2 == 0 ? 0.005 : -0.005);
              lng = currentLocation.longitude + (i * 0.003) - 0.015 + (i % 3 == 0 ? 0.005 : -0.005);
            }
          } catch (e) {
            // Generate realistic coordinates around current location
            lat = currentLocation.latitude + (i * 0.003) - 0.015 + (i % 2 == 0 ? 0.005 : -0.005);
            lng = currentLocation.longitude + (i * 0.003) - 0.015 + (i % 3 == 0 ? 0.005 : -0.005);
          }
        }

        newMarkers.add(
          Marker(
            markerId: MarkerId('bag_${bag["id"] ?? i}'),
            position: LatLng(lat, lng),
            icon: bagIcon,
            infoWindow: InfoWindow(
              title: bag["title"] ?? "Surprise Bag",
              snippet: "₹${bag["discountedPrice"] ?? "9.99"} • ${bag["itemsLeft"] ?? "1"} left",
            ),
            onTap: () {
              // Show bag details bottom sheet
              _showBagDetailsBottomSheet(bag);
            },
          ),
        );
      }

      // Add markers for restaurants with coordinates
      final restaurantsToShow = filteredRestaurants.take(maxRestaurantMarkers).toList();
      for (int i = 0; i < restaurantsToShow.length; i++) {
        final restaurant = restaurantsToShow[i];
        
        // Try to get real coordinates from restaurant data
        double lat = currentLocation.latitude;
        double lng = currentLocation.longitude;
        
        // Check if restaurant has coordinates
        if (restaurant["latitude"] != null && restaurant["longitude"] != null) {
          try {
            lat = double.parse(restaurant["latitude"].toString());
            lng = double.parse(restaurant["longitude"].toString());
          } catch (e) {
            // Use generated coordinates around current location
            lat = currentLocation.latitude + ((i + 0.5) * 0.004) - 0.020 + (i % 2 == 0 ? -0.008 : 0.008);
            lng = currentLocation.longitude + ((i + 0.5) * 0.004) - 0.020 + (i % 3 == 0 ? -0.008 : 0.008);
          }
        } else {
          // Generate realistic coordinates around current location
          lat = currentLocation.latitude + ((i + 0.5) * 0.004) - 0.020 + (i % 2 == 0 ? -0.008 : 0.008);
          lng = currentLocation.longitude + ((i + 0.5) * 0.004) - 0.020 + (i % 3 == 0 ? -0.008 : 0.008);
        }

        newMarkers.add(
          Marker(
            markerId: MarkerId('restaurant_${restaurant["id"] ?? i}'),
            position: LatLng(lat, lng),
            icon: restaurantIcon,
            infoWindow: InfoWindow(
              title: restaurant["title"] ?? "Restaurant",
              snippet: "${restaurant["cuisines"] ?? "Food"} • ⭐ ${restaurant["rate"] ?? "4.5"}",
            ),
            onTap: () {
              // Navigate to restaurant details
              String? restaurantId = restaurant["id"]?.toString();
              if (restaurantId != null && restaurantId.isNotEmpty) {
                Get.to(() => HotelDetails(detailId: restaurantId));
              }
            },
          ),
        );
      }

      // Update markers on map
      if (mounted) {
        setState(() {
          markers = newMarkers;
        });
      }

      print("Updated map with ${newMarkers.length} markers (${bagsToShow.length} bags, ${restaurantsToShow.length} restaurants)");
    } catch (e) {
      print("Error updating map markers: $e");
    }
  }

  // Show bag details in bottom sheet when marker is tapped
  void _showBagDetailsBottomSheet(Map<String, dynamic> bag) {
    // Find restaurant data
    final restaurant = homeController.allrest.firstWhere(
      (r) => r["id"] == bag["restaurantId"],
      orElse: () => {
        "title": "Unknown Restaurant",
        "image": "",
        "address": "Address not available",
      },
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bag["title"] ?? "Surprise Bag",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      restaurant["title"] ?? "Unknown Restaurant",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          "\$${bag["originalPrice"] ?? "13.95"}",
                          style: TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "\$${bag["discountedPrice"] ?? "4.65"}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: orangeColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "${bag["itemsLeft"] ?? "1"} left",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.to(() => SurpriseBagDetails(
                          bagData: bag,
                          restaurantData: restaurant,
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orangeColor,
                        minimumSize: Size(double.infinity, 45),
                      ),
                      child: Text(
                        "View Details",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
