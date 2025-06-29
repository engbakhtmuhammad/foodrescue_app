// ignore_for_file: unused_import, file_names, non_constant_identifier_names, duplicate_ignore, prefer_const_literals_to_create_immutables, prefer_const_constructors
// ignore_for_file: camel_case_types, use_key_in_widget_constructors, annotate_overrides, prefer_const_literals_to_create_immutables, file_names, unused_field, unused_element, avoid_unnecessary_containers, non_constant_identifier_names, unused_import, deprecated_member_use

import 'dart:ffi';

import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

dottedline() {
  return DottedLine(
      direction: Axis.horizontal,
      lineLength: double.infinity,
      lineThickness: 1.0,
      dashColor: greycolor,
      dashGapLength: 4.0);
}

List reportcard = [
  {"image": "assets/Hotel.jpg", "" "status": "1"},
  {"image": "assets/fabhotel.jpg", "status": "1"},
  {"image": "assets/hotelajanta.jpg", "status": "1"},
  {"image": "assets/kenilworth.jpg", "status": "1"},
  {"image": "assets/lobby.jpg", "status": "1"},
  {"image": "assets/getty.jpg", "status": "1"},
  {"image": "assets/Hotel.jpg", "status": "1"},
  {"image": "assets/fabhotel.jpg", "status": "1"},
  {"image": "assets/hotelajanta.jpg", "status": "1"},
  {"image": "assets/kenilworth.jpg", "status": "1"},
  {"image": "assets/lobby.jpg", "status": "1"},
  {"image": "assets/getty.jpg", "status": "1"},
  {
    "image": "assets/Hotel.jpg",
    "status": "1",
  },
  {"image": "assets/fabhotel.jpg", "status": "1"},
  {"image": "assets/hotelajanta.jpg", "status": "1"},
  {"image": "assets/kenilworth.jpg", "status": "1"},
  {"image": "assets/lobby.jpg", "status": "1"},
  {"image": "assets/getty.jpg", "status": "1"},
];
List card = [
  {"image": "assets/getty.jpg", "status": "1"},
  {"image": "assets/lobby.jpg", "status": "1"},
  {"image": "assets/hotelajanta.jpg", "status": "1"},
  {"image": "assets/fabhotel.jpg", "status": "1"},
  {"image": "assets/kenilworth.jpg", "status": "1"},
  {"image": "assets/getty.jpg", "status": "1"},
  {"image": "assets/lobby.jpg", "status": "1"},
  {"image": "assets/hotelajanta.jpg", "status": "1"},
  {"image": "assets/fabhotel.jpg", "status": "1"},
  {"image": "assets/kenilworth.jpg", "status": "1"},
  {"image": "assets/getty.jpg", "status": "1"},
  {"image": "assets/lobby.jpg", "status": "1"},
  {"image": "assets/hotelajanta.jpg", "status": "1"},
  {"image": "assets/fabhotel.jpg", "status": "1"},
  {"image": "assets/kenilworth.jpg", "status": "1"},
  {"image": "assets/getty.jpg", "status": "1"},
  {"image": "assets/lobby.jpg", "status": "1"},
  {"image": "assets/hotelajanta.jpg", "status": "1"},
];
List foodlist = [
  {"image": "assets/food4.jpg", "status": "1"},
  {"image": "assets/foodimg.jpg", "status": "1"},
  {"image": "assets/food.jpg", "status": "1"},
  {"image": "assets/food1.jpg", "status": "1"},
  {"image": "assets/food2.jpg", "status": "1"},
  {"image": "assets/food4.jpg", "status": "1"},
  {"image": "assets/foodimg.jpg", "status": "1"},
  {"image": "assets/food1.jpg", "status": "1"},
  {"image": "assets/food2.jpg", "status": "1"},
  {"image": "assets/food4.jpg", "status": "1"},
  {"image": "assets/foodimg.jpg", "status": "1"},
  {"image": "assets/food.jpg", "status": "1"},
  {"image": "assets/food1.jpg", "status": "1"},
  {"image": "assets/food2.jpg", "status": "1"},
  {"image": "assets/food4.jpg", "status": "1"},
  {"image": "assets/foodimg.jpg", "status": "1"},
  {"image": "assets/food1.jpg", "status": "1"},
  {"image": "assets/food2.jpg", "status": "1"},
];

