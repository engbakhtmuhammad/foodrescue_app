// ignore_for_file: file_names, prefer_const_constructors, deprecated_member_use

import 'package:foodrescue_app/controllers/Near_By_controller.dart';
import 'package:foodrescue_app/Utils/Bottom_bar.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/Custom_widegt.dart';
import '../../Utils/dark_light_mode.dart';

class Notificationpage extends StatefulWidget {
  const Notificationpage({super.key});

  @override
  State<Notificationpage> createState() => _NotificationpageState();
}

class _NotificationpageState extends State<Notificationpage> {
  @override
  void initState() {
    super.initState();
    getDarkMode();
    notification.notification();
  }

  NearybyController notification = Get.put(NearybyController());

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
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                  onTap: () {
                    Get.to(() => BottomBar());
                  },
                  child: selectedIndex == 2
                      ? SizedBox()
                      : Image.asset("assets/arrowleft.png",
                          height: 20, color: notifier.textColor)),
            ),
            title: Text(
              "Notification".tr,
              style: TextStyle(
                  fontSize: 17, fontFamily: "Gilroy Bold", color: notifier.textColor),
            ),
            elevation: 0,
            backgroundColor: notifier.background),
        backgroundColor: notifier.background,
        body: GetBuilder<NearybyController>(builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
                child: Column(
              children: [
                notification.isLoading
                    ? notification.notificationdata.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: notification.notificationdata.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                                          color: notifier.containerColor),
                                      child: Image.asset(
                                          "assets/notification.png",
                                          height: 25,
                                          color: notifier.textColor),
                                    ),
                                    SizedBox(width: Get.width * 0.03),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: Get.width * 0.58,
                                          child: Text(
                                            notification
                                                    .notificationdata[index]
                                                ["title"],
                                            style: TextStyle(
                                                fontFamily: "Gilroy Medium",
                                                fontSize: 15,
                                                color: greytext),
                                          ),
                                        ),
                                        SizedBox(
                                            height: Get.height * 0.013),
                                        SizedBox(
                                          width: Get.width * 0.55,
                                          child: Text(
                                              notification.notificationdata[
                                                  index]["description"],
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontFamily:
                                                      "Gilroy ExtraBold",
                                                  fontSize: 15,
                                                  color: notifier.textColor)),
                                        )
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        GetBuilder<NearybyController>(
                                            builder: (context) {
                                          String opentime =
                                              "2023-03-20T${notification.notificationdata[index]["datetime"].toString().split(" ").last}";
                                          return Text(
                                            DateFormat.jm().format(
                                                DateTime.parse(opentime)),
                                            style: TextStyle(
                                                fontFamily: "Gilroy Medium",
                                                fontSize: 15,
                                                color: greytext),
                                          );
                                        }),
                                        SizedBox(
                                            height: Get.height * 0.015),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          )
                        : Padding(
                            padding: EdgeInsets.only(top: Get.height * 0.35),
                            child: Center(
                              child: Text(
                                "Looks like you don't have any notifications at the moment.".tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: greycolor,
                                    fontFamily: "Gilroy Bold",
                                    fontSize: 16),
                              ),
                            ),
                          )
                    : Center(
                        child: Padding(
                        padding: EdgeInsets.only(top: Get.height * 0.4),
                        child:  CircularProgressIndi(),
                      ))
              ],
            )),
          );
        }),
      ),
    );
  }
}
