import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../Utils/Colors.dart';
import '../Utils/dark_light_mode.dart';
import '../config/app_config.dart';
import '../controllers/home_controller.dart';

class LocationRadiusPage extends StatefulWidget {
  @override
  _LocationRadiusPageState createState() => _LocationRadiusPageState();
}

class _LocationRadiusPageState extends State<LocationRadiusPage> {
  GoogleMapController? mapController;
  final HomeController homeController = Get.find<HomeController>();
  
  double selectedRadius = AppConfig.defaultRadius.toDouble();
  LatLng currentLocation = LatLng(AppConfig.defaultLatitude, AppConfig.defaultLongitude);
  String currentAddress = "Getting location...";
  bool isLoadingLocation = false;
  TextEditingController searchController = TextEditingController();
  
  Set<Circle> circles = {};
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  void _initializeLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      // Get current location from home controller if available
      if (homeController.currentLatitude.value != 0.0 && homeController.currentLongitude.value != 0.0) {
        currentLocation = LatLng(homeController.currentLatitude.value, homeController.currentLongitude.value);
        currentAddress = homeController.currentAddress.value;
      } else {
        // Get fresh location
        await _getCurrentLocation();
      }
      
      // Get saved radius from preferences or use default
      selectedRadius = homeController.selectedRadius.value.toDouble();
      
      _updateMapCircle();
    } catch (e) {
      print("Error initializing location: $e");
    } finally {
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentLocation = LatLng(position.latitude, position.longitude);
      
      // Get address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        currentAddress = "${place.locality}, ${place.administrativeArea}";
      }

    } catch (e) {
      print("Error getting location: $e");
      Get.snackbar("Error", "Failed to get current location");
    }
  }

  void _updateMapCircle() {
    circles.clear();
    markers.clear();
    
    // Add circle for radius
    circles.add(Circle(
      circleId: CircleId("radius"),
      center: currentLocation,
      radius: selectedRadius * 1000, // Convert km to meters
      fillColor: orangeColor.withOpacity(0.2),
      strokeColor: orangeColor,
      strokeWidth: 2,
    ));
    
    // Add marker for current location
    markers.add(Marker(
      markerId: MarkerId("current_location"),
      position: currentLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow: InfoWindow(
        title: "Your Location",
        snippet: currentAddress,
      ),
    ));
    
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    
    // Move camera to current location
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLocation,
          zoom: _getZoomLevel(selectedRadius),
        ),
      ),
    );
  }

  double _getZoomLevel(double radius) {
    if (radius <= 5) return 13.0;
    if (radius <= 10) return 12.0;
    if (radius <= 25) return 11.0;
    if (radius <= 50) return 10.0;
    return 9.0;
  }

  void _onRadiusChanged(double value) {
    setState(() {
      selectedRadius = value;
    });
    _updateMapCircle();
    
    // Update camera zoom based on radius
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLocation,
          zoom: _getZoomLevel(selectedRadius),
        ),
      ),
    );
  }

  void _searchLocation() async {
    String query = searchController.text.trim();
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng newLocation = LatLng(location.latitude, location.longitude);
        
        // Get address for the new location
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude, 
          location.longitude
        );
        
        String newAddress = query;
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          newAddress = "${place.locality}, ${place.administrativeArea}";
        }
        
        setState(() {
          currentLocation = newLocation;
          currentAddress = newAddress;
        });
        
        _updateMapCircle();
        
        // Move camera to new location
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentLocation,
              zoom: _getZoomLevel(selectedRadius),
            ),
          ),
        );
        
        // Clear search field
        searchController.clear();
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      Get.snackbar("Error", "Location not found");
    }
  }

  void _useCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });
    
    await _getCurrentLocation();
    _updateMapCircle();
    
    // Move camera to current location
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLocation,
          zoom: _getZoomLevel(selectedRadius),
        ),
      ),
    );
    
    setState(() {
      isLoadingLocation = false;
    });
  }

  void _confirmLocation() {
    // Save the selected location and radius to home controller
    homeController.updateLocationAndRadius(
      currentLocation.latitude,
      currentLocation.longitude,
      currentAddress,
      selectedRadius.toInt(),
    );
    
    Get.back();
    Get.snackbar(
      "Location Updated", 
      "Showing restaurants within ${selectedRadius.toInt()} km of $currentAddress",
      duration: Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColorNotifier>(context);
    
    return Scaffold(
      backgroundColor: notifier.background,
      appBar: AppBar(
        backgroundColor: notifier.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: notifier.textColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Choose a location to see what's available",
          style: TextStyle(
            color: notifier.textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Map
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              child: isLoadingLocation
                  ? Center(
                      child: CircularProgressIndicator(color: orangeColor),
                    )
                  : GoogleMap(
                      key: ValueKey('location_radius_map'),
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: currentLocation,
                        zoom: _getZoomLevel(selectedRadius),
                      ),
                      circles: circles,
                      markers: markers,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      compassEnabled: false,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      buildingsEnabled: false,
                      trafficEnabled: false,
                      indoorViewEnabled: false,
                      liteModeEnabled: true, // Enable lite mode for better performance
                    ),
            ),
          ),
          
          // Bottom section
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: notifier.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Distance selector
                  Text(
                    "Select a distance",
                    style: TextStyle(
                      color: notifier.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Slider
                  Row(
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: orangeColor,
                            inactiveTrackColor: Colors.grey.withOpacity(0.3),
                            thumbColor: orangeColor,
                            overlayColor: orangeColor.withOpacity(0.2),
                            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
                          ),
                          child: Slider(
                            value: selectedRadius,
                            min: AppConfig.minRadius.toDouble(),
                            max: AppConfig.maxRadius.toDouble(),
                            divisions: (AppConfig.maxRadius - AppConfig.minRadius),
                            onChanged: _onRadiusChanged,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: orangeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${selectedRadius.toInt()} km",
                          style: TextStyle(
                            color: orangeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Search field
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search for a city",
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: notifier.containerColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: TextStyle(color: notifier.textColor),
                    onSubmitted: (_) => _searchLocation(),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Use current location button
                  GestureDetector(
                    onTap: _useCurrentLocation,
                    child: Row(
                      children: [
                        Icon(Icons.my_location, color: orangeColor),
                        SizedBox(width: 12),
                        Text(
                          "Use my current location",
                          style: TextStyle(
                            color: orangeColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Spacer(),
                  
                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orangeColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Choose this location",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up map resources
    if (mapController != null) {
      try {
        mapController?.dispose();
      } catch (e) {
        // Ignore disposal errors
      }
      mapController = null;
    }
    circles.clear();
    markers.clear();
    searchController.dispose();
    super.dispose();
  }
}
