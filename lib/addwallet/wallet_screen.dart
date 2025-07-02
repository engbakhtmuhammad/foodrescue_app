// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, unnecessary_brace_in_string_interps, unused_import, depend_on_referenced_packages

import 'package:foodrescue_app/controllers/Controller.dart';
import 'package:foodrescue_app/controllers/Wallet_controller.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:foodrescue_app/addwallet/addwallet_screen.dart';
import 'package:foodrescue_app/api/Data_save.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/dark_light_mode.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  WalletController walletController = Get.put(WalletController());
  HomeController homePageController = Get.put(HomeController());

  @override
  void initState() {
    getDarkMode();
    super.initState();
    walletController.getWalletReportData();
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
          "Wallet".tr,
          style: TextStyle(
            fontSize: 17,
            fontFamily: "Gilroy Bold",
            color: notifier.textColor,
          ),
        ),
      ),
      body: SizedBox(
        height: Get.size.height,
        width: Get.size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GetBuilder<HomeController>(builder: (context) {
              return GetBuilder<WalletController>(builder: (context) {
                // tWallet = walletController.walletInfo?.wallet ?? "";
                // homePageController.tWallet =
                //     walletController.walletInfo?.wallet ?? "";
                return Container(
                  height: Get.height * 0.28,
                  width: Get.size.width,
                  margin: EdgeInsets.only(left: 15, top: 15, right: 15),
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.only(top: 0, left: 15),
                        child: Text(
                          "Wallet".tr,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: "Gilroy Bold",
                            color: notifier.textColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 10, left: 15),
                      //   child: Text(
                      //     "${homedata.homeDataList["currency"]}${walletController.wallet}", //misteck che
                      //     textAlign: TextAlign.start,
                      //     style: TextStyle(
                      //       fontSize: 45,
                      //       fontFamily: "Gilroy Bold",
                      //       color: WhiteColor,
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0, left: 15),
                        child: Text(
                          "Your current Balance".tr,
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: "Gilroy Bold",
                            color: notifier.textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/walletIMage.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                );
              });
            }),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 25),
              child: Text(
                "History".tr,
                style: TextStyle(
                  fontSize: 17,
                  color: notifier.textColor,
                  fontFamily: "Gilroy Medium",
                ),
              ),
            ),
            Expanded(
              child: GetBuilder<WalletController>(builder: (context) {
                return walletController.isLoading
                    ? ListView.builder(
                        itemCount: walletController.wallet.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.all(10),
                            child: ListTile(
                              leading: Container(
                                height: 70,
                                width: 60,
                                padding: EdgeInsets.all(12),
                                child: Image.asset(
                                  "assets/Wallet.png",
                                  color: Colors.orange,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xFFf6f7f9),
                                ),
                              ),
                              title: Text(
                                walletController.wallet[index]["message"] ??
                                    "", //mister che
                                maxLines: 1,
                                style: TextStyle(
                                  color: notifier.textColor,
                                  fontFamily: "Gilroy Bold",
                                  // fontSize: 16,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              subtitle: Text(
                                walletController.wallet[index]["status"] ?? "",
                                maxLines: 1,
                                style: TextStyle(
                                  color: notifier.textColor,
                                  fontFamily: "Gilroy Medium",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              trailing: walletController.wallet[index]
                                          ["status"] ==
                                      "Credit"
                                  ? TextButton(
                                      onPressed: () {},
                                      child: Text(
                                          "${walletController.wallet[index]["amt"] ?? ""}${homePageController.homeDataList["currency"]} +"),
                                    )
                                  : TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        "${walletController.wallet[index]["amt"] ?? ""}${homePageController.homeDataList["currency"]} -",
                                        style: TextStyle(
                                          color: Colors.orange.shade300,
                                        ),
                                      ),
                                    ),
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: CircularProgressIndi(),
                      );
              }),
            ),
            GestButton(
              Width: Get.size.width,
              height: 50,
              buttoncolor: Colors.blue,
              margin: EdgeInsets.only(top: 15, left: 35, right: 35),
              buttontext: "ADD AMOUNT".tr,
              style: TextStyle(
                fontFamily: "Gilroy Bold",
                color: WhiteColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              onclick: () {
                Get.to(() => AddWalletScreen());
              },
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
