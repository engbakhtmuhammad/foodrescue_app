// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_final_fields, await_only_futures, prefer_typing_uninitialized_variables, use_key_in_widget_constructors, unused_local_variable, prefer_collection_literals, unused_field, avoid_print, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, avoid_unnecessary_containers, file_names

import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:foodrescue_app/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayTmPayment extends StatefulWidget {
  final String? uid;
  final String? totalAmount;

  const PayTmPayment({this.uid, this.totalAmount});

  @override
  State<PayTmPayment> createState() => _PayTmPaymentState();
}

class _PayTmPaymentState extends State<PayTmPayment> {
  @override
  void initState() {
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
            "https://placeholder.com/paytm-disabled";
            print("Payment disabled - Firebase only: $url");

          },
          onPageFinished: (String url) {
            setState(() {
              // "${AppUrl.paymentBaseUrl + "flutterwave/index.php?amt=${widget.totalAmount}&email=${widget.email}"
              isLoading = false;
            });
          },

          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) async {
            final uri = Uri.parse(request.url);
            if (uri.queryParameters["status"] == null) {
              accessToken = uri.queryParameters["token"];
            } else {
              if (uri.queryParameters["status"] == "successful") {
                payerID = await uri.queryParameters["transaction_id"];
                Get.back(result: payerID);
              } else {
                Get.back();
                showToastMessage("${uri.queryParameters["status"]}");
              }
            }
            return NavigationDecision.navigate;
          },

        ),
      )
      ..loadRequest(Uri.parse(
          "https://placeholder.com/paytm-disabled"));
  }

  WebViewController webViewController = WebViewController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late WebViewController _controller;
  var progress;
  String? accessToken;
  String? payerID;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
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
                            child: const Text(
                              'Please don`t press back until the transaction is complete',
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.black,
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
          backgroundColor: Colors.black12,
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
}
