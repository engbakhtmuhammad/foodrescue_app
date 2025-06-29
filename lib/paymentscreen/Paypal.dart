// ignore_for_file: avoid_print, prefer_const_literals_to_create_immutables, must_be_immutable, file_names

import 'package:foodrescue_app/Getx_Controller/Discount_order_controller.dart';
import 'package:foodrescue_app/Payment/Bill_paid.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:get/get.dart';

class PayPalPayment extends StatefulWidget {
  String? title;
  String? bilamount;
  String? tip;
  String? restid;
  String? hotelname;
  String? address;
  String? discountamt;
  String? payedamt;
  String? walletamt;
  String? selectidPay;
  String? transactionid;
  String? discountvalue;
  String? tipamt;
  String? totelbill;
  // ignore: use_super_parameters
  PayPalPayment(
      {this.title,
      this.bilamount,
      this.tip,
      this.restid,
      this.hotelname,
      this.address,
      this.discountamt,
      this.payedamt,
      this.walletamt,
      this.selectidPay,
      this.transactionid,
      this.discountvalue,
      this.tipamt,
      this.totelbill,
      Key? key})
      : super(key: key);

  @override
  State<PayPalPayment> createState() => _PayPalPaymentState();
}

class _PayPalPaymentState extends State<PayPalPayment> {
  DiscountorderController discountorder = Get.put(DiscountorderController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: TextButton(
          onPressed: () => {
                // PayPal payment is currently disabled
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("PayPal payment is currently disabled"))
                )
              },
          child: const Text("Make Payment")),
    ));
  }
}
