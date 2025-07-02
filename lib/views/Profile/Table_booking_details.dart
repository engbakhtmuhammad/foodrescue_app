// ignore_for_file: file_names, unused_local_variable, unnecessary_string_interpolations, must_be_immutable
// ignore_for_file: camel_case_types, use_key_in_widget_constructors, annotate_overrides, prefer_const_literals_to_create_immutables, unused_field, unused_element, avoid_unnecessary_containers, non_constant_identifier_names, unused_import, deprecated_member_use

import 'package:foodrescue_app/controllers/Book_table_list_controller.dart';
import 'package:foodrescue_app/Utils/Bottom_bar.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/dark_light_mode.dart';

class Tablebookingdetails extends StatefulWidget {
  String? howmanypeople;
  String? tableid;
  String? bookingdate;
  String? time;
  Tablebookingdetails(
      {this.howmanypeople,
      this.tableid,
      this.bookingdate,
      this.time,
      super.key});

  @override
  State<Tablebookingdetails> createState() => _TablebookingdetailsState();
}

class _TablebookingdetailsState extends State<Tablebookingdetails> {
  @override
  void initState() {
    getDarkMode();
    super.initState();
    booktable.booktableList(tableid: widget.tableid);
  }

  TablelistsController booktable = Get.put(TablelistsController());

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
      resizeToAvoidBottomInset: false,
      backgroundColor: notifier.background,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: AppButton(
          buttonColor: orangeColor,
          buttontext: "Go Back Home".tr,
          onTap: () {
            Get.to(() => BottomBar());
          },
        ),
      ),
      appBar: AppBar(
          elevation: 0,
          backgroundColor: transparent,
          leading: BackButton(color: notifier.textColor),
          title: Text("Booking Summary".tr,
              style: TextStyle(
                  fontFamily: "Gilroy Bold", fontSize: 18, color: notifier.textColor))),
      body: GetBuilder<TablelistsController>(builder: (context) {
        return booktable.isLoading
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Get.height * 0.02),
                      Row(
                        children: [
                          Container(
                            height: Get.height * 0.05,
                            width: Get.width * 0.3,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: orangeColor),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GetBuilder<TablelistsController>(
                                    builder: (context) {
                                  int timestamp = DateTime.parse(
                                          booktable.tableList["book_date"])
                                      .millisecondsSinceEpoch;
                                  DateTime tsdate =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          timestamp);
                                  String fdatetime =
                                      DateFormat('MMM, dd yyy').format(tsdate);
                                  return SizedBox(
                                    // width: Get.width * 0.1,
                                    child: Text(fdatetime,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: "Gilroy Bold",
                                            fontSize: 16,
                                            color: WhiteColor)),
                                  );
                                }),
                              ],
                            ),
                          ),
                          SizedBox(width: Get.width * 0.03),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(booktable.tableList["table_status"],
                                  style: TextStyle(
                                      fontFamily: "Gilroy Bold",
                                      fontSize: 16,
                                      color: lightblue)),
                              SizedBox(height: Get.height * 0.01),
                              Text(booktable.tableList["rest_title"],
                                  style: TextStyle(
                                      fontFamily: "Gilroy Bold",
                                      fontSize: 16,
                                      color: notifier.textColor)),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: Get.height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GetBuilder<TablelistsController>(builder: (context) {
                            String booktime =
                                "2023-03-20T${booktable.tableList["book_time"]}";
                            return summary(
                                titletext: "Time".tr,
                                boxtext:
                                    "${DateFormat.jm().format(DateTime.parse(booktime))}",
                                width: Get.width * 0.45);
                          }),
                          summary(
                              titletext: "Booking For".tr,
                              boxtext: booktable.tableList["book_for"],
                              width: Get.width * 0.45)
                        ],
                      ),
                      SizedBox(height: Get.height * 0.02),
                      Row(
                        children: [
                          summary(
                              boxtext: booktable.tableList["name"],
                              titletext: "Booked by".tr,
                              width: Get.width * 0.5),
                          summary(
                              boxtext: "${booktable.tableList["noofpeople"]}",
                              titletext: "Guest",
                              width: Get.width * 0.3)
                        ],
                      ),
                      SizedBox(height: Get.height * 0.02),
                      Row(
                        children: [
                          summary(
                              boxtext: booktable.tableList["mobile"],
                              titletext: "Phone Number".tr,
                              width: Get.width * 0.5),
                          SizedBox(height: Get.height * 0.02),
                          summary(
                              boxtext: "${booktable.tableList["email"]}",
                              titletext: "Email address",
                              width: Get.width * 0.4),
                        ],
                      ),
                      SizedBox(height: Get.height * 0.02),
                      summary(
                          boxtext: "${booktable.tableList["book_date"]}",
                          titletext: "Booking date".tr,
                          width: Get.width * 0.4),
                    ],
                  ),
                ),
              )
            :  Center(child: CircularProgressIndi());
      }),
    );
  }

  summary({String? titletext, boxtext, double? width}) {
    return GetBuilder<TablelistsController>(builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titletext!,
            style: TextStyle(
                fontFamily: "Gilroy Bold",
                fontSize: 16,
                color: greytext.withOpacity(0.6)),
          ),
          SizedBox(height: Get.height * 0.01),
          Container(
            height: 50,
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 6, left: 0),
              child: Text(
                boxtext,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: "Gilroy Bold", fontSize: 16, color: notifier.textColor),
              ),
            ),
          )
        ],
      );
    });
  }
}
