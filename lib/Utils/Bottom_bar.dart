// import 'package:dm/hoteldetailage.dart';
// ignore_for_file: unused_field, library_private_types_in_public_api, camel_case_types, prefer_const_constructors, file_names, prefer_const_constructors_in_immutables
// ignore_for_file: use_key_in_widget_constructors, annotate_overrides, prefer_const_literals_to_create_immutables,  unused_element, avoid_unnecessary_containers, non_constant_identifier_names, unused_import, deprecated_member_use

import 'package:foodrescue_app/views/home/NewHomePage.dart';
import 'package:foodrescue_app/views/restaurant/Nearby_hotel.dart';
import 'package:foodrescue_app/views/browse/SearchPage.dart';
import 'package:foodrescue_app/views/favourites/FavouritesPage.dart';
import 'package:foodrescue_app/views/Profile/Profile.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dark_light_mode.dart';

int selectedIndex = 0;
bool backbutton = false;

class BottomBar extends StatefulWidget {
  // ignore: use_super_parameters
  BottomBar({Key? key}) : super(key: key);

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  late int _lastTimeBackButtonWasTapped;
  static const exitTimeInMillis = 2000;

  final _pageOption = [
    NewHomePage(),
    SearchPage(),
    Nearbyhotel(),
    FavouritesPage(),
    Profile(),
  ];
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
    return
        // WillPopScope(
        // // onWillPop: _handleWillPop,
        // child:
        Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: greycolor,
        backgroundColor: notifier.background,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
            fontFamily: 'Gilroy Bold', fontWeight: FontWeight.bold),
        fixedColor: orangeColor,
        unselectedLabelStyle: const TextStyle(fontFamily: 'Gilroy Medium'),
        currentIndex: selectedIndex,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
              icon: Image.asset("assets/home.png",
                  color: selectedIndex == 0
                      ? orangeColor
                      : greycolor.withOpacity(0.5),
                  height: MediaQuery.of(context).size.height / 35),
              label: 'Home'.tr),
          BottomNavigationBarItem(
              icon: Image.asset("assets/browse.png",
                  color: selectedIndex == 1
                      ? orangeColor
                      : greycolor.withOpacity(0.5),
                  height: MediaQuery.of(context).size.height / 35),
              label: 'Search'.tr),
          BottomNavigationBarItem(
              icon: Image.asset("assets/nearby.png",
                  color: selectedIndex == 2
                      ? orangeColor
                      : greycolor.withOpacity(0.5),
                  height: MediaQuery.of(context).size.height / 35),
              label: 'Popular'.tr),
          BottomNavigationBarItem(
              icon:  Image.asset("assets/heart.png",
                color: selectedIndex == 3
                    ? orangeColor
                    : greycolor.withOpacity(0.5),
                height: MediaQuery.of(context).size.height / 35),
              label: 'Favourites'.tr),
          BottomNavigationBarItem(
            icon: Image.asset("assets/profile.png",
                color: selectedIndex == 4
                    ? orangeColor
                    : greycolor.withOpacity(0.5),
                height: MediaQuery.of(context).size.height / 35),
            label: 'Profile'.tr,
          ),
        ],
        onTap: (index) {
          setState(() {});
          selectedIndex = index;
        },
      ),
      body: _pageOption[selectedIndex],
    );
  }
}
