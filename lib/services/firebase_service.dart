import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Utils/Colors.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Show toast message
  static showToastMessage(String message) {
    Fluttertoast.showToast(
        msg: message,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: gradientColor.withOpacity(0.9),
        textColor: Colors.white,
        fontSize: 14.0);
  }

  // Authentication Methods
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String mobile,
    required String ccode,
    required String password,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'name': name,
        'email': email,
        'mobile': mobile,
        'ccode': ccode,
        'created_at': FieldValue.serverTimestamp(),
        'status': 'active',
        'wallet_balance': 0,
        'membership_status': 'none',
      });

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Registration successful',
        'UserLogin': {
          'id': userCredential.user!.uid,
          'name': name,
          'email': email,
          'mobile': mobile,
          'ccode': ccode,
        }
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> loginUser({
    required String mobile,
    required String password,
    required String ccode,
  }) async {
    try {
      // For mobile login, we need to find user by mobile number first
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('mobile', isEqualTo: mobile)
          .where('ccode', isEqualTo: ccode)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        return {
          'ResponseCode': '400',
          'Result': 'false',
          'ResponseMsg': 'User not found',
        };
      }

      var userData = userQuery.docs.first.data() as Map<String, dynamic>;
      // Convert any Timestamp objects to strings to avoid JSON encoding issues
      userData = _convertTimestampsToStrings(userData);
      String email = userData['email'];

      // Sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Login successful',
        'UserLogin': {
          'id': userCredential.user!.uid,
          'name': userData['name'],
          'email': userData['email'],
          'mobile': userData['mobile'],
          'ccode': userData['ccode'],
        }
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': 'Invalid credentials',
      };
    }
  }

  static Future<Map<String, dynamic>> checkMobile({
    required String mobile,
    required String ccode,
  }) async {
    try {
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('mobile', isEqualTo: mobile)
          .where('ccode', isEqualTo: ccode)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        return {
          'ResponseCode': '400',
          'Result': 'false',
          'ResponseMsg': 'Mobile number already exists',
        };
      }

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Mobile number available',
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String mobile,
    required String ccode,
    required String newPassword,
  }) async {
    try {
      // Find user by mobile number
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('mobile', isEqualTo: mobile)
          .where('ccode', isEqualTo: ccode)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        return {
          'ResponseCode': '400',
          'Result': 'false',
          'ResponseMsg': 'User not found',
        };
      }

      var userData = userQuery.docs.first.data() as Map<String, dynamic>;
      // Convert any Timestamp objects to strings to avoid JSON encoding issues
      userData = _convertTimestampsToStrings(userData);
      String email = userData['email'];

      // Send password reset email
      await _auth.sendPasswordResetEmail(email: email);

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Password reset email sent',
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String uid,
    required String name,
    required String email,
    String? password,
  }) async {
    try {
      // Update Firestore document
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'email': email,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Update password if provided
      if (password != null && password.isNotEmpty) {
        await _auth.currentUser?.updatePassword(password);
      }

      // Get updated user data
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      var userData = userDoc.data() as Map<String, dynamic>;
      // Convert any Timestamp objects to strings to avoid JSON encoding issues
      userData = _convertTimestampsToStrings(userData);

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Profile updated successfully',
        'UserLogin': {
          'id': uid,
          'name': userData['name'],
          'email': userData['email'],
          'mobile': userData['mobile'],
          'ccode': userData['ccode'],
        }
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> deleteAccount({required String uid}) async {
    try {
      // Delete user document from Firestore
      await _firestore.collection('users').doc(uid).delete();
      
      // Delete user from Firebase Auth
      await _auth.currentUser?.delete();

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Account deleted successfully',
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Image upload method
  static Future<String?> uploadImage(File imageFile, String path) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('$path/$fileName');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Get user data from Firestore
  static Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;

        // Convert Firestore Timestamps to milliseconds for JSON compatibility
        if (data['created_at'] is Timestamp) {
          data['created_at'] = (data['created_at'] as Timestamp).millisecondsSinceEpoch;
        }
        if (data['updated_at'] is Timestamp) {
          data['updated_at'] = (data['updated_at'] as Timestamp).millisecondsSinceEpoch;
        }

        return data;
      }

      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Phone Authentication Methods
  static Future<Map<String, dynamic>> sendPhoneOTP({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(FirebaseAuthException error) verificationFailed,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          try {
            await _auth.signInWithCredential(credential);
          } catch (e) {
            print('Auto-verification failed: $e');
          }
        },
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Code auto-retrieval timeout: $verificationId');
        },
        timeout: const Duration(seconds: 60),
      );

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'OTP sent successfully',
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> verifyPhoneOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        return {
          'ResponseCode': '200',
          'Result': 'true',
          'ResponseMsg': 'Phone number verified successfully',
          'user': userCredential.user,
        };
      } else {
        return {
          'ResponseCode': '400',
          'Result': 'false',
          'ResponseMsg': 'Phone verification failed',
        };
      }
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Link phone number to existing email account
  static Future<Map<String, dynamic>> linkPhoneToAccount({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return {
          'ResponseCode': '400',
          'Result': 'false',
          'ResponseMsg': 'No user logged in',
        };
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await currentUser.linkWithCredential(credential);

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Phone number linked successfully',
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Register user with phone verification
  static Future<Map<String, dynamic>> registerUserWithPhone({
    required String name,
    required String email,
    required String mobile,
    required String ccode,
    required String password,
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      // First verify the phone number
      var phoneVerification = await verifyPhoneOTP(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      if (phoneVerification['Result'] != 'true') {
        return phoneVerification;
      }

      User? phoneUser = phoneVerification['user'];

      // Create email/password credential
      AuthCredential emailCredential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Link email/password to phone account
      UserCredential userCredential = await phoneUser!.linkWithCredential(emailCredential);

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'name': name,
        'email': email,
        'mobile': mobile,
        'ccode': ccode,
        'phone_verified': true,
        'email_verified': userCredential.user!.emailVerified,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'status': 'active',
        'wallet_balance': 0,
        'membership_status': 'none',
      });

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Registration successful',
        'UserLogin': {
          'id': userCredential.user!.uid,
          'name': name,
          'email': email,
          'mobile': mobile,
          'ccode': ccode,
          'phone_verified': true,
        }
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Helper method to convert Timestamp objects to strings
  static Map<String, dynamic> _convertTimestampsToStrings(Map<String, dynamic> data) {
    Map<String, dynamic> converted = {};

    data.forEach((key, value) {
      if (value is Timestamp) {
        converted[key] = value.toDate().toIso8601String();
      } else if (value is Map<String, dynamic>) {
        converted[key] = _convertTimestampsToStrings(value);
      } else if (value is List) {
        converted[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return _convertTimestampsToStrings(item);
          } else if (item is Timestamp) {
            return item.toDate().toIso8601String();
          }
          return item;
        }).toList();
      } else {
        converted[key] = value;
      }
    });

    return converted;
  }
}
