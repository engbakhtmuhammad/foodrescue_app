import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/controllers/home_controller.dart';
import 'package:foodrescue_app/controllers/favourites_controller.dart';
import 'package:foodrescue_app/Utils/dark_light_mode.dart';
import 'package:foodrescue_app/views/bags/SurpriseBagDetails.dart';
import 'package:foodrescue_app/views/notification/Notification.dart';
import 'package:foodrescue_app/views/restaurant/RestaurantReviewsPage.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../browse/LocationRadiusPage.dart';
import '../browse/SearchPage.dart';

class NewHomePage extends StatefulWidget {
  const NewHomePage({Key? key}) : super(key: key);

  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  final HomeController homeController = Get.find<HomeController>();
  final FavouritesController favouritesController =
      Get.put(FavouritesController());
  String selectedCategory = "all";

  @override
  void initState() {
    super.initState();
    print(
        "NewHomePage initState - Current bags: ${homeController.surpriseBags.length}");

    // Load data if not already loaded
    if (homeController.surpriseBags.isEmpty) {
      print("Loading data because surprise bags are empty");
      homeController.homeDataApi();
    } else {
      print(
          "Data already loaded with ${homeController.surpriseBags.length} bags");
    }
  }

  List<Map<String, dynamic>> get filteredBags {
    print(
        "Getting filtered bags - Category: $selectedCategory, Total bags: ${homeController.surpriseBags.length}");

    if (selectedCategory == "all") {
      // Return a copy of all surprise bags
      final allBags =
          List<Map<String, dynamic>>.from(homeController.surpriseBags);
      print("Returning ${allBags.length} bags for 'all' category");
      return allBags;
    } else {
      // Find the selected category data to get the title for comparison
      final selectedCategoryData = homeController.categories.firstWhere(
        (cat) => cat["id"] == selectedCategory,
        orElse: () => {"title": selectedCategory},
      );
      final categoryTitle = selectedCategoryData["title"]?.toString().toLowerCase() ?? selectedCategory.toLowerCase();
      
      print("Filtering by category ID: $selectedCategory, Title: $categoryTitle");

      // Filter by category using both bag category and restaurant cuisine
      final filtered = homeController.surpriseBags
          .where((bag) {
            // Check the bag's category field
            final bagCategory = bag["category"]?.toString().toLowerCase() ?? "";
            if (bagCategory.contains(categoryTitle)) {
              print("Bag ${bag["title"]} matches by bag category: $bagCategory");
              return true;
            }

            // Also check restaurant's cuisine as fallback
            final restaurant = homeController.allrest.firstWhere(
              (r) => r["id"] == bag["restaurantId"],
              orElse: () => {},
            );

            if (restaurant.isNotEmpty) {
              // Check restaurant category field first
              if (restaurant["category"] != null) {
                String restaurantCategory = restaurant["category"].toString().toLowerCase();
                if (restaurantCategory.contains(categoryTitle)) {
                  print("Bag ${bag["title"]} matches by restaurant category: $restaurantCategory");
                  return true;
                }
              }
              
              // Then check cuisines field
              if (restaurant["cuisines"] != null) {
                List<String> cuisines = restaurant["cuisines"].toString().split(',');
                final cuisineMatch = cuisines.any((cuisine) => cuisine
                    .trim()
                    .toLowerCase()
                    .contains(categoryTitle));

                if (cuisineMatch) {
                  print("Bag ${bag["title"]} matches by restaurant cuisine: ${restaurant["cuisines"]}");
                  return true;
                }
              }
            }

            return false;
          })
          .cast<Map<String, dynamic>>()
          .toList();

      print(
          "Returning ${filtered.length} filtered bags for category '$selectedCategory' (title: '$categoryTitle')");
      return filtered;
    }
  }

