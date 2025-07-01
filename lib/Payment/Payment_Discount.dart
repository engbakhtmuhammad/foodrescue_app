// ignore_for_file: sort_child_properties_last, file_names, must_be_immutable, unused_local_variable, unnecessary_brace_in_string_interps, avoid_print

import 'package:foodrescue_app/Getx_Controller/Controller.dart';
import 'package:foodrescue_app/Payment/Payment_Details.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:foodrescue_app/Utils/String.dart';
import 'package:foodrescue_app/Utils/image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/dark_light_mode.dart';

class PaymentDiscount extends StatefulWidget {
  String? tipamount;
  String? restid;
  String? hotelname;
  String? address;
  PaymentDiscount(
      {this.tipamount, this.restid, this.hotelname, this.address, super.key});

  @override
  State<PaymentDiscount> createState() => _PaymentDiscountState();
}

class _PaymentDiscountState extends State<PaymentDiscount> {
  @override
  void initState() {
    getDarkMode();
    super.initState();
    // hoteldetails.hoteldetail();
    print("=====================================" "${widget.tipamount}");
    setState(() {
      tipfor = "${widget.tipamount}";
    });
  }

  String tipfor = "";
  double paytip = 0.0;
  TextEditingController amountcontroller = TextEditingController();
  HomeController homeController = Get.put(HomeController());
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
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: AppButton(
            buttonColor: green,
            buttontext:
                "Proceed to pay ${homeController.homeDataList["currency"]}${paytip}",
            onTap: () {
              print("&&&&&&&&&&&&&&&&&&&&&&${widget.tipamount}");
              if (amountcontroller.text != "") {
                Get.to(() => PaymentDetails(
                      bilamount: double.parse(amountcontroller.text),
                      tip: double.tryParse(widget.tipamount ?? "0") ?? 0.0,
                      address: widget.address,
                    ));
              } else {
                Fluttertoast.showToast(
                    msg: "Please Enter Amount",
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: orangeColor,
                    textColor: Colors.white,
                    fontSize: 14.0);
              }
            },
          )),
      backgroundColor: notifier.background,
      appBar: PreferredSize(
          child: appbar(
             background: notifier.background,
              color: notifier.textColor,
              titletext: provider.youre,
              centertext: widget.hotelname,
              subtitletext: widget.address),
          preferredSize: const Size.fromHeight(65)),
      body: Column(
        children: [
          SizedBox(height: Get.height * 0.035),
          Stack(
            children: [
              Center(
                child: Stack(children: [
                  Image.asset("assets/off.png", height: 160),
                  // Image.asset("assets/research.jpg", height: 100, width: 120),
                  Container(
                    margin: const EdgeInsets.only(left: 40, top: 42),
                    // color: greenColor,
                    width: Get.width * 0.20,
                    child: Text("${tipfor}% Off".toUpperCase(),
                        style: TextStyle(
                            fontSize: 35,
                            color: notifier.textColor,
                            fontFamily: "Gilroy ExtraBold")),
                  )
                ]),
              ),
              Positioned(
                  top: 55,
                  left: 85,
                  child: Image.asset(image.emoji1, height: 80)),
              Positioned(
                  right: 86,
                  top: 25,
                  child: Image.asset(image.emoji, height: 40))
            ],
          ),
          SizedBox(height: Get.height * 0.02),
          Padding(
            padding: const EdgeInsets.only(left: 130),
            child: Row(
              children: [
                Text(provider.gold,
                    style: TextStyle(
                        fontSize: 18,
                        color: goldColor,
                        fontFamily: "Gilroy Bold")),
                // SizedBox(width: Get.width * 0.0),
                Text(provider.Benefits,
                    style: TextStyle(
                        fontSize: 16,
                        color: orangeColor,
                        fontFamily: "Gilroy Bold"))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(provider.paybillto,
                style: TextStyle(
                    fontSize: 17, color: greycolor, fontFamily: "Gilroy Bold")),
          ),
          SizedBox(height: Get.height * 0.03),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: textfield(
                prefixtext: "${homeController.homeDataList["currency"]} ",
                color: notifier.background,
                onChanged: (p0) {
                  setState(() {
                    paytip = double.parse(p0);
                  });
                },
                controller: amountcontroller,
                floatingLabelColor: orangeColor,
                labelcolor: notifier.textColor,
                labelText: "Enter amount as shown on the bill",
                Height: Get.height * 0.09,
                Width: double.infinity,
                prefixcolor: orangeColor,
                focusedBorderColor: orangeColor),
          )
        ],
      ),
    );
  }
}
