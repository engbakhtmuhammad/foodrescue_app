// ignore_for_file: sized_box_for_whitespace, file_names, prefer_const_literals_to_create_immutables, non_constant_identifier_names, avoid_print, unrelated_type_equality_checks, unused_local_variable, must_be_immutable, prefer_const_constructors, no_leading_underscores_for_local_identifiers, unused_element, deprecated_member_use, prefer_interpolation_to_compose_strings, unnecessary_brace_in_string_interps, prefer_const_declarations, dead_code, prefer_final_fields, unnecessary_null_comparison, unnecessary_new, library_private_types_in_public_api, unused_import, unused_field
import 'dart:ui';
import 'package:foodrescue_app/controllers/home_controller.dart';
import 'package:foodrescue_app/Getx_Controller/Hotel_details_Controller.dart';
import 'package:foodrescue_app/Hotel%20Menu/Gallery.dart';
import 'package:foodrescue_app/Hotel%20Menu/Menu.dart';
import 'package:foodrescue_app/Tabbar/Tab1.dart';
import 'package:foodrescue_app/Tabbar/Tab2.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:foodrescue_app/Utils/String.dart';
import 'package:foodrescue_app/Utils/image.dart';
import 'package:foodrescue_app/api/Data_save.dart';
import 'package:foodrescue_app/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_view/story_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Utils/dark_light_mode.dart';

class HotelDetails extends StatefulWidget {
  String? detailId;
  HotelDetails({this.detailId, super.key});

  @override
  State<HotelDetails> createState() => _HotelDetailsState();
}

