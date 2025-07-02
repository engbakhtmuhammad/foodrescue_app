// ignore_for_file: non_constant_identifier_names, avoid_print, file_names, prefer_const_constructors, unnecessary_string_interpolations, unused_element, must_be_immutable
// ignore: duplicate_ignore
// ignore_for_file: camel_case_types, use_key_in_widget_constructors, annotate_overrides, prefer_const_literals_to_create_immutables, file_names, unused_field, unused_element, avoid_unnecessary_containers, non_constant_identifier_names, unused_import, deprecated_member_use

import 'dart:convert';

import 'package:foodrescue_app/views/auth/Login_In.dart';
import 'package:foodrescue_app/views/auth/Verify_Account.dart';
import 'package:foodrescue_app/Utils/Bottom_bar.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:foodrescue_app/controllers/auth_controller.dart';
import 'package:foodrescue_app/services/firebase_service.dart';
import 'package:foodrescue_app/api/Data_save.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/optcontroller.dart';
import '../../Utils/dark_light_mode.dart';
import '../../config/app_config.dart';
import '../../main.dart';
import 'Forgot_Password.dart';

class Singup extends StatefulWidget {
  static String verify = "";
  const Singup({super.key});

  @override
  State<Singup> createState() => _SingupState();
}

class _SingupState extends State<Singup> {
  final FullName = TextEditingController();
  final Email = TextEditingController();
  final Password = TextEditingController();
  final Countrycode = TextEditingController();
  final Mobile = TextEditingController();
  String mobilecheck = "";
  OtpController otpCont = Get.put(OtpController());
  final AuthController authController = Get.put(AuthController());
  bool _obscureText = true;
  bool isPhoneRegistration = true; // Toggle between phone and email registration
  bool isLoading = false; // Loading state for buttons
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

  String Country = "";
  String pagerought = "";
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

  // Email registration method
  registerWithEmail() async {
    try {
      var result = await authController.registerUser(
        name: FullName.text,
        email: Email.text,
        mobile: "", // No mobile for email registration
        ccode: "",
        password: Password.text,
      );

      if (result["Result"] == "true") {
        Get.to(() => BottomBar());
        OneSignal.User.addTagWithKey("user_id", getData.read("UserLogin")["id"]);
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      } else {
        FirebaseService.showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print("Error in email registration: $e");
      FirebaseService.showToastMessage("Registration failed: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.background,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: SizedBox(
          height: Get.height * 0.12,
          child: Column(
            children: [
              AppButton(
                buttonColor: isLoading ? Colors.grey : orangeColor,
                buttontext: isLoading ? "Please wait...".tr : "Continue".tr,
                onTap: isLoading ? null : () async {
                  if ((_formKey.currentState?.validate() ?? false)) {
                    Mobilecheck(Mobile.text, Country);
                  }
                },
              ),
              SizedBox(height: Get.height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have account?".tr,
                    style: TextStyle(
                        fontFamily: "Gilroy Medium",
                        color: notifier.textColor,
                        fontSize: 16),
                  ),
                  InkWell(
                    onTap: () {
                      Get.to(() => const LoginPage());
                    },
                    child: Text(
                      " Log In".tr,
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
      appBar: loginappbar(backGround: notifier.background,color: notifier.textColor),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Get.height * 0.05),
                SizedBox(
                  width: Get.width * 0.70,
                  child: Text(
                    "Become a DineOut member".tr,
                    style: TextStyle(
                        fontFamily: "Gilroy Bold",
                        color: notifier.textColor,
                        fontSize: 22),
                  ),
                ),
                SizedBox(height: Get.height * 0.02),
                // Registration method toggle
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isPhoneRegistration = false;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isPhoneRegistration ? orangeColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: !isPhoneRegistration ? orangeColor : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            "Email Registration".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Gilroy Medium",
                              color: !isPhoneRegistration ? Colors.white : notifier.textColor,
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
                            isPhoneRegistration = true;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isPhoneRegistration ? orangeColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isPhoneRegistration ? orangeColor : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            "Phone Registration".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Gilroy Medium",
                              color: isPhoneRegistration ? Colors.white : notifier.textColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Get.height * 0.02),
                // Conditional input field based on registration type
                if (isPhoneRegistration) ...[
                  // Phone input field
                  IntlPhoneField(
                  keyboardType: TextInputType.number,
                  controller: Mobile,
                  cursorColor: const Color(0xff4361EE),
                  dropdownTextStyle: TextStyle(color: notifier.textColor, fontSize: 16),
                  style:
                      TextStyle(fontFamily: "Gilroy Medium", color: notifier.textColor),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    fillColor: transparent,
                    counterText: "",
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
                ] else ...[
                  // Email input field for email registration
                  TextFormField(
                    controller: Email,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontFamily: "Gilroy Medium",
                      color: notifier.textColor,
                    ),
                    decoration: InputDecoration(
                      fillColor: transparent,
                      filled: true,
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email'.tr;
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Please enter a valid email'.tr;
                      }
                      return null;
                    },
                  ),
                ],
                SizedBox(height: 10),
                passwordtextfield(
                    controller: FullName,
                    color: notifier.textColor,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Full name'.tr;
                      }
                      return null;
                    },
                    lebaltext: "Full Name".tr,
                    suffixIcon: null,
                    obscureText: false),
                SizedBox(height: 10),
                passwordtextfield(
                  color: notifier.textColor,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Email'.tr;
                      }
                      return null;
                    },
                    controller: Email,
                    lebaltext: "Email address".tr,
                    suffixIcon: null,
                    obscureText: false),
                SizedBox(height: 10),
                passwordtextfield(
                  color: notifier.textColor,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Email address'.tr;
                    }
                    return null;
                  },
                  lebaltext: "Password".tr,
                  controller: Password,
                  obscureText: _obscureText,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Mobilecheck(String mobile, String country) async {
    if (isLoading) return; // Prevent multiple submissions

    setState(() {
      isLoading = true;
    });

    try {
      // Skip the old API call and directly proceed with Firebase authentication
      // This eliminates the "No host specified in URI" error

      if (isPhoneRegistration) {
        // Phone registration with Firebase phone authentication
        String fullPhoneNumber = "$country$mobile";
        authController.sendPhoneOTP(phoneNumber: fullPhoneNumber).then((result) {
          setState(() {
            isLoading = false;
          });

          if (result["Result"] == "true") {
            Get.to(() => VerifyAccount(
              ccode: country,
              number: mobile,
              Email: Email.text,
              FullName: FullName.text,
              Password: Password.text,
              Signup: "Signup",
              otpCode: "", // Firebase handles OTP verification
            ));
          } else {
            FirebaseService.showToastMessage(result["ResponseMsg"]);
          }
        }).catchError((error) {
          setState(() {
            isLoading = false;
          });
          FirebaseService.showToastMessage("Failed to send OTP: ${error.toString()}");
        });
      } else {
        // Email registration - direct registration without phone verification
        await registerWithEmail();
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error in mobile check: $e");
      FirebaseService.showToastMessage("Registration failed: ${e.toString()}");
    }
  }
}
