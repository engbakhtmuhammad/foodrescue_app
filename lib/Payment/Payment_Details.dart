// ignore_for_file: sort_child_properties_last, file_names, non_constant_identifier_names, must_be_immutable, avoid_print, prefer_const_constructors, unnecessary_brace_in_string_interps, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'dart:io';

import 'package:foodrescue_app/Getx_Controller/Controller.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:foodrescue_app/Utils/dark_light_mode.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentDetails extends StatefulWidget {
  final double? bilamount;
  final double? tip;
  final String? address;
  final String? couponcode;
  final String? couponval;
  final String? ctype;
  final String? subtotal;
  final String? tax;
  final String? delivery;
  final String? discount;
  final String? wallet;
  final String? paymenttital;
  final String? totelbill;

  const PaymentDetails({
    super.key,
    this.bilamount,
    this.tip,
    this.address,
    this.couponcode,
    this.couponval,
    this.ctype,
    this.subtotal,
    this.tax,
    this.delivery,
    this.discount,
    this.wallet,
    this.paymenttital,
    this.totelbill,
  });

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  HomeController homedata = Get.put(HomeController());
  bool checkLogin = false;
  late ColorNotifier notifier;

  @override
  void initState() {
    super.initState();
    getDarkMode();
    checkLoginOrContinue();
  }

  getDarkMode() async {
    // Simplified dark mode handling
    notifier = Provider.of<ColorNotifier>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.background,
      appBar: AppBar(
        backgroundColor: notifier.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: notifier.textColor,
          ),
        ),
        title: Text(
          "Payment Details".tr,
          style: TextStyle(
            color: notifier.textColor,
            fontWeight: FontWeight.w400,
            fontSize: 18,
            fontFamily: 'Gilroy Medium',
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.payment,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(height: 20),
              Text(
                "Payment System Disabled".tr,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: notifier.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                "Payment functionality has been disabled in this Firebase-only version of the app. This is a demo version focused on restaurant browsing and Firebase authentication.".tr,
                style: TextStyle(
                  fontSize: 16,
                  color: notifier.textColor.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              AppButton(
                buttonColor: orangeColor,
                buttontext: "Go Back".tr,
                onTap: () {
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  checkLoginOrContinue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      checkLogin = prefs.getBool('Firstuser') ?? false;
    });
  }
}