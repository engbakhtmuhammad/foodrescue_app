// ignore_for_file: file_names, prefer_const_constructors, sized_box_for_whitespace, unused_import, sort_child_properties_last, non_constant_identifier_names, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps, avoid_print, prefer_typing_uninitialized_variables, unused_local_variable, unused_field, prefer_final_fields, prefer_interpolation_to_compose_strings, avoid_types_as_parameter_names
// ignore_for_file: camel_case_types, use_key_in_widget_constructors, annotate_overrides, unused_element, avoid_unnecessary_containers,  deprecated_member_use
// Do not use this page for now as we are using newHomePage.dart for now to achieve the TGTG
import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:foodrescue_app/controllers/home_controller.dart';
import 'package:foodrescue_app/controllers/Hotel_details_Controller.dart';
import 'package:foodrescue_app/controllers/Membership_controller.dart';
import 'package:foodrescue_app/controllers/Near_By_controller.dart';
import 'package:foodrescue_app/controllers/PaymentGetwey_controller.dart';
// Plan functionality removed as requested
import 'package:foodrescue_app/views/restaurant/Cuisines.dart';
import 'package:foodrescue_app/views/restaurant/Hotel_Details.dart';
import 'package:foodrescue_app/views/restaurant/Nearby_hotel.dart';
import 'package:foodrescue_app/views/notification/Notification.dart';
import 'package:foodrescue_app/views/bags/View_details.dart';
import 'package:foodrescue_app/views/bags/SurpriseBagDetails.dart';
import 'package:foodrescue_app/views/browse/LocationRadiusPage.dart';
import 'package:foodrescue_app/views/onboarding/IntroScreen.dart';
import 'package:foodrescue_app/views/auth/Login_In.dart';
import 'package:foodrescue_app/views/Profile/Profile.dart';
import 'package:foodrescue_app/Utils/Bottom_bar.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:foodrescue_app/Utils/String.dart';
import 'package:foodrescue_app/Utils/image.dart';
import 'package:foodrescue_app/utils/api_wrapper.dart';
import 'package:foodrescue_app/api/Data_save.dart';
import 'package:foodrescue_app/config/app_config.dart';

import 'package:foodrescue_app/views/Payment/FlutterWave.dart';
import 'package:foodrescue_app/views/Payment/InputFormater.dart';
import 'package:foodrescue_app/views/Payment/PaymentCard.dart';
import 'package:foodrescue_app/views/Payment/Paypal.dart';
import 'package:foodrescue_app/views/Payment/Paytm.dart';
import 'package:foodrescue_app/views/Payment/StripeWeb.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_paypal/flutter_paypal.dart';

// import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Payment/web_view.dart';
import '../../Utils/dark_light_mode.dart';
import '../Payment/PayStack.dart';

String? uID;
// bool tablebookscreen = false;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

var lat;
var long;

class _HomePageState extends State<HomePage> {
  // Homepage? homepage;

