import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Utils/Colors.dart';
import '../../Utils/dark_light_mode.dart';
import '../../controllers/favourites_controller.dart';
import '../../controllers/home_controller.dart';
import '../bags/SurpriseBagDetails.dart';

class FavouritesPage extends StatefulWidget {
  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  final FavouritesController favouritesController = Get.put(FavouritesController());
  final HomeController homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    favouritesController.loadFavourites();
  }

  @override
  Widget build(BuildContext context) {
    ColorNotifier notifier = Provider.of<ColorNotifier>(context, listen: true);
    
    return Scaffold(
      backgroundColor: notifier.background,
      appBar: AppBar(
        backgroundColor: notifier.background,
        elevation: 0,
        title: Text(
          'Favourites'.tr,
          style: TextStyle(
            color: notifier.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() => favouritesController.favourites.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_all, color: notifier.textColor),
                  onPressed: () => _showClearAllDialog(notifier),
                )
              : SizedBox()),
        ],
      ),
      body: Obx(() {
        if (favouritesController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: orangeColor),
          );
        }

        if (favouritesController.favourites.isEmpty) {
          return _buildEmptyState(notifier);
        }

        return RefreshIndicator(
          color: orangeColor,
          onRefresh: () async {
            await favouritesController.loadFavourites();
          },
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: favouritesController.favourites.length,
            itemBuilder: (context, index) {
              final favourite = favouritesController.favourites[index];
              return _buildFavouriteCard(favourite, notifier);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(ColorNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No Favourites Yet'.tr,
            style: TextStyle(
              color: notifier.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start adding surprise bags to your favourites!'.tr,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: orangeColor,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Browse Surprise Bags'.tr,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavouriteCard(Map<String, dynamic> favourite, ColorNotifier notifier) {
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
          final restaurant = homeController.allrest.firstWhere(
            (r) => r["id"] == favourite["restaurantId"],
            orElse: () => {
              "title": "Unknown Restaurant",
              "image": "",
              "address": "Address not available",
            },
          );
          Get.to(() => SurpriseBagDetails(
            bagData: favourite,
            restaurantData: restaurant,
          ));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: favourite["img"] ?? "",
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: Icon(Icons.restaurant, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: Icon(Icons.restaurant, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      favourite["title"] ?? "Surprise Bag",
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
                      favourite["restaurantName"] ?? "Unknown Restaurant",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "\$${favourite["discountedPrice"] ?? "9.99"}",
                          style: TextStyle(
                            color: orangeColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        if (favourite["originalPrice"] != null)
                          Text(
                            "\$${favourite["originalPrice"]}",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Remove from favourites button
              IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                onPressed: () => _removeFavourite(favourite),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeFavourite(Map<String, dynamic> favourite) {
    favouritesController.removeFavourite(favourite["id"] ?? "");
    Get.snackbar(
      "Removed".tr,
      "Removed from favourites".tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void _showClearAllDialog(ColorNotifier notifier) {
    Get.dialog(
      AlertDialog(
        backgroundColor: notifier.containerColor,
        title: Text(
          'Clear All Favourites'.tr,
          style: TextStyle(color: notifier.textColor),
        ),
        content: Text(
          'Are you sure you want to remove all favourites?'.tr,
          style: TextStyle(color: notifier.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              favouritesController.clearAllFavourites();
              Get.back();
              Get.snackbar(
                "Cleared".tr,
                "All favourites cleared".tr,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
            child: Text(
              'Clear All'.tr,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