// ignore: non_constant_identifier_names
CustomAppbar({String? Hedingtext, subtext, backarrow, Color? aapbarbgcolor,Color? color}) {
  return AppBar(
    backgroundColor: aapbarbgcolor,
    elevation: 0,
    leading: Transform.translate(
      offset: const Offset(-2, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: InkWell(
            onTap: () {
              Get.back();
            },
            child: Image.asset(backarrow, height: 20, color: color)),
      ),
    ),
    titleSpacing: 0,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Hedingtext!,
          style: TextStyle(
              fontFamily: "Gilroy Bold", color: color, fontSize: 16),
        ),
        Text(subtext,
            style: TextStyle(
                fontFamily: "Gilroy Medium", color: greycolor, fontSize: 16)),
      ],
    ),
  );
}

textfield(
    {String? text,
    labelText,
    prefixtext,
    suffix,
    Color? labelcolor,
    prefixcolor,
    floatingLabelColor,
    focusedBorderColor,
    TextDecoration? decoration,
    double? Width,
      Color? color,
    TextEditingController? controller,
    Function(String)? onChanged,
    Height}) {
  return Container(
      height: Height,
      width: Width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: color),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: orangeColor,
        keyboardType: TextInputType.number,
        style: TextStyle(
            color: orangeColor, fontFamily: "Gilroy Bold", fontSize: 18),
        decoration: InputDecoration(
          prefix: Text(
            prefixtext,
            // "₹",
            style: TextStyle(
                decoration: decoration,
                fontSize: 20,
                color: prefixcolor,
                fontFamily: "Gilroy Bold"),
          ),
          floatingLabelStyle: TextStyle(
              color: floatingLabelColor,
              fontFamily: "Gilroy Medium",
              fontSize: 16),
          labelText: labelText,
          labelStyle: TextStyle(
              color: labelcolor, fontFamily: "Gilroy Medium", fontSize: 16),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(6),
            child: suffix,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: focusedBorderColor),
            borderRadius: BorderRadius.circular(15),
          ),
          border:  OutlineInputBorder(
            borderSide: BorderSide(color: GreyColor),
              borderRadius: BorderRadius.all(Radius.circular(15))),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: GreyColor),
              borderRadius: BorderRadius.circular(15)),
        ),
      ));
}

AppButton(
    {Function()? onTap,
    String? buttontext,
    double? width,
    Color? buttonColor}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: buttonColor),
      height: 50,
      width: width,
      child: Center(
          child: Text(buttontext!,
              style: TextStyle(
                  color: WhiteColor, fontFamily: "Gilroy Bold", fontSize: 16))),
    ),
  );
}

appbar({String? titletext, centertext, subtitletext,required Color background,required Color color}) {
  return AppBar(
    elevation: 0,
    backgroundColor: background,
    leading: Transform.translate(
      offset: const Offset(1, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: InkWell(
            onTap: () {
              Get.back();
            },
            child: Image.asset("assets/arrowleft.png",
                height: 20, color: color)),
      ),
    ),
    centerTitle: true,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 25),
          child: Text(
            titletext!,
            style: TextStyle(
                color: greycolor, fontFamily: "Gilroy Medium", fontSize: 12),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 25),
          child: Text(centertext,
              style: TextStyle(
                  color: color,
                  fontFamily: "Gilroy ExtraBold",
                  fontSize: 20)),
        ),
        Text(subtitletext,
            style: TextStyle(
              color: greycolor,
              fontFamily: "Gilroy Medium",
              fontSize: 14,
            ),
            textAlign: TextAlign.center),
      ],
    ),
  );
}

