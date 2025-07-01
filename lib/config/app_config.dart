// Firebase configuration and constants
class AppConfig {
  // App constants
  static const String appName = "Food Rescue";
  static const String currency = "USD";
  static const String currencySymbol = "\$";

  // Default image URLs (these would be Firebase Storage URLs)
  static const String defaultImageUrl = "https://via.placeholder.com/300x200";
  static const String defaultUserImage = "https://via.placeholder.com/150x150";

  // Firebase collections - matching admin panel
  static const String usersCollection = "users";
  static const String restaurantsCollection = "restaurants";
  static const String bookingsCollection = "bookings";
  static const String menusCollection = "menus";
  static const String bannersCollection = "banners";
  static const String cuisinesCollection = "cuisines";
  static const String facilitiesCollection = "facilities";
  static const String galleriesCollection = "galleries";
  static const String galleryCategoriesCollection = "gallery_categories";
  static const String notificationsCollection = "notifications";
  static const String membershipPlansCollection = "membership_plans";
  static const String paymentGatewaysCollection = "payment_gateways";
  static const String payoutsCollection = "payouts";
  static const String walletTransactionsCollection = "wallet_transactions";
  static const String discountsCollection = "discounts";
  static const String faqsCollection = "faqs";
  static const String pagesCollection = "pages";
  static const String appSettingsCollection = "settings";
  static const String surpriseBagsCollection = "surprise_bags";
  static const String reservationsCollection = "reservations";
  static const String reviewsCollection = "reviews";
  static const String ordersCollection = "orders";

  // OneSignal App ID (replace with your actual OneSignal App ID)
  static const String oneSignalAppId = "your-onesignal-app-id";

  // Default values
  static const int defaultRadius = 10; // km
  static const int maxRadius = 100; // km
  static const int minRadius = 1; // km
  static const int defaultLimit = 20;
  static const int defaultTimeout = 30; // seconds
  static const double defaultLatitude = 37.7749;
  static const double defaultLongitude = -122.4194;
}

// Field Constants - to avoid conflicts and ensure consistency
class FieldConstants {
  // User fields
  static const String userId = "id";
  static const String userName = "name";
  static const String userEmail = "email";
  static const String userMobile = "mobile";
  static const String userCcode = "ccode";
  static const String userWalletBalance = "wallet_balance";
  static const String userCreatedAt = "created_at";
  static const String userUpdatedAt = "updated_at";

  // Restaurant fields
  static const String restaurantId = "id";
  static const String restaurantTitle = "title";
  static const String restaurantDescription = "description";
  static const String restaurantImg = "img";
  static const String restaurantAddress = "address";
  static const String restaurantLatitude = "latitude";
  static const String restaurantLongitude = "longitude";
  static const String restaurantRating = "rating";
  static const String restaurantStatus = "status";
  static const String restaurantCreatedAt = "created_at";
  static const String restaurantUpdatedAt = "updated_at";

  // Surprise Bag fields - matching admin panel
  static const String bagId = "id";
  static const String bagRestaurantId = "restaurantId";
  static const String bagRestaurantName = "restaurantName";
  static const String bagTitle = "title";
  static const String bagDescription = "description";
  static const String bagImg = "img";
  static const String bagOriginalPrice = "originalPrice";
  static const String bagDiscountedPrice = "discountedPrice";
  static const String bagDiscountPercentage = "discountPercentage";
  static const String bagItemsLeft = "itemsLeft";
  static const String bagTotalItems = "totalItems";
  static const String bagCategory = "category";
  static const String bagIsAvailable = "isAvailable";
  static const String bagStatus = "status";
  static const String bagPickupType = "pickupType";
  static const String bagTodayPickupStart = "todayPickupStart";
  static const String bagTodayPickupEnd = "todayPickupEnd";
  static const String bagTomorrowPickupStart = "tomorrowPickupStart";
  static const String bagTomorrowPickupEnd = "tomorrowPickupEnd";
  static const String bagPickupInstructions = "pickupInstructions";
  static const String bagDistance = "distance";
  static const String bagPickupAddress = "pickupAddress";
  static const String bagPickupLatitude = "pickupLatitude";
  static const String bagPickupLongitude = "pickupLongitude";
  static const String bagPossibleItems = "possibleItems";
  static const String bagAllergens = "allergens";
  static const String bagIsVegetarian = "isVegetarian";
  static const String bagIsVegan = "isVegan";
  static const String bagIsGlutenFree = "isGlutenFree";
  static const String bagDietaryInfo = "dietaryInfo";
  static const String bagRating = "rating";
  static const String bagTotalReviews = "totalReviews";
  static const String bagTotalSold = "totalSold";
  static const String bagCreatedAt = "createdAt";
  static const String bagUpdatedAt = "updatedAt";
  static const String bagLastSoldAt = "lastSoldAt";

