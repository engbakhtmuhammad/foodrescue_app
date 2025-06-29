import 'package:get/get.dart';
import '../services/payment_service.dart';
import '../services/firebase_service.dart';
import '../api/Data_save.dart';

class PaymentGatewayController extends GetxController {
  var paymentGateways = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Get payment gateways
  Future<void> getPaymentGateways() async {
    try {
      isLoading.value = true;
      
      var result = await PaymentService.getPaymentGateways();

      if (result['Result'] == 'true') {
        paymentGateways.value = List<Map<String, dynamic>>.from(
          result['paymentdata'] ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in getPaymentGateways: $e");
      FirebaseService.showToastMessage("Error loading payment gateways");
    } finally {
      isLoading.value = false;
    }
  }
}

class MembershipController extends GetxController {
  var membershipPlans = <Map<String, dynamic>>[].obs;
  var membershipData = Rxn<Map<String, dynamic>>();
  var isLoading = false.obs;

  // Get membership plans
  Future<void> getMembershipPlans() async {
    try {
      isLoading.value = true;
      
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await PaymentService.getMembershipPlans(uid: uid);

      if (result['Result'] == 'true') {
        membershipPlans.value = List<Map<String, dynamic>>.from(
          result['PlanData'] ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in getMembershipPlans: $e");
      FirebaseService.showToastMessage("Error loading membership plans");
    } finally {
      isLoading.value = false;
    }
  }

  // Get membership data
  Future<void> getMembershipData() async {
    try {
      isLoading.value = true;
      
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await PaymentService.getMembershipData(uid: uid);

      if (result['Result'] == 'true') {
        membershipData.value = result['MembershipData'];
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in getMembershipData: $e");
      FirebaseService.showToastMessage("Error loading membership data");
    } finally {
      isLoading.value = false;
    }
  }

  // Purchase plan
  Future<void> purchasePlan({
    required String planId,
    required String paymentMethod,
    required String transactionId,
    required double amount,
  }) async {
    try {
      isLoading.value = true;
      
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await PaymentService.purchasePlan(
        uid: uid,
        planId: planId,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
        amount: amount,
      );

      if (result['Result'] == 'true') {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
        // Refresh membership data
        await getMembershipData();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in purchasePlan: $e");
      FirebaseService.showToastMessage("Error purchasing plan");
    } finally {
      isLoading.value = false;
    }
  }
}

class WalletController extends GetxController {
  var walletData = Rxn<Map<String, dynamic>>();
  var walletTransactions = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Get wallet report
  Future<void> getWalletReport() async {
    try {
      isLoading.value = true;
      
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await PaymentService.getWalletReport(uid: uid);

      if (result['Result'] == 'true') {
        walletData.value = result['WalletData'];
        walletTransactions.value = List<Map<String, dynamic>>.from(
          result['WalletData']['transactions'] ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in getWalletReport: $e");
      FirebaseService.showToastMessage("Error loading wallet report");
    } finally {
      isLoading.value = false;
    }
  }

  // Update wallet
  Future<void> updateWallet({
    required double amount,
    required String type,
    required String description,
    String? transactionId,
  }) async {
    try {
      isLoading.value = true;
      
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await PaymentService.updateWallet(
        uid: uid,
        amount: amount,
        type: type,
        description: description,
        transactionId: transactionId,
      );

      if (result['Result'] == 'true') {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
        // Refresh wallet data
        await getWalletReport();
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in updateWallet: $e");
      FirebaseService.showToastMessage("Error updating wallet");
    } finally {
      isLoading.value = false;
    }
  }
}

class DiscountOrderController extends GetxController {
  var discountOrders = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Get discount orders
  Future<void> getDiscountOrders() async {
    try {
      isLoading.value = true;
      
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await PaymentService.getDiscountOrders(uid: uid);

      if (result['Result'] == 'true') {
        discountOrders.value = List<Map<String, dynamic>>.from(
          result['DiscountOrders'] ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in getDiscountOrders: $e");
      FirebaseService.showToastMessage("Error loading discount orders");
    } finally {
      isLoading.value = false;
    }
  }
}

class PlanPurchaseController extends GetxController {
  var purchaseHistory = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Get plan purchase history
  Future<void> getPlanPurchaseHistory() async {
    try {
      isLoading.value = true;
      
      var userData = getData.read("UserLogin");
      if (userData == null) {
        FirebaseService.showToastMessage("Please login first");
        return;
      }

      String uid = userData["id"];

      var result = await PaymentService.getMembershipData(uid: uid);

      if (result['Result'] == 'true') {
        purchaseHistory.value = List<Map<String, dynamic>>.from(
          result['MembershipData']['purchase_history'] ?? []
        );
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in getPlanPurchaseHistory: $e");
      FirebaseService.showToastMessage("Error loading purchase history");
    } finally {
      isLoading.value = false;
    }
  }
}
