// ignore_for_file: file_names, prefer_const_constructors, deprecated_member_use

import 'package:foodrescue_app/controllers/Near_By_controller.dart';
import 'package:foodrescue_app/views/restaurant/Hotel_Details.dart';
import 'package:foodrescue_app/Utils/Bottom_bar.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/String.dart';
import 'package:foodrescue_app/Utils/image.dart';
import 'package:foodrescue_app/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/Custom_widegt.dart';
import '../../Utils/dark_light_mode.dart';

// bool selectedbox = false;

class Nearbyhotel extends StatefulWidget {
  const Nearbyhotel({super.key});

  @override
  State<Nearbyhotel> createState() => _NearbyhotelState();
}

class _NearbyhotelState extends State<Nearbyhotel> {
  NearybyController nearbyrest = Get.put(NearybyController());
  @override
  void initState() {
    getDarkMode();
    super.initState();
    nearbyrest.nearbyrest();
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
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: notifier.background,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: notifier.background,
            centerTitle: true,
            leading: Transform.translate(
              offset: const Offset(-2, 0),
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: InkWell(
                      onTap: () {
                        Get.to(() => BottomBar());
                      },
                      child: selectedIndex == 1
                          ? SizedBox()
                          : Image.asset("assets/arrowleft.png",
                              height: 20, color: notifier.textColor))),
            ),
            title: Text(
              "Popular Restaurant around you".tr,
              style: TextStyle(
                  fontFamily: "Gilroy Bold",
                  fontSize: 16,
                  color: notifier.textColor),
            )),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: GetBuilder<NearybyController>(builder: (context) {
                return nearbyrest.isLoading
                    ? nearbyrest.cuisinerestlist.isNotEmpty
                        ? Column(
                            children: [
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: nearbyrest.cuisinerestlist.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () {
                                      // selectedbox = true;
                                      String? restaurantId = nearbyrest
                                          .cuisinerestlist[index]["id"]
                                          ?.toString();
                                      if (restaurantId != null &&
                                          restaurantId.isNotEmpty) {
                                        Get.to(() => HotelDetails(
                                            detailId: restaurantId));
                                      } else {
                                        Get.snackbar(
                                            "Error", "Restaurant ID not found");
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 160,
                                            width: 130,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: notifier.textColor),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Stack(children: [
                                                FadeInImage.assetNetwork(
                                                  fadeInCurve:
                                                      Curves.easeInCirc,
                                                  placeholder:
                                                      "assets/ezgif.com-crop.gif",
                                                  height: 160,
                                                  width: 130,
                                                  placeholderCacheHeight: 160,
                                                  placeholderCacheWidth: 130,
                                                  placeholderFit: BoxFit.fill,
                                                  // placeholderScale: 1.0,
                                                  image: nearbyrest
                                                          .cuisinerestlist[
                                                              index]["img"]
                                                          ?.toString() ??
                                                      "https://picsum.photos/300/200",
                                                  fit: BoxFit.cover,
                                                ),
                                              ]),
                                            ),
                                          ),
                                          SizedBox(width: Get.width * 0.03),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                nearbyrest
                                                        .cuisinerestlist[index]
                                                            ["title"]
                                                        ?.toString() ??
                                                    "Restaurant",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontFamily: "Gilroy Bold",
                                                    color: notifier.textColor),
                                              ),
                                              SizedBox(
                                                  height: Get.height * 0.01),
                                              Row(
                                                children: [
                                                  Image.asset(image.star,
                                                      height: 20),
                                                  SizedBox(
                                                      width: Get.width * 0.015),
                                                  Text(
                                                    nearbyrest.cuisinerestlist[
                                                                index]["rating"]
                                                            ?.toString() ??
                                                        "0.0",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontFamily:
                                                            "Gilroy Bold",
                                                        color:
                                                            notifier.textColor),
                                                  ),
                                                  SizedBox(
                                                      width: Get.width * 0.015),
                                                ],
                                              ),
                                              SizedBox(
                                                  height: Get.height * 0.01),
                                              SizedBox(
                                                width: Get.width * 0.53,
                                                child: Text(
                                                  nearbyrest.cuisinerestlist[
                                                              index]["fullAddress"]
                                                          ?.toString() ??
                                                      "No address",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily:
                                                          "Gilroy Medium",
                                                      color: greycolor),
                                                ),
                                              ),
                                              SizedBox(
                                                  height: Get.height * 0.01),
                                              SizedBox(
                                                width: Get.width * 0.53,
                                                child: Text(
                                                  nearbyrest.cuisinerestlist[
                                                              index]
                                                              ["shortDescription"]
                                                          ?.toString() ??
                                                      "No description",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily:
                                                          "Gilroy Medium",
                                                      color: greycolor),
                                                ),
                                              ),
                                              SizedBox(
                                                  height: Get.height * 0.02),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                // height: 40,
                                                width: Get.width * 0.54,
                                                decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                        stops: const [
                                                          0.6,
                                                          0.8,
                                                          1
                                                        ],
                                                        colors: [
                                                          Colors.transparent,
                                                          Colors.red
                                                              .withOpacity(0.1),
                                                          Colors.red
                                                              .withOpacity(0.1)
                                                        ]),
                                                    border: Border.all(
                                                        color: lightgrey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                          width:
                                                              Get.width * 0.32,
                                                          child: GetBuilder<
                                                                  NearybyController>(
                                                              builder:
                                                                  (context) {
                                                            String
                                                                currentdiscount =
                                                                "";
                                                            DateTime date =
                                                                DateTime.now();
                                                            String dateFormat =
                                                                DateFormat(
                                                                        'EEEE')
                                                                    .format(
                                                                        date);
                                                            if (dateFormat ==
                                                                    "Friday" ||
                                                                dateFormat ==
                                                                    "Saturday" ||
                                                                dateFormat ==
                                                                    "Sunday") {
                                                              currentdiscount =
                                                                  nearbyrest.cuisinerestlist[
                                                                          index]
                                                                      [
                                                                      "fridaySundayOffer"];
                                                            } else {
                                                              currentdiscount =
                                                                  nearbyrest.cuisinerestlist[
                                                                          index]
                                                                      [
                                                                      "mondayThursdayOffer"];
                                                            }
                                                            return Text(
                                                              "EXTRA $currentdiscount% OFF",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      "Gilroy Bold",
                                                                  color:
                                                                      orangeColor,
                                                                  fontSize: 14),
                                                            );
                                                          }),
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              Get.width * 0.32,
                                                          child: Text(
                                                            provider.andfree
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                                fontSize: 10,
                                                                color:
                                                                    orangeColor,
                                                                fontFamily:
                                                                    "Gilroy Medium"),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          provider.gold
                                                              .toUpperCase(),
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color: goldColor,
                                                              fontFamily:
                                                                  "Gilroy Bold"),
                                                        ),
                                                        Text(
                                                          provider.benefits
                                                              .toUpperCase(),
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              color:
                                                                  orangeColor,
                                                              fontFamily:
                                                                  "Gilroy Medium"),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            ],
                          )
                        : Padding(
                            padding: EdgeInsets.only(top: Get.height * 0.35),
                            child: Center(
                              child: Text(
                                "We do not currently have any restaurants Popular."
                                    .tr,
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
                        child: CircularProgressIndi(),
                      ));
              })),
        ),
      ),
    );
  }
}