class _HotelDetailsState extends State<HotelDetails>
    with SingleTickerProviderStateMixin {
  final StoryController storyController = StoryController();
  final StoryController storyController1 = StoryController();
  bool _pinned = true;
  bool _snap = false;
  bool _floating = false;

  @override
  void initState() {
    getDarkMode();
    hoteldata.hoteldetail(id: widget.detailId);
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

  TabController? controller;
  HoteldetailController hoteldata = Get.put(HoteldetailController());
  HomeController homeapi = Get.find<HomeController>();

  List strarray = [];
  int selectedIndex1 = 0;
  int getTime(int hour, int min) {
    TimeOfDay n = TimeOfDay.now();
    int nowSec = (n.hour * 60 + n.minute) * 60;
    int veiSec = (hour * 60 + min) * 60;
    int dif = veiSec - nowSec;
    print("==dif=${dif}");
    return dif;
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

    List<Widget>  tab = [
      GetBuilder<HoteldetailController>(builder: (context) {
        return Tab1(
          restid: widget.detailId,
          address: hoteldata.hoteldetails["fullAddress"]?.toString() ?? "No address",
          hotelname: hoteldata.hoteldetails["title"]?.toString() ?? "Restaurant",
          tip: hoteldata.hoteldetails["mondayThursdayOffer"]?.toString() ?? "0",
        );
      }),
      GetBuilder<HoteldetailController>(builder: (context) {
        return Tab2(
            restid: widget.detailId,
            address: hoteldata.hoteldetails["fullAddress"]?.toString() ?? "No address",
            hotelname: hoteldata.hoteldetails["title"]?.toString() ?? "Restaurant",
            tip: hoteldata.hoteldetails["fridaySundayOffer"]?.toString() ?? "0");
      }),
    ];

    return Scaffold(
        backgroundColor: notifier.background,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: notifier.background,
              floating: true,
              pinned: _pinned,
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: GestureDetector(
                  onTap: (){
                    Get.back();
                  },
                  child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back,size: 22,color: BlackColor,)),
                ),
              ),
              iconTheme: IconThemeData(color: notifier.textColor),
              expandedHeight: Get.height * 0.3,
              flexibleSpace: FlexibleSpaceBar(
                background: GetBuilder<HoteldetailController>(
                  builder: (context) {
                    return hoteldata.isLoading ? Stack(
                      children: [
                        GetBuilder<HoteldetailController>(builder: (context) {
                          String time = hoteldata.hoteldetails["openTime"]?.toString() ?? "09:00";
                          String closetime = hoteldata.hoteldetails["closeTime"]?.toString() ?? "22:00";
                          List<String> durations = time.split(':');
                          List<String> close = closetime.split(':');
                          print('${durations[0]} hours ${durations[1]} minutes ');
                          return getTime(int.parse(durations[0]),
                                      int.parse(durations[1])) <=
                                  0 //open time
                              ? getTime(int.parse(close[0]), int.parse(close[1])) >=
                                      0 //close time
                                  ? Container(
                                      height: Get.height * 0.35,
                                      width: double.infinity,
                                      color: notifier.textColor,
                                      child: carouselSliderWidget(),
                                    )
                                  : Lottie.asset(
                                      'assets/96375-dineout-temp-closed.json',
                                      width: 350,
                                      height: Get.height * 0.35,
                                      fit: BoxFit.cover,
                                    )
                              : Lottie.asset(
                                  'assets/96375-dineout-temp-closed.json',
                                  width: 350,
                                  height: Get.height * 0.35,
                                  fit: BoxFit.cover,
                                );
                        }),
                        Positioned(
                          bottom: 24,
                          right: 12,
                          child: InkWell(
                            onTap: () {
                              Get.to(() => Gallery(galleryid: widget.detailId));
                            },
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 8),
                                  // width: Get.width,
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.4),
                                      borderRadius:  BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        provider.viewgall.tr,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Gilroy Bold",
                                            fontSize: 13),
                                      ),
                                      Icon(Icons.arrow_forward_ios_rounded,
                                          size: 15, color: Colors.white)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                        : Center(
                    child: Padding(
                    padding: EdgeInsets.only(top: Get.height * 0.4),
                    child:  CircularProgressIndi(),
                    ));
                  }
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: GetBuilder<HoteldetailController>(builder: (context) {
                return hoteldata.isLoading
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: Get.height * 0.03),
                                GetBuilder<HoteldetailController>(
                                    builder: (context) {
                                  String opentime =
                                      "2023-03-20T${hoteldata.hoteldetails["openTime"]?.toString() ?? "09:00"}";
                                  return Text(
                                    "Open time: ${DateFormat.jm().format(DateTime.parse(opentime))}"
                                        .toUpperCase(),
                                    style: TextStyle(
                                        fontFamily: "Gilroy Medium",
                                        color: notifier.textColor,
                                        letterSpacing: 3,
                                        fontSize: 12),
                                  );
                                }),
                                SizedBox(height: Get.height * 0.02),
                                GetBuilder<HoteldetailController>(
                                    builder: (context) {
                                  String closetime =
                                      "2023-03-20T${hoteldata.hoteldetails["closeTime"]?.toString() ?? "22:00"}";
                                  return Text(
                                    "Close time: ${DateFormat.jm().format(DateTime.parse(closetime))}"
                                        .toUpperCase(),
                                    style: TextStyle(
                                        fontFamily: "Gilroy Medium",
                                        color: notifier.textColor,
                                        letterSpacing: 3,
                                        fontSize: 12),
                                  );
                                }),
                                SizedBox(height: Get.height * 0.02),
                                Text(
                                  hoteldata.hoteldetails["title"]?.toString() ?? "Restaurant",
                                  style: TextStyle(
                                      fontFamily: "Gilroy ExtraBold",
                                      color: notifier.textColor,
                                      fontSize: 24),
                                ),
                                SizedBox(height: Get.height * 0.02),
                                SizedBox(
                                  width: Get.width * 0.92,
                                  child: Text(
                                    hoteldata.hoteldetails["shortDescription"]?.toString() ?? "No shortDescription available",
                                    style: TextStyle(
                                        fontFamily: "Gilroy Medium",
                                        color: greycolor,
                                        fontSize: 16),
                                  ),
                                ),
                                SizedBox(height: Get.height * 0.02),
                                Text(
                                  "Popular Dishes".tr,
                                  style: TextStyle(
                                      fontFamily: "Gilroy Bold",
                                      color: notifier.textColor,
                                      fontSize: 16),
                                ),
                                SizedBox(height: Get.height * 0.02),
                                GetBuilder<HoteldetailController>(
                                    builder: (context) {
                                  String str =
                                      hoteldata.hoteldetails["popularDishes"]?.toString() ?? "";
                                  strarray = str.split(",");
                                  return GridView(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 6,
                                              mainAxisSpacing: 6,
                                              childAspectRatio: 2.2),
                                      children: strarray.map((word) {
                                        return Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              color: notifier.containerColor),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 6),
                                          // height: 20,

                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                "assets/badgecheck.png",
                                                height: 15,
                                              ),
                                              SizedBox(width: Get.width * 0.01),
                                              SizedBox(
                                                width: Get.width * 0.21,
                                                child: Text(
                                                  word,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: notifier.textColor,
                                                      fontFamily:
                                                          "Gilroy MEdium",
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList());
                                }),
                                SizedBox(height: Get.height * 0.035),
                                dottedline(),
                                SizedBox(height: Get.height * 0.03),
                                Row(
                                  children: [
                                    Image.asset(image.staricon,
                                        height: 16, color: yelloColor),
                                    SizedBox(width: Get.width * 0.02),
                                    Text(
                                      hoteldata.hoteldetails["rating"]?.toString() ?? "0.0",
                                      style: TextStyle(
                                          fontFamily: "Gilroy Bold",
                                          color: notifier.textColor,
                                          fontSize: 16),
                                    ),
                                    SizedBox(width: Get.width * 0.02),
                                    CircleAvatar(
                                      radius: 2,
                                      backgroundColor: greycolor,
                                    ),
                                    SizedBox(width: Get.width * 0.02),
                                    Text(
                                      "${homeapi.homeDataList["currency"]}${hoteldata.hoteldetails["approxPrice"]?.toString() ?? "0"}",
                                      style: TextStyle(
                                          fontFamily: "Gilroy Bold",
                                          color: notifier.textColor,
                                          fontSize: 16),
                                    ),
                                    SizedBox(width: Get.width * 0.02),
                                    Text(
                                      provider.fortwo.tr,
                                      style: TextStyle(
                                          fontFamily: "Gilroy Medium",
                                          color: greycolor,
                                          fontSize: 15),
                                    ),
                                  ],
                                ),
                                SizedBox(height: Get.height * 0.03),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                       color: notifier.containerColor),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: Get.height * 0.01),
                                      RichText(
                                        text: TextSpan(
                                          text: provider.gold.tr,
                                          style: TextStyle(
                                              fontFamily: "Gilroy ExtraBold",
                                              color: notifier.textColor,
                                              fontSize: 18),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: provider.Benefits.tr,
                                                style: TextStyle(
                                                    fontFamily: "Gilroy Bold",
                                                    fontSize: 16,
                                                    color: notifier.textColor)),
                                          ],
                                        ),
                                      ),
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                      GetBuilder<HoteldetailController>(
                                          builder: (context) {
                                        return Container(
                                          alignment: Alignment.centerLeft,
                                          height: Get.height * 0.07,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        bottom: BorderSide(
                                                            color: notifier.background,
                                                            width: 2))),
                                                child: TabBar(
                                                  labelStyle: const TextStyle(
                                                      fontFamily:
                                                          'Gilroy Bold'),
                                                  indicatorSize:
                                                      TabBarIndicatorSize.label,
                                                  indicator: MD2Indicator(
                                                    indicatorSize:
                                                        MD2IndicatorSize.full,
                                                    indicatorHeight: 5,
                                                    indicatorColor: orangeColor,
                                                  ),
                                                  indicatorColor: orangeColor,
                                                  indicatorWeight: 2,
                                                  controller: controller,
                                                  indicatorPadding:
                                                      EdgeInsets.zero,
                                                  labelPadding: EdgeInsets.zero,
                                                  labelColor:
                                                      selectedIndex1 == 0
                                                          ? orangeColor
                                                          : darkpurple,
                                                  unselectedLabelColor:
                                                      notifier.textColor,
                                                  tabs:  [
                                                    Tab(
                                                      child: Text(
                                                        "Mon-Thu".tr,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Gilroy Bold',
                                                            fontSize: 15),
                                                      ),
                                                    ),
                                                    Tab(
                                                      child: Text(
                                                        "Fri-Sun".tr,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Gilroy Bold',
                                                            fontSize: 15),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      SizedBox(height: Get.height * 0.02),
                                      GetBuilder<HoteldetailController>(
                                          builder: (context) {
                                        return Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: RedColor),
                                          width: double.infinity,
                                          child: SizedBox(
                                            height: hoteldata.hoteldetails[
                                                        "tShow"] !=
                                                    "0"
                                                ? Get.height * 0.22
                                                : Get.height * 0.14,
                                            width: Get.height * 0.1,
                                            child: TabBarView(
                                              controller: controller,
                                              children: tab
                                                  .map((tab) => tab)
                                                  .toList(),
                                            ),
                                          ),
                                          // child: SizedBox(
                                          //   height: hoteldata.hoteldetails[
                                          //               "show_table"] ==
                                          //           "0"
                                          //       ? Get.height * 0.07
                                          //       : Get.height * 0.20,
                                          //   width: Get.height * 0.1,
                                          //   child: TabBarView(
                                          //     controller: controller,
                                          //     children: tab
                                          //         .map((tab) => tab)
                                          //         .toList(),
                                          //   ),
                                          // ),
                                        );
                                      })
                                    ],
                                  ),
                                ),

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                SizedBox(height: Get.height * 0.03),
                                Text(
                                  provider.Location.tr,
                                  style: TextStyle(
                                      fontFamily: 'Gilroy Bold',
                                      fontSize: 16,
                                      color: notifier.textColor),
                                ),
                                SizedBox(height: Get.height * 0.03),
                                SizedBox(
                                  width: Get.width * 0.80,
                                  child: RichText(
                                    text: TextSpan(
                                      text: hoteldata.hoteldetails["fullAddress"]?.toString() ?? "No address available",
                                      style: TextStyle(
                                          fontFamily: "Gilroy Medium",
                                          color: greycolor,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                                SizedBox(height: Get.height * 0.03),
                                InkWell(
                                  onTap: () {
                                    openMap(
                                        double.tryParse(
                                            hoteldata.hoteldetails["latitude"]?.toString() ?? "0.0") ?? 0.0,
                                        double.tryParse(hoteldata
                                            .hoteldetails["longtitude"]?.toString() ?? "0.0") ?? 0.0);
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      text:
                                          "${hoteldata.hoteldetails["rest_distance"]?.toString() ?? "0.0"} away |",
                                      style: TextStyle(
                                          fontFamily: "Gilroy Medium",
                                          color: orangeColor,
                                          fontSize: 16),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: provider.viewon,
                                            style: TextStyle(
                                                fontFamily: "Gilroy Medium",
                                                fontSize: 16,
                                                color: orangeColor)),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                    color: orangeColor,
                                    endIndent: 120,
                                    thickness: 1),
                                SizedBox(height: Get.height * 0.03),
                                viewmenu(
                                    onTap: () {
                                      Get.to(() => Menu(
                                            viewmenuid: widget.detailId,
                                          ));
                                    },
                                    image: image.openbook,
                                    titletext: provider.viewmenu,
                                    Subtext: "Pages"),
                                SizedBox(height: Get.height * 0.03),
                                dottedline(),
                                SizedBox(height: Get.height * 0.03),
                                viewmenu(
                                    onTap: () async {
                                      Uri phoneno = Uri.parse(
                                          'tel:${hoteldata.hoteldetails["mobile"]?.toString() ?? ""}');
                                      if (await launchUrl(phoneno)) {
                                        //dialer opened
                                      } else {
                                        //dailer is not opened
                                      }
                                    },
                                    image: image.telephone,
                                    titletext: provider.Call,
                                    Subtext: hoteldata.hoteldetails["mobile"]?.toString() ?? "No phone number"),
                                SizedBox(height: Get.height * 0.03),
                                Text(
                                  provider.Features,
                                  style: TextStyle(
                                      fontFamily: 'Gilroy Bold',
                                      fontSize: 17,
                                      color: notifier.textColor),
                                ),
                                SizedBox(height: Get.height * 0.03),
                                GetBuilder<HoteldetailController>(
                                    builder: (context) {
                                  return ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: hoteldata.restdata.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Column(
                                        children: [
                                          Row(
                                            children: [
                                              Image.network(
                                                  hoteldata.restdata[index]["img"] ?? "https://picsum.photos/30/30",
                                                  height: 30,
                                                  width: 30),
                                              SizedBox(width: Get.width * 0.04),
                                              SizedBox(
                                                child: Text(
                                                  hoteldata.restdata[index]["title"]?.toString() ?? "Feature",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'Gilroy Medium',
                                                      fontSize: 15,
                                                      color: notifier.textColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: Get.height * 0.02),
                                        ],
                                      );
                                    },
                                  );
                                }),
                                SizedBox(height: Get.height * 0.015),
                                Text(
                                  "Similar Restaurants".tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Gilroy Bold',
                                      fontSize: 18,
                                      color: notifier.textColor),
                                ),
                                SizedBox(height: Get.height * 0.02),
                                GetBuilder<HoteldetailController>(
                                    builder: (context) {
                                  return SizedBox(
                                    height: Get.height * 0.5,
                                    width: double.infinity,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemCount: hoteldata.relatedrest.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        HotelDetails(
                                                          detailId: hoteldata
                                                                  .relatedrest[
                                                              index]["id"],
                                                        )));
                                          },
                                          child: Stack(
                                            children: [
                                              Container(
                                                  margin:
                                                      const EdgeInsets.all(6),
                                                  height: Get.height * 0.5,
                                                  width: Get.height * 0.40,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                          color: greycolor.withOpacity(0.4))),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    child: Stack(
                                                      children: [
                                                        FadeInImage
                                                            .assetNetwork(
                                                          fadeInCurve:
                                                              Curves.easeInCirc,
                                                          placeholder:
                                                              "assets/ezgif.com-crop.gif",
                                                          height:
                                                              Get.height * 0.4,
                                                          width:
                                                              double.infinity,
                                                          placeholderCacheHeight:
                                                              320,
                                                          placeholderCacheWidth:
                                                              240,
                                                          placeholderFit:
                                                              BoxFit.fill,
                                                          // placeholderScale: 1.0,
                                                          image: AppUrl
                                                                  .imageurl +
                                                              hoteldata
                                                                      .relatedrest[
                                                                  index]["img"],
                                                          fit: BoxFit.cover,
                                                        ),
                                                        Positioned(
                                                          child: Container(
                                                            height: MediaQuery.of(context).size.height * 0.5, //imagee size
                                                            decoration: BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    begin: Alignment.topCenter,
                                                                    end: Alignment.bottomCenter,
                                                                    stops: [0.4, 0.7, 2],
                                                                    colors: [
                                                                  Colors.transparent,
                                                                  Colors.black,
                                                                      Colors.black])),
                                                          ),
                                                        ),
                                                        Positioned(
                                                            top: -10,
                                                            right: 40,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              height:
                                                                  Get.height *
                                                                      0.12,
                                                              width: Get.width *
                                                                  0.48,
                                                              color: darkpurple
                                                                  .withOpacity(
                                                                      0.5),
                                                              child: Container(
                                                                height:
                                                                    Get.height *
                                                                        0.08,
                                                                width:
                                                                    Get.width *
                                                                        0.34,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        color:
                                                                            notifier.textColor)),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    GetBuilder<
                                                                            HoteldetailController>(
                                                                        builder:
                                                                            (context) {
                                                                      String
                                                                          currentdiscount =
                                                                          "";
                                                                      DateTime
                                                                          date =
                                                                          DateTime
                                                                              .now();
                                                                      String
                                                                          dateFormat =
                                                                          DateFormat('EEEE')
                                                                              .format(date);
                                                                      if (dateFormat == "Friday" ||
                                                                          dateFormat ==
                                                                              "Saturday" ||
                                                                          dateFormat ==
                                                                              "Sunday") {
                                                                        currentdiscount =
                                                                            hoteldata.relatedrest[index]["fridaySundayOffer"]?.toString() ?? "0";
                                                                      } else {
                                                                        currentdiscount =
                                                                            hoteldata.relatedrest[index]["mondayThursdayOffer"]?.toString() ?? "0";
                                                                      }
                                                                      return Text(
                                                                          "${currentdiscount}% OFF",
                                                                          style: TextStyle(
                                                                              fontFamily: "Gilroy Bold",
                                                                              color: notifier.background,
                                                                              fontSize: 20));
                                                                    }),
                                                                    SizedBox(
                                                                        height: Get.height *
                                                                            0.01),
                                                                    Text(
                                                                      provider.Today.tr.toUpperCase(),
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              "Gilroy Medium",
                                                                          color: notifier.background,
                                                                          fontSize:
                                                                              12),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            )),
                                                      ],
                                                    ),
                                                  )),
                                              Positioned(
                                                  left: 16,
                                                  bottom: 0,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          hoteldata.relatedrest[index]["title"]?.toString() ?? "Restaurant",
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "Gilroy Bold",
                                                              fontSize: 18,
                                                              color:
                                                                  WhiteColor)),
                                                      SizedBox(
                                                          height: Get.height *
                                                              0.006),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .star_rate_rounded,
                                                              color: yelloColor,
                                                              size: 22),
                                                          Text(
                                                            hoteldata
                                                                    .relatedrest[
                                                                index]["rating"]
                                                                    ?.toString() ?? "0.0" ,
                                                            style: TextStyle(
                                                                color:
                                                                    greycolor,
                                                                fontFamily:
                                                                    "Gilroy Bold",
                                                                fontSize: 16),
                                                          ),
                                                          SizedBox(
                                                              width: Get.width *
                                                                  0.01),
                                                          CircleAvatar(
                                                              radius: 2,
                                                              backgroundColor:
                                                                  greycolor),
                                                          SizedBox(
                                                              width: Get.width *
                                                                  0.02),
                                                          Text(
                                                            hoteldata.relatedrest[index]["area"]?.toString() ?? "No address",
                                                            style: TextStyle(
                                                                color:
                                                                    greycolor,
                                                                fontFamily:
                                                                    "Gilroy Bold",
                                                                fontSize: 16),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                          height: Get.height *
                                                              0.005),
                                                      SizedBox(
                                                        width: Get.width * 0.50,
                                                        child: Text(
                                                          hoteldata.relatedrest[index]["shortDescription"]?.toString() ?? "No shortDescription",
                                                          style: TextStyle(
                                                              color: greycolor,
                                                              fontFamily:
                                                                  "Gilroy Medium",
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height:
                                                              Get.height * 0.03)
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }),
                                SizedBox(height: Get.height * 0.04)
                              ],
                            ),
                          )
                        ],
                      )
                    : Center(
                        child:  CircularProgressIndi());
              }),
            ),
          ],
        ),
    );
  }

  viewmenu({String? image, titletext, Subtext, Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            height: 50,
            width: 55,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), color: orangeColor),
            child: Image.asset(image!, height: 20, color: WhiteColor),
          ),
          SizedBox(width: Get.width * 0.03),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titletext,
                style: TextStyle(
                    fontFamily: 'Gilroy Bold', fontSize: 16, color: notifier.textColor),
              ),
              SizedBox(height: Get.height * 0.005),
              Text(
                Subtext,
                style: TextStyle(
                    fontFamily: 'Gilroy Medium',
                    fontSize: 16,
                    color: greycolor),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget carouselSliderWidget() {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: StoryView(
        indicatorColor: notifier.textColor,
        storyItems: [
          for (var i = 0; i < hoteldata.storyview.length; i++)
            StoryItem.inlineImage(
                url: hoteldata.storyview[i]["image"] ?? "https://picsum.photos/400/600",
                controller: storyController),
        ],
        // onStoryShow: (s) {
        //   if (storycontroller1 == true) {
        //   } else {}
        // },
        onComplete: () {
          print("Completed a cycle");
        },
        progressPosition: ProgressPosition.bottom,
        repeat: true,
        inline: true,
        controller: storyController,
      ),
    );
  }

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

}

