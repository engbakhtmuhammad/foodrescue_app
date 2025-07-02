// ignore_for_file: file_names, must_be_immutable

import 'package:foodrescue_app/controllers/Table_status_wise_controller.dart';
import 'package:foodrescue_app/views/Profile/Table_booking_details.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/dark_light_mode.dart';

class Cancelled extends StatefulWidget {
  String? noofpeople;
  String? bookingdate;
  Cancelled({this.noofpeople, this.bookingdate, super.key});

  @override
  State<Cancelled> createState() => _CancelledState();
}

class _CancelledState extends State<Cancelled> {
  @override
  void initState() {
    getDarkMode();
    super.initState();
    bookingstatus.tableStatus(status: "Cancelled");
  }

  TableStatusController bookingstatus = Get.put(TableStatusController());
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
      backgroundColor: transparent,
      body: GetBuilder<TableStatusController>(builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SingleChildScrollView(
            child: GetBuilder<TableStatusController>(builder: (context) {
              return Column(
                children: [
                  bookingstatus.isLoading
                      ? bookingstatus.tableStatusList.isNotEmpty
                          ? ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: bookingstatus.tableStatusList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.to(() => Tablebookingdetails(
                                            howmanypeople: widget.noofpeople,
                                            tableid: bookingstatus
                                                .tableStatusList[index]["id"],
                                          ));
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: Get.width * 0.67,
                                              child: Text(
                                                bookingstatus
                                                        .tableStatusList[index]
                                                    ["rest_title"],
                                                style: TextStyle(
                                                    fontFamily: "Gilroy Bold",
                                                    color: notifier.textColor,
                                                    fontSize: 18),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  bookingstatus.tableStatusList[
                                                      index]["table_status"],
                                                  style: TextStyle(
                                                      fontFamily:
                                                          "Gilroy Medium",
                                                      color: greentext,
                                                      fontSize: 16),
                                                ),
                                                SizedBox(
                                                    width: Get.width * 0.02),
                                              ],
                                            )
                                          ],
                                        ),
                                        SizedBox(height: Get.height * 0.015),
                                        Row(
                                          children: [
                                            GetBuilder<TableStatusController>(
                                                builder: (context) {
                                              String closetime =
                                                  "2023-03-20T${bookingstatus.tableStatusList[index]["book_time"]}";
                                              return Text(
                                                "Book time: ${DateFormat.jm().format(DateTime.parse(closetime))}",
                                                style: TextStyle(
                                                    fontFamily: "Gilroy Medium",
                                                    color: greycolor,
                                                    fontSize: 17),
                                              );
                                            }),
                                            Icon(Icons.timer_outlined,
                                                color: greycolor, size: 25)
                                          ],
                                        ),
                                        SizedBox(height: Get.height * 0.015),
                                        Text(
                                          "Table For ${bookingstatus.tableStatusList[index]["noofpeople"]} Person",
                                          style: TextStyle(
                                              fontFamily: "Gilroy Medium",
                                              color: greycolor,
                                              fontSize: 16),
                                        ),
                                        SizedBox(height: Get.height * 0.015),
                                        dottedline(),
                                        SizedBox(height: Get.height * 0.015),
                                        RichText(
                                            text: TextSpan(
                                          text: bookingstatus
                                                  .tableStatusList[index]
                                              ["book_date"],
                                          style: TextStyle(
                                              fontFamily: "Gilroy Medium",
                                              color: greycolor,
                                              fontSize: 16),
                                        )),
                                        SizedBox(height: Get.height * 0.02),
                                        Divider(color: notifier.background)
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : Padding(
                              padding: EdgeInsets.only(top: Get.height * 0.35),
                              child: Center(
                                child: Text(
                                  "You have no upcoming bookings.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: greycolor,
                                      fontFamily: "Gilroy Bold",
                                      fontSize: 16),
                                ),
                              ),
                            )
                      : Padding(
                          padding: EdgeInsets.only(top: Get.height * 0.35),
                          child:
                               Center(child: CircularProgressIndi()),
                        )
                ],
              );
            }),
          ),
        );
      }),
    );
  }
}
