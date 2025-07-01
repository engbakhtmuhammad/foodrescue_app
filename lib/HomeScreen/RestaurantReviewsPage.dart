import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/dark_light_mode.dart';
import 'package:foodrescue_app/controllers/review_controller.dart';
import 'package:provider/provider.dart';

class RestaurantReviewsPage extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const RestaurantReviewsPage({
    Key? key,
    required this.restaurantId,
    required this.restaurantName,
  }) : super(key: key);

  @override
  State<RestaurantReviewsPage> createState() => _RestaurantReviewsPageState();
}

class _RestaurantReviewsPageState extends State<RestaurantReviewsPage> {
  final ReviewController reviewController = Get.put(ReviewController());
  final TextEditingController commentController = TextEditingController();
  double selectedRating = 5.0;
  Map<String, dynamic>? userReview;
  Map<String, dynamic> ratingInfo = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await reviewController.loadRestaurantReviews(widget.restaurantId);
    userReview = await reviewController.getUserReview(widget.restaurantId);
    ratingInfo = await reviewController.getRestaurantRatingInfo(widget.restaurantId);
    
    if (userReview != null) {
      selectedRating = (userReview!['rating'] as num).toDouble();
      commentController.text = userReview!['comment'] ?? '';
    }
    
    setState(() {});
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
          "Reviews",
          style: TextStyle(
            color: notifier.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Restaurant info and rating summary
          _buildRatingSummary(notifier),
          
          // Add/Edit review section
          _buildReviewForm(notifier),
          
          // Reviews list
          Expanded(
            child: _buildReviewsList(notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(ColorNotifier notifier) {
    double averageRating = ratingInfo['averageRating']?.toDouble() ?? 0.0;
    int reviewCount = ratingInfo['reviewCount'] ?? 0;
    
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
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
          Text(
            widget.restaurantName,
            style: TextStyle(
              color: notifier.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: TextStyle(
                  color: notifier.textColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < averageRating.floor() ? Icons.star : 
                        index < averageRating ? Icons.star_half : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "$reviewCount reviews",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewForm(ColorNotifier notifier) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16),
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
          Text(
            userReview != null ? "Edit Your Review" : "Add Your Review",
            style: TextStyle(
              color: notifier.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          
          // Rating stars
          Row(
            children: [
              Text(
                "Rating: ",
                style: TextStyle(
                  color: notifier.textColor,
                  fontSize: 14,
                ),
              ),
              ...List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedRating = (index + 1).toDouble();
                    });
                  },
                  child: Icon(
                    index < selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 24,
                  ),
                );
              }),
              SizedBox(width: 8),
              Text(
                selectedRating.toStringAsFixed(1),
                style: TextStyle(
                  color: notifier.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Comment field
          TextField(
            controller: commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Write your review...",
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: orangeColor),
              ),
            ),
            style: TextStyle(color: notifier.textColor),
          ),
          
          SizedBox(height: 12),
          
          // Submit button
          Row(
            children: [
              Expanded(
                child: Obx(() => ElevatedButton(
                  onPressed: reviewController.isLoading.value ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangeColor,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: reviewController.isLoading.value
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          userReview != null ? "Update Review" : "Add Review",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                )),
              ),
              if (userReview != null) ...[
                SizedBox(width: 12),
                OutlinedButton(
                  onPressed: reviewController.isLoading.value ? null : _deleteReview,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList(ColorNotifier notifier) {
    return Obx(() {
      if (reviewController.reviews.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                "No reviews yet",
                style: TextStyle(
                  color: notifier.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Be the first to review this restaurant",
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
        itemCount: reviewController.reviews.length,
        itemBuilder: (context, index) {
          final review = reviewController.reviews[index];
          return _buildReviewCard(review, notifier);
        },
      );
    });
  }

  Widget _buildReviewCard(Map<String, dynamic> review, ColorNotifier notifier) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
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
          Row(
            children: [
              CircleAvatar(
                backgroundColor: orangeColor,
                child: Text(
                  (review['userName'] ?? 'A')[0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['userName'] ?? 'Anonymous',
                      style: TextStyle(
                        color: notifier.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < (review['rating'] as num).toDouble()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                        SizedBox(width: 8),
                        Text(
                          review['rating'].toString(),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review['comment'] != null && review['comment'].isNotEmpty) ...[
            SizedBox(height: 12),
            Text(
              review['comment'],
              style: TextStyle(
                color: notifier.textColor,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _submitReview() async {
    if (commentController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please write a comment");
      return;
    }

    bool success;
    if (userReview != null) {
      success = await reviewController.updateReview(
        reviewId: userReview!['id'],
        rating: selectedRating,
        comment: commentController.text.trim(),
      );
    } else {
      success = await reviewController.addReview(
        restaurantId: widget.restaurantId,
        rating: selectedRating,
        comment: commentController.text.trim(),
      );
    }

    if (success) {
      _loadData(); // Reload data
    }
  }

  void _deleteReview() async {
    if (userReview != null) {
      bool success = await reviewController.deleteReview(userReview!['id']);
      if (success) {
        setState(() {
          userReview = null;
          commentController.clear();
          selectedRating = 5.0;
        });
        _loadData();
      }
    }
  }
}
