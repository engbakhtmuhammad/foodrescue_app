import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/dark_light_mode.dart';
import 'package:foodrescue_app/controllers/reservation_controller.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({Key? key}) : super(key: key);

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> with SingleTickerProviderStateMixin {
  final ReservationController reservationController = Get.find<ReservationController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    reservationController.loadUserReservations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        title: Text(
          "My Reservations",
          style: TextStyle(
            color: notifier.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: orangeColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: orangeColor,
          tabs: [
            Tab(text: "Active"),
            Tab(text: "Completed"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),
      body: Obx(() {
        if (reservationController.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: orangeColor));
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildReservationsList(reservationController.activeReservations, notifier, "active"),
            _buildReservationsList(reservationController.completedReservations, notifier, "completed"),
            _buildReservationsList(reservationController.cancelledReservations, notifier, "cancelled"),
          ],
        );
      }),
    );
  }

  Widget _buildReservationsList(List<Map<String, dynamic>> reservations, ColorNotifier notifier, String type) {
    if (reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == "active" ? Icons.shopping_bag_outlined :
              type == "completed" ? Icons.check_circle_outline :
              Icons.cancel_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              type == "active" ? "No active reservations" :
              type == "completed" ? "No completed reservations" :
              "No cancelled reservations",
              style: TextStyle(
                color: notifier.textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              type == "active" ? "Reserve a surprise bag to see it here" :
              type == "completed" ? "Completed reservations will appear here" :
              "Cancelled reservations will appear here",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => reservationController.loadUserReservations(),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          return _buildReservationCard(reservation, notifier, type);
        },
      ),
    );
  }

  Widget _buildReservationCard(Map<String, dynamic> reservation, ColorNotifier notifier, String type) {
    final bagData = reservation['bagData'] as Map<String, dynamic>? ?? {};
    final restaurantData = reservation['restaurantData'] as Map<String, dynamic>? ?? {};
    
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(reservation['status']).withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(reservation['status']),
                  color: _getStatusColor(reservation['status']),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  _getStatusText(reservation['status']),
                  style: TextStyle(
                    color: _getStatusColor(reservation['status']),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Spacer(),
                Text(
                  "Code: ${reservation['reservationCode'] ?? 'N/A'}",
                  style: TextStyle(
                    color: notifier.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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
                // Restaurant and bag info
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: bagData["image"] ?? restaurantData["image"] ?? "https://picsum.photos/60/60",
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
                        children: [
                          Text(
                            restaurantData["title"] ?? "Unknown Restaurant",
                            style: TextStyle(
                              color: notifier.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            bagData["title"] ?? "Surprise Bag",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Pickup: ${reservation['pickupDate']} ${reservation['pickupStartTime']}-${reservation['pickupEndTime']}",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "\$${reservation['price'] ?? '9.99'}",
                          style: TextStyle(
                            color: orangeColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (reservation['originalPrice'] != null)
                          Text(
                            "\$${reservation['originalPrice']}",
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
                SizedBox(height: 16),
                // Action buttons
                if (type == "active") ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _cancelReservation(reservation['id']),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _markAsPickedUp(reservation['id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orangeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Picked Up",
                            style: TextStyle(color: Colors.white),
                          ),
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
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return orangeColor;
      case 'picked_up':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.schedule;
      case 'picked_up':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'picked_up':
        return 'Picked Up';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  void _cancelReservation(String reservationId) {
    Get.dialog(
      AlertDialog(
        title: Text("Cancel Reservation"),
        content: Text("Are you sure you want to cancel this reservation?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await reservationController.cancelReservation(reservationId);
            },
            child: Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _markAsPickedUp(String reservationId) {
    Get.dialog(
      AlertDialog(
        title: Text("Mark as Picked Up"),
        content: Text("Have you picked up this surprise bag?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await reservationController.markAsPickedUp(reservationId);
            },
            child: Text("Yes", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}
