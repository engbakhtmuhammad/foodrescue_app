// ignore_for_file: file_names, non_constant_identifier_names, avoid_print, unused_field

import 'dart:convert';

import 'package:foodrescue_app/Getx_Controller/optcontroller.dart';
import 'package:foodrescue_app/LoginFlow/Forgot_Password.dart';
import 'package:foodrescue_app/LoginFlow/Verify_Account.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:foodrescue_app/utils/api_wrapper.dart';
import 'package:foodrescue_app/api/Data_save.dart';
import 'package:foodrescue_app/config/app_config.dart';
import 'package:foodrescue_app/controllers/auth_controller.dart';
import 'package:foodrescue_app/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/dark_light_mode.dart';


class ResendCode extends StatefulWidget {
  const ResendCode({super.key});

  @override
  State<ResendCode> createState() => _ResendCodeState();
}

class _ResendCodeState extends State<ResendCode> {
  final FullName = TextEditingController();
  final Email = TextEditingController();
  final Password = TextEditingController();
  final Countrycode = TextEditingController();
  final Mobile = TextEditingController();
  OtpController otpCont = Get.put(OtpController());
  String mobilecheck = "";
  String Country = "";
  @override
  void initState() {
    getDarkMode();
    super.initState();
  }

  // ignore: prefer_final_fields
  String _verificationId = "";
  int? _resendToken;
  final _formKey = GlobalKey<FormState>();
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: AppButton(
          buttonColor: orangeColor,
          buttontext: "Send OTP".tr,
          onTap: () {
            Mobilecheck(Mobile.text, Country);
            setState(() {
              // verifyotp = true;
            });
          },
        ),
      ),
      appBar: loginappbar(
          backGround: notifier.background, color: notifier.textColor),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Get.height * 0.05),
            Text(
              "Phone Number".tr,
              style: TextStyle(
                  fontFamily: "Gilroy Bold",
                  color: notifier.textColor,
                  fontSize: 22),
            ),
            SizedBox(height: Get.height * 0.02),
            SizedBox(
              width: Get.width * 0.80,
              child: Text(
                "We will call or send SMS to confirm your number.".tr,
                style: TextStyle(
                    fontFamily: "Gilroy Medium",
                    color: greycolor,
                    fontSize: 16),
              ),
            ),
            SizedBox(height: Get.height * 0.02),
            IntlPhoneField(
              keyboardType: TextInputType.number,
              controller: Mobile,
              dropdownTextStyle:
                  TextStyle(color: notifier.textColor, fontSize: 16),
              style: TextStyle(
                  fontFamily: "Gilroy Medium", color: notifier.textColor),
              cursorColor: const Color(0xff4361EE),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                fillColor: transparent,
                filled: true,
                hintText: 'Enter your Phone'.tr,
                hintStyle: const TextStyle(
                  fontFamily: 'Gilroy Medium',
                  // fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xffAAACAE),
                ),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xffF3F3FA)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: orangeColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: greycolor,
                    ),
                    borderRadius: BorderRadius.circular(15)),
              ),
              initialCountryCode: 'IN',
              invalidNumberMessage: 'please enter your phone number '.tr,
              onChanged: (phone) {
                setState(() {
                  Country = phone.countryCode;
                  print(phone.countryCode);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // Future<bool> sendOTP({required String phone, Countrycode}) async {
  //   await FirebaseAuth.instance.verifyPhoneNumber(
  //     phoneNumber: Countrycode + phone,
  //     verificationCompleted: (PhoneAuthCredential credential) {},
  //     verificationFailed: (FirebaseAuthException e) {},
  //     codeSent: (String verificationId, int? resendToken) async {
  //       _verificationId = verificationId;
  //       _resendToken = resendToken;
  //     },
  //     timeout: const Duration(seconds: 60),
  //     forceResendingToken: _resendToken,
  //     codeAutoRetrievalTimeout: (String verificationId) {
  //       verificationId = _verificationId;
  //     },
  //   );
  //   debugPrint("_verificationId: $_verificationId");
  //   return true;
  // }

  Mobilecheck(String mobile, String country) async {
    try {
      // Use Firebase phone authentication instead of old API
      String fullPhoneNumber = "$country$mobile";
      print("Proceeding with Firebase phone authentication for: $fullPhoneNumber");

      // Use AuthController for Firebase phone authentication
      final AuthController authController = Get.put(AuthController());

      authController.sendPhoneOTP(phoneNumber: fullPhoneNumber).then((result) {
        if (result["Result"] == "true") {
          Get.to(() => VerifyAccount(
            ccode: country,
            number: mobile,
            Signup: "ResendCode",
            otpCode: "", // Firebase handles OTP verification
          ));
        } else {
          FirebaseService.showToastMessage(result["ResponseMsg"]);
        }
      });
    } catch (e) {
      print("Error in mobile check: $e");
      FirebaseService.showToastMessage("Failed to send OTP: ${e.toString()}");
    }
  }
}
