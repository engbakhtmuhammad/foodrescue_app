import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/controllers/home_controller.dart';
import 'package:foodrescue_app/controllers/reservation_controller.dart';
import 'package:foodrescue_app/controllers/favourites_controller.dart';
import 'package:foodrescue_app/Utils/dark_light_mode.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'PaymentSelectionDialog.dart';
import '../restaurant/RestaurantDetailsPage.dart';

class SurpriseBagDetails extends StatefulWidget {
  final Map<String, dynamic> bagData;
  final Map<String, dynamic> restaurantData;

  const SurpriseBagDetails({
    Key? key,
    required this.bagData,
    required this.restaurantData,
  }) : super(key: key);

  @override
  State<SurpriseBagDetails> createState() => _SurpriseBagDetailsState();
}

class _SurpriseBagDetailsState extends State<SurpriseBagDetails> {
  final HomeController homeController = Get.find<HomeController>();
  final ReservationController reservationController = Get.find<ReservationController>();
  final FavouritesController favouritesController = Get.put(FavouritesController());
  bool isReserving = false;

  @override
  Widget build(BuildContext context) {
    ColorNotifier notifier = Provider.of<ColorNotifier>(context, listen: true);
    
    return Scaffold(
      backgroundColor: notifier.background,
      body: CustomScrollView(
        slivers: [
          // TGTG-style App Bar with Large Image
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
            actions: [
              Obx(() {
                final bagId = widget.bagData["id"] ?? DateTime.now().millisecondsSinceEpoch.toString();
                final isFav = favouritesController.isFavourite(bagId);

                return IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      isFav ? IconlyBold.heart : IconlyLight.heart,
                      color: isFav ? Colors.red : Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: () {
                    favouritesController.toggleFavourite(
                      widget.bagData,
                      widget.restaurantData["title"] ?? "Unknown Restaurant",
                      widget.restaurantData["img"] ?? "",
                      widget.restaurantData["fullAddress"] ?? "Address not available",
                    );
                  },
                );
              }),
              SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Main image
                  CachedNetworkImage(
                    imageUrl: widget.bagData["img"] ?? widget.restaurantData["image"] ?? "https://picsum.photos/400/200",
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(color: orangeColor),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: Icon(IconlyLight.bag, size: 80, color: Colors.grey),
                    ),
                  ),
                  // Subtle gradient overlay at bottom
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                        stops: [0.0, 0.7, 1.0],
                      ),
                    ),
                  ),
                  // Restaurant info overlay at bottom - TGTG style
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      children: [
                        Row(
                      children: [
                        // Popular badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            "Popular",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        // Quantity left badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            "${widget.bagData["itemsLeft"] ?? "2"} left",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                        Row(
                          children: [
                            // Restaurant logo
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CachedNetworkImage(
                                  imageUrl: widget.restaurantData["img"] ?? widget.restaurantData["image"],
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
                            SizedBox(width: 12),
                            // Restaurant name and address
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.restaurantData["title"] ?? "Unknown Restaurant",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
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
                                  SizedBox(height: 2),
                                  Text(
                                    widget.restaurantData["fullAddress"]!=null? widget.restaurantData["fullAddress"]: widget.restaurantData["address"]?? "Address not available",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
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
                      ],
                    ),
                  ),
              
                ],
              ),
            ),
          ),
          
          // TGTG-style Content
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
                  // Main bag info card - TGTG style
                  _buildMainInfoCard(notifier),
                  
                  SizedBox(height: 20),
                  
                  // Restaurant info - TGTG style
                  _buildRestaurantCard(notifier),
                  
                  SizedBox(height: 20),
                  
                  // Pickup details - TGTG style
                  _buildPickupCard(notifier),
                  
                  SizedBox(height: 20),
                  
                  // What you might get - TGTG style
                  _buildWhatYouMightGetCard(notifier),
                  
                  SizedBox(height: 120), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildTGTGBottomButton(notifier),
    );
  }

  // TGTG-style Main Info Card
  Widget _buildMainInfoCard(ColorNotifier notifier) {
    final originalPrice = double.tryParse(widget.bagData["originalPrice"]?.toString() ?? "0") ?? 0.0;
    final currentPrice = double.tryParse(widget.bagData["discountedPrice"]?.toString() ?? "0") ?? 0.0;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          // Title and bag icon
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: orangeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  IconlyLight.bag,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.bagData["title"] ?? "${widget.restaurantData["title"] ?? "Unknown Restaurant"} Surprise Bag",
                  style: TextStyle(
                    color: notifier.textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Rating and price row
          Row(
            children: [
              // Star rating
              Row(
                children: [
                  Icon(Icons.star, color: Colors.green, size: 18),
                  SizedBox(width: 4),
                  Text(
                    "${widget.bagData["rating"] ?? "4.9"}",
                    style: TextStyle(
                      fontSize: 16,
                      color: notifier.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    "(${widget.bagData["totalReviews"] ?? "1,219"})",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Spacer(),
              // Prices
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (originalPrice > currentPrice)
                    Text(
                      "\$${originalPrice.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    "\$${currentPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: notifier.textColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Pickup time with today badge
          Row(
            children: [
              Icon(IconlyLight.time_circle, color: Colors.grey[600], size: 18),
              SizedBox(width: 8),
              Text(
                "Pick up: ${widget.bagData["todayPickupStart"] ?? "10:30"} - ${widget.bagData["todayPickupEnd"] ?? "11:00"}",
                style: TextStyle(
                  fontSize: 14,
                  color: notifier.textColor,
                ),
              ),
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: orangeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.bagData["pickupType"] ?? "Today",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TGTG-style Restaurant Card
  Widget _buildRestaurantCard(ColorNotifier notifier) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Location section
          GestureDetector(
            onTap: () {
              // Navigate to restaurant details page
              Get.to(() => RestaurantDetailsPage(restaurantData: widget.restaurantData));
            },
            child: Container(
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
              child: Row(
                children: [
                  Icon(IconlyLight.location, color: orangeColor, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.restaurantData["fullAddress"]!=null?widget.restaurantData["fullAddress"].split(',').first:widget.restaurantData["address"].split(',').first ?? "Address not available",
                          style: TextStyle(
                            color: notifier.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "More information about the store",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(IconlyLight.arrow_right_2, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          
          // Popular section
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: orangeColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "This item is popular",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "This Surprise Bag is a crowd favorite, with top ratings and plenty of saves.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TGTG-style Pickup Card
  Widget _buildPickupCard(ColorNotifier notifier) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: notifier.containerColor,
        borderRadius: BorderRadius.circular(20),
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
              Icon(IconlyLight.time_circle, color: orangeColor, size: 24),
              SizedBox(width: 12),
              Text(
                "Pickup Details",
                style: TextStyle(
                  color: notifier.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Pickup time
          _buildPickupInfoRow(
            icon: IconlyLight.calendar,
            title: "Pickup Time",
            subtitle: widget.bagData["pickupType"] ?? "Today",
            time: "${widget.bagData["todayPickupStart"] ?? "18:00"} - ${widget.bagData["todayPickupEnd"] ?? "20:00"}",
            notifier: notifier,
          ),
          
          SizedBox(height: 16),
          
          // Location
          _buildPickupInfoRow(
            icon: IconlyLight.location,
            title: "Pickup Location",
            subtitle: widget.restaurantData["fullAddress"]!=null?widget.restaurantData["fullAddress"].split(',').first:widget.restaurantData["address"].split(',').first ?? "Address not available",
            time: null,
            notifier: notifier,
          ),
          
          SizedBox(height: 16),
          
          // Instructions
          if (widget.bagData["pickupInstructions"] != null && widget.bagData["pickupInstructions"].toString().isNotEmpty)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(IconlyLight.info_circle, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.bagData["pickupInstructions"] ?? "Please bring your confirmation and a reusable bag",
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
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

  // TGTG-style What You Might Get Card
  Widget _buildWhatYouMightGetCard(ColorNotifier notifier) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // What you could get section
          Container(
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
                Text(
                  "What you could get",
                  style: TextStyle(
                    color: notifier.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  widget.bagData["description"] ?? 
                  "Our surprise bags contain a melt-in-your-mouth selection of 6 Krispy Kreme doughnuts. You'll receive a surprise box of 6 delicious doughnuts chosen directly from the cabinet at the time of your collection.",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          
          // Category tag
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.bagData["category"] ?? "Bread & pastries",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TGTG-style Bottom Button
  Widget _buildTGTGBottomButton(ColorNotifier notifier) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifier.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isReserving ? null : _handleReservation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            child: isReserving
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Reserving...",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    "Reserve",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildPickupInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    String? time,
    required ColorNotifier notifier,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: notifier.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              if (time != null) ...[
                SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    color: orangeColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Add the missing _handleReservation method
  void _handleReservation() async {
    setState(() {
      isReserving = true;
    });

    try {
      // Get restaurant data
      final restaurant = homeController.allrest.firstWhere(
        (r) => r["id"] == widget.bagData["restaurantId"],
        orElse: () => {
          "title": widget.restaurantData["title"] ?? "Unknown Restaurant",
          "image": widget.restaurantData["img"] ?? "",
          "fullAddress": widget.restaurantData["fullAddress"] ?? "Address not available",
        },
      );

      final price = double.tryParse(widget.bagData["discountedPrice"]?.toString() ?? "0") ?? 0.0;

      // Show payment dialog
      showDialog(
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
