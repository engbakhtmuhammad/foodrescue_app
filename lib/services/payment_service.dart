import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get payment gateways
  static Future<Map<String, dynamic>> getPaymentGateways() async {
    try {
      QuerySnapshot paymentSnapshot = await _firestore
          .collection('payment_gateways')
          .where('status', isEqualTo: 'active')
          .orderBy('order')
          .get();

      List<Map<String, dynamic>> paymentData = paymentSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Payment gateways retrieved successfully',
        'paymentdata': paymentData,
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Get membership plans
  static Future<Map<String, dynamic>> getMembershipPlans({
    required String uid,
  }) async {
    try {
      QuerySnapshot plansSnapshot = await _firestore
          .collection('membership_plans')
          .where('status', isEqualTo: 'active')
          .orderBy('price')
          .get();

      List<Map<String, dynamic>> planData = plansSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Membership plans retrieved successfully',
        'PlanData': planData,
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Purchase membership plan
  static Future<Map<String, dynamic>> purchasePlan({
    required String uid,
    required String planId,
    required String paymentMethod,
    required String transactionId,
    required double amount,
  }) async {
    try {
      // Get plan details
      DocumentSnapshot planDoc = await _firestore
          .collection('membership_plans')
          .doc(planId)
          .get();

      if (!planDoc.exists) {
        return {
          'ResponseCode': '400',
          'Result': 'false',
          'ResponseMsg': 'Plan not found',
        };
      }

      var planData = planDoc.data() as Map<String, dynamic>;

      // Create purchase record
      DocumentReference purchaseRef = await _firestore.collection('plan_purchases').add({
        'user_id': uid,
        'plan_id': planId,
        'plan_name': planData['name'],
        'plan_duration': planData['duration_days'],
        'amount': amount,
        'payment_method': paymentMethod,
        'transaction_id': transactionId,
        'status': 'completed',
        'purchase_date': FieldValue.serverTimestamp(),
        'expiry_date': Timestamp.fromDate(
          DateTime.now().add(Duration(days: planData['duration_days'])),
        ),
      });

      // Update user's membership status
      await _firestore.collection('users').doc(uid).update({
        'membership_status': planData['name'],
        'membership_expiry': Timestamp.fromDate(
          DateTime.now().add(Duration(days: planData['duration_days'])),
        ),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Plan purchased successfully',
        'purchase_id': purchaseRef.id,
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Get user's membership data
  static Future<Map<String, dynamic>> getMembershipData({
    required String uid,
  }) async {
    try {
      // Get user's current membership
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        return {
          'ResponseCode': '400',
          'Result': 'false',
          'ResponseMsg': 'User not found',
        };
      }

      var userData = userDoc.data() as Map<String, dynamic>;

      // Get purchase history
      QuerySnapshot purchasesSnapshot = await _firestore
          .collection('plan_purchases')
          .where('user_id', isEqualTo: uid)
          .orderBy('purchase_date', descending: true)
          .get();

      List<Map<String, dynamic>> purchaseHistory = purchasesSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Membership data retrieved successfully',
        'MembershipData': {
          'current_plan': userData['membership_status'] ?? 'none',
          'expiry_date': userData['membership_expiry'],
          'purchase_history': purchaseHistory,
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

  // Get wallet report
  static Future<Map<String, dynamic>> getWalletReport({
    required String uid,
  }) async {
    try {
      // Get wallet transactions
      QuerySnapshot transactionsSnapshot = await _firestore
          .collection('wallet_transactions')
          .where('user_id', isEqualTo: uid)
          .orderBy('created_at', descending: true)
          .get();

      List<Map<String, dynamic>> transactions = transactionsSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();

      // Get current wallet balance
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      double currentBalance = 0.0;
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        currentBalance = (userData['wallet_balance'] ?? 0).toDouble();
      }

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Wallet report retrieved successfully',
        'WalletData': {
          'current_balance': currentBalance,
          'transactions': transactions,
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

  // Update wallet balance
  static Future<Map<String, dynamic>> updateWallet({
    required String uid,
    required double amount,
    required String type, // 'credit' or 'debit'
    required String description,
    String? transactionId,
  }) async {
    try {
      // Get current balance
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        return {
          'ResponseCode': '400',
          'Result': 'false',
          'ResponseMsg': 'User not found',
        };
      }

      var userData = userDoc.data() as Map<String, dynamic>;
      double currentBalance = (userData['wallet_balance'] ?? 0).toDouble();

      double newBalance;
      if (type == 'credit') {
        newBalance = currentBalance + amount;
      } else {
        newBalance = currentBalance - amount;
        if (newBalance < 0) {
          return {
            'ResponseCode': '400',
            'Result': 'false',
            'ResponseMsg': 'Insufficient wallet balance',
          };
        }
      }

      // Update user's wallet balance
      await _firestore.collection('users').doc(uid).update({
        'wallet_balance': newBalance,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Create transaction record
      await _firestore.collection('wallet_transactions').add({
        'user_id': uid,
        'amount': amount,
        'type': type,
        'description': description,
        'transaction_id': transactionId,
        'balance_before': currentBalance,
        'balance_after': newBalance,
        'created_at': FieldValue.serverTimestamp(),
      });

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Wallet updated successfully',
        'new_balance': newBalance,
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Get discount orders
  static Future<Map<String, dynamic>> getDiscountOrders({
    required String uid,
  }) async {
    try {
      QuerySnapshot ordersSnapshot = await _firestore
          .collection('discount_orders')
          .where('user_id', isEqualTo: uid)
          .orderBy('created_at', descending: true)
          .get();

      List<Map<String, dynamic>> discountOrders = [];

      for (var doc in ordersSnapshot.docs) {
        var orderData = doc.data() as Map<String, dynamic>;
        
        // Get restaurant details
        DocumentSnapshot restaurantDoc = await _firestore
            .collection('restaurants')
            .doc(orderData['restaurant_id'])
            .get();

        var restaurantData = restaurantDoc.exists 
            ? restaurantDoc.data() as Map<String, dynamic>
            : {};

        discountOrders.add({
          'id': doc.id,
          ...orderData,
          'restaurant_name': restaurantData['title'] ?? 'Unknown Restaurant',
          'restaurant_image': restaurantData['img'] != null && 
                             (restaurantData['img'] as List).isNotEmpty
              ? restaurantData['img'][0]
              : '',
        });
      }

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Discount orders retrieved successfully',
        'DiscountOrders': discountOrders,
      };
    } catch (e) {
      return {
        'ResponseCode': '400',
        'Result': 'false',
        'ResponseMsg': e.toString(),
      };
    }
  }

  // Get referral data
  static Future<Map<String, dynamic>> getReferralData({
    required String uid,
  }) async {
    try {
      // Get user's referral code
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        return {
          'ResponseCode': '400',
          'Result': 'false',
          'ResponseMsg': 'User not found',
        };
      }

      var userData = userDoc.data() as Map<String, dynamic>;
      String referralCode = userData['referral_code'] ?? uid.substring(0, 8).toUpperCase();

      // Get referrals made by this user
      QuerySnapshot referralsSnapshot = await _firestore
          .collection('referrals')
          .where('referrer_id', isEqualTo: uid)
          .get();

      List<Map<String, dynamic>> referrals = referralsSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();

      return {
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Referral data retrieved successfully',
        'ReferralData': {
          'referral_code': referralCode,
          'total_referrals': referrals.length,
          'referrals': referrals,
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
}