bottombar(
    {String? Hedingtext,
    buttontext1,
    // buttontext2,
    Color? bgcolor,
    Function()? onTap}) {
  return Container(
    height: Get.height * 0.17,
    width: double.infinity,
    color: bgcolor,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/confetti1.png", height: 25),
              SizedBox(width: Get.width * 0.02),
              Text(Hedingtext!,
                  style: TextStyle(
                      fontFamily: "Gilroy Bold",
                      color: orangeColor,
                      fontSize: 15)),
              SizedBox(width: Get.width * 0.02),
              Image.asset("assets/confetti.png", height: 25)
            ],
          ),
          SizedBox(height: Get.height * 0.015),
          InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    stops: const [0.1, 0.8, 1],
                    colors: <Color>[orangeColor, orangeColor, Colors.red],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: orangeColor),
              height: 50,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    buttontext1,
                    style: TextStyle(
                        fontFamily: 'Gilroy Bold',
                        fontSize: 16,
                        color: WhiteColor),
                  ),
                  // SizedBox(height: Get.height * 0.005),
                  // Text(
                  //   "",
                  //   style: TextStyle(
                  //       fontFamily: 'Gilroy Bold',
                  //       fontSize: 12,
                  //       color: WhiteColor),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

loginappbar({required Color? backGround, required Color? color}) {
  return AppBar(
      backgroundColor: backGround,
      elevation: 0,
      leading: Transform.translate(
          offset: const Offset(-6, 0),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Image.asset(
                  "assets/leftarrow.png",
                  color: color,
                )),
          )));
}

Widget passwordtextfield(
    {Widget? suffixIcon,
    String? lebaltext,
    double? width,
    bool? obscureText,
      Color? color,
    String? Function(String?)? validator,
    TextEditingController? controller}) {
  return Container(
    width: width,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
    child: TextFormField(
      controller: controller,
      obscureText: obscureText!,
      validator: validator,
      style: TextStyle(
        fontSize: 16,
        fontFamily: "Gilroy Medium",
        color: color,
      ),
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        labelText: lebaltext,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: orangeColor),
          borderRadius: BorderRadius.circular(15),
        ),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.4),
            ),
            borderRadius: BorderRadius.circular(15)),
      ),
    ),
  );
}

  Widget CircularProgressIndi(){
   return  CircularProgressIndicator(color: Color(0xff473F97),);
  }

List banner = [
  {"image": "https://i.ibb.co/ZgZrJ9q/1.png", "id": "1"},
  {"image": "https://i.ibb.co/TRJPR2k/2.png", "id": "2"},
  {"image": "https://i.ibb.co/bKdQrR8/3.png", "id": "3"},
];

List hoteldetail = [
  {
    "id": "1",
    "title": "Mahesh Pav Bhaji",
    "offer": "extra 10% off",
    "image": "assets/pavbhaji.jpg",
    "massage": "Chinese,South indian,pizzas Vishal nazed 7.7 km",
    "review": "4.0(80+)",
    "mins": "40 Mins",
  },
  {
    "id": "2",
    "title": "Gopal Chinese",
    "offer": "extra 15% off",
    "image": "assets/chinese.jpg",
    "massage": "Chinese,South 3.4 km",
    "review": "3.0(50+)",
    "mins": "30 Mins",
  },
  {
    "id": "3",
    "title": "Anand dhosha",
    "offer": "extra 25% off",
    "image": "assets/dhosa.png",
    "massage": "Dhosa,Gotalo,Palakpanir,pizzas dhosa 5.2 km",
    "review": "5.0(100+)",
    "mins": "50 Mins",
  },
  {
    "id": "4",
    "title": "Kathiyavadi restaurants",
    "offer": "extra 30% off",
    "image": "assets/kathiyavadi.jpg",
    "massage": "Rotli,shak,Dalbhat,salad,achar,Chhas and extra...",
    "review": "4.5(100+)",
    "mins": "15 Mins",
  },
  {
    "id": "5",
    "title": "south Indian restaurants",
    "offer": "extra 25% off",
    "image": "assets/southindian.jpg",
    "massage": "Idlisambar,Vada,Uttapam,Appam,Upma and Extra",
    "review": "3.5(70+)",
    "mins": "20 Mins",
  },
  {
    "id": "6",
    "title": "Mahesh Pav Bhaji",
    "offer": "extra 10% off",
    "image": "assets/pavbhaji.jpg",
    "massage": "Chinese,South indian,pizzas Vishal nazed 7.7 km",
    "review": "4.0(80+)",
    "mins": "40 Mins",
  },
  {
    "id": "7",
    "title": "Gopal Chinese",
    "offer": "extra 15% off",
    "image": "assets/chinese.jpg",
    "massage": "Chinese,South 3.4 km",
    "review": "3.0(50+)",
    "mins": "30 Mins",
  },
  {
    "id": "8",
    "title": "Anand dhosha",
    "offer": "extra 25% off",
    "image": "assets/dhosa.png",
    "massage": "Dhosa,Gotalo,Palakpanir,pizzas dhosa 5.2 km",
    "review": "5.0(100+)",
    "mins": "50 Mins",
  },
  {
    "id": "9",
    "title": "Kathiyavadi restaurants",
    "offer": "extra 30% off",
    "image": "assets/kathiyavadi.jpg",
    "massage": "Rotli,shak,Dalbhat,salad,achar,Chhas and extra...",
    "review": "4.5(100+)",
    "mins": "15 Mins",
  },
  {
    "id": "10",
    "title": "south Indian restaurants",
    "offer": "extra 25% off",
    "image": "assets/southindian.jpg",
    "massage": "Idlisambar,Vada,Uttapam,Appam,Upma and Extra",
    "review": "3.5(70+)",
    "mins": "20 Mins",
  },
];