  String _getCategoryDisplayName() {
    if (selectedCategory == "all") return "All";
    
    final selectedCategoryData = homeController.categories.firstWhere(
      (cat) => cat["id"] == selectedCategory,
      orElse: () => {"title": selectedCategory},
    );
    return selectedCategoryData["title"]?.toString() ?? selectedCategory;
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
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                      backgroundColor: orangeColor.withOpacity(.1)),
                  onPressed: () => Get.to(() => LocationRadiusPage()),
                  icon:
                      Icon(IconlyLight.location, color: orangeColor, size: 24),
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

          IconButton.filledTonal(
            style: IconButton.styleFrom(
                backgroundColor: orangeColor.withOpacity(.1)),
            onPressed: () => Get.to(() => Notificationpage()),
            icon: Stack(
              children: [
                Icon(IconlyLight.notification, color: orangeColor, size: 24),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: orangeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: WhiteColor)),
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
      height: 50,
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
              final categoryId = category["id"]?.toString() ?? "";
              final categoryTitle = category["title"]?.toString() ?? "";
              final isSelected = selectedCategory == categoryId;

              return Container(
                margin: EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () {
                    print(
                        "Category selected: $categoryTitle (ID: $categoryId)");
                    setState(() {
                      selectedCategory = categoryId; // Use ID instead of title
                    });

                    // If selecting "All" and no data is loaded, force refresh
                    if (categoryId == "all" &&
                        homeController.surpriseBags.isEmpty) {
                      print("Forcing data refresh for 'All' category");
                      homeController.homeDataApi();
                    }

                    // Trigger a rebuild of the GetBuilder widgets
                    homeController.update();
                  },
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.teal : notifier.containerColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected
                            ? Colors.teal
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      categoryTitle,
                      style: TextStyle(
                        color: isSelected ? Colors.white : notifier.textColor,
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
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
                onPressed: () => Get.to(() => SearchPage()),
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
          height: 300,
          child: GetBuilder<HomeController>(
            builder: (controller) {
              final bags = filteredBags;
              print(
                  "Building recommended section - filtered bags: ${bags.length}, isLoading: ${controller.isLoading.value}");

              if (controller.isLoading.value && bags.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.teal),
                );
              }

              if (bags.isEmpty && !controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(IconlyLight.bag, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        selectedCategory == "all"
                            ? "No surprise bags available"
                            : "No bags found for '${_getCategoryDisplayName()}'",
                        style: TextStyle(
                          color: notifier.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Check back later for new bags!",
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
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: bags.length > 10
                    ? 10
                    : bags.length, // Show max 10 in recommended
                itemBuilder: (context, index) {
                  final bag = bags[index];
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
            final bags = filteredBags;
            print(
                "Building save section - filtered bags: ${bags.length}, isLoading: ${controller.isLoading.value}");

            if (controller.isLoading.value && bags.isEmpty) {
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

            if (bags.isEmpty && !controller.isLoading.value) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(IconlyLight.bag, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        selectedCategory == "all"
                            ? "No surprise bags available"
                            : "No bags found for '${_getCategoryDisplayName()}'",
                        style: TextStyle(
                          color: notifier.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Check back later for new bags!",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
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
              itemCount: bags.length,
              itemBuilder: (context, index) {
                final bag = bags[index];
                return _buildSaveCard(bag, notifier);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecommendedCard(
      Map<String, dynamic> bag, ColorNotifier notifier) {
    // Find restaurant data
    final restaurant = homeController.allrest.firstWhere(
      (r) => r["id"] == bag["restaurantId"],
      orElse: () => {
        "title": "Unknown Restaurant",
        "image": "",
        "fullAddress": "Address not available",
      },
    );

    return Container(
      width: 280,
      margin: EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () {
          Get.to(() => SurpriseBagDetails(
                bagData: bag,
                restaurantData: restaurant,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
            
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
                      imageUrl: bag["img"]?.toString().isNotEmpty == true
                          ? bag["img"]
                          : bag["image"]?.toString().isNotEmpty == true
                              ? bag["image"]
                              : "https://via.placeholder.com/280x160/f0f0f0/999999?text=No+Image",
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: double.infinity,
                        height: 160,
                        color: Colors.grey[300],
                        child: Icon(IconlyLight.category,
                            color: Colors.grey, size: 40),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: double.infinity,
                        height: 160,
                        color: Colors.grey[300],
                        child: Icon(IconlyLight.category,
                            color: Colors.grey, size: 40),
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
                          Icon(IconlyBold.star, color: Colors.amber, size: 14),
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
                      final bagId = bag["id"] ??
                          DateTime.now().millisecondsSinceEpoch.toString();
                      final isFav = favouritesController.isFavourite(bagId);

                      return IconButton.filledTonal(
                        style: IconButton.styleFrom(
                            backgroundColor: orangeColor.withOpacity(.2)),
                        onPressed: () {
                          favouritesController.toggleFavourite(
                            bag,
                            restaurant["title"] ?? "Unknown Restaurant",
                            restaurant["image"] ?? "",
                            restaurant["fullAddress"] ?? "Address not available",
                          );
                        },
                        icon: Icon(
                          isFav ? IconlyBold.heart : IconlyLight.heart,
                          size: 20,
                          color: isFav ? Colors.red : Colors.grey[600],
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
                          imageUrl: restaurant["image"]
                                      ?.toString()
                                      .isNotEmpty ==
                                  true
                              ? restaurant["image"]
                              : restaurant["img"]?.toString().isNotEmpty == true
                                  ? restaurant["img"]
                                  : "https://via.placeholder.com/40x40/f0f0f0/999999?text=Logo",
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Icon(
                              IconlyLight.category,
                              color: Colors.grey,
                              size: 20),
                          errorWidget: (context, url, error) => Icon(
                              IconlyLight.category,
                              color: Colors.grey,
                              size: 20),
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
                        color: Colors.grey[800],
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
                            color: Colors.grey[800],
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
        "fullAddress": "Address not available",
      },
    );

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Get.to(() => SurpriseBagDetails(
                bagData: bag,
                restaurantData: restaurant,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: Offset(0, 2),
                spreadRadius: 0,
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
                      imageUrl: bag["img"]?.toString().isNotEmpty == true
                          ? bag["img"]
                          : bag["image"]?.toString().isNotEmpty == true
                              ? bag["image"]
                              : "https://via.placeholder.com/120x120/f0f0f0/999999?text=No+Image",
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[300],
                        child: Icon(IconlyLight.category,
                            color: Colors.grey, size: 30),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[300],
                        child: Icon(IconlyLight.category,
                            color: Colors.grey, size: 30),
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
                          Icon(IconlyBold.star, color: Colors.amber, size: 12),
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
                      final bagId = bag["id"] ??
                          DateTime.now().millisecondsSinceEpoch.toString();
                      final isFav = favouritesController.isFavourite(bagId);

                      return GestureDetector(
                        onTap: () {
                          favouritesController.toggleFavourite(
                            bag,
                            restaurant["title"] ?? "Unknown Restaurant",
                            restaurant["image"] ?? "",
                            restaurant["fullAddress"] ?? "Address not available",
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
                            isFav ? IconlyBold.heart : IconlyLight.heart,
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
                          imageUrl: restaurant["image"]
                                      ?.toString()
                                      .isNotEmpty ==
                                  true
                              ? restaurant["image"]
                              : restaurant["img"]?.toString().isNotEmpty == true
                                  ? restaurant["img"]
                                  : "https://via.placeholder.com/32x32/f0f0f0/999999?text=R",
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Icon(
                              IconlyLight.category,
                              color: Colors.grey,
                              size: 16),
                          errorWidget: (context, url, error) => Icon(
                              IconlyLight.category,
                              color: Colors.grey,
                              size: 16),
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
                          color: Colors.grey[800],
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
                              color: Colors.grey[800],
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
