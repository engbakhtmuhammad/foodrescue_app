// ignore_for_file: non_constant_identifier_names, file_names
// ignore_for_file: camel_case_types, use_key_in_widget_constructors, annotate_overrides, prefer_const_literals_to_create_immutables, unused_field, unused_element, avoid_unnecessary_containers,  unused_import, deprecated_member_use

import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/dark_light_mode.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {

  @override
  void initState() {
    getDarkMode();
    super.initState();
  }
  late ColorNotifier notifier;
  getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setIsDark");
    if (previousState == null) {
      notifier.setIsDark = false;
    } else {
      notifier.setIsDark = previousState;
    }
  }
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.textColor,
      appBar: AppBar(
        backgroundColor: notifier.textColor,
        elevation: 0.2,
        leading: Transform.translate(
          offset: const Offset(-2, 0),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Image.asset("assets/arrowleft.png",
                    height: 20, color: notifier.background)),
          ),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "order".toUpperCase().tr,
                  style: TextStyle(
                      fontFamily: "Gilroy Bold",
                      color: notifier.background,
                      fontSize: 16),
                ),
                Text(
                  "#1325939904415".toUpperCase().tr,
                  style: TextStyle(
                      fontFamily: "Gilroy Bold",
                      color: notifier.background,
                      fontSize: 16),
                ),
              ],
            ),
            Text("₹2254.5".tr,
                style: TextStyle(
                    fontFamily: "Gilroy Medium",
                    color: greycolor,
                    fontSize: 16)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset("assets/pin.png", height: 30),
                  SizedBox(width: Get.width * 0.025),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Royal Dine Restaurant".tr,
                        style: TextStyle(
                            fontFamily: "Gilroy Bold",
                            color: notifier.background,
                            fontSize: 16),
                      ),
                      Text(
                        "Adajan Gam".tr,
                        style: TextStyle(
                            fontFamily: "Gilroy Medium",
                            color: greycolor,
                            fontSize: 16),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: Get.height * 0.05),
              Text(
                "details".toUpperCase().tr,
                style: TextStyle(
                    fontFamily: "Gilroy Bold", color: notifier.background, fontSize: 16),
              ),
              SizedBox(height: Get.height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Bill Total".tr,
                    style: TextStyle(
                        fontFamily: "Gilroy Medium",
                        color: greycolor,
                        fontSize: 16),
                  ),
                  Text(
                    "₹2505".tr,
                    style: TextStyle(
                        fontFamily: "Gilroy Medium",
                        color: greycolor,
                        fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: Get.height * 0.015),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "10% Today's discount".tr,
                    style: TextStyle(
                        fontFamily: "Gilroy Medium",
                        color: greentext,
                        fontSize: 16),
                  ),
                  Text(
                    "-₹250.5".tr,
                    style: TextStyle(
                        fontFamily: "Gilroy Medium",
                        color: greentext,
                        fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: Get.height * 0.015),
              dottedline(),
              SizedBox(height: Get.height * 0.015),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Paid".tr,
                    style: TextStyle(
                        fontFamily: "Gilroy Medium",
                        color: greycolor,
                        fontSize: 16),
                  ),
                  Row(
                    children: [
                      Text(
                        "Total".tr,
                        style: TextStyle(
                            fontFamily: "Gilroy Bold",
                            color: notifier.background,
                            fontSize: 18),
                      ),
                      SizedBox(width: Get.width * 0.1),
                      Text(
                        "₹2254.5".tr,
                        style: TextStyle(
                            fontFamily: "Gilroy Bold",
                            color: notifier.background,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: Get.height * 0.02),
              DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: Container(
                    width: double.infinity,
                    color: greenColor.withOpacity(0.12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: Center(
                      child: Text(
                        "You've saved ₹250.5 on this visit".tr,
                        style: TextStyle(
                            fontFamily: "Gilroy Medium",
                            color: greentext,
                            fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: Get.height * 0.035),
              Text(
                "help with this order".toUpperCase().tr,
                style: TextStyle(
                    fontFamily: "Gilroy Medium",
                    color: notifier.background,
                    fontSize: 16),
              ),
              SizedBox(height: Get.height * 0.035),
              Help(text: "Restaurant has denied to accept payment via swiggy".tr),
              SizedBox(height: Get.height * 0.005),
              Divider(color: greycolor),
              SizedBox(height: Get.height * 0.005),
              Help(text: "My transaction has failed multipal times".tr),
              SizedBox(height: Get.height * 0.005),
              Divider(color: greycolor),
              SizedBox(height: Get.height * 0.005),
              Help(text: "I paid the bill amount twice".tr),
              SizedBox(height: Get.height * 0.005),
              Divider(color: greycolor),
              SizedBox(height: Get.height * 0.005),
              Help(text: "I paid the bill to the wrong restaurant".tr),
              SizedBox(height: Get.height * 0.005),
              Divider(color: greycolor),
              SizedBox(height: Get.height * 0.005),
              Help(text: "I paid more then the bill".tr),
              SizedBox(height: Get.height * 0.005),
              Divider(color: greycolor),
              SizedBox(height: Get.height * 0.005),
              Help(text: "need a copy of the bill".tr),
            ],
          ),
        ),
      ),
    );
  }

  Help({String? text}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: Get.width * 0.85,
          child: Text(
            text!,
            style: TextStyle(
                fontFamily: "Gilroy Medium", color: notifier.background, fontSize: 15),
          ),
        ),
        Icon(Icons.keyboard_arrow_down, size: 27, color: greycolor)
      ],
    );
  }
}