  // Legacy field mappings for backward compatibility
  static const String bagImage = "image"; // Old field name
  static const String bagQuantity = "quantity"; // Old field name
  static const String bagPickupStartTime = "pickupStartTime"; // Old field name
  static const String bagPickupEndTime = "pickupEndTime"; // Old field name

  // Reservation fields
  static const String reservationId = "id";
  static const String reservationUserId = "userId";
  static const String reservationBagId = "bagId";
  static const String reservationRestaurantId = "restaurantId";
  static const String reservationBagData = "bagData";
  static const String reservationRestaurantData = "restaurantData";
  static const String reservationStatus = "status";
  static const String reservationTime = "reservationTime";
  static const String reservationPickupStartTime = "pickupStartTime";
  static const String reservationPickupEndTime = "pickupEndTime";
  static const String reservationPickupDate = "pickupDate";
  static const String reservationPrice = "price";
  static const String reservationOriginalPrice = "originalPrice";
  static const String reservationPaymentStatus = "paymentStatus";
  static const String reservationCode = "reservationCode";
  static const String reservationPaymentMethod = "paymentMethod";
  static const String reservationTransactionId = "transactionId";

  // Booking fields
  static const String bookingId = "id";
  static const String bookingUserId = "user_id";
  static const String bookingRestaurantId = "restaurant_id";
  static const String bookingName = "name";
  static const String bookingEmail = "email";
  static const String bookingMobile = "mobile";
  static const String bookingCcode = "ccode";
  static const String bookingFor = "book_for";
  static const String bookingTime = "book_time";
  static const String bookingDate = "book_date";
  static const String bookingNumberOfPeople = "number_of_people";
  static const String bookingStatus = "status";
  static const String bookingCreatedAt = "created_at";
  static const String bookingUpdatedAt = "updated_at";

  // Status values
  static const String statusActive = "active";
  static const String statusInactive = "inactive";
  static const String statusPending = "pending";
  static const String statusConfirmed = "confirmed";
  static const String statusCompleted = "completed";
  static const String statusCancelled = "cancelled";
  static const String statusPickedUp = "picked_up";

  // Payment status values
  static const String paymentPending = "pending";
  static const String paymentPaid = "paid";
  static const String paymentCompleted = "completed";
  static const String paymentFailed = "failed";
  static const String paymentRefunded = "refunded";
}

// Legacy compatibility - Firebase-only implementation
class AppUrl {
  static const String oneSignel = AppConfig.oneSignalAppId;

  // Placeholder values for legacy compatibility - not used in Firebase implementation
  static const String imageurl = ""; // Images come from Firebase data directly
  static const String baseUrl = ""; // Not used - Firebase handles all data
  static const String paymentBaseUrl = ""; // Not used - payment disabled
  static const String payFast = ""; // Not used - payment disabled
  static const String forgetpassword = ""; // Not used - Firebase auth handles this
  static const String editprofile = ""; // Not used - Firebase handles profile updates
  static const String pagelist = ""; // Not used - Firebase handles page data
}
