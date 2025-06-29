// ignore_for_file: file_names, non_constant_identifier_names, avoid_print, unnecessary_brace_in_string_interps, deprecated_member_use

import 'dart:io';

import 'package:foodrescue_app/LoginFlow/Resend_Code.dart';
import 'package:foodrescue_app/LoginFlow/Sign_up.dart';
import 'package:foodrescue_app/Utils/Bottom_bar.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:foodrescue_app/controllers/auth_controller.dart';
import 'package:foodrescue_app/services/firebase_service.dart';
import 'package:foodrescue_app/api/Data_save.dart';
import 'package:foodrescue_app/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/dark_light_mode.dart';

bool verifyotp = false;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Email = TextEditingController();
  final Mobile = TextEditingController();
  final password = TextEditingController();
  final AuthController authController = Get.put(AuthController());
  bool _obscureText = true;
  bool isPhoneLogin = false; // Toggle between phone and email login
  String? Country;
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void initState() {
    getDarkMode();
    super.initState();
  }

  String loginpage = "";
  bool isChecked = false;

  final _formKey = GlobalKey<FormState>();
  final formKey = GlobalKey<FormState>();

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
        exit(0);
      },
      child: Scaffold(
        backgroundColor: notifier.background,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: SizedBox(
            height: Get.height * 0.12,
            child: Column(
              children: [
                AppButton(
                  buttonColor: orangeColor,
                  buttontext: "Sign In".tr,
                  onTap: () {
                    if ((_formKey.currentState?.validate() ?? false)) {
                      initPlatformState();
                      if (isPhoneLogin) {
                        login(Mobile.text, Country ?? "", password.text);
                      } else {
                        loginWithEmail(Email.text, password.text);
                      }
                    }
                  },
                ),
                SizedBox(height: Get.height * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?".tr,
                      style: TextStyle(
                          fontFamily: "Gilroy Medium",
                          color: notifier.textColor,
                          fontSize: 16),
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(() => const Singup());
                      },
                      child: Text(
                        " Sign Up".tr,
                        style: TextStyle(
                            fontFamily: "Gilroy Bold",
                            color: orangeColor,
                            fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
            backgroundColor: notifier.background,
            elevation: 0,
            leading: Transform.translate(
                offset: const Offset(-4, 0),
                child: Padding(
                  padding: const EdgeInsets.all(19),
                  child: InkWell(
                      onTap: () {
                        setState(() {
                          exit(0);
                        });
                      },
                      child: Image.asset("assets/leftarrow.png",
                          color: notifier.textColor)),
                ))),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Get.height * 0.05),
                Text(
                  "Welcome back".tr,
                  style: TextStyle(
                      fontFamily: "Gilroy Bold",
                      color: notifier.textColor,
                      fontSize: 22),
                ),
                SizedBox(height: Get.height * 0.03),
                // Login method toggle
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isPhoneLogin = false;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isPhoneLogin ? orangeColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: !isPhoneLogin ? orangeColor : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            "Email Login".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Gilroy Medium",
                              color: !isPhoneLogin ? Colors.white : notifier.textColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isPhoneLogin = true;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isPhoneLogin ? orangeColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isPhoneLogin ? orangeColor : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            "Phone Login".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Gilroy Medium",
                              color: isPhoneLogin ? Colors.white : notifier.textColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Get.height * 0.02),
                // Conditional input field based on login type
                if (!isPhoneLogin) ...[
                  // Email input field
                  TextFormField(
                    controller: Email,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontFamily: "Gilroy Medium",
                      color: notifier.textColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your Email'.tr,
                      hintStyle: const TextStyle(
                        fontFamily: 'Gilroy Medium',
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
                          color: Colors.grey.withOpacity(0.4),
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ] else ...[
                  // Phone input field
                  IntlPhoneField(
                  keyboardType: TextInputType.number,
                  controller: Mobile,
                  dropdownTextStyle: TextStyle(color: notifier.textColor, fontSize: 16),
                  style:
                  TextStyle(fontFamily: "Gilroy Medium", color: notifier.textColor),
                  cursorColor: const Color(0xff4361EE),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    iconColor: notifier.textColor,
                    fillColor: transparent,
                    filled: true,
                    counterText: "",
                    hintText: 'Enter your Phone'.tr,
                    hintStyle: const TextStyle(
                      fontFamily: 'Gilroy Medium',
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
                          color: Colors.grey.withOpacity(0.4),
                        ),
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  initialCountryCode: 'IN',
                  invalidNumberMessage: 'please enter your phone number '.tr,
                  onChanged: (phone) {
                    Country = phone.countryCode;
                    print(phone.countryCode);
                  },
                ),
                ],
                const SizedBox(height: 10),
                passwordtextfield(
                  lebaltext: "Password",
                  color: notifier.textColor,
                  controller: password,
                  obscureText: _obscureText,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Password';
                    }
                    return null;
                  },
                  suffixIcon: InkWell(
                      onTap: () {
                        _toggle();
                      },
                      child: !_obscureText
                          ? Icon(
                        Icons.visibility,
                        color: orangeColor,
                      )
                          : Icon(
                        Icons.visibility_off,
                        color: Colors.grey.withOpacity(0.5),
                      )),
                ),
                SizedBox(height: Get.height * 0.015),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.to(() => const ResendCode());
                      },
                      child: Text(
                        "Forgot Password?".tr,
                        style: TextStyle(
                            fontFamily: "Gilroy Medium",
                            color: notifier.textColor,
                            fontSize: 16),
                      ),
                    ),
                    Row(
                      children: [
                        Transform.translate(
                          offset: const Offset(8,0),
                          child: Theme(
                            data: ThemeData(unselectedWidgetColor: greycolor),
                            child: Checkbox(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              value: isChecked,
                              activeColor: notifier.textColor,
                              checkColor: notifier.background,
                              onChanged: (value) {
                                setState(() {
                                  isChecked = value!;
                                  save("Remember", value);
                                });
                              },
                            ),
                          ),
                        ),
                        Text(
                          "Remember Me".tr,
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Gilroy Medium",
                              color: notifier.textColor),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: Get.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  login(String mobile, String country, String password) async {
    try {
      var result = await authController.loginUser(
        mobile: mobile,
        password: password,
        ccode: country,
      );

      loginpage = result["Result"];
      print("*********************${loginpage}");

      if (loginpage == "true") {
        Get.to(() => BottomBar());
        // OneSignal.shared.sendTag("user_id", getData.read("UserLogin")["id"]);
        OneSignal.User.addTagWithKey("user_id", getData.read("UserLogin")["id"]);
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print(e.toString());
      FirebaseService.showToastMessage("Login failed: ${e.toString()}");
    }
  }

  loginWithEmail(String email, String password) async {
    try {
      var result = await authController.loginWithEmail(
        email: email,
        password: password,
      );

      loginpage = result["Result"];
      print("*********************${loginpage}");

      if (loginpage == "true") {
        Get.to(() => BottomBar());
        OneSignal.User.addTagWithKey("user_id", getData.read("UserLogin")["id"]);
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print(e.toString());
      FirebaseService.showToastMessage("Email login failed: ${e.toString()}");
    }
  }

  // Future<void> initPlatformState() async {
  //   OneSignal.shared.setAppId(AppUrl.oneSignel);
  //   OneSignal.shared
  //       .promptUserForPushNotificationPermission()
  //       .then((accepted) {});
  //   OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
  //     print("Accepted OSPermissionStateChanges : $changes");
  //   });
  //   // print("--------------__uID : ${getData.read("UserLogin")["id"]}");

  // }

  Future<void> initPlatformState() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(AppConfig.oneSignalAppId);
    OneSignal.Notifications.requestPermission(true).then((value) {
        print("Signal value:- $value");
      },);
  }

}