List listfood = [
  {
    "id": "1",
    "title": "Fast Food",
    "subtitle": "20 Restaurants",
    "image": "assets/fastfood.png",
  },
  {
    "id": "2",
    "title": "Breakfast",
    "subtitle": "70 Restaurants",
    "image": "assets/Breakfast.jpg",
  },
  {
    "id": "3",
    "title": "Dinner",
    "subtitle": "40 Restaurants",
    "image": "assets/dinner.jpg",
  },
  {
    "id": "4",
    "title": "Launch",
    "subtitle": "50 Restaurants",
    "image": "assets/launch.jpg",
  },
  {
    "id": "5",
    "title": "Drinks",
    "subtitle": "80 Restaurants",
    "image": "assets/drinks.jpg",
  },
  {
    "id": "6",
    "title": "Fast Food",
    "subtitle": "60 Restaurants",
    "image": "assets/fastfood.png",
  },
  {
    "id": "7",
    "title": "Breakfast",
    "subtitle": "70 Restaurants",
    "image": "assets/Breakfast.jpg",
  },
  {
    "id": "8",
    "title": "Dinner",
    "subtitle": "80 Restaurants",
    "image": "assets/dinner.jpg",
  },
  {
    "id": "9",
    "title": "Launch",
    "subtitle": "90 Restaurants",
    "image": "assets/launch.jpg",
  },
  {
    "id": "10",
    "title": "Drinks",
    "subtitle": "50 Restaurants",
    "image": "assets/drinks.jpg",
  },
];

List manypeople = [
  {"people": "1", "id": "1"},
  {"people": "2", "id": "2"},
  {"people": "3", "id": "3"},
  {"people": "4", "id": "4"},
  {"people": "5", "id": "5"},
  {"people": "6", "id": "6"},
  {"people": "7", "id": "7"},
  {"people": "8", "id": "8"},
  {"people": "9", "id": "9"},
  {"people": "10", "id": "10"},
];

// List whattime = [
//   {"time": "4:30 PM", "id": "1"},
//   {"time": "5:30 PM", "id": "2"},
//   {"time": "6:30 PM", "id": "3"},
//   {"time": "7:30 PM", "id": "4"},
//   {"time": "8:30 PM", "id": "5"},
//   {"time": "9:30 PM", "id": "6"},
//   {"time": "10:30 PM", "id": "7"},
//   {"time": "11:30 PM", "id": "8"},
//   {"time": "12:30 AM", "id": "9"},
//   {"time": "1:30 AM", "id": "10"},
// ];
showToastMessage(message) {
  Fluttertoast.showToast(
    msg: message,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: orangeColor,
    textColor: Colors.white,
    fontSize: 14.0,
  );
}



GestButton({
  String? buttontext,
  Function()? onclick,
  double? Width,
  double? height,
  Color? buttoncolor,
  EdgeInsets? margin,
  TextStyle? style,
}) {
  return GestureDetector(
    onTap: onclick,
    child: Container(
      height: height,
      width: Width,
      // margin: EdgeInsets.only(top: 15, left: 30, right: 30),
      margin: margin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: buttoncolor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: const Offset(
              0.5,
              0.5,
            ),
            blurRadius: 1,
          ), //BoxShadow
        ],
      ),
      child: Text(buttontext!, style: style),
    ),
  );
}

dynamic height;
dynamic width;
