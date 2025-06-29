// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_interpolation_to_compose_strings, avoid_print, unnecessary_new, unused_import, depend_on_referenced_packages

import 'package:foodrescue_app/Getx_Controller/Controller.dart';
import 'package:foodrescue_app/Getx_Controller/Wallet_controller.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:foodrescue_app/api/Data_save.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/dark_light_mode.dart';

class ReferFriendScreen extends StatefulWidget {
  const ReferFriendScreen({super.key});

  @override
  State<ReferFriendScreen> createState() => _ReferFriendScreenState();
}

class _ReferFriendScreenState extends State<ReferFriendScreen> {
  WalletController walletController = Get.find();
  PackageInfo? packageInfo;
  String? appName;
  String? packageName;

  @override
  void initState() {
    getDarkMode();
    super.initState();
    getPackage();
  }

  void getPackage() async {
    //! App details get
    packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo!.appName;
    packageName = packageInfo!.packageName;
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
    return Scaffold(
      backgroundColor: notifier.background,
      appBar: AppBar(
        backgroundColor: notifier.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: notifier.textColor),
        ),
        title: Text(
          "Refer a Friend".tr,
          style: TextStyle(
            fontSize: 17,
            fontFamily: "Gilroy Bold",
            color: notifier.textColor,
          ),
        ),
      ),
      body: GetBuilder<WalletController>(builder: (context) {
        return SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: SizedBox(
            height: Get.size.height,
            width: Get.size.width,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Image.asset(
                  "assets/images/refer.png",
                  height: 220,
                  width: Get.size.width,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "${"Earn".tr} ${homedata.homeDataList["currency"]} + ${walletController.refercredit}} ${"for Each\n Friend you refer".tr}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Gilroy Bold",
                    color: notifier.textColor,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/lovef.png",
                            height: 28,
                            width: 28,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Share the referral link with your friends".tr,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: "Gilroy Medium",
                              fontSize: 16,
                              color: notifier.textColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/lovef.png",
                            height: 28,
                            width: 28,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "${"Friend get".tr} ${homedata.homeDataList["currency"]} + walletController.refercredit} ${"on their first complete\ntransaction".tr}",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: "Gilroy Medium",
                              fontSize: 16,
                              color: notifier.textColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/lovef.png",
                            height: 28,
                            width: 28,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "${"You get".tr} ${homedata.homeDataList["currency"]} + ${walletController.signupcredit}} ${"on your wallet".tr}",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: "Gilroy Medium",
                              fontSize: 16,
                              color: notifier.textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 50,
                ),
                Container(
                  height: 50,
                  width: Get.size.width,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 15, left: 35, right: 35),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            walletController.rCode,
                            style: TextStyle(
                              fontFamily: "Gilroy Bold",
                              color: notifier.textColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                            new ClipboardData(text: walletController.rCode),
                          );
                          showToastMessage("Copy");
                        },
                        child: Image.asset(
                          "assets/images/copy.png",
                          height: 20,
                          width: 20,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFe1e9f5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                GestButton(
                  Width: Get.size.width,
                  height: 50,
                  buttoncolor: Colors.blue,
                  margin: EdgeInsets.only(top: 15, left: 35, right: 35),
                  buttontext: "Refer a friend".tr,
                  style: TextStyle(
                    fontFamily: "Gilroy Bold",
                    color: WhiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  onclick: () async {
                    // await FlutterShare.share(
                    //     title: '$appName',
                    //     text:
                    //         'Hey! Now use our app to share with your family or friends. User will get wallet amount on your 1st successful transaction. Enter my referral code ${walletController.rCode} & Enjoy your shopping !!!',
                    //     linkUrl:
                    //         'https://play.google.com/store/apps/details?id=$packageName',
                    //     chooserTitle: '$appName');
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> share() async {
    print("!!!!!!!!!!" + appName.toString());
    print("!!!!!!!!!!" + packageName.toString());
    // await FlutterShare.share(
    //     title: '$appName',
    //     text:
    //         'Hey! Now use our app to share with your family or friends. User will get wallet amount on your 1st successful transaction. Enter my referral code ${walletController.rCode} & Enjoy your shopping !!!',
    //     linkUrl: 'https://play.google.com/store/apps/details?id=$packageName',
    //     chooserTitle: '$appName');
  }
}
