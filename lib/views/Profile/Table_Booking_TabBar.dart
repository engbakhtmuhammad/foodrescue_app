// ignore_for_file: file_names, sized_box_for_whitespace, prefer_const_constructors, must_be_immutable, library_private_types_in_public_api, unnecessary_null_comparison
// ignore_for_file: camel_case_types, use_key_in_widget_constructors, annotate_overrides, prefer_const_literals_to_create_immutables, unused_field, unused_element, avoid_unnecessary_containers, non_constant_identifier_names, unused_import, deprecated_member_use

import 'package:foodrescue_app/Tabbar/Accepted.dart';
import 'package:foodrescue_app/Tabbar/Cancelled.dart';
import 'package:foodrescue_app/Tabbar/Pending.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/dark_light_mode.dart';

class TableBooking extends StatefulWidget {
  String? noofpeople;
  String? bookingdate;
  String? time;
  // ignore: use_super_parameters
  TableBooking({this.noofpeople, this.bookingdate, this.time, Key? key})
      : super(key: key);

  @override
  State<TableBooking> createState() => _TableBookingState();
}

class _TableBookingState extends State<TableBooking>
    with SingleTickerProviderStateMixin {
  TabController? controller;

  // late ColorNotifire notifire;

  @override
  void initState() {
    getDarkMode();
    super.initState();
    controller = TabController(length: 3, vsync: this);
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

  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    List<Widget> tab = [
      Pending(
          noofpeople: widget.noofpeople,
          bookingdate: widget.bookingdate,
          time: widget.time),
      Accepted(noofpeople: widget.noofpeople, bookingdate: widget.bookingdate),
      Cancelled(noofpeople: widget.noofpeople, bookingdate: widget.bookingdate),
    ];
    int selectedIndex1 = 0;
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(color: notifier.textColor),
          title: Text(
            "Your Bookings".tr,
            style: TextStyle(
                fontFamily: 'Gilroy Bold', fontSize: 16, color: notifier.textColor),
          ),
          elevation: 0,
          backgroundColor: notifier.background,
        ),
        backgroundColor: notifier.background,
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  height: Get.height * 0.07,
                  width: Get.width / 1,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TabBar(
                        labelStyle: const TextStyle(fontFamily: 'Gilroy_Bold'),
                        indicatorSize: TabBarIndicatorSize.label,
                        indicator: MD2Indicator(
                          indicatorSize: MD2IndicatorSize.full,
                          indicatorHeight: 5,
                          indicatorColor: yelloColor,
                        ),
                        indicatorColor: yelloColor,
                        indicatorWeight: 3,
                        controller: controller,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        indicatorPadding: EdgeInsets.zero,
                        labelPadding: EdgeInsets.zero,
                        labelColor:
                            selectedIndex1 == 0 ? notifier.textColor : greycolor,
                        unselectedLabelColor: greycolor.withOpacity(0.7),
                        tabs:  [
                          Tab(
                            child: Center(
                              child: Text(
                                "Pending".tr,
                                style: TextStyle(
                                    fontFamily: 'Gilroy Bold', fontSize: 15),
                              ),
                            ),
                          ),
                          Tab(
                            child: Center(
                              child: Text(
                                "Accepted".tr,
                                style: TextStyle(
                                    fontFamily: 'Gilroy Bold', fontSize: 15),
                              ),
                            ),
                          ),
                          Tab(
                            child: Center(
                              child: Text(
                                "Cancelled".tr,
                                style: TextStyle(
                                    fontFamily: 'Gilroy Bold', fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Get.height * 0.01),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: controller,
                  children: tab.map((tab) => tab).toList(),
                ),
              ),
            ),
          ],
        ));
  }
}

class MD2Indicator extends Decoration {
  final double indicatorHeight;
  final Color indicatorColor;
  final MD2IndicatorSize indicatorSize;
  const MD2Indicator({
    required this.indicatorHeight,
    required this.indicatorColor,
    required this.indicatorSize,
  });
  @override
  _MD2Painter createBoxPainter([VoidCallback? onChanged]) {
    return _MD2Painter(this, onChanged!);
  }
}

enum MD2IndicatorSize {
  tiny,
  normal,
  full,
}

class _MD2Painter extends BoxPainter {
  final MD2Indicator decoration;
  _MD2Painter(this.decoration, VoidCallback onChanged)
      : assert(decoration != null),
        super(onChanged);
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);
    Rect? rect;
    if (decoration.indicatorSize == MD2IndicatorSize.full) {
      rect = Offset(offset.dx,
              (configuration.size!.height - decoration.indicatorHeight)) &
          Size(configuration.size!.width, decoration.indicatorHeight);
    } else if (decoration.indicatorSize == MD2IndicatorSize.normal) {
      rect = Offset(offset.dx + 6,
              (configuration.size!.height - decoration.indicatorHeight)) &
          Size(configuration.size!.width - 12, decoration.indicatorHeight);
    } else if (decoration.indicatorSize == MD2IndicatorSize.tiny) {
      rect = Offset(offset.dx + configuration.size!.width / 2 - 8,
              (configuration.size!.height - decoration.indicatorHeight)) &
          Size(16, decoration.indicatorHeight);
    }
    final Paint paint = Paint();
    paint.color = decoration.indicatorColor;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndCorners(rect!,
            topRight: Radius.circular(8), topLeft: Radius.circular(8)),
        paint);
  }
}