class MD2Indicator extends Decoration {
  final double indicatorHeight;
  final Color indicatorColor;
  final MD2IndicatorSize indicatorSize;
  const MD2Indicator({
    required this.indicatorHeight,
    required this.indicatorColor,
    required this.indicatorSize,
  });
  @override
  _MD2Painter createBoxPainter([VoidCallback? onChanged]) {
    return new _MD2Painter(this, onChanged!);
  }
}

enum MD2IndicatorSize {
  tiny,
  normal,
  full,
}

class _MD2Painter extends BoxPainter {
  final MD2Indicator decoration;
  _MD2Painter(this.decoration, VoidCallback onChanged)
      : assert(decoration != null),
        super(onChanged);
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);
    Rect? rect;
    if (decoration.indicatorSize == MD2IndicatorSize.full) {
      rect = Offset(offset.dx,
              (configuration.size!.height - decoration.indicatorHeight)) &
          Size(configuration.size!.width, decoration.indicatorHeight);
    } else if (decoration.indicatorSize == MD2IndicatorSize.normal) {
      rect = Offset(offset.dx + 6,
              (configuration.size!.height - decoration.indicatorHeight)) &
          Size(configuration.size!.width - 12, decoration.indicatorHeight);
    } else if (decoration.indicatorSize == MD2IndicatorSize.tiny) {
      rect = Offset(offset.dx + configuration.size!.width / 2 - 8,
              (configuration.size!.height - decoration.indicatorHeight)) &
          Size(16, decoration.indicatorHeight);
    }
    final Paint paint = Paint();
    paint.color = decoration.indicatorColor;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndCorners(rect!,
            topRight: Radius.circular(8), topLeft: Radius.circular(8)),
        paint);
  }
}
