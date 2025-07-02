import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../Utils/Colors.dart';
import '../../Utils/dark_light_mode.dart';
import '../../controllers/payment_controller.dart';
import '../../config/app_config.dart';
import '../../services/stripe_service.dart';
import '../../services/paypal_service.dart';
import '../../services/razorpay_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentSelectionDialog extends StatefulWidget {
  final double amount;
  final String reservationId;
  final Map<String, dynamic> reservationData;
  final Function(String paymentMethod, String transactionId) onPaymentSuccess;

  const PaymentSelectionDialog({
    Key? key,
    required this.amount,
    required this.reservationId,
    required this.reservationData,
    required this.onPaymentSuccess,
  }) : super(key: key);

  @override
  _PaymentSelectionDialogState createState() => _PaymentSelectionDialogState();
}

class _PaymentSelectionDialogState extends State<PaymentSelectionDialog> {
  final PaymentController paymentController = Get.find<PaymentController>();
  String selectedPaymentMethod = '';
  bool isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    paymentController.getPaymentGateways();
  }

  void _processPayment(String paymentMethod) async {
    setState(() {
      isProcessingPayment = true;
      selectedPaymentMethod = paymentMethod;
    });

    try {
      String transactionId = '';
      bool paymentSuccess = false;

      switch (paymentMethod.toLowerCase()) {
        case 'wallet':
          paymentSuccess = await _processWalletPayment();
          transactionId = 'wallet_${DateTime.now().millisecondsSinceEpoch}';
          break;
        case 'stripe':
          paymentSuccess = await _processStripePayment();
          transactionId = 'stripe_${DateTime.now().millisecondsSinceEpoch}';
          break;
        case 'paypal':
          paymentSuccess = await _processPayPalPayment();
          transactionId = 'paypal_${DateTime.now().millisecondsSinceEpoch}';
          break;
        case 'razorpay':
          paymentSuccess = await _processRazorPayPayment();
          transactionId = 'razorpay_${DateTime.now().millisecondsSinceEpoch}';
          break;
        default:
          Get.snackbar("Error", "Payment method not supported");
          return;
      }

      if (paymentSuccess) {
        widget.onPaymentSuccess(paymentMethod, transactionId);
        Get.back(); // Close dialog
        Get.snackbar(
          "Payment Successful", 
          "Your reservation has been confirmed!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar("Payment Failed", "Please try again or use a different payment method");
      }
    } catch (e) {
      Get.snackbar("Error", "Payment processing failed: ${e.toString()}");
    } finally {
      setState(() {
        isProcessingPayment = false;
        selectedPaymentMethod = '';
      });
    }
  }

  Future<bool> _processWalletPayment() async {
    // Simulate wallet payment processing
    await Future.delayed(Duration(seconds: 2));
    
    // Check if user has sufficient wallet balance
    var result = await paymentController.getWalletReport();
    if (result['Result'] == 'true') {
      double walletBalance = (result['WalletData']['current_balance'] ?? 0.0).toDouble();
      if (walletBalance >= widget.amount) {
        // Deduct from wallet
        var deductResult = await paymentController.updateWallet(
          amount: widget.amount,
          type: 'debit',
          description: 'Surprise bag reservation payment',
        );
        return deductResult['Result'] == 'true';
      } else {
        Get.snackbar("Insufficient Balance", "Please add money to your wallet or use another payment method");
        return false;
      }
    }
    return false;
  }

  Future<bool> _processStripePayment() async {
    try {
      // Initialize Stripe if not already done
      await StripeService.init();

      // Get user info for billing details
      final user = FirebaseAuth.instance.currentUser;
      final billingDetails = {
        'email': user?.email ?? '',
        'name': user?.displayName ?? '',
      };

      // Process payment with Stripe
      final result = await StripeService.processPayment(
        amount: widget.amount,
        currency: 'USD',
        billingDetails: billingDetails,
        metadata: {
          'reservation_id': widget.reservationId,
          'app_name': 'Food Rescue App',
        },
      );

      if (result['success'] == true) {
        Get.snackbar(
          "Payment Successful",
          "Payment processed successfully via Stripe",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          "Payment Failed",
          result['error'] ?? "Stripe payment failed",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Payment Error",
        "Stripe payment error: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> _processPayPalPayment() async {
    try {
      // Get user info
      final user = FirebaseAuth.instance.currentUser;
      final userInfo = {
        'email': user?.email ?? '',
        'name': user?.displayName ?? '',
      };

      // Process payment with PayPal
      final result = await PayPalService.launchPayPalPayment(
        context: context,
        amount: widget.amount,
        currency: 'USD',
        description: 'Surprise Bag Payment - Food Rescue App',
        userInfo: userInfo,
      );

      if (result['success'] == true) {
        // Verify payment
        final verificationResult = await PayPalService.verifyPayment(
          result['transaction_id'],
        );

        if (verificationResult['success'] == true) {
          Get.snackbar(
            "Payment Successful",
            "Payment processed successfully via PayPal",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          return true;
        } else {
          Get.snackbar(
            "Payment Verification Failed",
            "PayPal payment could not be verified",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return false;
        }
      } else {
        Get.snackbar(
          "Payment Failed",
          result['error'] ?? "PayPal payment failed",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Payment Error",
        "PayPal payment error: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> _processRazorPayPayment() async {
    try {
      // Initialize RazorPay
      RazorPayService.init();

      // Get user info
      final user = FirebaseAuth.instance.currentUser;
      final userInfo = {
        'email': user?.email ?? '',
        'name': user?.displayName ?? '',
        'phone': user?.phoneNumber ?? '',
      };

      // Create a completer to handle async callback
      final completer = Completer<bool>();

      // Process payment with RazorPay
      final result = await RazorPayService.processPayment(
        amount: widget.amount,
        currency: 'INR', // RazorPay primarily works with INR
        description: 'Surprise Bag Payment - Food Rescue App',
        userInfo: userInfo,
        onSuccess: (paymentData) async {
          // Verify payment signature
          final verificationResult = await RazorPayService.verifyPayment(
            paymentId: paymentData['payment_id'],
            orderId: paymentData['order_id'],
            signature: paymentData['signature'],
          );

          if (verificationResult['success'] == true) {
            Get.snackbar(
              "Payment Successful",
              "Payment processed successfully via RazorPay",
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            completer.complete(true);
          } else {
            Get.snackbar(
              "Payment Verification Failed",
              "RazorPay payment could not be verified",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            completer.complete(false);
          }
        },
        onError: (error) {
          Get.snackbar(
            "Payment Failed",
            error,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          completer.complete(false);
        },
      );

      if (result['success'] == true && result['status'] == 'pending') {
        // Wait for callback result
        return await completer.future;
      } else {
        Get.snackbar(
          "Payment Failed",
          result['error'] ?? "RazorPay payment failed",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Payment Error",
        "RazorPay error: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Show card input dialog for Stripe
  Future<bool?> _showCardInputDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Enter Card Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Card Number",
                hintText: "1234 5678 9012 3456",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "MM/YY",
                      hintText: "12/25",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "CVV",
                      hintText: "123",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: "Cardholder Name",
                hintText: "John Doe",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: orangeColor),
            child: Text("Pay \$${widget.amount.toStringAsFixed(2)}", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Show PayPal login dialog
  Future<bool?> _showPayPalLoginDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payment, color: Colors.blue),
            SizedBox(width: 8),
            Text("PayPal Login"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You will be redirected to PayPal to complete your payment."),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "PayPal Email",
                hintText: "your@email.com",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text("Login & Pay", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Show RazorPay options dialog
  Future<bool?> _showRazorPayOptionsDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payments, color: Colors.indigo),
            SizedBox(width: 8),
            Text("RazorPay Payment"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Choose your payment method:"),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.credit_card),
              title: Text("Credit/Debit Card"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.of(context).pop(true),
            ),
            ListTile(
              leading: Icon(Icons.account_balance),
              title: Text("Net Banking"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.of(context).pop(true),
            ),
            ListTile(
              leading: Icon(Icons.phone_android),
              title: Text("UPI"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColorNotifier>(context);
    
    return Dialog(
      backgroundColor: notifier.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Payment Method",
                  style: TextStyle(
                    color: notifier.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: notifier.textColor),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Amount
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: orangeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount:",
                    style: TextStyle(
                      color: notifier.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "${AppConfig.currencySymbol}${widget.amount.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: orangeColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Payment Methods
            Text(
              "Choose Payment Method:",
              style: TextStyle(
                color: notifier.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            SizedBox(height: 12),
            
            // Payment options
            Obx(() {
              if (paymentController.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: orangeColor),
                );
              }
              
              return Column(
                children: [
                  // Wallet Payment
                  _buildPaymentOption(
                    'Wallet',
                    Icons.account_balance_wallet,
                    'wallet',
                    notifier,
                  ),
                  
                  // Stripe
                  _buildPaymentOption(
                    'Credit/Debit Card',
                    Icons.credit_card,
                    'stripe',
                    notifier,
                  ),
                  
                  // PayPal
                  _buildPaymentOption(
                    'PayPal',
                    Icons.payment,
                    'paypal',
                    notifier,
                  ),
                  
                  // RazorPay
                  _buildPaymentOption(
                    'RazorPay',
                    Icons.payments,
                    'razorpay',
                    notifier,
                  ),
                ],
              );
            }),
            
            SizedBox(height: 20),
            
            // Terms
            Text(
              "By proceeding, you agree to our terms and conditions.",
              style: TextStyle(
                color: notifier.textColor.withOpacity(0.6),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String title,
    IconData icon,
    String method,
    ColorNotifier notifier,
  ) {
    bool isSelected = selectedPaymentMethod == method;
    bool isLoading = isProcessingPayment && isSelected;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isProcessingPayment ? null : () => _processPayment(method),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? orangeColor : Colors.grey.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected ? orangeColor.withOpacity(0.1) : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? orangeColor : notifier.textColor,
                  size: 24,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? orangeColor : notifier.textColor,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: orangeColor,
                      strokeWidth: 2,
                    ),
                  )
                else if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: orangeColor,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
