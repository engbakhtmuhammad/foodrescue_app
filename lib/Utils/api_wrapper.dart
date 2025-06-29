// Legacy API wrapper for backward compatibility
// This is a placeholder to prevent compilation errors
// All functionality should be migrated to Firebase services

import 'package:foodrescue_app/services/firebase_service.dart';

class ApiWrapper {
  // Legacy method for showing toast messages
  static void showToastMessage(String message) {
    FirebaseService.showToastMessage(message);
  }
  
  // Placeholder methods to prevent compilation errors
  static Future<Map<String, dynamic>?> dataPost(String url, Map<String, dynamic> data) async {
    // This should not be used - migrate to Firebase services
    print("Warning: Using deprecated API method. Please migrate to Firebase services.");
    return null;
  }
  
  static Future<Map<String, dynamic>?> dataGet(String url) async {
    // This should not be used - migrate to Firebase services
    print("Warning: Using deprecated API method. Please migrate to Firebase services.");
    return null;
  }
}
