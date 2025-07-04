import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/dark_light_mode.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantDetailsPage extends StatefulWidget {
  final Map<String, dynamic> restaurantData;

  const RestaurantDetailsPage({
    Key? key,
    required this.restaurantData,
  }) : super(key: key);

  @override
  State<RestaurantDetailsPage> createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  @override
  Widget build(BuildContext context) {
    ColorNotifier notifier = Provider.of<ColorNotifier>(context, listen: true);
    
    return Scaffold(
      backgroundColor: notifier.background,
      body: CustomScrollView(
        slivers: [
          // TGTG-style App Bar with Restaurant Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: notifier.background,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(IconlyLight.arrow_left, color: Colors.white, size: 20),
              ),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Restaurant main image
                  CachedNetworkImage(
                    imageUrl: widget.restaurantData["img"]??widget.restaurantData["image"] ?? "",
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(color: orangeColor),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: Icon(IconlyLight.home, size: 80, color: Colors.grey),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                        stops: [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                  // Restaurant name and logo overlay
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        // Restaurant logo
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: CachedNetworkImage(
                              imageUrl: widget.restaurantData["img"] ?? widget.restaurantData["image"] ?? "",
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: Icon(IconlyLight.home, color: Colors.grey),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: Icon(IconlyLight.home, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Restaurant name and address
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.restaurantData["title"] ?? "Restaurant Name",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 5,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.restaurantData["fullAddress"] ?? widget.restaurantData["address"] ?? "Address not available",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 5,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Restaurant content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: notifier.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24),
                  
                  // Location card
                  _buildLocationCard(notifier),
                  
                  SizedBox(height: 20),
                  
                  // Surprise bags section
                  _buildSurpriseBagsSection(notifier),
                  
                  SizedBox(height: 20),
                  
                  // About section
                  _buildAboutSection(notifier),
                  
                  SizedBox(height: 20),
                  
                  // Stats section
                  _buildStatsSection(notifier),
                  
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(ColorNotifier notifier) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: notifier.containerColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(IconlyLight.location, color: orangeColor, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.restaurantData["fullAddress"] ?? widget.restaurantData["address"] ?? "Address not available",
                  style: TextStyle(
                    color: notifier.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final lat = widget.restaurantData["latitude"];
              final lng = widget.restaurantData["longitude"];
              if (lat != null && lng != null) {
              final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(IconlyLight.send, color: orangeColor, size: 24),
                  SizedBox(width: 8),
                  Text(
                    "Click to open map",
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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

  Widget _buildSurpriseBagsSection(ColorNotifier notifier) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Surprise Bags from this store",
            style: TextStyle(
              color: notifier.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          // Sample surprise bag item (you can make this dynamic)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: notifier.containerColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Bag image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[300],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: widget.restaurantData["img"]??widget.restaurantData["image"] ?? "",
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: Icon(IconlyLight.bag, color: Colors.grey),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: Icon(IconlyLight.bag, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                
                // Bag details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.restaurantData["title"] ?? "Restaurant"} Surprise Bag",
                        style: TextStyle(
                          color: notifier.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Today: 10:30 PM - 11:00 PM",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Price and badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "2",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "£4.65",
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                Icon(IconlyLight.arrow_right_2, color: Colors.grey[400]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(ColorNotifier notifier) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About",
            style: TextStyle(
              color: notifier.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            widget.restaurantData["shortDescription"] ?? "We're famous for our amazing food, but did you know that every item is hand checked and our decorated range are always hand filled by one of our awesome team? And whether you buy your food from our store, one of our retail partners, have your food delivered or buy on our website, your food is always made fresh daily!",
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ColorNotifier notifier) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.cake,
                      color: Colors.blue[700],
                      size: 32,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "3 years",
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.eco,
                      color: Colors.green[700],
                      size: 32,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "7,500+",
                    style: TextStyle(
                      color: Colors.green[900],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
}
