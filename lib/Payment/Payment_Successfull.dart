// ignore_for_file: file_names, non_constant_identifier_names, must_be_immutable, avoid_print
// ignore_for_file: camel_case_types, use_key_in_widget_constructors, annotate_overrides, prefer_const_literals_to_create_immutables, unused_field, unused_element, avoid_unnecessary_containers,  unused_import, deprecated_member_use

import 'package:foodrescue_app/Getx_Controller/Hotel_details_Controller.dart';
import 'package:foodrescue_app/Profile/FAQ.dart';
import 'package:foodrescue_app/Profile/Profile.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/dark_light_mode.dart';

class PaymentSuccessfull extends StatefulWidget {
  String? day;
  String? people;
  String? time;
  String? hotelname;
  String? hoteladdress;

  // String? bookingdate;
  PaymentSuccessfull(
      {this.day,
      this.people,
      this.time,
      this.hotelname,
      this.hoteladdress,
      super.key});

  @override
  State<PaymentSuccessfull> createState() => _PaymentSuccessfullState();
}

class _PaymentSuccessfullState extends State<PaymentSuccessfull> {
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
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: InkWell(
            onTap: () {
              Get.to(() => const faqsandhelp());
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Need help with this order?",
                    style: TextStyle(
                        fontFamily: "Gilroy Medium",
                        color: greycolor,
                        fontSize: 14)),
                SizedBox(width: Get.width * 0.01),
                Text("view help".toUpperCase(),
                    style: TextStyle(
                        fontFamily: "Gilroy Medium",
                        color: orangeColor,
                        fontSize: 14))
              ],
            ),
          )),
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: GetBuilder<HoteldetailController>(
            builder: (context) {
              return appbar(
                  background: notifier.background,
                  color: notifier.textColor,
                  titletext: "Bill paid at",
                  centertext: "${widget.hotelname}",
                  subtitletext: "${widget.hoteladdress}");
            },
          )),
      backgroundColor: notifier.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Stack(children: [
                Positioned(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    margin: const EdgeInsets.only(top: 30),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.centerLeft,
                            stops: const [
                              0.2,
                              0.4,
                              2
                            ],
                            colors: [
                              green.withOpacity(0.06),
                              green.withOpacity(0.06),
                              green.withOpacity(0.15),
                            ]),
                        border: Border.all(color: green.withOpacity(0.08)),
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        SizedBox(height: Get.height * 0.03),
                        SizedBox(
                          width: Get.width * 0.65,
                          child: Text("You have a booked a table !",
                              style: TextStyle(
                                  fontFamily: "Gilroy ExtraBold",
                                  fontSize: 25,
                                  color: notifier.textColor),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                    top: 10,
                    left: Get.width * 0.4,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: green.withOpacity(0.8),
                          border: Border.all(color: green, width: 2)),
                      child: Icon(Icons.check, size: 28, color: greenColor),
                    )),
              ]),
              SizedBox(height: Get.height * 0.025),
              Row(
                children: [
                  Text("Booking id".toUpperCase(),
                      style: TextStyle(
                          fontFamily: "Gilroy Medium",
                          fontSize: 16,
                          color: notifier.textColor)),
                  SizedBox(width: Get.width * 0.03),
                  Text("#1325939904415".toUpperCase(),
                      style: TextStyle(
                          fontFamily: "Gilroy Medium",
                          fontSize: 16,
                          color: notifier.textColor)),
                ],
              ),
              Stack(
                children: [
                  Container(
                    height: 165,
                    width: double.infinity,
                    color: transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: notifier.containerColor),
                      child: Column(
                        children: [
                          billdetails(
                              titletext: "Day",
                              subtitletext: "${widget.day}",
                              fontsize: 16,
                              fontFamily: "Gilroy Medium"),
                          SizedBox(height: Get.height * 0.01),
                          billdetails(
                              titletext: "People",
                              subtitletext: "${widget.people}",
                              fontsize: 16,
                              DiscountText: "",
                              fontFamily: "Gilroy Medium"),
                          SizedBox(height: Get.height * 0.01),
                          billdetails(
                              titletext: "Time",
                              subtitletext: "${widget.time}",
                              fontsize: 16,
                              fontFamily: "Gilroy Medium"),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      left: Get.width * 0.29,
                      child: InkWell(
                        onTap: () {
                          setState(() {});
                          print("############################${widget.time}");
                          Get.to(() => Profile(
                              people: widget.people,
                              bookingdate: widget.day,
                              time: widget.time));
                        },
                        child: Container(
                          height: 50,
                          width: Get.width * 0.35,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: green),
                          child: Center(
                              child: Text("Done",
                                  style: TextStyle(
                                      fontFamily: "Gilroy Bold",
                                      color: notifier.textColor,
                                      fontSize: 17))),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  billdetails(
      {String? titletext,
      subtitletext,
      fontFamily,
      DiscountText,
      double? fontsize}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            RichText(
              text: TextSpan(
                text: titletext,
                style: TextStyle(
                    fontFamily: fontFamily,
                    color: notifier.textColor,
                    fontSize: fontsize),
                children: <TextSpan>[
                  TextSpan(
                      text: DiscountText,
                      style: TextStyle(
                          fontFamily: "Gilroy Medium",
                          fontSize: 16,
                          color: notifier.textColor)),
                ],
              ),
            ),
          ],
        ),
        Text(subtitletext,
            style: TextStyle(
                fontFamily: "Gilroy Medium",
                fontSize: 16,
                color: notifier.textColor)),
      ],
    );
  }
}
