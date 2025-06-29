import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../api/Data_save.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var currentUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      currentUser.value = user;
      isLoggedIn.value = user != null;
      
      if (user != null) {
        // User is signed in
        print('User signed in: ${user.uid}');
      } else {
        // User is signed out
        print('User signed out');
        // Clear stored user data
        getData.remove('UserLogin');
        getData.remove('Firstuser');
      }
    });
  }

  // Register user
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String mobile,
    required String ccode,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      
      var result = await FirebaseService.registerUser(
        name: name,
        email: email,
        mobile: mobile,
        ccode: ccode,
        password: password,
      );

      if (result['Result'] == 'true') {
        // Save user data locally
        save("UserLogin", result["UserLogin"]);
        save("Firstuser", true);
      }

      return result;
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }

  // Login user
  Future<Map<String, dynamic>> loginUser({
    required String mobile,
    required String password,
    required String ccode,
  }) async {
    try {
      isLoading.value = true;
      
      var result = await FirebaseService.loginUser(
        mobile: mobile,
        password: password,
        ccode: ccode,
      );

      if (result['Result'] == 'true') {
        // Save user data locally
        save("UserLogin", result["UserLogin"]);
        save("Firstuser", true);
      }

      return result;
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }

  // Check if mobile exists
  Future<Map<String, dynamic>> checkMobile({
    required String mobile,
    required String ccode,
  }) async {
    try {
      isLoading.value = true;
      
      return await FirebaseService.checkMobile(
        mobile: mobile,
        ccode: ccode,
      );
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword({
    required String mobile,
    required String ccode,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;
      
      return await FirebaseService.resetPassword(
        mobile: mobile,
        ccode: ccode,
        newPassword: newPassword,
      );
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? password,
  }) async {
    try {
      isLoading.value = true;
      
      String uid = currentUser.value?.uid ?? getData.read("UserLogin")["id"];
      
      var result = await FirebaseService.updateProfile(
        uid: uid,
        name: name,
        email: email,
        password: password,
      );

      if (result['Result'] == 'true') {
        // Update local user data
        save("UserLogin", result["UserLogin"]);
      }

      return result;
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }

  // Delete account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      isLoading.value = true;
      
      String uid = currentUser.value?.uid ?? getData.read("UserLogin")["id"];
      
      var result = await FirebaseService.deleteAccount(uid: uid);

      if (result['Result'] == 'true') {
        // Clear local data
        getData.remove('Firstuser');
        getData.remove('Remember');
        getData.remove("UserLogin");
      }

      return result;
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await FirebaseService.signOut();
      // Clear local data
      getData.remove('UserLogin');
      getData.remove('Firstuser');
      getData.remove('Remember');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Get current user data
  Map<String, dynamic>? getCurrentUserData() {
    return getData.read("UserLogin");
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return currentUser.value != null && getData.read("UserLogin") != null;
  }

  // Get user ID
  String? getUserId() {
    return currentUser.value?.uid ?? getData.read("UserLogin")?["id"];
  }

  // Phone verification variables
  var verificationId = ''.obs;
  var resendToken = Rxn<int>();

  // Send phone OTP
  Future<Map<String, dynamic>> sendPhoneOTP({
    required String phoneNumber,
  }) async {
    try {
      isLoading.value = true;

      var result = await FirebaseService.sendPhoneOTP(
        phoneNumber: phoneNumber,
        codeSent: (String vId, int? rToken) {
          verificationId.value = vId;
          resendToken.value = rToken;
          print('Code sent to $phoneNumber');
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
          FirebaseService.showToastMessage('Verification failed: ${e.message}');
        },
      );

      return result;
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }

  // Verify phone OTP
  Future<Map<String, dynamic>> verifyPhoneOTP({
    required String smsCode,
  }) async {
    try {
      isLoading.value = true;

      if (verificationId.value.isEmpty) {
        return {
          'ResponseCode': '400',
          'Result': 'false',
          'ResponseMsg': 'No verification ID found. Please request OTP again.',
        };
      }

      var result = await FirebaseService.verifyPhoneOTP(
        verificationId: verificationId.value,
        smsCode: smsCode,
      );

      return result;
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }

  // Register user with phone verification
  Future<Map<String, dynamic>> registerUserWithPhone({
    required String name,
    required String email,
    required String mobile,
    required String ccode,
    required String password,
    required String smsCode,
  }) async {
    try {
      isLoading.value = true;

      if (verificationId.value.isEmpty) {
        return {
          'ResponseCode': '400',
          'Result': 'false',
          'ResponseMsg': 'No verification ID found. Please request OTP again.',
        };
      }

      var result = await FirebaseService.registerUserWithPhone(
        name: name,
        email: email,
        mobile: mobile,
        ccode: ccode,
        password: password,
        verificationId: verificationId.value,
        smsCode: smsCode,
      );

      if (result['Result'] == 'true') {
        // Save user data locally
        save("UserLogin", result["UserLogin"]);
        save("Firstuser", true);
      }

      return result;
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }

  // Login with email and password
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Get user data from Firestore
        var userDoc = await FirebaseService.getUserData(userCredential.user!.uid);

        if (userDoc != null) {
          save("UserLogin", userDoc);
          save("Firstuser", true);

          return {
            'ResponseCode': '200',
            'Result': 'true',
            'ResponseMsg': 'Login successful',
            'UserLogin': userDoc,
          };
        }
      }

      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': 'Login failed',
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }

  // Check if user has valid session
  bool hasValidSession() {
    var userData = getData.read("UserLogin");
    return userData != null && currentUser.value != null;
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    if (currentUser.value != null) {
      try {
        await currentUser.value!.reload();
        currentUser.value = _auth.currentUser;
      } catch (e) {
        print('Error refreshing user data: $e');
      }
    }
  }
}
