import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/controllers/home_controller.dart';
import 'package:foodrescue_app/controllers/favourites_controller.dart';
import 'package:foodrescue_app/Utils/dark_light_mode.dart';
import 'package:foodrescue_app/HomeScreen/SurpriseBagDetails.dart';
import 'package:foodrescue_app/HomeScreen/Notification.dart';
import 'package:foodrescue_app/HomeScreen/RestaurantReviewsPage.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'LocationRadiusPage.dart';
import 'SearchPage.dart';

class NewHomePage extends StatefulWidget {
  const NewHomePage({Key? key}) : super(key: key);

  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  final HomeController homeController = Get.find<HomeController>();
  final FavouritesController favouritesController = Get.put(FavouritesController());
  String selectedCategory = "all";

  @override
  void initState() {
    super.initState();
    // Load data if not already loaded
    if (homeController.surpriseBags.isEmpty) {
      homeController.homeDataApi();
    }
  }

  List<Map<String, dynamic>> get filteredBags {
    print("Getting filtered bags - Category: $selectedCategory, Total bags: ${homeController.surpriseBags.length}");

    if (selectedCategory == "all") {
      return List<Map<String, dynamic>>.from(homeController.surpriseBags);
    } else {
      return homeController.surpriseBags.where((bag) {
        // Check the bag's category field
        final bagCategory = bag["category"]?.toString().toLowerCase() ?? "";
        final categoryMatch = bagCategory.contains(selectedCategory.toLowerCase());

        print("Bag: ${bag["title"]}, Category: $bagCategory, Selected: $selectedCategory, Match: $categoryMatch");
        return categoryMatch;
      }).cast<Map<String, dynamic>>().toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorNotifier notifier = Provider.of<ColorNotifier>(context, listen: true);
    
    return Scaffold(
      backgroundColor: notifier.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with location and notification
            _buildHeader(notifier),
            
            // Category tabs
            _buildCategoryTabs(notifier),
            
            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => homeController.homeDataApi(),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recommended section
                      _buildRecommendedSection(notifier),
                      
                      SizedBox(height: 24),
                      
                      // Save before it's too late section
                      _buildSaveSection(notifier),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorNotifier notifier) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // Location
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: orangeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset("assets/livelocation.png",
                  color: orangeColor,
                  height: MediaQuery.of(context).size.height / 25)
                ),
                SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.to(() => LocationRadiusPage()),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Chosen location",
                          style: TextStyle(
                            color: notifier.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Felling, Gateshead",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
              ],
            ),
          ),
          
          // Notification button
          IconButton(
            onPressed: () => Get.to(() => Notificationpage()),
            icon: Stack(
              children: [
                Image.asset("assets/onesignal.png",
                  color: orangeColor,
                  height: MediaQuery.of(context).size.height / 35),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: orangeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: WhiteColor)
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(ColorNotifier notifier) {
    return SizedBox(
      height: 40,
      child: GetBuilder<HomeController>(
        builder: (controller) {
          if (controller.categories.isEmpty) {
            return SizedBox.shrink();
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              final categoryTitle = category["title"]?.toString() ?? "";
              final isSelected = selectedCategory == categoryTitle;

              return Container(
                margin: EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedCategory = categoryTitle;
                    });
                  },
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.teal : notifier.containerColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? Colors.teal : Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      categoryTitle,
                      style: TextStyle(
                        color: isSelected ? Colors.white : notifier.textColor,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRecommendedSection(ColorNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recommended for you",
                style: TextStyle(
                  color: notifier.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: ()=>Get.to(() => SearchPage()),
                child: Text(
                  "See all",
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 16),
        
        // Horizontal scrolling cards
        Container(
          height: 280,
          child: GetBuilder<HomeController>(
            builder: (controller) {
              if (filteredBags.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.teal),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredBags.length > 10 ? 10 : filteredBags.length, // Show max 10 in recommended
                itemBuilder: (context, index) {
                  final bag = filteredBags[index];
                  return _buildRecommendedCard(bag, notifier);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaveSection(ColorNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Save before it's too late",
                style: TextStyle(
                  color: notifier.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  "See all",
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 16),
        
        // Vertical list
        GetBuilder<HomeController>(
          builder: (controller) {
            if (filteredBags.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Colors.teal),
                      SizedBox(height: 16),
                      Text(
                        "Loading surprise bags...",
                        style: TextStyle(
                          color: notifier.textColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredBags.length,
              itemBuilder: (context, index) {
                final bag = filteredBags[index];
                return _buildSaveCard(bag, notifier);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecommendedCard(Map<String, dynamic> bag, ColorNotifier notifier) {
    // Find restaurant data
    final restaurant = homeController.allrest.firstWhere(
      (r) => r["id"] == bag["restaurantId"],
      orElse: () => {
        "title": "Unknown Restaurant",
        "image": "",
        "address": "Address not available",
      },
    );

    return Container(
      width: 280,
      margin: EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () {
          Get.to(() => SurpriseBagDetails(
            bagData: bag,
            restaurantName: restaurant["title"] ?? "Unknown Restaurant",
            restaurantImage: restaurant["image"] ?? "",
            restaurantAddress: restaurant["address"] ?? "Address not available",
          ));
        },
        onLongPress: () {
          Get.to(() => RestaurantReviewsPage(
            restaurantId: restaurant["id"] ?? "",
            restaurantName: restaurant["title"] ?? "Unknown Restaurant",
          ));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with badges
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: bag["img"] ?? "https://picsum.photos/280/160",
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: double.infinity,
                        height: 160,
                        color: Colors.grey[300],
                        child: Icon(Icons.restaurant, color: Colors.grey, size: 40),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: double.infinity,
                        height: 160,
                        color: Colors.grey[300],
                        child: Icon(Icons.restaurant, color: Colors.grey, size: 40),
                      ),
                    ),
                  ),

                  // Popular badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Popular",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Rating badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          SizedBox(width: 2),
                          Text(
                            restaurant["rating"]?.toString() ?? "4.3",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Favourite button
                  Positioned(
                    bottom: 12,
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
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

                  // Restaurant logo
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: restaurant["image"] ?? "https://picsum.photos/40/40",
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Icon(Icons.restaurant, color: Colors.grey, size: 20),
                          errorWidget: (context, url, error) => Icon(Icons.restaurant, color: Colors.grey, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant["title"] ?? "Unknown Restaurant",
                      style: TextStyle(
                        color: notifier.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 4),

                    Text(
                      bag["title"] ?? "Surprise Bag",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 8),

                    Text(
                      "Pick up today: ${bag["pickupStartTime"] ?? "10:30"} PM - ${bag["pickupEndTime"] ?? "11:00"} PM  9.9 km",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 8),

                    Row(
                      children: [
                        Text(
                          "\$${bag["originalPrice"] ?? "13.95"}",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "\$${bag["discountedPrice"] ?? "4.65"}",
                          style: TextStyle(
                            color: notifier.textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveCard(Map<String, dynamic> bag, ColorNotifier notifier) {
    // Find restaurant data
    final restaurant = homeController.allrest.firstWhere(
      (r) => r["id"] == bag["restaurantId"],
      orElse: () => {
        "title": "Unknown Restaurant",
        "image": "",
        "address": "Address not available",
      },
    );

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Get.to(() => SurpriseBagDetails(
            bagData: bag,
            restaurantName: restaurant["title"] ?? "Unknown Restaurant",
            restaurantImage: restaurant["image"] ?? "",
            restaurantAddress: restaurant["address"] ?? "Address not available",
          ));
        },
        onLongPress: () {
          Get.to(() => RestaurantReviewsPage(
            restaurantId: restaurant["id"] ?? "",
            restaurantName: restaurant["title"] ?? "Unknown Restaurant",
          ));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
          child: Row(
            children: [
              // Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: bag["img"] ?? "https://picsum.photos/120/120",
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[300],
                        child: Icon(Icons.restaurant, color: Colors.grey, size: 30),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[300],
                        child: Icon(Icons.restaurant, color: Colors.grey, size: 30),
                      ),
                    ),
                  ),

                  // Rating badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 12),
                          SizedBox(width: 2),
                          Text(
                            restaurant["rating"]?.toString() ?? "4.3",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Favourite button
                  Positioned(
                    bottom: 8,
                    right: 8,
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
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isFav ? Colors.red : Colors.grey[600],
                          ),
                        ),
                      );
                    }),
                  ),

                  // Restaurant logo
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: restaurant["image"] ?? "https://picsum.photos/32/32",
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Icon(Icons.restaurant, color: Colors.grey, size: 16),
                          errorWidget: (context, url, error) => Icon(Icons.restaurant, color: Colors.grey, size: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant["title"] ?? "Unknown Restaurant",
                        style: TextStyle(
                          color: notifier.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 4),

                      Text(
                        bag["title"] ?? "Surprise Bag",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 8),

                      Text(
                        "Pick up today: ${bag["pickupStartTime"] ?? "03:00"} PM - ${bag["pickupEndTime"] ?? "03:15"} PM  2.3 km",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 8),

                      Row(
                        children: [
                          Text(
                            "\$${bag["originalPrice"] ?? "13.95"}",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "\$${bag["discountedPrice"] ?? "4.65"}",
                            style: TextStyle(
                              color: notifier.textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
