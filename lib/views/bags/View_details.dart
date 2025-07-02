// ignore_for_file: file_names, unnecessary_brace_in_string_interps, avoid_print, must_be_immutable

// import 'package:foodrescue_app/controllers/home_controller.dart';
import 'package:foodrescue_app/controllers/Discount_order_list_controller.dart';
import 'package:foodrescue_app/controllers/Membership_controller.dart';
import 'package:foodrescue_app/controllers/Table_status_wise_controller.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:foodrescue_app/Utils/String.dart';
import 'package:foodrescue_app/Utils/image.dart';
import 'package:flutter/material.dart';
import 'package:foodrescue_app/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/dark_light_mode.dart';

class ViewDetails extends StatefulWidget {
  String? discount;
  String? discountamt;
  ViewDetails({this.discount, this.discountamt, super.key});

  @override
  State<ViewDetails> createState() => _ViewDetailsState();
}

class _ViewDetailsState extends State<ViewDetails> {
  @override
  void initState() {
    getDarkMode();
    super.initState();
    discountorderlist.discountorderlist();
    bookingstatus.tableStatus(status: "Pending");
  }

  DiscountorderlistController discountorderlist =
      Get.put(DiscountorderlistController());
  HomeController homedata = Get.find<HomeController>();
  MembershipController membership = Get.put(MembershipController());
  TableStatusController bookingstatus = Get.put(TableStatusController());
  double discountamount = 0.0;
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
      backgroundColor: notifier.background,
      appBar: AppBar(
        elevation: 1,
        title: Text(
          provider.your.tr,
          style: TextStyle(
              fontSize: 17, color: notifier.textColor, fontFamily: "Gilroy Bold"),
        ),
        backgroundColor: notifier.background,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset(image.arrowleft, height: 10, color: notifier.textColor),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            SizedBox(height: Get.height * 0.03),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: notifier.background,
                  border: Border.all(color: notifier.containerColor)),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12)),
                        color: notifier.containerColor),
                    height: 70,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GetBuilder<DiscountorderlistController>(
                            builder: (context) {
                          discountamount = 0.0;
                          for (var i = 0;
                              i < discountorderlist.discountorder.length;
                              i++) {
                            discountamount = discountamount +
                                double.parse(discountorderlist.discountorder[i]
                                    ["discount_amt"]);
                          }
                          return Text(
                              "${homedata.homeDataList["currency"]}${double.parse(discountamount.toString()).toStringAsFixed(2)} saved with Dineout",
                              style: TextStyle(
                                  color: notifier.textColor,
                                  fontFamily: "Gilroy ExtraBold",
                                  fontSize: 20));
                        }),
                        Text(
                            "Using pro membership valid till ${membership.member["valid_till"]}".tr,
                            style: TextStyle(
                                color: notifier.textColor,
                                fontFamily: "Gilroy Medium",
                                fontSize: 14,
                                height: 1.2)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            width: Get.width * 0.6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    GetBuilder<DiscountorderlistController>(
                                        builder: (context) {
                                      return Text(
                                          '${homedata.homeDataList["currency"]}${double.parse(discountamount.toString()).toStringAsFixed(2)}',
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontFamily: "Gilroy ExtraBold",
                                              color: orangeColor,
                                              fontSize: 16));
                                    }),
                                    SizedBox(width: Get.width * 0.02),
                                    Text(provider.savedwi.tr,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: "Gilroy Bold",
                                            color: notifier.textColor))
                                  ],
                                ),
                                GetBuilder<DiscountorderlistController>(
                                    builder: (context) {
                                  print(
                                      "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${discountorderlist.discountorder.length}");
                                  return Text("on ${discountorderlist.discountorder.length} dineout orders",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: "Gilroy Medium",
                                          color: greycolor));
                                })
                              ],
                            )),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20, top: 10),
                          child: Image.asset(image.services, height: 50),
                        )
                      ],
                    ),
                  ),
                  dottedline(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                width: Get.width * 0.62,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        GetBuilder<TableStatusController>(
                                            builder: (context) {
                                          print(
                                              "@@@@@@@@@@@@@@@@@@@@@@@@${bookingstatus.tableStatusList.length}");
                                          return Text(
                                              '${bookingstatus.tableStatusList.length}',
                                              style: TextStyle(
                                                  fontFamily:
                                                      "Gilroy ExtraBold",
                                                  color: orangeColor,
                                                  fontSize: 16));
                                        }),
                                        SizedBox(width: Get.width * 0.02),
                                        Text("times used table booking".tr,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontFamily: "Gilroy Bold",
                                                color: notifier.textColor))
                                      ],
                                    ),
                                    Text("using pro membership".tr,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: "Gilroy Medium",
                                            color: greycolor))
                                  ],
                                )),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 20),
                          child: Image.asset(image.group, height: 65),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: Get.height * 0.03)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
