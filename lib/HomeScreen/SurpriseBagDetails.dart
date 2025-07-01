import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/controllers/home_controller.dart';
import 'package:foodrescue_app/controllers/reservation_controller.dart';
import 'package:foodrescue_app/Utils/dark_light_mode.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'PaymentSelectionDialog.dart';

class SurpriseBagDetails extends StatefulWidget {
  final Map<String, dynamic> bagData;
  final String restaurantName;
  final String restaurantImage;
  final String restaurantAddress;

  const SurpriseBagDetails({
    Key? key,
    required this.bagData,
    required this.restaurantName,
    required this.restaurantImage,
    required this.restaurantAddress,
  }) : super(key: key);

  @override
  State<SurpriseBagDetails> createState() => _SurpriseBagDetailsState();
}

class _SurpriseBagDetailsState extends State<SurpriseBagDetails> {
  final HomeController homeController = Get.find<HomeController>();
  final ReservationController reservationController = Get.find<ReservationController>();
  bool isReserving = false;



  @override
  Widget build(BuildContext context) {
    ColorNotifier notifier = Provider.of<ColorNotifier>(context, listen: true);
    
    return Scaffold(
      backgroundColor: notifier.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: notifier.background,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.favorite_border, color: Colors.white),
                ),
                onPressed: () {
                  // Add to favorites functionality
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.bagData["img"] ?? widget.restaurantImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.restaurant, size: 50, color: Colors.grey),
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
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Availability badge
                  Positioned(
                    top: 60,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getAvailabilityColor(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getAvailabilityText(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: notifier.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant Info
                    _buildRestaurantInfo(notifier),
                    SizedBox(height: 24),
                    
                    // Bag Details
                    _buildBagDetails(notifier),
                    SizedBox(height: 24),
                    
                    // Pickup Info
                    _buildPickupInfo(notifier),
                    SizedBox(height: 24),
                    
                    // Description
                    _buildDescription(notifier),
                    SizedBox(height: 24),
                    
                    // What you might get
                    _buildWhatYouMightGet(notifier),
                    SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomReserveButton(notifier),
    );
  }

  Widget _buildRestaurantInfo(ColorNotifier notifier) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: widget.restaurantImage,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: Icon(Icons.restaurant),
            ),
            errorWidget: (context, url, error) => Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: Icon(Icons.restaurant),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.restaurantName,
                style: TextStyle(
                  color: notifier.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.restaurantAddress,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  SizedBox(width: 4),
                  Text(
                    "4.5 (120 reviews)",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBagDetails(ColorNotifier notifier) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: notifier.containerColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.bagData["title"] ?? "Surprise Bag",
                style: TextStyle(
                  color: notifier.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: orangeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${widget.bagData["itemsLeft"] ?? 1} left",
                  style: TextStyle(
                    color: orangeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                "\$${widget.bagData["discountedPrice"] ?? "9.99"}",
                style: TextStyle(
                  color: orangeColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text(
                "\$${widget.bagData["originalPrice"] ?? "29.99"}",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                 "${widget.bagData["discountPercentage"] ?? "67"}% OFF",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickupInfo(ColorNotifier notifier) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: notifier.containerColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pickup Information",
            style: TextStyle(
              color: notifier.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildPickupInfoRow(
            Icons.access_time,
            "Pickup Time",
            "${widget.bagData["pickupStartTime"] ?? "18:00"} - ${widget.bagData["pickupEndTime"] ?? "20:00"}",
            notifier,
          ),
          SizedBox(height: 12),
          _buildPickupInfoRow(
            Icons.calendar_today,
            "Available",
            "Today",
            notifier,
          ),
          SizedBox(height: 12),
          _buildPickupInfoRow(
            Icons.location_on,
            "Pickup Location",
            widget.restaurantAddress,
            notifier,
          ),
        ],
      ),
    );
  }

  Widget _buildPickupInfoRow(IconData icon, String title, String value, ColorNotifier notifier) {
    return Row(
      children: [
        Icon(icon, size: 20, color: orangeColor),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: notifier.textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(ColorNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About this bag",
          style: TextStyle(
            color: notifier.textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Text(
          widget.bagData["description"] ?? 
          "A delicious surprise bag filled with fresh items that would otherwise go to waste. Perfect for discovering new flavors while helping reduce food waste!",
          style: TextStyle(
            color: notifier.textColor,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildWhatYouMightGet(ColorNotifier notifier) {
    List<String> items = [
      "Fresh pastries and bread",
      "Seasonal vegetables",
      "Prepared meals",
      "Desserts and sweets",
      "Beverages",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What you might get",
          style: TextStyle(
            color: notifier.textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: Colors.green),
              SizedBox(width: 8),
              Text(
                item,
                style: TextStyle(
                  color: notifier.textColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildBottomReserveButton(ColorNotifier notifier) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: notifier.containerColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: isReserving ? null : _reserveBag,
          style: ElevatedButton.styleFrom(
            backgroundColor: orangeColor,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: isReserving
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  "Reserve for \$${widget.bagData["discountedPrice"] ?? "9.99"}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Color _getAvailabilityColor() {
    int quantity = int.tryParse(widget.bagData["itemsLeft"]?.toString() ?? "0") ?? 0;
    if (quantity > 5) return Colors.green;
    if (quantity > 0) return Colors.orange;
    return Colors.red;
  }

  String _getAvailabilityText() {
    int quantity = int.tryParse(widget.bagData["itemsLeft"]?.toString() ?? "0") ?? 0;
    if (quantity > 5) return "Available";
    if (quantity > 0) return "Few left";
    return "Sold out";
  }

  void _reserveBag() async {
    setState(() {
      isReserving = true;
    });

    try {
      // Check if user has already reserved this bag
      if (reservationController.hasReservedBag(widget.bagData["id"] ?? "")) {
        Get.snackbar("Info", "You have already reserved this surprise bag");
        return;
      }

      // Find restaurant data
      Map<String, dynamic> restaurantData = {
        "id": widget.bagData["restaurantId"] ?? "",
        "title": widget.restaurantName,
        "image": widget.restaurantImage,
        "address": widget.restaurantAddress,
      };

      // Try to find more complete restaurant data
      final restaurant = homeController.allrest.firstWhere(
        (r) => r["id"] == widget.bagData["restaurantId"],
        orElse: () => restaurantData,
      );

      // Get the price for payment
      double price = double.tryParse(widget.bagData["discountedPrice"]?.toString() ?? "0") ?? 0.0;

      // Show payment selection dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PaymentSelectionDialog(
          amount: price,
          reservationId: widget.bagData["id"] ?? "",
          reservationData: {
            'bagData': widget.bagData,
            'restaurantData': restaurant,
          },
          onPaymentSuccess: (paymentMethod, transactionId) async {
            // Create reservation with payment info
            bool success = await reservationController.reserveSurpriseBagWithPayment(
              bagId: widget.bagData["id"] ?? "",
              restaurantId: widget.bagData["restaurantId"] ?? "",
              bagData: widget.bagData,
              restaurantData: restaurant,
              paymentMethod: paymentMethod,
              transactionId: transactionId,
            );

            if (success) {
              // Navigate back to home
              Get.back();
            }
          },
        ),
      );
    } catch (e) {
      print("Error reserving bag: $e");
      Get.snackbar("Error", "Failed to reserve surprise bag. Please try again.");
    } finally {
      setState(() {
        isReserving = false;
      });
    }
  }
}
