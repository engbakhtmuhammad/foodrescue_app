// ignore_for_file: file_names, non_constant_identifier_names, must_be_immutable, sort_child_properties_last, deprecated_member_use

import 'package:foodrescue_app/controllers/Controller.dart';
import 'package:foodrescue_app/views/Profile/FAQ.dart';
import 'package:foodrescue_app/views/Profile/Profile.dart';
import 'package:foodrescue_app/Utils/Bottom_bar.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/dark_light_mode.dart';

class BillPaid extends StatefulWidget {
  String? discountvalue;
  String? tipamt;
  String? totelbill;
  String? discountamt;
  String? payedamt;
  String? restid;
  String? walletamt;
  String? hotelname;
  String? address;
  String? selectidPay;
  String? transactionid;
  BillPaid(
      {super.key,
      this.restid,
      this.hotelname,
      this.address,
      this.discountvalue,
      this.tipamt,
      this.totelbill,
      this.discountamt,
      this.payedamt,
      this.walletamt,
      this.selectidPay,
      this.transactionid});

  @override
  State<BillPaid> createState() => _BillPaidState();
}

class _BillPaidState extends State<BillPaid> {

  @override
  void initState() {
    getDarkMode();
    super.initState();
  }
  HomeController homedata = Get.put(HomeController());
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
    return WillPopScope(
      onWillPop: () {
        Get.to(() => BottomBar());
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: notifier.background,
        bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: InkWell(
              onTap: () {
                Get.to(() => const faqsandhelp());
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Need help with this order?".tr,
                      style: TextStyle(
                          fontFamily: "Gilroy Medium",
                          color: greycolor,
                          fontSize: 14)),
                  SizedBox(width: Get.width * 0.01),
                  Text("view help".toUpperCase().tr,
                      style: TextStyle(
                          fontFamily: "Gilroy Medium",
                          color: orangeColor,
                          fontSize: 14))
                ],
              ),
            )),
        appBar: PreferredSize(
            child: appbar(
              background: notifier.background,
                color: notifier.textColor,
                titletext: "Bill paid at".tr,
                centertext: widget.hotelname,
                subtitletext: widget.address),
            preferredSize: const Size.fromHeight(65)),
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
                      // height: Get.height * 0.3,
                      child: Column(
                        children: [
                          SizedBox(height: Get.height * 0.02),
                          Text(
                              "${homedata.homeDataList["currency"]}${widget.payedamt}",
                              style: TextStyle(
                                  fontFamily: "Gilroy ExtraBold",
                                  fontSize: 64,
                                  color: notifier.textColor),
                              textAlign: TextAlign.center),
                          Text("Paid by you".tr,
                              style: TextStyle(
                                  fontFamily: "Gilroy ExtraBold",
                                  fontSize: 24,
                                  color: notifier.textColor),
                              textAlign: TextAlign.center),
                          SizedBox(height: Get.height * 0.02),
                          Text(
                              "${homedata.homeDataList["currency"]}${widget.totelbill} bill cleared",
                              style: TextStyle(
                                  fontFamily: "Gilroy ExtraBold",
                                  fontSize: 20,
                                  color: green),
                              textAlign: TextAlign.center),
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
                SizedBox(height: Get.height * 0.03),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          stops: const [
                            0.15,
                            0.25,
                            2
                          ],
                          colors: [
                            orangeColor.withOpacity(0.1),
                            Colors.red.withOpacity(0.1),
                            Red.withOpacity(0.08),
                          ]),
                      border: Border.all(color: boxcolor),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Gold'.tr,
                              style: TextStyle(
                                  fontFamily: "Gilroy ExtraBold",
                                  color: goldColor,
                                  fontSize: 18),
                              children: <TextSpan>[
                                TextSpan(
                                    text: ' Benefits applied',
                                    style: TextStyle(
                                        fontFamily: "Gilroy Medium",
                                        fontSize: 16,
                                        color: orangeColor)),
                              ],
                            ),
                          ),
                          SizedBox(height: Get.height * 0.01),
                          Row(children: [
                            Text(
                                "${homedata.homeDataList["currency"]}${widget.discountamt}", //mere angne me tumhara kya kam hai
                                style: TextStyle(
                                    fontFamily: "Gilroy ExtraBold",
                                    color: notifier.textColor,
                                    fontSize: 18)),
                            SizedBox(width: Get.width * 0.02),
                            Text("saved on this bill!".tr,
                                style: TextStyle(
                                    fontFamily: "Gilroy Medium",
                                    color: notifier.textColor,
                                    fontSize: 16)),
                            Icon(Icons.keyboard_arrow_right,
                                size: 28, color: notifier.textColor)
                          ]),
                        ],
                      ),
                      Image.asset("assets/emoji.png", height: 60)
                    ],
                  ),
                ),
                SizedBox(height: Get.height * 0.025),
                Stack(
                  children: [
                    Container(
                      // height: 165,
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
                                titletext: "Total restaurant bill".tr,
                                subtitletext:
                                    "${homedata.homeDataList["currency"]}${widget.totelbill}",
                                fontsize: 16,
                                fontFamily: "Gilroy Medium"),
                            SizedBox(height: Get.height * 0.01),
                            billdetails(
                                titletext: "Waiter tip".tr,
                                subtitletext:
                                    "${homedata.homeDataList["currency"]}${widget.tipamt}",
                                fontsize: 16,
                                fontFamily: "Gilroy Medium"),
                            SizedBox(height: Get.height * 0.01),
                            billdetails(
                                titletext: "Gold ",
                                subtitletext:
                                    "-${homedata.homeDataList["currency"]}${widget.discountamt}",
                                fontsize: 18,
                                DiscountText:
                                    "${widget.discountvalue}% today's discount",
                                fontFamily: "Gilroy ExtraBold"),
                            SizedBox(height: Get.height * 0.01),
                            Divider(color: greycolor),
                            SizedBox(height: Get.height * 0.005),
                            billdetails(
                                titletext: "Total paid".tr,
                                subtitletext:
                                    "${homedata.homeDataList["currency"]}${widget.payedamt}",
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
                            Get.to(() => Profile(
                                  discountamount: widget.discountamt,
                                  discount: widget.discountvalue,
                                ));
                          },
                          child: Container(
                            height: 50,
                            width: Get.width * 0.35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: green),
                            child: Center(
                                child: Text("Done".tr,
                                    style: TextStyle(
                                        fontFamily: "Gilroy Bold",
                                        color: WhiteColor,
                                        fontSize: 17))),
                          ),
                        )),
                  ],
                ),
              ],
            ),
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
                fontFamily: "Gilroy Medium", fontSize: 16, color: notifier.textColor)),
      ],
    );
  }
}
