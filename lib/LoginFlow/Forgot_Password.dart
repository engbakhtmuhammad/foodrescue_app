// ignore_for_file: file_names, non_constant_identifier_names, unused_element, must_be_immutable, unused_field, unnecessary_brace_in_string_interps, avoid_print

import 'dart:convert';

import 'package:foodrescue_app/LoginFlow/Login_In.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:foodrescue_app/utils/api_wrapper.dart';
import 'package:foodrescue_app/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/dark_light_mode.dart';

class ForgotPassword extends StatefulWidget {
  String? mobileNo;
  String? ccode;

  ForgotPassword({this.mobileNo, this.ccode, super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final Newpassword = TextEditingController();
  final password = TextEditingController();
  final Mobile = TextEditingController();
  final Email = TextEditingController();
  final Password = TextEditingController();
  bool _obscureText = true;
  bool _obscureText1 = true;
  String mobilecheck = "";
  String forgotpass = "";
  String Country = "";
  final _formKey = GlobalKey<FormState>();
  String forgetPasswprdResult = "";
  String forgetMsg = "";

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggle1() {
    setState(() {
      _obscureText1 = !_obscureText1;
    });
  }

  @override
  void initState() {
    getDarkMode();
    super.initState();
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
          buttontext: "Reset Password".tr,
          onTap: () {
            if ((_formKey.currentState?.validate() ?? false)) {
              if (Newpassword.text == password.text) {
                ForgetPasswordApi(ccode: widget.ccode, mobile: widget.mobileNo);
              } else {
                ApiWrapper.showToastMessage("please valid password");
              }
            }
          },
        ),
      ),
      appBar: loginappbar(
          backGround: notifier.background, color: notifier.textColor),
      backgroundColor: notifier.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Get.height * 0.05),
              SizedBox(
                width: Get.width * 0.70,
                child: Text(
                  "Create Your New Password".tr,
                  style: TextStyle(
                      fontFamily: "Gilroy Bold",
                      color: notifier.textColor,
                      fontSize: 22),
                ),
              ),
              SizedBox(height: Get.height * 0.02),
              SizedBox(
                width: Get.width * 0.80,
                child: Text(
                  "Your new password must be different from previous password."
                      .tr,
                  style: TextStyle(
                      fontFamily: "Gilroy Medium",
                      color: greycolor,
                      fontSize: 16),
                ),
              ),
              SizedBox(height: Get.height * 0.03),
              passwordtextfield(
                lebaltext: "New Password".tr,
                controller: Newpassword,
                color: notifier.textColor,
                obscureText: _obscureText,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Password'.tr;
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
                            color: darkpurple,
                          )
                        : Icon(
                            Icons.visibility_off,
                            color: greycolor,
                          )),
              ),
              SizedBox(height: Get.height * 0.03),
              passwordtextfield(
                lebaltext: "Password".tr,
                controller: password,
                color: notifier.textColor,
                obscureText: _obscureText1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Password'.tr;
                  }
                  return null;
                },
                suffixIcon: InkWell(
                    onTap: () {
                      _toggle1();
                    },
                    child: !_obscureText1
                        ? Icon(
                            Icons.visibility,
                            color: darkpurple,
                          )
                        : Icon(
                            Icons.visibility_off,
                            color: greycolor,
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ForgetPasswordApi({
    String? mobile,
    String? ccode,
  }) async {
    try {
      Map map = {
        "mobile": mobile,
        "ccode": ccode,
        "password": Newpassword.text,
      };
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.forgetpassword);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        forgetPasswprdResult = result["Result"];
        forgetMsg = result["ResponseMsg"];
        if (forgetPasswprdResult == "true") {
          Get.to(() => const LoginPage());
          ApiWrapper.showToastMessage(forgetMsg);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
