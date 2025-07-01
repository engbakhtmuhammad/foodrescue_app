// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names, file_names, sized_box_for_whitespace, avoid_print, must_be_immutable, unnecessary_brace_in_string_interps, unused_local_variable, unrelated_type_equality_checks
// ignore_for_file: camel_case_types, use_key_in_widget_constructors, annotate_overrides, unused_field, unused_element, avoid_unnecessary_containers, unused_import, deprecated_member_use

import 'package:foodrescue_app/controllers/home_controller.dart';
import 'package:foodrescue_app/Getx_Controller/Hotel_details_Controller.dart';
import 'package:foodrescue_app/Payment/Payment_Discount.dart';
import 'package:foodrescue_app/Payment/Payment_Successfull.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:foodrescue_app/Utils/String.dart';
import 'package:foodrescue_app/Utils/image.dart';
import 'package:foodrescue_app/utils/api_wrapper.dart';
import 'package:foodrescue_app/api/Data_save.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/dark_light_mode.dart';

bool checkvalue = false;
final Mobile = TextEditingController();
TextEditingController fullname = TextEditingController();
TextEditingController Emailaddress = TextEditingController();

class Tab1 extends StatefulWidget {
  String? restid;
  String? hotelname;
  String? address;
  String? tip;

  Tab1({this.restid, this.hotelname, this.address, this.tip, super.key});

  @override
  State<Tab1> createState() => _Tab1State();
}

class _Tab1State extends State<Tab1> {
  String dropdownvalue = "+91";
  var items = ["+91", "+1", "+385", "+355", "+54"];
  int? selectedIndex;
  int? selectedIndex1;
  int? selectedIndex2;
  String Country = "";

  DateTime selectedDate = DateTime.now();

  int currentDateSelectedIndex = 0;
  ScrollController scrollController = ScrollController();
  String today = "";
  String currenttime = "";
  String selecttime = "";
  DateTime dateToday =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    getDarkMode();
    super.initState();

    today = dateToday.toString().split(" ").first;

