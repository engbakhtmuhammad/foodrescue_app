// ignore_for_file: prefer_final_fields, unused_field, prefer_typing_uninitialized_variables, use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, avoid_print, prefer_const_constructors, avoid_unnecessary_containers, file_names, non_constant_identifier_names
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Utils/dark_light_mode.dart';

class Flutterwave extends StatefulWidget {
  final String? email;
  final String? totalAmount;

  const Flutterwave({this.email, this.totalAmount});

  @override
  State<Flutterwave> createState() => _FlutterwaveState();
}

class _FlutterwaveState extends State<Flutterwave> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late WebViewController _controller;
  var progress;
  String? accessToken;
  String? payerID;
  bool isLoading = true;
  @override
  void initState() {
    getDarkMode();
    super.initState();
    webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (val) {
            progress = val;
            setState(() {});
          },
          onPageStarted: (String url) {
            "https://dineout.zozostudio.tech/flutterwave/index.php?amt=${widget.totalAmount}&email=${widget.email}";
          },
          onPageFinished: (String url) {
            isLoading = false;
            setState(() {});
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(
          "https://dineout.zozostudio.tech/flutterwave/index.php?amt=${widget.totalAmount}&email=${widget.email}"));
  }

  WebViewController webViewController = WebViewController();
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
    if (_scaffoldKey.currentState == null) {
      return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: webViewController),
              isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: CircularProgressIndi(),
                          ),
                          SizedBox(height: Get.height * 0.02),
                          SizedBox(
                            width: Get.width * 0.80,
                            child: Text(
                              'Please don`t press back until the transaction is complete'.tr,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: notifier.textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Stack(),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          backgroundColor: notifier.background,
          elevation: 0.0,
        ),
        body: Center(
          child: Container(
            child: CircularProgressIndi(),
          ),
        ),
      );
    }
  }

  WebView(
      {required String initialUrl,
      required javascriptMode,
      required Future<NavigationDecision> Function(NavigationRequest request)
          navigationDelegate,
      required bool gestureNavigationEnabled,
      required Null Function(dynamic controller) onWebViewCreated,
      required Null Function(dynamic finish) onPageFinished,
      required Null Function(dynamic val) onProgress}) {
    return loginappbar(backGround: notifier.background,color: notifier.textColor);
  }
}
