import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../Utils/Colors.dart';
import '../Utils/dark_light_mode.dart';
import '../controllers/payment_controller.dart';
import '../config/app_config.dart';

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
    // Simulate Stripe payment processing
    await Future.delayed(Duration(seconds: 3));
    // In a real app, you would integrate with Stripe SDK
    return true; // Simulate success
  }

  Future<bool> _processPayPalPayment() async {
    // Simulate PayPal payment processing
    await Future.delayed(Duration(seconds: 3));
    // In a real app, you would integrate with PayPal SDK
    return true; // Simulate success
  }

  Future<bool> _processRazorPayPayment() async {
    // Simulate RazorPay payment processing
    await Future.delayed(Duration(seconds: 3));
    // In a real app, you would integrate with RazorPay SDK
    return true; // Simulate success
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
