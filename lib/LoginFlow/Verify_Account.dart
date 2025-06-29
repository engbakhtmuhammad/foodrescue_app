// ignore_for_file: file_names, unused_catch_clause, non_constant_identifier_names, avoid_print, prefer_final_fields
// ignore_for_file: camel_case_types, use_key_in_widget_constructors, annotate_overrides, prefer_const_literals_to_create_immutables, unused_field, unused_element, avoid_unnecessary_containers, unused_import, deprecated_member_use

import 'dart:convert';

import 'package:foodrescue_app/LoginFlow/Forgot_Password.dart';
import 'package:foodrescue_app/Utils/Bottom_bar.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:foodrescue_app/controllers/auth_controller.dart';
import 'package:foodrescue_app/services/firebase_service.dart';
import 'package:foodrescue_app/api/Data_save.dart';
import 'package:foodrescue_app/config/app_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Getx_Controller/optcontroller.dart';
import '../Utils/dark_light_mode.dart';

String pagerought = "";
// ignore: must_be_immutable
class VerifyAccount extends StatefulWidget {
  String? ccode;
  String? number;
  String? FullName;
  String? Email;
  String? Password;
  String? Signup;
  String? otpCode;

  VerifyAccount(
      {this.FullName,
      this.Email,
      this.Password,
      this.ccode,
      this.number,
      this.Signup,
      this.otpCode,
      super.key});

  @override
  State<VerifyAccount> createState() => _VerifyAccountState();
}

class _VerifyAccountState extends State<VerifyAccount> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final pinController = TextEditingController();
  OtpController otpController = Get.put(OtpController());
  String code = "";


  String _verificationId = "";

  int? _resendToken;
  String verrification = "";


  @override
  void initState() {
    getDarkMode();
    super.initState();
    setState(() {
      verrification = widget.Signup ?? "";
    });
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
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: AppButton(
          buttonColor: orangeColor,
          buttontext: "Verify Account".tr,
          onTap: () async {
            if (code.length == 6) {
              if (verrification == "Signup") {
                // Use Firebase phone authentication for registration
                AuthController authController = Get.find<AuthController>();
                var result = await authController.registerUserWithPhone(
                  name: widget.FullName ?? "",
                  email: widget.Email ?? "",
                  mobile: widget.number ?? "",
                  ccode: widget.ccode ?? "",
                  password: widget.Password ?? "",
                  smsCode: code,
                );

                if (result["Result"] == "true") {
                  Get.to(() => BottomBar());
                  OneSignal.User.addTagWithKey(
                      "user_id", getData.read("UserLogin")["id"]);
                  FirebaseService.showToastMessage(result["ResponseMsg"]);
                } else {
                  FirebaseService.showToastMessage(result["ResponseMsg"]);
                }
                initPlatformState();
              } else {
                // For password reset, verify OTP first
                AuthController authController = Get.find<AuthController>();
                var result = await authController.verifyPhoneOTP(smsCode: code);

                if (result["Result"] == "true") {
                  Get.to(() => ForgotPassword(
                        ccode: widget.ccode,
                        mobileNo: widget.number,
                      ));
                } else {
                  FirebaseService.showToastMessage(result["ResponseMsg"]);
                }
              }
            } else {
              FirebaseService.showToastMessage("Please Enter Valid 6-digit OTP");
            }
          },
        ),
      ),
      appBar: loginappbar(
          backGround: notifier.background, color: notifier.textColor),
      backgroundColor: notifier.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Get.height * 0.05),
            Text(
              "Verify Account".tr,
              style: TextStyle(
                  fontFamily: "Gilroy Bold",
                  color: notifier.textColor,
                  fontSize: 22),
            ),
            SizedBox(height: Get.height * 0.02),
            SizedBox(
              width: Get.width * 0.80,
              child: RichText(
                text: TextSpan(
                  text:
                  "Please, enter the verification code we send to your mobile"
                      .tr,
                  style: TextStyle(
                      fontFamily: "Gilroy Medium",
                      color: greycolor,
                      fontSize: 16),
                  children: <TextSpan>[
                    TextSpan(
                        text: "  ${widget.ccode} ${widget.number}",
                        style: TextStyle(
                            fontFamily: "Gilroy Bold",
                            fontSize: 16,
                            color: notifier.textColor)),
                  ],
                ),
              ),
            ),
            SizedBox(height: Get.height * 0.02),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Pinput(
                length: 6,
                controller: pinController,
                submittedPinTheme: PinTheme(
                    width: 56,
                    height: 56,
                    textStyle: TextStyle(
                        fontSize: 20,
                        color: notifier.textColor,
                        fontFamily: "Gilroy Bold"),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: orangeColor))),
                defaultPinTheme: PinTheme(
                  width: 56,
                  height: 56,
                  textStyle: TextStyle(
                      fontSize: 20,
                      color: notifier.background,
                      fontFamily: "Gilroy Bold"),
                  decoration: BoxDecoration(
                      color: notifier.containerColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: greycolor.withOpacity(0.2))),
                ),
                errorText: 'Wrong otp'.tr,
                onChanged: (value) {
                  code = value;
                },
              ),
            ),
            SizedBox(height: Get.height * 0.02),
            InkWell(
              onTap: () {
                setState(() {});
                pinController.clear();

                // Resend OTP using Firebase phone authentication
                String fullPhoneNumber = "${widget.ccode}${widget.number}";
                AuthController authController = Get.find<AuthController>();
                authController.sendPhoneOTP(phoneNumber: fullPhoneNumber).then((result) {
                  if (result["Result"] == "true") {
                    FirebaseService.showToastMessage("OTP sent successfully");
                  } else {
                    FirebaseService.showToastMessage(result["ResponseMsg"]);
                  }
                });
              },
              child: Text(
                "Resend code?".tr,
                style: TextStyle(
                    fontFamily: "Gilroy Bold",
                    color: notifier.textColor,
                    fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }



  //
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

//   Future<void> initPlatformState() async {
//     OneSignal.shared.setAppId(AppUrl.oneSignel);
//     OneSignal.shared
//         .promptUserForPushNotificationPermission()
//         .then((accepted) {});
//     OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
//       print("Accepted OSPermissionStateChanges : $changes");
//     });
//     // print("--------------__uID : ${getData.read("UserLogin")["id"]}");
//     await OneSignal.shared.sendTag("user_id", getData.read("UserLogin")["id"]);
//   }
// }
  Future<void> initPlatformState() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(AppConfig.oneSignalAppId);
    OneSignal.Notifications.requestPermission(true).then(
          (value) {
        print("Signal value:- $value");
      },
    );
  }
}


// Old Register function removed - now using Firebase phone authentication
// in the verification button onTap handler above