  @override
  void initState() {
    super.initState();
    setState(() {
      payment.paymentgateway();
      // Controller will load ALL restaurants automatically without location requirements
      print("HomePage initState completed - controller will load ALL restaurants");
    });
    // Initialize filtered lists
    _initializeFilteredLists();
    // plugin.initialize(publicKey: AppUrl.publicKeyTest);
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _initializeFilteredLists() {
    // Initialize with all data
    filteredRestaurants = List.from(hData.allrest);
    filteredSurpriseBags = List.from(hData.surpriseBags);
  }

  void _filterByCategory() {
    if (selectedCategory == "all") {
      filteredRestaurants = List.from(hData.allrest);
      filteredSurpriseBags = List.from(hData.surpriseBags);
    } else {
      // Filter restaurants by cuisine
      filteredRestaurants = hData.allrest.where((restaurant) {
        if (restaurant["cuisines"] != null) {
          List<String> cuisines = restaurant["cuisines"].toString().split(',');
          return cuisines.any((cuisine) =>
            cuisine.trim().toLowerCase().contains(selectedCategory.toLowerCase())
          );
        }
        return false;
      }).cast<Map<String, dynamic>>().toList();

      // Filter surprise bags by restaurant cuisine
      filteredSurpriseBags = hData.surpriseBags.where((bag) {
        final restaurant = hData.allrest.firstWhere(
          (r) => r["id"] == bag["restaurantId"],
          orElse: () => {},
        );

        if (restaurant.isNotEmpty && restaurant["cuisines"] != null) {
          List<String> cuisines = restaurant["cuisines"].toString().split(',');
          return cuisines.any((cuisine) =>
            cuisine.trim().toLowerCase().contains(selectedCategory.toLowerCase())
          );
        }
        return false;
      }).cast<Map<String, dynamic>>().toList();
    }
    setState(() {});
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Plan functionality removed as requested
    print("Payment success but plan functionality disabled: ${response.paymentId}");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print(
        'Error Response: ${"ERROR: " + response.code.toString() + " - " + response.message!}');
    showToastMessage(response.message!);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    showToastMessage(response.walletName!);
  }

  @override
  void dispose() {
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardTypee cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      _paymentCard.type = cardType;
    });
  }

  String? SelectedIndex;
  int currentindex = 0;
  bool selected = true;
  // Plan-related variables removed as requested

  // Category filtering variables
  String selectedCategory = "all";
  List<Map<String, dynamic>> filteredRestaurants = [];
  List<Map<String, dynamic>> filteredSurpriseBags = [];

  var first;
  var address;
  String selectidPay = "0";
  String razorpaykey = "";
  String? paymenttital;
  int? _groupValue;
  // Plan-related variables (disabled but kept for compatibility)
  String? planid = "";
  String planprice = "0";
  String? plan1 = "";
  String? plan2 = "";
  bool defultplan = false;
  final _paymentCard = PaymentCardCreated();
  var currency;
  var _autoValidateMode = AutovalidateMode.disabled;
  int currentTotalprice = 0;
  final _formKey = GlobalKey<FormState>();
  final _card = PaymentCardCreated();
  var numberController = TextEditingController();
  late Razorpay _razorpay;

  // final plugin = PaystackPlugin();
  PaystackController paystackCont = Get.put(PaystackController());
  HomeController hData = Get.find<HomeController>();

  // Plan functionality disabled - dummy object for compatibility
  var planpurchase = _DummyPlanPurchase();
  PaymentgatewayController payment = Get.put(PaymentgatewayController());

  // MembershipController membership = Get.put(MembershipController());
  String? accessToken = "";
  String payerID = "";
  String totelbill = "0";

  Future getUserLocation() async {
    print("getUserLocation() called");
    setState(() {});
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    print("Location permission check: $permission");
    permission = await Geolocator.requestPermission();
    print("Location permission request: $permission");
    if (permission == LocationPermission.denied) {
      print("Location permission denied!");
    }
    try {
      var currentLocation = await locateUser();
      debugPrint('location: ${currentLocation.latitude}');
      lat = currentLocation.latitude;
      long = currentLocation.longitude;
      print("Location retrieved successfully: $lat, $long");

      List<Placemark> addresses = await placemarkFromCoordinates(
          currentLocation.latitude, currentLocation.longitude);
      print("Addresses retrieved: ${addresses.length}");

      await placemarkFromCoordinates(
          currentLocation.latitude, currentLocation.longitude)
          .then((List<Placemark> placemarks) {
        Placemark place = placemarks[0];
        setState(() {
          address = '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
        });
        print("Address set: $address");
      }).catchError((e) {
        debugPrint("Error in address resolution: $e");
      });

      first = addresses.first.name;
      print("FIRST ${address}");
      // address ='${address.street}, ${address.subLocality}, ${address.subAdministrativeArea}, ${address.postalCode}';

      // Controller handles data loading automatically
      setState(() {});
      print("getUserLocation() completed");
    } catch (e) {
      print("Error in getUserLocation(): $e");
      // Controller handles data loading automatically
    }
  }

  Future getUserLocation1() async {
    print("getUserLocation1() called");
    setState(() {});
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    print("Location permission check: $permission");
    permission = await Geolocator.requestPermission();
    print("Location permission request: $permission");
    if (permission == LocationPermission.denied) {
      print("Location permission denied!");
    }
    try {
      var currentLocation = await locateUser();
      debugPrint('location: ${currentLocation.latitude}');
      lat = currentLocation.latitude;
      long = currentLocation.longitude;
      print("Location retrieved successfully: $lat, $long");

      // Controller handles data loading automatically
      setState(() {});
      print("getUserLocation1() completed");
    } catch (e) {
      print("Error in getUserLocation1(): $e");
      // Controller handles data loading automatically
    }
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(

        desiredAccuracy: LocationAccuracy.high);
  }
  late ColorNotifier notifier;
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    Future.delayed(Duration(seconds: 0), () {
      setState(() {});
    });

    return WillPopScope(
      onWillPop: () {
        exit(0);
      },
      child: Scaffold(
        // Plan section removed as requested
        // bottomNavigationBar: GetBuilder<HomeController>(builder: (context) {
        //   return hData.homeDataList["is_subscribe"] == 0
        //       ? bottombar(
        //       Hedingtext: "special prices only for you".tr.toUpperCase(),
        //       bgcolor: transparent,
        //       buttontext1: "select a plan".tr.toUpperCase(),
        //       onTap: bottomsheet)
        //       : SizedBox();
        // }),
        backgroundColor: notifier.background,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: notifier.background,
            toolbarHeight: 80,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Good evening!",
                  style: TextStyle(
                    color: notifier.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    Get.to(() => LocationRadiusPage());
                  },
                  child: Row(
                    children: [
                      Obx(() => hData.isGettingLocation.value
                        ? SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(orangeColor),
                            ),
                          )
                        : Icon(
                            Icons.location_on,
                            size: 16,
                            color: orangeColor,
                          ),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hData.currentAddress.value.isNotEmpty
                            ? hData.currentAddress.value
                            : "Getting location...",
                          style: TextStyle(
                            color: notifier.textColor.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: notifier.textColor.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Get.to(() => Notificationpage());
                },
                icon: Stack(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: notifier.textColor,
                      size: 24,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: orangeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
            ],
            ),
        body: RefreshIndicator(
          onRefresh: () {
            return Future.delayed(
              Duration(seconds: 2), () {
                // Refresh ALL restaurants data
                hData.homeDataApi();
              },
            );
          },
          child: SingleChildScrollView(
              child: GetBuilder<HomeController>(builder: (hData) {
                return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: hData.isLoading.value == true
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: orangeColor),
                                SizedBox(height: 16),
                                Text(
                                  "Loading restaurants...".tr,
                                  style: TextStyle(
                                    color: notifier.textColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: Get.height * 0.02),

                        Container(
                          height: Get.height * 0.4,
                          width: double.infinity,
                          child: CarouselSlider.builder(
                            options: CarouselOptions(
                              autoPlay: true,
                              aspectRatio: 2.0,
                              height: Get.height * 0.4,
                              enlargeCenterPage: true,
                            ),
                            itemCount: hData.sliderimage.length,
                            itemBuilder: (BuildContext context, int index,
                                int realIndex) {
                              return Container(
                                margin: EdgeInsets.only(left: 6, right: 6),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: hData.sliderimage.isEmpty
                                      ? Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.white))
                                      : FadeInImage.assetNetwork(
                                    fadeInCurve: Curves.easeInCirc,
                                    placeholder:
                                    "assets/ezgif.com-crop.gif",
                                    height: Get.height * 0.4,
                                    width: Get.width * 0.7,
                                    imageErrorBuilder:
                                        (context, error, stackTrace) {
                                      return Image.asset(
                                          "assets/ezgif.com-crop.gif");
                                    },
                                    placeholderCacheHeight: 320,
                                    placeholderCacheWidth: 240,
                                    placeholderFit: BoxFit.fill,
                                    // placeholderScale: 1.0,
                                    image: hData.sliderimage[index]["image"] ?? "https://picsum.photos/400/200",

                                    // "${AppUrl.imageurl} + ${home_controller.homeDatakmodal?.homeData.bannerlist}",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // print(''),
                        // "${Confing.imageurl}${homeController.newordermodelnew!.orderData![index].catImg}",
                        SizedBox(height: Get.height * 0.02),
                        Membership
                            ? Column(
                          children: [
                            Text(provider.saved.tr,
                                style: TextStyle(
                                    color: orangeColor,
                                    fontFamily: "Gilroy ExtraBold",
                                    fontSize: 20)),
                            Text(provider.days.tr,
                                style: TextStyle(
                                    color: greycolor,
                                    fontFamily: "Gilroy Bold",
                                    fontSize: 16)),
                            SizedBox(height: Get.height * 0.02),
                            InkWell(
                              onTap: () {
                                Get.to(() => ViewDetails());
                              },
                              child: Container(
                                width: Get.width * 0.32,
                                height: Get.height * 0.05,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color:
                                        greycolor.withOpacity(0.5)),
                                    borderRadius:
                                    BorderRadius.circular(30)),
                                child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          width: Get.width * 0.026),
                                      Text(
                                        provider.view.tr,
                                        style: TextStyle(
                                            fontFamily: "Gilroy Bold",
                                            color: notifier.textColor,
                                            fontSize: 14),
                                      ),
                                      Icon(Icons.keyboard_arrow_right,
                                          size: 20,  color: notifier.textColor,)
                                    ]),
                              ),
                            ),
                            SizedBox(height: Get.height * 0.02),
                            Row(
                              children: [
                                SizedBox(width: Get.width * 0.05),
                                Container(
                                  height: Get.height * 0.04,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 6),
                                  width: Get.width * 0.2,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(30),
                                      color: RedColor),
                                  child: Center(
                                    child: Text(provider.Active.tr,
                                        style: TextStyle(
                                            fontFamily: "Gilroy Bold",
                                            color: orangeColor,
                                            fontSize: 10),
                                        textAlign: TextAlign.center),
                                  ),
                                ),
                                SizedBox(width: Get.width * 0.015),
                                SizedBox(
                                  width: Get.width * 0.65,
                                  child: Text(
                                    provider.membership.tr,
                                    style: TextStyle(
                                        fontFamily: "Gilroy Medium",
                                        color: greycolor,
                                        fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Get.height * 0.03),
                            dottedline(),
                          ],
                        )
                            : SizedBox(),
                        SizedBox(height: Get.height * 0.03),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(image.petals,
                                height: 20, color: BlackColor),
                            SizedBox(width: Get.width * 0.02),
                            Text(
                              provider.membershipBe.tr.toUpperCase(),
                              style: TextStyle(
                                  fontFamily: "Gilroy Medium",
                                  color: greycolor,
                                  letterSpacing: 4,
                                  fontSize: 12),
                            ),
                            Image.asset(image.petals,
                                height: 20, color: notifier.background),
                            SizedBox(width: Get.width * 0.02),
                          ],
                        ),
                        SizedBox(height: Get.height * 0.03),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: greycolor.withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(15)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: Get.width * 0.65,
                                            child: Text(
                                              provider.upto.tr,
                                              style: TextStyle(
                                                  fontFamily: "Gilroy Bold",
                                                  color: notifier.textColor,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          Text(
                                            provider.attop.tr,
                                            style: TextStyle(
                                                fontFamily: "Gilroy Medium",
                                                color: greycolor,
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      Image.asset(image.group2, height: 55),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  InkWell(
                                    splashColor: transparent,
                                    onTap: () {
                                      Get.to(() => Nearbyhotel());
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                              greycolor.withOpacity(0.5)),
                                          borderRadius:
                                          BorderRadius.circular(15)),
                                      child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Image.asset(image.New,
                                                    height: 20),
                                                SizedBox(
                                                    width: Get.width * 0.04),
                                                Text(
                                                  provider.explore.tr
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      color: orangeColor,
                                                      fontFamily:
                                                      "Gilroy Bold",
                                                      fontSize: 13),
                                                ),
                                              ],
                                            ),
                                            CircleAvatar(
                                              radius: 15,
                                              backgroundColor: BlackColor,
                                              backgroundImage:
                                              AssetImage(image.deniout),
                                            )
                                          ]),
                                    ),
                                  ),
                                  SizedBox(height: Get.height * 0.02),
                                  InkWell(
                                    onTap: () {
                                      Get.to(() => Nearbyhotel());
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                              greycolor.withOpacity(0.5)),
                                          borderRadius:
                                          BorderRadius.circular(15)),
                                      child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Image.asset(image.New,
                                                    height: 20,
                                                    color: yelloColor),
                                                SizedBox(
                                                    width: Get.width * 0.04),
                                                Text(
                                                  "book a table".tr
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      color: yelloColor,
                                                      fontFamily:
                                                      "Gilroy Bold",
                                                      fontSize: 13),
                                                ),
                                              ],
                                            ),
                                            CircleAvatar(
                                              radius: 15,
                                              backgroundColor: yelloColor,
                                              backgroundImage: AssetImage(
                                                  "assets/group3.png"),
                                            )
                                          ]),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: Get.height * 0.02),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(provider.trending.tr,
                                    style: TextStyle(
                                        fontFamily: "Gilroy Bold",
                                        color: WhiteColor,
                                        fontSize: 16),
                                  ),
                                  SizedBox(height: Get.height * 0.03),
                                  GetBuilder<HomeController>(
                                      builder: (context) {
                                        return SizedBox(
                                          height: Get.height * 0.64,
                                          width: double.infinity,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            padding: EdgeInsets.zero,
                                            itemCount: filteredRestaurants.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    currentindex = index;
                                                  });
                                                  String? restaurantId = filteredRestaurants[index]["id"]?.toString();
                                                  if (restaurantId != null && restaurantId.isNotEmpty) {
                                                    Get.to(() => HotelDetails(detailId: restaurantId));
                                                  } else {
                                                    Get.snackbar("Error", "Restaurant ID not found");
                                                  }
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(12),
                                                  ),
                                                  height: Get.height * 0.75,
                                                  width: Get.width * 0.78,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(12),
                                                        ),
                                                        height: Get.height * 0.5,
                                                        width: Get.width * 0.72,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(12),
                                                          child: Stack(children: [
                                                            FadeInImage
                                                                .assetNetwork(
                                                              fadeInCurve: Curves
                                                                  .easeInCirc,
                                                              placeholder:
                                                              "assets/ezgif.com-crop.gif",
                                                              height: Get.height *
                                                                  0.70,
                                                              width:
                                                              Get.width * 0.8,
                                                              placeholderCacheHeight:
                                                              320,
                                                              placeholderCacheWidth:
                                                              240,
                                                              placeholderFit:
                                                              BoxFit.fill,
                                                              // placeholderScale: 1.0,
                                                              image: filteredRestaurants[index]["image"]?.toString() ?? "https://picsum.photos/300/200",
                                                              fit: BoxFit.cover,
                                                            ),
                                                            Positioned(
                                                                top: -10,
                                                                right: 40,
                                                                child: Container(
                                                                  padding:
                                                                  EdgeInsets
                                                                      .all(8),
                                                                  height:
                                                                  Get.height *
                                                                      0.12,
                                                                  width:
                                                                  Get.width *
                                                                      0.48,
                                                                  color: darkpurple
                                                                      .withOpacity(
                                                                      0.5),
                                                                  child:
                                                                  Container(
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
                                                                            HomeController>(
                                                                            builder:
                                                                                (context) {
                                                                              String
                                                                              currentdiscount =
                                                                                  "";
                                                                              DateTime
                                                                              date =
                                                                              DateTime.now();
                                                                              String
                                                                              dateFormat =
                                                                              DateFormat('EEEE').format(date);
                                                                              if (dateFormat == "Friday" ||
                                                                                  dateFormat ==
                                                                                      "Saturday" ||
                                                                                  dateFormat ==
                                                                                      "Sunday") {
                                                                                currentdiscount =
                                                                                filteredRestaurants[index]["fridaySundayOffer"]?.toString() ?? "0";
                                                                              } else {
                                                                                currentdiscount =
                                                                                filteredRestaurants[index]["mondayThursdayOffer"]?.toString() ?? "0";
                                                                              }

                                                                              return Text(
                                                                                "${currentdiscount}% OFF",
                                                                                style: TextStyle(
                                                                                    fontFamily: "Gilroy Bold",
                                                                                    color:  notifier.textColor,
                                                                                    fontSize: 20),
                                                                              );
                                                                            }),
                                                                        SizedBox(
                                                                            height:
                                                                            Get.height * 0.01),
                                                                        Text(
                                                                          "Today's Discount".tr
                                                                              .toUpperCase(),
                                                                          style: TextStyle(
                                                                              fontFamily:
                                                                              "Gilroy Medium",
                                                                              color:
                                                                              notifier.textColor,
                                                                              fontSize:
                                                                              12),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )),
                                                          ]),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height:
                                                          Get.height * 0.02),
                                                      Text(
                                                        filteredRestaurants[index]["title"]?.toString() ?? "Restaurant",
                                                        style: TextStyle(
                                                            color:  notifier.textColor,
                                                            fontFamily:
                                                            "Gilroy Bold",
                                                            fontSize: 18),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .star_rate_rounded,
                                                              color: yelloColor,
                                                              size: 22),
                                                          Text(
                                                            filteredRestaurants[index]["rating"]?.toString() ?? "0.0",
                                                            style: TextStyle(
                                                                color: greycolor,
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
                                                            filteredRestaurants[index]["fullAddress"]?.toString() ?? "No address",
                                                            style: TextStyle(
                                                                color: greycolor,
                                                                fontFamily:
                                                                "Gilroy Bold",
                                                                fontSize: 16),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        width: Get.width * 0.45,
                                                        child: Text(
                                                            filteredRestaurants[index]["shortDescription"]?.toString() ?? "No description",
                                                            style: TextStyle(
                                                                color: greycolor,
                                                                fontFamily:
                                                                "Gilroy Medium",
                                                                fontSize: 14)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      }),

                                  // Surprise Bags Section - TGTG Style
                                  SizedBox(height: Get.height * 0.04),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Surprise Bags Near You".tr,
                                        style: TextStyle(
                                            color: notifier.textColor,
                                            fontFamily: "Gilroy Bold",
                                            fontSize: 20),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Navigate to all bags
                                        },
                                        child: Text(
                                          "See all",
                                          style: TextStyle(
                                            color: orangeColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: Get.height * 0.02),
                                  GetBuilder<HomeController>(
                                      builder: (context) {
                                        return hData.surpriseBags.isEmpty
                                            ? Container(
                                                height: Get.height * 0.25,
                                                decoration: BoxDecoration(
                                                  color: notifier.containerColor,
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                                ),
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons.shopping_bag_outlined,
                                                        size: 48,
                                                        color: Colors.grey,
                                                      ),
                                                      SizedBox(height: 16),
                                                      Text(
                                                        "No surprise bags available".tr,
                                                        style: TextStyle(
                                                          color: notifier.textColor,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        "Check back later for new bags!".tr,
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : SizedBox(
                                                height: Get.height * 0.42,
                                                width: double.infinity,
                                                child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  shrinkWrap: true,
                                                  padding: EdgeInsets.only(right: 16),
                                                  itemCount: hData.surpriseBags.length,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    var bag = hData.surpriseBags[index];
                                                    // Find the restaurant for this bag
                                                    var restaurant = hData.allrest.firstWhere(
                                                      (r) => r["id"] == bag["restaurantId"],
                                                      orElse: () => {
                                                        "title": "Unknown Restaurant",
                                                        "image": "",
                                                        "address": "Address not available",
                                                      },
                                                    );

                                                    return InkWell(
                                                      onTap: () {
                                                        Get.to(() => SurpriseBagDetails(
                                                          bagData: bag,
                                                          restaurantData: restaurant,
                                                        ));
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.only(right: 16),
                                                        width: Get.width * 0.72,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(16),
                                                          color: notifier.containerColor,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.black.withOpacity(0.08),
                                                              blurRadius: 12,
                                                              offset: Offset(0, 4),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            // Image with overlay
                                                            Container(
                                                              height: Get.height * 0.22,
                                                              width: double.infinity,
                                                              child: Stack(
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius: BorderRadius.only(
                                                                      topLeft: Radius.circular(16),
                                                                      topRight: Radius.circular(16),
                                                                    ),
                                                                    child: Image.network(
                                                                      bag["image"] ?? restaurant["image"] ?? "https://picsum.photos/300/200",
                                                                      fit: BoxFit.cover,
                                                                      width: double.infinity,
                                                                      height: double.infinity,
                                                                      errorBuilder: (context, error, stackTrace) {
                                                                        return Container(
                                                                          color: Colors.grey[300],
                                                                          child: Icon(Icons.restaurant, size: 50, color: Colors.grey),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                  // Availability badge
                                                                  Positioned(
                                                                    top: 12,
                                                                    right: 12,
                                                                    child: Container(
                                                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                      decoration: BoxDecoration(
                                                                        color: _getBagAvailabilityColor(bag),
                                                                        borderRadius: BorderRadius.circular(12),
                                                                      ),
                                                                      child: Text(
                                                                        "${bag["quantity"] ?? 1} left",
                                                                        style: TextStyle(
                                                                          color: Colors.white,
                                                                          fontSize: 11,
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  // Pickup time badge
                                                                  Positioned(
                                                                    bottom: 12,
                                                                    left: 12,
                                                                    child: Container(
                                                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors.black.withOpacity(0.7),
                                                                        borderRadius: BorderRadius.circular(8),
                                                                      ),
                                                                      child: Row(
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        children: [
                                                                          Icon(Icons.access_time, size: 12, color: Colors.white),
                                                                          SizedBox(width: 4),
                                                                          Text(
                                                                            "${bag["pickupStartTime"] ?? "18:00"}-${bag["pickupEndTime"] ?? "20:00"}",
                                                                            style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 11,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            // Content section
                                                            Expanded(
                                                              child: Padding(
                                                                padding: EdgeInsets.all(16),
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    // Restaurant name
                                                                    Text(
                                                                      restaurant["title"] ?? "Unknown Restaurant",
                                                                      style: TextStyle(
                                                                        fontFamily: "Gilroy Bold",
                                                                        color: notifier.textColor,
                                                                        fontSize: 16,
                                                                      ),
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                    SizedBox(height: 4),
                                                                    // Distance and rating
                                                                    Row(
                                                                      children: [
                                                                        Icon(Icons.location_on, size: 14, color: Colors.grey),
                                                                        SizedBox(width: 4),
                                                                        Text(
                                                                          "0.5 km",
                                                                          style: TextStyle(
                                                                            color: Colors.grey,
                                                                            fontSize: 12,
                                                                          ),
                                                                        ),
                                                                        SizedBox(width: 12),
                                                                        Icon(Icons.star, size: 14, color: Colors.amber),
                                                                        SizedBox(width: 4),
                                                                        Text(
                                                                          "4.5",
                                                                          style: TextStyle(
                                                                            color: Colors.grey,
                                                                            fontSize: 12,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 12),
                                                                    // Bag title
                                                                    Text(
                                                                      bag["title"] ?? "Surprise Bag",
                                                                      style: TextStyle(
                                                                        color: notifier.textColor.withOpacity(0.8),
                                                                        fontSize: 14,
                                                                      ),
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                    Spacer(),
                                                                    // Price section
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Text(
                                                                                  "\$${bag["discountedPrice"] ?? "9.99"}",
                                                                                  style: TextStyle(
                                                                                    fontFamily: "Gilroy Bold",
                                                                                    color: orangeColor,
                                                                                    fontSize: 18,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(width: 8),
                                                                                Text(
                                                                                  "\$${bag["originalPrice"] ?? "29.99"}",
                                                                                  style: TextStyle(
                                                                                    color: Colors.grey,
                                                                                    fontSize: 14,
                                                                                    decoration: TextDecoration.lineThrough,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            SizedBox(height: 2),
                                                                            Text(
                                                                              "Save 67%",
                                                                              style: TextStyle(
                                                                                color: Colors.green,
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w600,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        // Reserve button
                                                                        Container(
                                                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                                          decoration: BoxDecoration(
                                                                            color: orangeColor,
                                                                            borderRadius: BorderRadius.circular(20),
                                                                          ),
                                                                          child: Text(
                                                                            "Reserve",
                                                                            style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ));
                                                  },
                                                ),
                                              );
                                      }),

                                  // SizedBox(height: Get.height * 0.04),
                                  Text(
                                    "Explore cuisines".tr,
                                    style: TextStyle(
                                        color:  notifier.textColor,
                                        fontFamily: "Gilroy Bold",
                                        fontSize: 16),
                                  ),
                                  SizedBox(height: Get.height * 0.02),
                                  GetBuilder<HomeController>(
                                      builder: (context) {
                                        return SizedBox(
                                          height: Get.height * 0.15,
                                          width: double.infinity,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            padding: EdgeInsets.zero,
                                            itemCount: hData.CuisineList.length + 1, // +1 for "All" category
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              String cuisineId;
                                              String cuisineTitle;
                                              String imageUrl;

                                              if (index == 0) {
                                                // First item is "All" category
                                                cuisineId = "all";
                                                cuisineTitle = "All";
                                                imageUrl = "https://picsum.photos/100/100";
                                              } else {
                                                // Regular cuisine categories
                                                int cuisineIndex = index - 1;
                                                cuisineId = hData.CuisineList[cuisineIndex]["id"]?.toString() ?? "all";
                                                cuisineTitle = hData.CuisineList[cuisineIndex]["title"]?.toString() ?? "All";
                                                imageUrl = hData.CuisineList[cuisineIndex]["image"]?.toString() ?? "https://picsum.photos/100/100";
                                              }

                                              bool isSelected = selectedCategory == cuisineId;

                                              return InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    selectedCategory = cuisineId;
                                                  });
                                                  _filterByCategory();
                                                },
                                                child: Container(
                                                  width: Get.width * 0.25,
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          border: isSelected ? Border.all(
                                                            color: orangeColor,
                                                            width: 3,
                                                          ) : null,
                                                        ),
                                                        child: CircleAvatar(
                                                            backgroundImage:
                                                            NetworkImage(imageUrl),
                                                            radius: 35,
                                                            backgroundColor:
                                                            transparent),
                                                      ),
                                                      SizedBox(
                                                          height:
                                                          Get.height * 0.01),
                                                      SizedBox(
                                                        width: Get.width * 0.23,
                                                        child: Center(
                                                          child: Text(
                                                            cuisineTitle,
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: isSelected ? orangeColor : BlackColor,
                                                                fontFamily: isSelected ? "Gilroy Bold" : "Gilroy Medium"),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      }),
                                  SizedBox(height: Get.height * 0.02),
                                  Text(
                                    "Related Restaurants".tr,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color:  notifier.textColor,
                                        fontFamily: "Gilroy Bold"),
                                  ),
                                  SizedBox(height: Get.height * 0.02),
                                  GetBuilder<HomeController>(
                                      builder: (context) {
                                        return SizedBox(
                                            width: double.infinity,
                                            height: Get.height * 0.4,
                                            child: hData.isLoading.value
                                                ? CarouselSlider.builder(
                                              itemCount:
                                              hData.allrest.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                  int index,
                                                  int pageViewIndex) {
                                                return InkWell(
                                                  onTap: () {
                                                    String? restaurantId = hData.allrest[index]["id"]?.toString();
                                                    if (restaurantId != null && restaurantId.isNotEmpty) {
                                                      Get.to(() => HotelDetails(detailId: restaurantId));
                                                    } else {
                                                      Get.snackbar("Error", "Restaurant ID not found");
                                                    }
                                                  },
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        margin:
                                                        EdgeInsets.only(
                                                            left: 6,
                                                            right: 6),
                                                        // height: Get.height / 6,

                                                        decoration:
                                                        BoxDecoration(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              15),
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              15),
                                                          child: FadeInImage
                                                              .assetNetwork(
                                                            fadeInCurve: Curves
                                                                .easeInCirc,
                                                            placeholder:
                                                            "assets/ezgif.com-crop.gif",
                                                            height:
                                                            Get.height *
                                                                0.70,
                                                            width:
                                                            Get.width *
                                                                0.8,
                                                            placeholderCacheHeight:
                                                            320,
                                                            placeholderCacheWidth:
                                                            240,
                                                            placeholderFit:
                                                            BoxFit.fill,
                                                            // placeholderScale: 1.0,
                                                            image: hData.allrest[index]["image"] ?? "https://picsum.photos/300/200",
                                                            fit: BoxFit
                                                                .cover,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        decoration:
                                                        BoxDecoration(
                                                          gradient: LinearGradient(
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                              stops: const [
                                                                0.6,
                                                                0.8,
                                                                1
                                                              ],
                                                              colors: [
                                                                Colors
                                                                    .transparent,
                                                                Colors.black
                                                                    .withOpacity(
                                                                    0.9),
                                                                Colors.black
                                                                    .withOpacity(
                                                                    0.8),
                                                              ]),
                                                        ),
                                                      ),
                                                      Positioned(
                                                          top: -10,
                                                          right: 45,
                                                          child: Container(
                                                            padding:
                                                            EdgeInsets
                                                                .all(8),
                                                            height:
                                                            Get.height *
                                                                0.12,
                                                            width:
                                                            Get.width *
                                                                0.48,
                                                            color: orangeshadow
                                                                .withOpacity(
                                                                0.5),
                                                            child:
                                                            Container(
                                                              height:
                                                              Get.height *
                                                                  0.08,
                                                              width:
                                                              Get.width *
                                                                  0.34,
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color:
                                                                      WhiteColor)),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                                children: [
                                                                  GetBuilder<
                                                                      HomeController>(
                                                                      builder:
                                                                          (context) {
                                                                        String
                                                                        currentdiscount =
                                                                            "";
                                                                        DateTime
                                                                        date =
                                                                        DateTime.now();
                                                                        String
                                                                        dateFormat =
                                                                        DateFormat('EEEE').format(date);
                                                                        if (dateFormat == "Friday" ||
                                                                            dateFormat ==
                                                                                "Saturday" ||
                                                                            dateFormat ==
                                                                                "Sunday") {
                                                                          currentdiscount =
                                                                          hData.allrest[index]["fridaySundayOffer"]?.toString() ?? "0";
                                                                        } else {
                                                                          currentdiscount =
                                                                          hData.allrest[index]["mondayThursdayOffer"]?.toString() ?? "0";
                                                                        }

                                                                        return Text(
                                                                          "${currentdiscount}% OFF",
                                                                          style: TextStyle(
                                                                              fontFamily: "Gilroy Bold",
                                                                              color:  notifier.textColor,
                                                                              fontSize: 20),
                                                                        );
                                                                      }),
                                                                  SizedBox(
                                                                      height:
                                                                      Get.height * 0.01),
                                                                  Text(
                                                                    "Today's Discount".tr
                                                                        .toUpperCase(),
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                        "Gilroy Medium",
                                                                        color:
                                                                        notifier.textColor,
                                                                        fontSize:
                                                                        12),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          )),
                                                      Positioned(
                                                        left: 14,
                                                        bottom: 10,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            SizedBox(
                                                                height: Get
                                                                    .height *
                                                                    0.08),
                                                            Text(
                                                              hData.allrest[index]["title"]?.toString() ?? "Restaurant",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                  16,
                                                                  color:
                                                                  WhiteColor,
                                                                  fontFamily:
                                                                  "Gilroy Medium"),
                                                            ),
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .star_rate_rounded,
                                                                    color:
                                                                    yelloColor,
                                                                    size:
                                                                    22),
                                                                Text(
                                                                  hData.allrest[index]["rating"]?.toString() ?? "0.0",
                                                                  style: TextStyle(
                                                                      color:
                                                                      greycolor,
                                                                      fontFamily:
                                                                      "Gilroy Bold",
                                                                      fontSize:
                                                                      16),
                                                                ),
                                                                SizedBox(
                                                                    width: Get.width *
                                                                        0.01),
                                                                CircleAvatar(
                                                                    radius:
                                                                    2,
                                                                    backgroundColor:
                                                                    greycolor),
                                                                SizedBox(
                                                                    width: Get.width *
                                                                        0.02),
                                                                Text(
                                                                  hData.allrest[index]["area"]?.toString() ?? "No address",
                                                                  style: TextStyle(
                                                                      color:
                                                                      greycolor,
                                                                      fontFamily:
                                                                      "Gilroy Bold",
                                                                      fontSize:
                                                                      16),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              width:
                                                              Get.width *
                                                                  0.4,
                                                              child: Text(
                                                                  hData.allrest[index]["description"]?.toString() ?? "No description",
                                                                  style: TextStyle(
                                                                      color:
                                                                      greycolor,
                                                                      fontFamily:
                                                                      "Gilroy Medium",
                                                                      fontSize:
                                                                      14)),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              options: CarouselOptions(
                                                // aspectRatio: 12,
                                                  enlargeCenterPage: true,
                                                  autoPlay: true,
                                                  height: Get.height * 0.5),
                                            )
                                                : Center(
                                                child:
                                                CircularProgressIndi()));
                                      }),
                                ]),
                            SizedBox(height: Get.height * 0.02)
                          ],
                        ),
                      ],
                    ));
              })),
        ),
      ),
    );
  }

  webViewPaymentMethod(
      {required String initialUrl,
        required String status1,
        required String status2}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentWebVIew(
          initialUrl: initialUrl,
          navigationDelegate: (request) async {
            final uri = Uri.parse(request.url);

            debugPrint("************ URL:--- $initialUrl");
            debugPrint("************ Navigating to URL: ${request.url}");
            debugPrint("************ Parsed URI: $uri");
            debugPrint("************ 2435243254: ${uri.queryParameters[status1]}");

            // Check the status parameter instead of Result
            final status = uri.queryParameters[status1];
            debugPrint(" /*/*/*/*/*/*/*/*/*/*/*/*/*/ Status ---- $status");
            if (status == null) {
              debugPrint("No status parameter found.");
            } else {
              debugPrint("Status parameter: $status");
              if (status == status2) {
                debugPrint("Purchase successful.");
                Get.back();
                Get.back();
                planpurchase.planpurchase(
                    planid: planid,
                    pname: paymenttital,
                    transactionid: "transactionid");

                return NavigationDecision.prevent;
              } else {
                debugPrint("Purchase failed with status: $status.");
                Navigator.pop(context);
                // ignore: unnecessary_string_interpolations
                tost("$status");
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
        ),
      ),
    );
  }

  // Plan section removed as requested
  // bottomsheet() {
  //   // Get.back();
  //   return showModalBottomSheet(
  //       backgroundColor: RedColor.withOpacity(0.9),
  //       isScrollControlled: true,
  //       context: context,
  //       shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(15), topRight: Radius.circular(15))),
  //       builder: (context) {
  //         return StatefulBuilder(
  //             builder: (BuildContext context, StateSetter setState) {
  //               return Container(
  //                 height: Get.height * 0.35,
  //                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
  //                 child: Column(
  //                   children: [
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Image.asset("assets/confetti1.png", height: 25),
  //                         SizedBox(width: Get.width * 0.02),
  //                         Text("special prices only for you".tr.toUpperCase(),
  //                             style: TextStyle(
  //                                 fontFamily: "Gilroy Bold",
  //                                 color: orangeColor,
  //                                 fontSize: 15)),
  //                         SizedBox(width: Get.width * 0.02),
  //                         Image.asset("assets/confetti.png", height: 25)
  //                       ],
  //                     ),
  //                     SizedBox(
  //                       height: Get.height * 0.2,
  //                       width: double.infinity,
  //                       child: ListView.builder(
  //                           scrollDirection: Axis.horizontal,
  //                           shrinkWrap: true,
  //                           padding: EdgeInsets.zero,
  //                           itemCount: hData.PlanData.length,
  //                           itemBuilder: (context, index) {
  //                             return Stack(children: [
  //                               Container(
  //                                 height: 150,
  //                                 width: 172,
  //
  //                                 padding: EdgeInsets.symmetric(
  //                                     vertical: 16, horizontal: 6),
  //                                 child: InkWell(
  //                                   onTap: () {
  //                                     setState(() {});
  //                                     defultplan = true;
  //                                     SelectedIndex = hData.PlanData[index]["id"];
  //                                     print(
  //                                         "*+*+*+*+*+*+*-+-/-+ hData PlanData-*-+*-*/-+*----*-+-*+-*+"
  //                                             "${hData.PlanData[index]["price"]}");
  //                                     plan1 = hData.PlanData[index]["title"];
  //                                     plan2 = hData.PlanData[index]["price"];
  //                                     planid = hData.PlanData[index]["id"];
  //                                     planprice = hData.PlanData[index]["price"];
  //                                   },
  //                                   child: Container(
  //                                     padding: EdgeInsets.symmetric(
  //                                         horizontal: 14, vertical: 6),
  //                                     decoration: BoxDecoration(
  //                                         borderRadius: BorderRadius.circular(12),
  //                                         color: notifier.background,
  //                                         border: Border.all(
  //                                             color: SelectedIndex ==
  //                                                 hData.PlanData[index]["id"]
  //                                                 ? orangeColor
  //                                                 : transparent,
  //                                             width: 2)),
  //                                     child: Column(
  //                                       mainAxisAlignment: MainAxisAlignment.center,
  //                                       crossAxisAlignment:
  //                                       CrossAxisAlignment.start,
  //                                       children: [
  //                                         Text(hData.PlanData[index]["title"],
  //                                             style: TextStyle(
  //                                                 color:  notifier.textColor,
  //                                                 fontFamily: "Gilroy Bold",
  //                                                 fontSize: 16)),
  //                                         SizedBox(height: Get.height * 0.015),
  //                                         Row(
  //                                           children: [
  //                                             Text(
  //                                                 "${hData.homeDataList["currency"]}${hData.PlanData[index]["price"]}",
  //                                                 style: TextStyle(
  //                                                     color:  notifier.textColor,
  //                                                     fontFamily: "Gilroy Bold",
  //                                                     fontSize: 18)),
  //                                           ],
  //                                         ),
  //                                         SizedBox(height: Get.height * 0.015),
  //                                         Text("${hData.PlanData[index]["day"]}day",
  //                                             style: TextStyle(
  //                                                 color: darkpurple,
  //                                                 fontFamily: "Gilroy Bold",
  //                                                 fontSize: 16))
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                               Positioned(
  //                                 right: -0.2,
  //                                 top: 4,
  //                                 child: InkWell(
  //                                   onTap: () {
  //                                     // selected = selected;
  //                                   },
  //                                   child: CircleAvatar(
  //                                     radius: 14,
  //                                     backgroundColor: SelectedIndex ==
  //                                         hData.PlanData[index]["id"]
  //                                         ? orangeColor
  //                                         : transparent,
  //                                     child: Icon(Icons.check,
  //                                         color: SelectedIndex ==
  //                                             hData.PlanData[index]["id"]
  //                                             ?  notifier.textColor
  //                                             : transparent),
  //                                   ),
  //                                 ),
  //                               )
  //                             ]);
  //                           }),
  //                     ),
  //                     InkWell(
  //                       onTap: () {
  //                         // ignore: unnecessary_null_comparison
  //                         if (planprice != null) {
  //                           Get.back();
  //                           paymentSheett();
  //                         } else {
  //                           ApiWrapper.showToastMessage(
  //                               "Please select at least one plan".tr);
  //                         }
  //                       },
  //                       child: Container(
  //                         decoration: BoxDecoration(
  //                             gradient: LinearGradient(
  //                               stops: [0.1, 0.8, 1],
  //                               colors: <Color>[
  //                                 orangeColor,
  //                                 orangeColor,
  //                                 Colors.red
  //                               ],
  //                             ),
  //                             borderRadius: BorderRadius.circular(12),
  //                             color: orangeColor),
  //                         padding: EdgeInsets.symmetric(vertical: 5),
  //                         width: double.infinity,
  //                         child: Center(
  //                           child: Column(
  //                             children: [
  //                               Text(
  //                                 "buy EasyGo".tr.toUpperCase(),
  //                                 style: TextStyle(
  //                                     fontFamily: 'Gilroy Bold',
  //                                     fontSize: 16,
  //                                     color: WhiteColor),
  //                               ),
  //                               SizedBox(height: 2),
  //                               !defultplan
  //                                   ? Text(
  //                                 "select plan".tr,
  //                                 style: TextStyle(
  //                                     fontFamily: 'Gilroy Bold',
  //                                     fontSize: 14,
  //                                     color: WhiteColor),
  //                               )
  //                                   : Text(
  //                                 "at ${hData.homeDataList["currency"]}${plan2} for ${plan1}",
  //                                 style: TextStyle(
  //                                     fontFamily: 'Gilroy Bold',
  //                                     fontSize: 14,
  //                                     color: WhiteColor),
  //                               )
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             });
  //       });
  // }

  Future paymentSheett() {
    return showModalBottomSheet(
      backgroundColor: boxcolor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (context) {
        return Wrap(children: [
          StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10),
                    Center(
                      child: Container(
                        height: Get.height / 80,
                        width: Get.width / 5,
                        decoration: const BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(Radius.circular(20))),
                      ),
                    ),
                    SizedBox(height: Get.height / 50),
                    Row(children: [
                      SizedBox(width: Get.width / 14),
                      Text("Select Payment Method".tr,
                          style: TextStyle(
                              color: WhiteColor,
                              fontSize: Get.height / 40,
                              fontFamily: "Gilroy Medium")),
                    ]),
                    SizedBox(height: Get.height / 50),
                    //! --------- List view paymente ----------
                    SizedBox(
                      height: Get.height * 0.50,
                      child:
                      GetBuilder<PaymentgatewayController>(builder: (context) {
                        return payment.isLoading
                            ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: payment.paymentGetway.length,
                          itemBuilder: (ctx, i) {
                            return payment.paymentGetway[i]["p_show"] == "1"
                                ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              child: sugestlocationtype(
                                borderColor: selectidPay ==
                                    payment.paymentGetway[i]["id"]
                                    ? orangeColor
                                    : greycolor.withOpacity(0.5),
                                title: payment.paymentGetway[i]
                                ["title"],
                                titleColor: WhiteColor,
                                val: 0,
                                image: payment.paymentGetway[i]["image"] ?? "https://picsum.photos/100/100",
                                adress: payment.paymentGetway[i]
                                ["subtitle"],
                                ontap: () async {
                                  setState(() {
                                    razorpaykey = payment
                                        .paymentGetway[i]["attributes"];
                                    paymenttital = payment
                                        .paymentGetway[i]["title"];
                                    selectidPay =
                                    payment.paymentGetway[i]["id"];
                                    _groupValue = i;
                                  });
                                },
                                radio: Radio(
                                  activeColor: orangeColor,
                                  value: i,
                                  // fillColor:
                                  //     MaterialStateColor.resolveWith(
                                  //         (states) => orangeColor),
                                  groupValue: _groupValue,
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                              ),
                            )
                                : SizedBox();
                          },
                        )
                            : Center(
                          child: CircularProgressIndi(),
                        );
                      }),
                    ),
                    Container(
                      height: 80,
                      width: Get.size.width,
                      alignment: Alignment.center,
                      child: GestButton(
                        Width: Get.size.width,
                        height: 50,
                        buttoncolor: orangeColor,
                        margin: EdgeInsets.only(top: 10, left: 30, right: 30),
                        buttontext: "Continue".tr,
                        style: TextStyle(
                          fontFamily: "",
                          color: WhiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        onclick: () {
                          //!---- Stripe Payment ------

                          print("*+*+*+*+*+*+*-+-/-+ planprice-*-+*-*/-+*----*-+-*+-*+""${planprice}");

                          if (paymenttital == "Razorpay") {
                            Get.back();
                            openCheckout();
                          } else if (paymenttital == "Pay TO Owner") {
                            planpurchase.planpurchase(
                              planid: planid,
                              pname: paymenttital,
                            );
                            Get.back();
                          } else if (paymenttital == "Paypal") {
                            // payplepayment(onSuccess: (Map params) {
                            //   planpurchase.planpurchase(
                            //       planid: planid,
                            //       pname: paymenttital,
                            //       transactionid: params["paymentId"]);
                            // });
                            showToastMessage("PayPal payment is currently disabled");
                          }
                          else if (paymenttital == "Stripe") {
                            Get.back();
                            stripePayment();
                          }
                          else if (paymenttital == "PayStack") {
                            paystackCont.getPaystack(amount: planprice).then((value) {
                              Get.to(() => PaymentWebVIew(
                                initialUrl: value["data"]
                                ["authorization_url"],
                                navigationDelegate:
                                    (NavigationRequest request) async {
                                  final uri = Uri.parse(request.url);
                                  print("PAYSTACK RESPONSE ${request}");
                                  print("PAYSTACK URL  ${request.url}");
                                  Get.back();
                                  Get.back();
                                  // Plan functionality disabled
                                  planpurchase.planpurchase(
                                      planid: planid,
                                      pname: paymenttital,
                                      transactionid: "transactionid");

                                  return NavigationDecision.navigate;
                                },
                              ))!
                                  .then((otid) {

                                //! order Api call
                                if (otid != null) {
                                  planpurchase.planpurchase(
                                      planid: planid,
                                      pname: paymenttital,
                                      transactionid: otid);
                                } else {

                                }
                              });
                            },);
                          }
                          else if (paymenttital == "Payfast") {
                            debugPrint("payFast");
                            webViewPaymentMethod(
                              initialUrl:
                              "${AppUrl.paymentBaseUrl + AppUrl.payFast}amt=$planprice",
                              status1: "status",
                              status2: "success",
                            );
                          }
                          else if (paymenttital == "Midtrans") {
                            webViewPaymentMethod(
                              initialUrl:
                              "${AppUrl.paymentBaseUrl}Midtrans/index.php?name=test&email=${getData.read("UserLogin")["email"]}&phone=${getData.read("UserLogin")["ccode"] + getData.read("UserLogin")["mobile"]}&amt=${planprice}",
                              status1: "status_code",
                              status2: "200",
                            );

                          }
                          else if (paymenttital == "Khalti Payment") {
                            print("===================:-------");
                            Get.to(() => PaymentWebVIew(
                              initialUrl:
                              "${AppUrl.paymentBaseUrl}Khalti/index.php?amt=${planprice}",
                              navigationDelegate:
                                  (NavigationRequest request) async {
                                final uri = Uri.parse(request.url);
                                print("URL + ${uri.queryParameters}");
                                if (uri.queryParameters["status"] == null) {
                                  // accessToken = uri.queryParameters["token"]!;
                                } else {
                                  if (uri.queryParameters["status"] ==
                                      "Completed") {
                                    payerID = uri
                                        .queryParameters["transaction_id"]!;
                                    print("PAYER ID $payerID");
                                    Get.back(result: payerID);
                                  } else {
                                    Get.back();
                                    Fluttertoast.showToast(
                                        msg:
                                        "${uri.queryParameters["status"]}",
                                        timeInSecForIosWeb: 4);
                                  }
                                }
                                return NavigationDecision.navigate;
                              },
                            ))!
                                .then((otid) {
                              if (otid != null) {
                                planpurchase.planpurchase(
                                    planid: planid,
                                    pname: paymenttital,
                                    transactionid: otid);
                              } else {
                                Get.back();
                              }
                            });
                          }
                          else if (paymenttital == "2checkout"){
                            debugPrint("2checkout");
                            webViewPaymentMethod(
                              initialUrl:
                              "${AppUrl.paymentBaseUrl}2checkout/index.php?amt=${planprice}",
                              status1: "status",
                              status2: "successful",
                            );
                          }
                          //===================================== done
                          else if (paymenttital == "MercadoPago") {
                            print("===================:-------");

                            webViewPaymentMethod(
                                initialUrl:
                                "${AppUrl.paymentBaseUrl}merpago/index.php?amt=${planprice}",
                                status1: "status",
                                status2: "successful");
                          }
                          else if (paymenttital == "FlutterWave") {
                            Get.to(() => Flutterwave(
                              totalAmount: currentTotalprice.toString(),
                              email: getData
                                  .read("UserLogin")["email"]
                                  .toString(),
                            ))!
                                .then((otid) {
                              if (otid != null) {
                                planpurchase.planpurchase(
                                    planid: planid,
                                    pname: paymenttital,
                                    transactionid: otid);
                              } else {
                                Get.back();
                              }
                            });
                          }
                          else if (paymenttital == "Paytm") {
                            Get.to(() => PayTmPayment(
                              totalAmount: currentTotalprice.toString(),
                              uid: getData
                                  .read("UserLogin")["id"]
                                  .toString(),
                            ))!
                                .then((otid) {
                              if (otid != null) {
                                planpurchase.planpurchase(
                                    planid: planid,
                                    pname: paymenttital,
                                    transactionid: otid);
                              } else {
                                Get.back();
                              }
                            });
                          }
                          else if (paymenttital == "SenangPay") {
                            print(paymenttital.toString());
                          }
                        },
                      ),
                      decoration: BoxDecoration(
                        color: BlackColor,
                      ),
                    ),
                  ],
                );
              }),
        ]);
      },
    );
  }

  Widget sugestlocationtype(
      {Function()? ontap,
        title,
        val,
        image,
        adress,
        radio,
        Color? borderColor,
        Color? titleColor}) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return InkWell(
            splashColor: Colors.transparent,
            onTap: ontap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Get.width / 18),
              child: Container(
                height: Get.height / 9,
                decoration: BoxDecoration(
                    border: Border.all(color: borderColor!, width: 1),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(11)),
                child: Row(
                  children: [
                    SizedBox(width: Get.width / 55),
                    Container(
                        height: Get.height / 12,
                        width: Get.width / 5.5,
                        decoration: BoxDecoration(
                            color: const Color(0xffF2F4F9),
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: FadeInImage(
                              placeholder: const AssetImage("assets/loading2.gif"),
                              image: NetworkImage(image)),
                          // Image.network(image, height: Get.height / 08)
                        )),
                    SizedBox(width: Get.width / 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: Get.height * 0.01),
                        Text(title,
                            style: TextStyle(
                              fontSize: Get.height / 55,
                              fontFamily: "Gilroy Bold",
                              color: titleColor,
                            )),
                        SizedBox(
                          width: Get.width * 0.50,
                          child: Text(adress,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: Get.height / 65,
                                  fontFamily: "Gilroy Medium",
                                  color: Colors.grey)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    radio
                  ],
                ),
              ),
            ),
          );
        });
  }

  //!-------- Razorpay ----------//

  void openCheckout() async {
    var username = getData.read("UserLogin")["name"] ?? "";
    var mobile = getData.read("UserLogin")["mobile"] ?? "";
    var email = getData.read("UserLogin")["email"] ?? "";
    print("razorpaykeyrazorpaykey" "$razorpaykey");
    var options = {
      'key': razorpaykey,
      'amount': (double.parse(planprice.toString()) * 100).toString(),
      'name': username,
      'description': "",
      'timeout': 500,
      'prefill': {'contact': mobile, 'email': email},
    };
    print("#################" "$username");

    print("%%%%%%%%%%%%%%%%%" "$mobile");
    print("&&&&&&&&&&&&&&&&&" "$email");

    print("*****************" "$options");
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  stripePayment() {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: boxcolor,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Ink(
                    child: Column(
                      children: [
                        SizedBox(height: Get.height / 45),
                        Center(
                          child: Container(
                            height: Get.height / 85,
                            width: Get.width / 5,
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.4),
                                borderRadius:
                                const BorderRadius.all(Radius.circular(20))),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: Get.height * 0.03),
                              Text("Add Your payment information".tr,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.5)),
                              SizedBox(height: Get.height * 0.02),
                              Form(
                                key: _formKey,
                                autovalidateMode: _autoValidateMode,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      style: TextStyle(color: Colors.black),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(19),
                                        CardNumberInputFormatter()
                                      ],
                                      controller: numberController,
                                      onSaved: (String? value) {
                                        _paymentCard.number =
                                            CardUtils.getCleanedNumber(value!);

                                        CardTypee cardType =
                                        CardUtils.getCardTypeFrmNumber(
                                            _paymentCard.number.toString());
                                        setState(() {
                                          _card.name = cardType.toString();
                                          _paymentCard.type = cardType;
                                        });
                                      },
                                      onChanged: (val) {
                                        CardTypee cardType =
                                        CardUtils.getCardTypeFrmNumber(val);
                                        setState(() {
                                          _card.name = cardType.toString();
                                          _paymentCard.type = cardType;
                                        });
                                      },
                                      validator: CardUtils.validateCardNum,
                                      decoration: InputDecoration(
                                        prefixIcon: SizedBox(
                                          height: 10,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                              horizontal: 6,
                                            ),
                                            child: CardUtils.getCardIcon(
                                              _paymentCard.type,
                                            ),
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: orangeColor,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: orangeColor,
                                          ),
                                        ),


                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: orangeColor,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: orangeColor,
                                          ),
                                        ),
                                        hintText:
                                        "What number is written on card?".tr,
                                        hintStyle: TextStyle(color: Colors.grey),
                                        labelStyle: TextStyle(color: Colors.grey),
                                        labelText: "Number".tr,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Flexible(
                                          flex: 4,
                                          child: TextFormField(
                                            style: TextStyle(color: Colors.grey),
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(4),
                                            ],
                                            decoration: InputDecoration(
                                                prefixIcon: SizedBox(
                                                  height: 10,
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14),
                                                    child: Image.asset(
                                                      'assets/card_cvv.png',
                                                      width: 6,
                                                      color: orangeColor,
                                                    ),
                                                  ),
                                                ),
                                                focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: orangeColor,
                                                  ),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: orangeColor,
                                                  ),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: orangeColor,
                                                  ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: orangeColor)),
                                                hintText:
                                                "Number behind the card".tr,
                                                hintStyle:
                                                TextStyle(color: Colors.grey),
                                                labelStyle:
                                                TextStyle(color: Colors.grey),
                                                labelText: 'CVV'.tr),
                                            validator: CardUtils.validateCVV,
                                            keyboardType: TextInputType.number,
                                            onSaved: (value) {
                                              _paymentCard.cvv = int.parse(value!);
                                            },
                                          ),
                                        ),
                                        SizedBox(width: Get.width * 0.03),
                                        Flexible(
                                          flex: 4,
                                          child: TextFormField(
                                            style: TextStyle(color: Colors.black),
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(4),
                                              CardMonthInputFormatter()
                                            ],
                                            decoration: InputDecoration(
                                              prefixIcon: SizedBox(
                                                height: 10,
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 14),
                                                  child: Image.asset(
                                                    'assets/calender.png',
                                                    width: 10,
                                                    color: orangeColor,
                                                  ),
                                                ),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: orangeColor,
                                                ),
                                              ),
                                              focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: orangeColor,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: orangeColor,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: orangeColor,
                                                ),
                                              ),
                                              hintText: 'MM/YY'.tr,
                                              hintStyle:
                                              TextStyle(color: Colors.black),
                                              labelStyle:
                                              TextStyle(color: Colors.grey),
                                              labelText: "Expiry Date".tr,
                                            ),
                                            validator: CardUtils.validateDate,
                                            keyboardType: TextInputType.number,
                                            onSaved: (value) {
                                              List<int> expiryDate =
                                              CardUtils.getExpiryDate(value!);
                                              _paymentCard.month = expiryDate[0];
                                              _paymentCard.year = expiryDate[1];
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: Get.height * 0.055),
                                    Container(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: Get.width,
                                        child: CupertinoButton(
                                          onPressed: () {
                                            _validateInputs();
                                          },
                                          color: orangeColor,
                                          child: Text(
                                            "Pay".tr,
                                            style: TextStyle(fontSize: 17.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: Get.height * 0.065),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            });
      },
    );
  }

  void _validateInputs() {
    final FormState form = _formKey.currentState!;
    if (!form.validate()) {
      setState(() {
        _autoValidateMode =
            AutovalidateMode.always; // Start validating on every change.
      });
      showToastMessage("Please fix the errors in red before submitting.".tr);
    } else {
      var username = getData.read("UserLogin")["name"];
      var email = getData.read("UserLogin")["email"];
      _paymentCard.name = username;
      _paymentCard.email = email;
      _paymentCard.amount = currentTotalprice.toString();
      form.save();

      Get.to(() => StripePaymentWeb(paymentCard: _paymentCard))!.then((otid) {
        Get.back();
        //! order Api call
        if (otid != null) {
          //! Api Call Payment Success
          planpurchase.planpurchase();
        }
      });

      showToastMessage("Payment card is valid".tr);
    }
  }
  // payplepayment({required Function onSuccess}) {
  //   return Navigator.of(context).push(MaterialPageRoute(
  //     builder: (context) {
  //       return UsePaypal(
  //           sandboxMode: true,
  //           clientId:
  //           "Aa0Yim_XLAz89S4cqO-kT4pK3QbFsruHvEm8zDYX_Y-wIKgsGyv4TzL84dGgtWYUoJqTvKUh0JonIaKa",
  //           secretKey:
  //           "ECZEZmIjx0j_3_RStM7eT3Bc0Ehdd_yW4slqTnCtNI8WtVOVL1qwRh__u1W_8qKygnPDs0XaviNlb7-z",
  //           returnURL:
  //           "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=EC-35S7886705514393E",
  //           cancelURL: "https://dineout.zozostudio.tech/paypal/cancle.php",
  //           transactions: [
  //             {
  //               "amount": {
  //                 "total": plan2,
  //                 "currency": "USD",
  //                 "details": {
  //                   "subtotal": plan2,
  //                   "shipping": '0',
  //                   "shipping_discount": 0
  //                 }
  //               },
  //               "description": "The payment transaction description.",
  //               // "payment_options": {
  //               //   "allowed_payment_method":
  //               //       "INSTANT_FUNDING_SOURCE"
  //               // },
  //               "item_list": {
  //                 "items": [
  //                   {
  //                     "name": "A demo product",
  //                     "quantity": 1,
  //                     "price": plan2,
  //                     "currency": "USD"
  //                   }
  //                 ],

  //                 // shipping address is not required though
  //                 "shipping_address": {
  //                   "recipient_name": "Jane Foster",
  //                   "line1": "Travis County",
  //                   "line2": "",
  //                   "city": "Austin",
  //                   "country_code": "US",
  //                   "postal_code": "73301",
  //                   "phone": "+00000000",
  //                   "state": "Texas"
  //                 },
  //               }
  //             }
  //           ],
  //           note: "Contact us for any questions on your order.",
  //           onSuccess: onSuccess,
  //           onError: (error) {
  //             print("onError: $error");
  //           },
  //           onCancel: (params) {
  //             print('cancelled: $params');
  //           });
  //     },
  //   ));
  // }

  // Helper method for bag availability color
  Color _getBagAvailabilityColor(Map<String, dynamic> bag) {
    int quantity = int.tryParse(bag["quantity"]?.toString() ?? "0") ?? 0;
    if (quantity > 5) return Colors.green;
    if (quantity > 0) return Colors.orange;
    return Colors.red;
  }
}

Future tost(String text) {
  return Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM_LEFT,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.grey.shade300,
    textColor: Colors.black,
    fontSize: 16.0,
  );
}

class Slide {
  String image;

  Slide(this.image);
}

// Dummy class to replace plan functionality
class _DummyPlanPurchase {
  void planpurchase({String? planid, String? pname, String? transactionid}) {
    print("Plan functionality disabled - would have processed: planid=$planid, pname=$pname, transactionid=$transactionid");
  }
}