    print("******************** hotelname ****************"
        "${widget.hotelname}");
    print("******************** address ****************" "${widget.address}");
  }

  String? Noofpeople;

  Iterable<TimeOfDay> getTimes(
      TimeOfDay startTime, TimeOfDay endTime, Duration step) sync* {
    var hour = startTime.hour;
    var minute = startTime.minute;
    do {
      yield TimeOfDay(hour: hour, minute: minute);
      minute += step.inMinutes;
      while (minute >= 60) {
        minute -= 60;
        hour++;
      }
    } while (hour < endTime.hour ||
        (hour == endTime.hour && minute <= endTime.minute));
  }

  List<String> listOfMonths = [
    "Jan".tr,
    "Feb".tr,
    "Mar".tr,
    "Apr".tr,
    "May".tr,
    "Jun".tr,
    "Jul".tr,
    "Aug".tr,
    "Sep".tr,
    "Oct".tr,
    "Nov".tr,
    "Dec".tr,
  ];

  List<String> listOfDays = ["Mon".tr, "Tue".tr, "Wed".tr, "Thu".tr, "Fri".tr, "Sat".tr, "Sun".tr];

  int getTime(int hour, int min) {
    TimeOfDay n = TimeOfDay.now();
    int nowSec = (n.hour * 60 + n.minute) * 60;
    int veiSec = (hour * 60 + min) * 60;
    int dif = veiSec - nowSec;

    print("==dif=${dif}");
    return dif;
  }

  HomeController hoteldiscount = Get.put(HomeController());
  HoteldetailController hdetail = Get.put(HoteldetailController());

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
      backgroundColor: notifier.containerColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${hdetail.hoteldetails["mondayThursdayOffer"]}% Welcome Discount",
                  style: TextStyle(
                      fontFamily: 'Gilroy Bold',
                      fontSize: 16,
                      color: notifier.textColor),
                ),
                InkWell(
                    onTap: bottomsheet,
                    child:
                        Image.asset(image.info, height: 20, color: notifier.textColor))
              ],
            ),
            SizedBox(height: Get.height * 0.01),
            GetBuilder<HoteldetailController>(builder: (context) {
              print(
                  "###################################${hdetail.hoteldetails["openTime"]}");
              String time = hdetail.hoteldetails["openTime"]?.toString() ?? "09:00";
              String closetime = hdetail.hoteldetails["closeTime"]?.toString() ?? "22:00";
              List<String> durations = time.split(':');
              List<String> close = closetime.split(':');
              print('${durations[0]} hours ${durations[1]} minutes ');
              print('${durations})');
              String currentdiscount = "";
              DateTime date = DateTime.now();
              String dateFormat = DateFormat('EEEE').format(date);
              if (dateFormat == "Friday" ||
                  dateFormat == "Saturday" ||
                  dateFormat == "Sunday") {
                currentdiscount = hdetail.hoteldetails["fridaySundayOffer"]?.toString() ?? "No offer";
              } else {
                currentdiscount = hdetail.hoteldetails["mondayThursdayOffer"]?.toString() ?? "No offer";
              }
              return Column(
                children: [
                  SizedBox(height: Get.height * 0.01),
                  GetBuilder<HomeController>(builder: (context) {
                    print(
                        "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@${hoteldiscount.homeDataList["is_subscribe"]}");
                    String tdata =
                        DateFormat("hh:mm:ss a").format(DateTime.now());
                    print("###############################$tdata");
                    return GestureDetector(
                      onTap: () {
                        getTime(int.parse(durations[0]),
                                    int.parse(durations[1])) <
                                0 //open time
                            ? getTime(int.parse(close[0]),
                                        int.parse(close[1])) >=
                                    0 //close time
                                ? hoteldiscount.homeDataList["is_subscribe"] ==
                                        1
                                    ? Get.to(() => PaymentDiscount(
                                          tipamount: currentdiscount,
                                          address: widget.address,
                                          hotelname: widget.hotelname,
                                          restid: widget.restid,
                                        ))
                                    : ApiWrapper.showToastMessage(
                                        "Please subscribe membership and pay bill to get offer".tr)
                                : ApiWrapper.showToastMessage(
                                    "Sorry you're late restaurant is closed".tr)
                            : ApiWrapper.showToastMessage(
                                "Sorry you're late restaurant is closed".tr);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              stops: [0.1, 0.8, 1],
                              colors: <Color>[
                                orangeColor,
                                orangeColor,
                                Colors.red
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: orangeColor),
                        height: 50,
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            provider.paybill.tr.toUpperCase(),
                            style: TextStyle(
                                fontFamily: 'Gilroy Bold',
                                fontSize: 14,
                                color: WhiteColor),
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: Get.height * 0.02),
                  GetBuilder<HoteldetailController>(builder: (context) {
                    return hdetail.hoteldetails["show_table"] != "0"
                        ? InkWell(
                            onTap: () {
                              getTime(int.parse(durations[0]),
                                          int.parse(durations[1])) <=
                                      0 //open time
                                  ? getTime(int.parse(close[0]),
                                              int.parse(close[1])) >=
                                          0 //close time
                                      ? hoteldiscount.homeDataList[
                                                  "is_subscribe"] ==
                                              1
                                          ? BookTable()
                                          : ApiWrapper.showToastMessage(
                                              "Please subscribe membership and book a table to get offer")
                                      : ApiWrapper.showToastMessage(
                                          "Sorry you're late restaurant is closed")
                                  : ApiWrapper.showToastMessage(
                                      "Sorry you're late restaurant is closed");
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xffff5722),
                                      Color(0xffffc107)
                                    ],
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: orangeColor),
                              height: 50,
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  "book a table to get offer".tr.toUpperCase(),
                                  style: TextStyle(
                                      fontFamily: 'Gilroy Bold',
                                      fontSize: 14,
                                      color: WhiteColor),
                                ),
                              ),
                            ))
                        : SizedBox();
                  })
                ],
              );
            })
          ],
        ),
      ),
    );
  }

  bottomsheet() {
    return showModalBottomSheet(
        backgroundColor: notifier.containerColor,
        isScrollControlled: true,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration:
                  BoxDecoration(color: notifier.containerColor,borderRadius: BorderRadius.circular(15)),
              height: Get.height * 0.80,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: Get.height * 0.01),
                            SizedBox(
                              width: Get.width * 0.80,
                              child: Text(
                                "${hdetail.hoteldetails["monmondayThursdayOfferthru"]}% Welcome Discount",
                                style: TextStyle(
                                    fontFamily: 'Gilroy ExtraBold',
                                    fontSize: 20,
                                    color: notifier.textColor),
                              ),
                            ),
                            SizedBox(height: Get.height * 0.03),
                            Text(
                              provider.Terms.tr,
                              style: TextStyle(
                                  fontFamily: 'Gilroy Bold',
                                  fontSize: 16,
                                  color: notifier.textColor),
                            ),
                            SizedBox(height: Get.height * 0.025),
                            Html(
                              data: hdetail.hoteldetails["description"],
                              style: {
                                "body": Style(
                                    maxLines: 5,
                                    textOverflow: TextOverflow.ellipsis,
                                    color: notifier.textColor,
                                    fontSize: FontSize(14)),
                              },
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            );
          });
        });
  }

  discount({String? text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: CircleAvatar(radius: 3, backgroundColor: greycolor),
        ),
        SizedBox(width: Get.width * 0.03),
        SizedBox(
          width: Get.width * 0.85,
          child: Text(
            text!,
            style: TextStyle(
                fontFamily: 'Gilroy Medium', fontSize: 15, color: notifier.textColor),
          ),
        ),
      ],
    );
  }

  BookTable() {
    List<String> times = [];

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String fdatetime = DateFormat('dd-MMM-yyy').format(tsdate);
    print(
        "###################################${hdetail.hoteldetails["openTime"]}");
    String time = hdetail.hoteldetails["openTime"];
    String closetime = hdetail.hoteldetails["closeTime"];
    List<String> durations = time.split(':');
    List<String> close = closetime.split(':');

    print('${durations[0]} hours ${durations[1]} minutes ');
    print('${durations})');
    final startTime = TimeOfDay(
        hour: int.parse(durations[0]), minute: int.parse(durations[1]));
    final endTime =
        TimeOfDay(hour: int.parse(close[0]), minute: int.parse(close[1]));
    final step = Duration(minutes: 30);

    DateTime now = DateTime.now();

    if ((startTime.hour < now.hour && startTime.minute < now.minute) && currentDateSelectedIndex==0) {
      if (now.minute < 30) {
        final startTime = TimeOfDay(hour: now.hour, minute: now.minute);
        times = getTimes(startTime, endTime, step)
            .map((tod) => tod.format(context))
            .toList();
      } else {
        int minit = 60 - now.minute;
        final startTime =
            TimeOfDay(hour: now.hour, minute: now.minute + (minit - 1));
        times = getTimes(startTime, endTime, step)
            .map((tod) => tod.format(context))
            .toList();
      }
    } else {
      times = getTimes(startTime, endTime, step)
          .map((tod) => tod.format(context))
          .toList();
    }
    String timesedual =
        DateFormat("HH:mm").format(DateTime.now()).split(":").first;
    String opentime = "2023-03-20T${timesedual}";
    String yagnik = DateFormat.jm().format(DateTime.parse(opentime));
    print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@$yagnik");

    print("!!!!!!!!!!!!!!!!!!!!!!!${times.length}");

    return showModalBottomSheet(
        // isDismissible: true
        backgroundColor: notifier.background,
        isScrollControlled: true,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: Get.height * 0.8,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Scaffold(
                backgroundColor: notifier.background,
                floatingActionButton: Container(
                  transform: Matrix4.translationValues(
                      0.0, -80, 0.0), // translate up by 30
                  child: FloatingActionButton(
                    backgroundColor: notifier.textColor.withOpacity(0.5),
                    onPressed: () {
                      Get.back();
                    },
                    child: Icon(Icons.close),
                  ),
                ),
                body: SingleChildScrollView(
                  child: GetBuilder<HoteldetailController>(builder: (context) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: Get.height * 0.02),
                        Center(
                          child: Text(
                            "Book a Table".tr,
                            style: TextStyle(
                                fontFamily: "Gilroy Bold",
                                fontSize: 16,
                                color: notifier.textColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${widget.hotelname}",
                                style: TextStyle(
                                    fontFamily: "Gilroy Bold",
                                    fontSize: 16,
                                    color: notifier.textColor),
                              ),
                              SizedBox(height: Get.height * 0.01),
                              Text("${widget.address}",
                                  style: TextStyle(
                                      fontFamily: "Gilroy Medium",
                                      fontSize: 16,
                                      color: greycolor)),
                              SizedBox(height: Get.height * 0.03),
                              Text("What Day?".tr.toUpperCase(),
                                  style: TextStyle(
                                      fontFamily: "Gilroy Bold",
                                      fontSize: 15,
                                      color: notifier.textColor)),
                              SizedBox(height: Get.height * 0.015),
                              Container(
                                  height: 80,
                                  child: ListView.separated(
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return SizedBox(width: 10);
                                    },
                                    itemCount: 365,
                                    controller: scrollController,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return InkWell(
                                        onTap: () {

                                          setState(() {
                                            currentDateSelectedIndex = index;
                                            selectedDate = DateTime.now()
                                                .add(Duration(days: index));
                                          });
                                          print("###########################"
                                              "$currentDateSelectedIndex");
                                          if ((startTime.hour < now.hour && startTime.minute < now.minute) && currentDateSelectedIndex==0) {
                                            if (now.minute < 30) {
                                              final startTime = TimeOfDay(hour: now.hour, minute: now.minute);
                                              times = getTimes(startTime, endTime, step)
                                                  .map((tod) => tod.format(context))
                                                  .toList();
                                            } else {
                                              int minit = 60 - now.minute;
                                              final startTime =
                                              TimeOfDay(hour: now.hour, minute: now.minute + (minit - 1));
                                              times = getTimes(startTime, endTime, step)
                                                  .map((tod) => tod.format(context))
                                                  .toList();
                                            }
                                          } else {
                                            times = getTimes(startTime, endTime, step)
                                                .map((tod) => tod.format(context))
                                                .toList();
                                          }
                                        },
                                        child: Container(
                                          height: 50,
                                          width: Get.width * 0.25,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color:
                                                      currentDateSelectedIndex ==
                                                              index
                                                          ? orangeColor
                                                          : notifier.containerColor
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: currentDateSelectedIndex ==
                                                      index
                                                  ? orangeColor
                                                  : notifier.containerColor),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                listOfMonths[DateTime.now()
                                                            .add(Duration(
                                                                days: index))
                                                            .month -
                                                        1]
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color:
                                                        currentDateSelectedIndex ==
                                                                index
                                                            ? Colors.white
                                                            : notifier.textColor),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                DateTime.now()
                                                    .add(Duration(days: index))
                                                    .day
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        currentDateSelectedIndex ==
                                                                index
                                                            ? Colors.white
                                                            : notifier.textColor),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                listOfDays[DateTime.now()
                                                            .add(Duration(
                                                                days: index))
                                                            .weekday -
                                                        1]
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color:
                                                        currentDateSelectedIndex ==
                                                                index
                                                            ? Colors.white
                                                            : notifier.textColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )),
                              SizedBox(height: Get.height * 0.03),
                              Text("how many people".tr.toUpperCase(),
                                  style: TextStyle(
                                      fontFamily: "Gilroy Bold",
                                      fontSize: 15,
                                      color: notifier.textColor)),
                              SizedBox(
                                height: 70,
                                width: double.infinity,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  itemCount: manypeople.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedIndex = index;
                                              Noofpeople =
                                                  manypeople[index]["people"];
                                              print(
                                                  "-+-+-+-+-+-+-+-+-selectedIndex+-+-+-+----------------++"
                                                  "$Noofpeople");
                                            });
                                          },
                                          child: Container(
                                              margin: EdgeInsets.all(4),
                                              height: 50,
                                              width: 80,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          selectedIndex == index
                                                              ? orangeColor
                                                              : notifier.containerColor),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: selectedIndex == index
                                                      ? orangeColor
                                                      : notifier.containerColor),
                                              child: Center(
                                                child: Text(
                                                    manypeople[index]["people"],
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: "Gilroy Bold",
                                                      color:
                                                          selectedIndex == index
                                                              ? WhiteColor
                                                              : notifier.textColor,
                                                    )),
                                              )),
                                        ));
                                  },
                                ),
                              ),
                              SizedBox(height: Get.height * 0.03),
                              Text("What Time?".tr.toUpperCase(),
                                  style: TextStyle(
                                      fontFamily: "Gilroy Bold",
                                      fontSize: 15,
                                      color: notifier.textColor)),
                              GetBuilder<HomeController>(builder: (context) {
                                return SizedBox(
                                  height: 70,
                                  width: double.infinity,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    padding: EdgeInsets.zero,
                                    itemCount: times.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedIndex1 = index;
                                                selecttime = times[index]
                                                    .toString()
                                                    .split(" ")
                                                    .first;
                                                print(
                                                    "^^^^^^^^^^^^^^^^^^^^^^^^^^^"
                                                    "${selecttime}");
                                              });
                                            },
                                            child: Container(
                                                margin: EdgeInsets.all(4),
                                                height: 50,
                                                width: 90,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: selectedIndex1 ==
                                                                index
                                                            ? orangeColor
                                                            : notifier.containerColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color:
                                                        selectedIndex1 == index
                                                            ? orangeColor
                                                            : notifier.containerColor),
                                                child: Center(
                                                  child: Text(times[index],
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            "Gilroy Bold",
                                                        color: selectedIndex1 ==
                                                                index
                                                            ? WhiteColor
                                                            : notifier.textColor,
                                                      )),
                                                )),
                                          ));
                                    },
                                  ),
                                );
                              }),
                              SizedBox(height: Get.height * 0.03),
                              Text("Personal details".tr.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: "Gilroy Bold",
                                      color: notifier.textColor)),
                              SizedBox(height: Get.height * 0.01),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(getData.read("UserLogin")["name"],
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: "Gilroy Bold",
                                              color: notifier.textColor)),
                                      SizedBox(width: Get.width * 0.02),
                                      Text(
                                          getData.read("UserLogin")["ccode"] +
                                              getData
                                                  .read("UserLogin")["mobile"],
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: "Gilroy Bold",
                                              color: notifier.textColor)),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: Get.height * 0.01),
                              Text(getData.read("UserLogin")["email"],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: "Gilroy Bold",
                                      color: notifier.textColor)),
                              SizedBox(height: Get.height * 0.02),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Booking For Someone".tr,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: "Gilroy Bold",
                                          color: notifier.textColor)),
                                  Theme(
                                    data: ThemeData(
                                        unselectedWidgetColor: orangeColor),
                                    child: Checkbox(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          side:
                                              BorderSide(color: Colors.orange)),
                                      value: checkvalue,
                                      activeColor: orangeColor,
                                      checkColor: notifier.background,
                                      onChanged: (value) {
                                        setState(() {
                                          checkvalue = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  button(
                                      boxColor: transparent,
                                      borderbolor: cyan,
                                      buttontext: "Cancel".tr,
                                      textColor: cyan,
                                      onTap: () {
                                        Get.back();
                                        ApiWrapper.showToastMessage(
                                            "Booking cancelled".tr);
                                      }),
                                  SizedBox(width: Get.width * 0.02),
                                  button(
                                      borderbolor: pinkcolor,
                                      boxColor: pinkcolor,
                                      buttontext: "Save".tr,
                                      textColor: WhiteColor,
                                      onTap: () {
                                        hdetail.hoteldetail(id: widget.restid);
                                        if (selectedIndex != null &&
                                            selectedIndex1 != null) {
                                          if (checkvalue == true) {
                                            Get.back();
                                            changeDetails();
                                          } else {
                                            hoteldiscount.Tablebook(
                                                restid: widget.restid,
                                                bookdate:
                                                    selectedDate.toString(),
                                                bookfor: checkvalue
                                                    ? "other".tr
                                                    : "self".tr,
                                                booktime: selecttime,
                                                fullname: fullname.text,
                                                Emailaddress: Emailaddress.text,
                                                Mobile: Mobile.text,
                                                numpeople: Noofpeople);

                                            Get.to(() => PaymentSuccessfull(
                                                  day: selectedDate
                                                      .toString()
                                                      .split(" ")
                                                      .first,
                                                  people: Noofpeople,
                                                  time: selecttime,
                                                  hotelname: widget.hotelname,
                                                  hoteladdress: widget.address,
                                                ));
                                          }
                                        } else {
                                          ApiWrapper.showToastMessage(
                                              "Please select People & Time".tr);
                                        }
                                      })
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    );
                  }),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerTop,
              ),
            );
          });
        });
  }

  button(
      {String? buttontext,
      Color? textColor,
      borderbolor,
      boxColor,
      Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 165,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderbolor),
            color: boxColor),
        child: Center(
            child: Text(
          buttontext!,
          style: TextStyle(
              fontFamily: "Gilroy Bold", fontSize: 16, color: textColor),
        )),
      ),
    );
  }

  changeDetails() {
    return showModalBottomSheet(
        backgroundColor: notifier.background,
        isScrollControlled: true,
        context: context,
        // isDismissible: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: Get.height * 0.7,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              child: Scaffold(
                backgroundColor: notifier.background,
                floatingActionButton: Container(
                  transform: Matrix4.translationValues(
                      0.0, -80, 0.0), // translate up by 30
                  child: FloatingActionButton(
                    backgroundColor: notifier.textColor.withOpacity(0.5),
                    onPressed: () {
                      Get.back();
                    },
                    child: Icon(Icons.close),
                  ),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: Get.width * 0.28),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.hotelname}",
                              style: TextStyle(
                                  fontFamily: "Gilroy Bold",
                                  fontSize: 16,
                                  color: notifier.textColor),
                            ),
                            SizedBox(height: Get.height * 0.01),
                            Text("${widget.address}",
                                style: TextStyle(
                                    fontFamily: "Gilroy Medium",
                                    fontSize: 16,
                                    color: greycolor)),
                            SizedBox(height: Get.height * 0.015),
                            Edittextfeild(
                                hedingtext: "Full Name".tr,
                                hinttext: "Enter Your Name".tr,
                                controller: fullname),
                            SizedBox(height: Get.height * 0.015),
                            Edittextfeild(
                                hedingtext: "Email".tr,
                                hinttext: "Enter Your Email Address".tr,
                                controller: Emailaddress),
                            SizedBox(height: Get.height * 0.015),
                            Text(
                              "Mobile number".tr,
                              style: TextStyle(
                                  fontFamily: "Gilroy Bold",
                                  fontSize: 16,
                                  color: greycolor),
                            ),
                            SizedBox(height: Get.height * 0.01),
                            IntlPhoneField(
                              dropdownIcon: Icon(
                                Icons.arrow_drop_down,
                                color: notifier.textColor,
                              ),
                              dropdownTextStyle: TextStyle(
                                color: notifier.textColor,
                                fontSize: 14,
                              ),
                              style: TextStyle(
                                  fontFamily: "Gilroy Medium",
                                  color: notifier.textColor),
                              keyboardType: TextInputType.number,
                              controller: Mobile,
                              cursorColor: const Color(0xff4361EE),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                fillColor: transparent,
                                filled: true,
                                hintText: 'Enter your Phone Number.tr',
                                hintStyle: const TextStyle(
                                  fontFamily: 'Gilroy Medium',
                                  // fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xffAAACAE),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xffF3F3FA)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: darkpurple),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: greycolor.withOpacity(0.5),
                                    ),
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                              initialCountryCode: 'IN',
                              invalidNumberMessage:
                                  'please enter your phone number '.tr,
                              onChanged: (phone) {
                                Country = phone.countryCode;
                                print(phone.countryCode);
                              },
                            ),
                            SizedBox(height: Get.height * 0.03),
                            AppButton(
                                buttonColor: pinkcolor,
                                width: double.infinity,
                                buttontext: "Save Changes".tr,
                                onTap: () {
                                  hoteldiscount.Tablebook(
                                      restid: widget.restid,
                                      bookdate: selectedDate.toString(),
                                      bookfor: checkvalue ? "other" : "self",
                                      booktime: DateTime.now().toString(),
                                      fullname: fullname.text,
                                      Emailaddress: Emailaddress.text,
                                      Mobile: Mobile.text,
                                      numpeople: Noofpeople);
                                  Get.to(() => PaymentSuccessfull(
                                        day: selectedDate
                                            .toString()
                                            .split(" ")
                                            .first,
                                        people: Noofpeople,
                                        time: selecttime,
                                        hotelname: widget.hotelname,
                                        hoteladdress: widget.address,
                                      ));
                                })
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerTop,
              ),
            );
          });
        });
  }

  Edittextfeild(
      {String? hinttext, hedingtext, TextEditingController? controller}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hedingtext,
                style: TextStyle(
                    fontFamily: "Gilroy Bold", fontSize: 16, color: greycolor)),
            Text("*",
                style: TextStyle(
                    fontFamily: "Gilroy Bold", fontSize: 20, color: greycolor)),
          ],
        ),
        Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: TextField(
            cursorColor: notifier.textColor,
            controller: controller,
            style: TextStyle(
                color: notifier.textColor, fontFamily: "Gilroy Medium", fontSize: 16),
            decoration: InputDecoration(
              hintText: hinttext,
              // prefix: Text("data"),
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              hintStyle: TextStyle(color: greycolor),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: greycolor.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(15)),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: cyan),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}