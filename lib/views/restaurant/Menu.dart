// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors, file_names, must_be_immutable, unnecessary_string_interpolations, use_key_in_widget_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:foodrescue_app/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:foodrescue_app/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/dark_light_mode.dart';

class Menu extends StatefulWidget {
  String? viewmenuid;
  Menu({this.viewmenuid, super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  List list = [];
  @override
  void initState() {
    getDarkMode();
    super.initState();
    menulist.viewmenulist(id: widget.viewmenuid);
    // ignore: avoid_print
    print("6666666666666viewmenu length---------------"
        "${menulist.viewmenu.length.toString()}");
  }

  HomeController menulist = Get.put(HomeController());

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
      body: GetBuilder<HomeController>(builder: (context) {
        return Column(
          children: [
            CustomAppbar(
                aapbarbgcolor: notifier.background,
                Hedingtext: "Menu".tr,
                color: notifier.textColor,
                subtext: "${menulist.viewmenu.length.toString()} Pages",
                backarrow: "assets/arrowleft.png"),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(bottom: 12),
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: menulist.viewmenu.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: Get.height * 0.025),
                          Text(menulist.viewmenu[index]["title"],
                              style: TextStyle(
                                  fontFamily: "Gilroy Bold",
                                  color: notifier.textColor,
                                  fontSize: 16)),
                          SizedBox(height: Get.height * 0.025),
                          InkWell(
                            onTap: () {
                              Get.to(() => FullScreenImage(
                                  imageUrl:
                                      menulist.viewmenu[index]["img"],
                                  tag: "generate_a_unique_tag"));
                            },
                            child: Container(
                              height: Get.height * 0.5,
                              width: double.infinity,
                              child: FadeInImage.assetNetwork(
                                fadeInCurve: Curves.easeInCirc,
                                placeholder: "assets/ezgif.com-crop.gif",
                                height: Get.height * 0.4,
                                width: Get.width * 0.7,
                                placeholderCacheHeight: 320,
                                placeholderCacheWidth: 240,
                                placeholderFit: BoxFit.fill,
                                // placeholderScale: 1.0,
                                image:
                                    menulist.viewmenu[index]["img"],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  String? imageUrl;
  String? tag;
  FullScreenImage({this.imageUrl, this.tag});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: tag ?? "",
            child: CachedNetworkImage(
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.contain,
              imageUrl: imageUrl ?? "",
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
