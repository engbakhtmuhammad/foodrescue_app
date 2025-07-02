// ignore_for_file: camel_case_types, file_names, prefer_const_constructors, non_constant_identifier_names

import 'package:accordion/accordion.dart';
import 'package:foodrescue_app/controllers/Controller.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/Custom_widegt.dart';
import '../../Utils/dark_light_mode.dart';

class faqsandhelp extends StatefulWidget {
  const faqsandhelp({super.key});

  @override
  State<faqsandhelp> createState() => _faqsandhelpState();
}

class _faqsandhelpState extends State<faqsandhelp> {
  @override
  void initState() {
    getDarkMode();
    super.initState();
    Faqlist.Faqdata();
  }

  HomeController Faqlist = Get.put(HomeController());
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
      appBar: AppBar(
        leading: BackButton(color: notifier.textColor),
        elevation: 0,
        backgroundColor: notifier.background,
        title: Text(
          "help & support".tr.toUpperCase(),
          style: TextStyle(
              fontFamily: "Gilroy Bold", fontSize: 16, color: notifier.textColor),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            child: GetBuilder<HomeController>(builder: (context) {
              return Column(
                children: [
                  Faqlist.isLoading
                      ? Accordion(
                          maxOpenSections: 1,
                          disableScrolling: true,
                          headerBorderRadius: 20,
                          flipRightIconIfOpen: true,
                          rightIcon: Icon(Icons.keyboard_arrow_down_sharp,color: notifier.textColor,size: 22),
                          contentBorderColor: transparent,
                          contentBackgroundColor: notifier.containerColor,
                          headerBackgroundColor: notifier.containerColor.withOpacity(0.1),
                          headerPadding:
                              EdgeInsets.symmetric(vertical: 7, horizontal: 15),
                          children: [
                            for (var i = 0; i < Faqlist.FAQ.length; i++)
                              AccordionSection(
                                  headerBackgroundColor: notifier.containerColor,
                                  // leftIcon: Icon(Icons.insights_rounded, color: Colors.white),
                                  header: Text(Faqlist.FAQ[i]["question"],
                                      style: TextStyle(
                                          fontFamily: "Gilroy Bold",
                                          fontSize: 16,
                                          color: notifier.textColor)),
                                  content: Text(Faqlist.FAQ[i]["answer"],
                                      style: TextStyle(
                                          fontFamily: "Gilroy Medium",
                                          fontSize: 16,
                                          color: greycolor)),
                                  // contentBorderWidth: 10,
                                  contentHorizontalPadding: 20),
                          ],
                        )
                      : Padding(
                          padding: EdgeInsets.only(top: Get.height * 0.35),
                          child:
                               Center(child: CircularProgressIndi()),
                        )
                ],
              );
            }),
          )),
    );
  }
}
