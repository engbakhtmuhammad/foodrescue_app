// Security Configuration for Food Rescue App
// This file contains security settings and constants

class SecurityConfig {
  // Rate limiting
  static const int maxOrdersPerHour = 5;
  static const int maxLoginAttemptsPerHour = 10;
  static const int maxPasswordResetAttemptsPerDay = 3;
  
  // Payment security
  static const double maxOrderAmount = 100.0;
  static const double minOrderAmount = 1.0;
  static const int paymentTimeoutMinutes = 15;
  
  // Session management
  static const int sessionTimeoutMinutes = 60;
  static const int maxConcurrentSessions = 3;
  
  // Data validation
  static const int maxNameLength = 50;
  static const int maxEmailLength = 100;
  static const int maxPhoneLength = 20;
  static const int maxAddressLength = 200;
  static const int maxNotesLength = 500;
  
  // File upload security
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
  ];
  
  // API security
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  static const int rateLimitWindowMinutes = 15;
  static const int maxApiCallsPerWindow = 100;
  
  // Encryption settings
  static const int saltLength = 32;
  static const int hashIterations = 10000;
  
  // Suspicious activity thresholds
  static const int maxFailedPayments = 3;
  static const int maxCancelledOrders = 5;
  static const int suspiciousOrderAmountThreshold = 50;
  
  // Geolocation security
  static const double maxDistanceFromRestaurant = 50.0; // km
  static const int locationAccuracyThreshold = 100; // meters
  
  // Device security
  static const int maxDevicesPerUser = 5;
  static const bool requireBiometricAuth = false; // Can be enabled for production
  
  // Content security
  static const List<String> bannedWords = [
    // Add inappropriate words that should be filtered
    'spam',
    'scam',
    'fraud',
  ];
  
  // Notification security
  static const int maxNotificationsPerDay = 50;
  static const int notificationCooldownMinutes = 5;
  
  // Database security rules (for reference)
  static const Map<String, dynamic> firestoreSecurityRules = {
    'users': {
      'read': 'auth.uid == resource.data.uid',
      'write': 'auth.uid == resource.data.uid && validateUserData(resource.data)',
    },
    'surprise_bag_orders': {
      'read': 'auth.uid == resource.data.userId || auth.uid in resource.data.restaurantOwners',
      'write': 'auth.uid == resource.data.userId && validateOrderData(resource.data)',
    },
    'restaurants': {
      'read': 'true', // Public read
      'write': 'auth.uid in resource.data.owners',
    },
  };
  
  // Validation patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';
  static const String passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
  
  // Security headers for API calls
  static const Map<String, String> securityHeaders = {
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
    'Content-Security-Policy': "default-src 'self'",
  };
  
  // Error messages (generic to avoid information disclosure)
  static const Map<String, String> securityErrorMessages = {
    'invalid_credentials': 'Invalid email or password',
    'account_locked': 'Account temporarily locked due to multiple failed attempts',
    'payment_failed': 'Payment could not be processed. Please try again',
    'order_limit_exceeded': 'You have reached the maximum number of orders for this period',
    'suspicious_activity': 'Activity flagged for review. Please contact support',
    'session_expired': 'Your session has expired. Please log in again',
    'invalid_location': 'Location verification failed',
    'file_too_large': 'File size exceeds the maximum allowed limit',
    'invalid_file_type': 'File type not supported',
    'rate_limit_exceeded': 'Too many requests. Please try again later',
  };
  
  // Audit log categories
  static const List<String> auditLogCategories = [
    'authentication',
    'payment',
    'order_creation',
    'order_modification',
    'profile_update',
    'password_change',
    'suspicious_activity',
    'data_export',
    'admin_action',
  ];
  
  // Feature flags for security features
  static const Map<String, bool> securityFeatures = {
    'enableTwoFactorAuth': false,
    'enableBiometricAuth': false,
    'enableLocationVerification': true,
    'enablePaymentVerification': true,
    'enableFraudDetection': true,
    'enableAuditLogging': true,
    'enableRateLimiting': true,
    'enableContentFiltering': true,
    'enableDeviceTracking': true,
    'enableSessionManagement': true,
  };
  
  // Production security checklist
  static const List<String> productionSecurityChecklist = [
    'Enable HTTPS/TLS encryption',
    'Configure Firebase Security Rules',
    'Enable Firebase App Check',
    'Set up proper API key restrictions',
    'Configure CORS policies',
    'Enable audit logging',
    'Set up monitoring and alerting',
    'Configure backup and recovery',
    'Enable DDoS protection',
    'Set up intrusion detection',
    'Configure data retention policies',
    'Enable secure headers',
    'Set up certificate pinning',
    'Configure proper error handling',
    'Enable fraud detection',
    'Set up payment security',
    'Configure user session management',
    'Enable content security policies',
    'Set up vulnerability scanning',
    'Configure incident response procedures',
  ];
  
  // Compliance requirements
  static const Map<String, List<String>> complianceRequirements = {
    'GDPR': [
      'Data minimization',
      'Consent management',
      'Right to erasure',
      'Data portability',
      'Privacy by design',
      'Data breach notification',
    ],
    'PCI_DSS': [
      'Secure payment processing',
      'Encrypted data transmission',
      'Access control',
      'Regular security testing',
      'Secure development practices',
      'Vulnerability management',
    ],
    'SOC2': [
      'Security controls',
      'Availability monitoring',
      'Processing integrity',
      'Confidentiality measures',
      'Privacy protection',
    ],
  };
  
  // Security monitoring thresholds
  static const Map<String, int> monitoringThresholds = {
    'failed_logins_per_minute': 10,
    'failed_payments_per_hour': 5,
    'api_errors_per_minute': 20,
    'suspicious_orders_per_day': 3,
    'data_export_requests_per_day': 2,
    'password_reset_requests_per_hour': 5,
  };
  
  // Incident response severity levels
  static const Map<String, String> incidentSeverityLevels = {
    'critical': 'Data breach, system compromise, payment fraud',
    'high': 'Service outage, security vulnerability, compliance violation',
    'medium': 'Performance degradation, minor security issue',
    'low': 'Cosmetic issues, minor bugs',
  };
}
