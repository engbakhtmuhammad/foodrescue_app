// Stripe Configuration
// IMPORTANT: Never commit your secret key to version control
// In production, use environment variables or secure configuration management

class StripeConfig {
  // Your Stripe publishable key (safe to expose in client)
  static const String publishableKey = 'pk_test_51RevdgQKE5g5ygzypGh2HoSU5uagwcSE8qiAxEbK180mT3g7L1Fie02UA2J1L5p4InfXaUJfuSCgMPP920Cy2c1k004UOb60Xf';
  
  // WARNING: This should be moved to a backend service in production
  // For development only - replace with your actual secret key
  static const String secretKey = 'sk_test_YOUR_SECRET_KEY_HERE';
  
  // Stripe API base URL
  static const String baseUrl = 'https://api.stripe.com/v1';
  
  // Default currency
  static const String defaultCurrency = 'USD';
  
  // Webhook endpoint secret (for production)
  static const String webhookSecret = 'whsec_YOUR_WEBHOOK_SECRET_HERE';
  
  // Payment configuration
  static const bool automaticPaymentMethods = true;
  static const bool captureMethod = true; // true = automatic, false = manual
  
  // Supported payment methods
  static const List<String> supportedPaymentMethods = [
    'card',
    'apple_pay',
    'google_pay',
  ];
  
  // Business information for payment sheet
  static const String merchantDisplayName = 'Food Rescue App';
  static const String merchantCountryCode = 'US';
  
  // Error messages
  static const Map<String, String> errorMessages = {
    'card_declined': 'Your card was declined. Please try a different payment method.',
    'insufficient_funds': 'Your card has insufficient funds. Please try a different payment method.',
    'expired_card': 'Your card has expired. Please try a different payment method.',
    'incorrect_cvc': 'Your card\'s security code is incorrect. Please try again.',
    'processing_error': 'An error occurred while processing your payment. Please try again.',
    'network_error': 'Network error. Please check your connection and try again.',
  };
}
