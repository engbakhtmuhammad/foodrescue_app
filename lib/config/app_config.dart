// Firebase configuration and constants
class AppConfig {
  // App constants
  static const String appName = "Food Rescue";
  static const String currency = "USD";
  static const String currencySymbol = "\$";
  
  // Default image URLs (these would be Firebase Storage URLs)
  static const String defaultImageUrl = "https://via.placeholder.com/300x200";
  static const String defaultUserImage = "https://via.placeholder.com/150x150";
  
  // Firebase collections
  static const String usersCollection = "users";
  static const String restaurantsCollection = "restaurants";
  static const String bookingsCollection = "bookings";
  static const String menusCollection = "menus";
  static const String bannersCollection = "banners";
  static const String cuisinesCollection = "cuisines";
  static const String galleriesCollection = "galleries";
  static const String notificationsCollection = "notifications";
  static const String membershipPlansCollection = "membership_plans";
  static const String paymentGatewaysCollection = "payment_gateways";
  static const String walletTransactionsCollection = "wallet_transactions";
  static const String discountsCollection = "discounts";
  static const String faqsCollection = "faqs";
  static const String pagesCollection = "pages";
  static const String appSettingsCollection = "app_settings";
  
  // OneSignal App ID (replace with your actual OneSignal App ID)
  static const String oneSignalAppId = "your-onesignal-app-id";
  
  // Default values
  static const int defaultRadius = 10; // km
  static const int defaultLimit = 20;
  static const int defaultTimeout = 30; // seconds
}

// Legacy compatibility - keeping some old constants for gradual migration
class AppUrl {
  static const String imageurl = "";
  static const String baseUrl = "";
  static const String paymentBaseUrl = "";
  static const String payFast = "";
  static const String oneSignel = AppConfig.oneSignalAppId;
  static const String forgetpassword = "";
  static const String mobilecheck = "";
  static const String editprofile = "";
  static const String pagelist = "";
}
