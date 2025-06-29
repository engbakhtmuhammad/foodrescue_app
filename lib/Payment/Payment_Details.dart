// ignore_for_file: sort_child_properties_last, file_names, non_constant_identifier_names, must_be_immutable, avoid_print, prefer_const_constructors, unnecessary_brace_in_string_interps, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, prefer_const_literals_to_create_immutables, deprecated_member_use

import 'dart:io';

import 'package:foodrescue_app/Getx_Controller/Controller.dart';
import 'package:foodrescue_app/Getx_Controller/Discount_order_controller.dart';
import 'package:foodrescue_app/Getx_Controller/PaymentGetwey_controller.dart';
import 'package:foodrescue_app/Getx_Controller/Wallet_controller.dart';
import 'package:foodrescue_app/Payment/Bill_paid.dart';
import 'package:foodrescue_app/Payment/web_view.dart';
import 'package:foodrescue_app/Utils/Colors.dart';
import 'package:foodrescue_app/Utils/Custom_widegt.dart';
import 'package:foodrescue_app/api/Data_save.dart';
import 'package:foodrescue_app/config/app_config.dart';
import 'package:foodrescue_app/paymentscreen/FlutterWave.dart';
import 'package:foodrescue_app/paymentscreen/InputFormater.dart';
import 'package:foodrescue_app/paymentscreen/PayStack.dart';
import 'package:foodrescue_app/paymentscreen/PaymentCard.dart';
import 'package:foodrescue_app/paymentscreen/Paytm.dart';
import 'package:foodrescue_app/paymentscreen/StripeWeb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_paypal/flutter_paypal.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Utils/dark_light_mode.dart';

class PaymentDetails extends StatefulWidget {
  double? bilamount;
  String? tip;
  String? restid;
  String? hotelname;
  String? address;
  PaymentDetails(
      {this.bilamount,
      this.tip,
      this.restid,
      this.hotelname,
      this.address,
      super.key});

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  PaymentgatewayController payment = Get.put(PaymentgatewayController());
  DiscountorderController Discountorder = Get.put(DiscountorderController());
  HomeController homedata = Get.put(HomeController());
  WalletController walletcontroller = Get.put(WalletController());

  TextEditingController tipcontroller = TextEditingController();
  String totelamount = "0.0";
  String disacount = "0.0";
  String paytip = "0";
  String billdiscount = "0";
  String totelbill = "0";
  String selectidPay = "0";
  String razorpaykey = "";
  String? paymenttital;
  int? _groupValue;
  bool cancletip = false;
  var useWallet = 0.0;
  var tempWallet = 0.0;
  String wallet = "";
  bool? status;
  dynamic tex = 0.00;
  bool? checkLogin;
  final _paymentCard = PaymentCardCreated();
  var currency;
  int price = 0;
  var _autoValidateMode = AutovalidateMode.disabled;
  int currentTotalprice = 0;
  final _formKey = GlobalKey<FormState>();
  final _card = PaymentCardCreated();
  var numberController = TextEditingController();
  late Razorpay _razorpay;


  @override
  void initState() {
    getDarkMode();
    super.initState();
    setState(() {
      payment.paymentgateway();
      //Discountorder.discountnow();
    });

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    print("%%%%%%%%%%%%###############" "${widget.bilamount}");
    print("%%%%%%%%%%%%###############" "${widget.tip}");
    totelamount = widget.bilamount.toString();
    disacount = widget.tip ?? "";
    billdiscount =
        "${(double.parse(totelamount) * double.parse(disacount) / 100)}";
    totelbill =
        "${(double.parse(totelamount) - double.parse(billdiscount) + double.parse(paytip))}";
    wallet = homedata.homeDataList["wallet"] ?? "";
    tempWallet = double.parse(homedata.homeDataList["wallet"] ?? "");
    // tex =
    //     double.parse("${(int.parse(totelbill) * walletcontroller.tex / 100)}");
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // bookNowOrder(response.paymentId);
    Discountorder.discountnow(
        discountamount: billdiscount,
        discountvalue: widget.tip,
        payedamount: double.parse(totelbill).toStringAsFixed(2),
        paymentid: selectidPay,
        restid: widget.restid,
        tipamount: paytip,
        totelamount: totelamount,
        transactionid: response.paymentId,
        wallatamount: "0",
        tipcmt: tipcontroller.text);
    Get.to(() => BillPaid(
          address: widget.address,
          hotelname: widget.hotelname,
          restid: widget.restid,
          discountvalue: widget.tip,
          tipamt: paytip,
          totelbill: totelamount,
          discountamt: billdiscount,
          payedamt: double.parse(totelbill).toStringAsFixed(2),
          walletamt: "0",
          selectidPay: selectidPay,
          transactionid: response.paymentId,
        ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print(
        'Error Response: ${"ERROR: " + response.code.toString() + " - " + response.message!}');
    showToastMessage(response.message!);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    showToastMessage(response.walletName!);
  }

  @override
  void dispose() {
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardTypee cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      _paymentCard.type = cardType;
    });
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

  handlePaymentSuccess(){
    setState(() {
      Discountorder.discountnow(
          discountamount: billdiscount,
          discountvalue: widget.tip,
          payedamount: double.parse(totelbill)
              .toStringAsFixed(2),
          paymentid: selectidPay,
          restid: widget.restid,
          tipamount: paytip,
          totelamount: totelamount,
          transactionid: "0",
          tipcmt: tipcontroller.text,
          wallatamount: "0");
      Get.to(() => BillPaid(
        address: widget.address,
        hotelname: widget.hotelname,
        restid: widget.restid,
        discountvalue: widget.tip,
        tipamt: paytip,
        totelbill: totelamount,
        discountamt: billdiscount,
        payedamt: double.parse(totelbill).toStringAsFixed(2),
        walletamt: "0",
        selectidPay: selectidPay,
        transactionid: "transactionid",
      ));
    });


  }

  PaystackController paystackController = Get.put(PaystackController());
  String? accessToken = "";
  String? payerID = "";

  webViewWalletAddAmount({required String initialUrl,required String status1,required String status2}){
    Get.back();
    Get.to(() => PaymentWebVIew(
      initialUrl: initialUrl,
      navigationDelegate: (request) async{
        final uri = Uri.parse(request.url);

        debugPrint("************ URL:--- $initialUrl");
        debugPrint("************ Navigating to URL: ${request.url}");
        debugPrint("************ Parsed URI: $uri");
        debugPrint("************ 2435243254: ${uri.queryParameters[status1]}");

        // Check the status parameter instead of Result
        final status = uri.queryParameters[status1];
        debugPrint(" /*/*/*/*/*/*/*/*/*/*/*/*/*/ Status ---- $status");
        if (status == null) {
          debugPrint("No status parameter found.");
        } else {
          debugPrint("Status parameter: $status");
          if (status == status2) {
            debugPrint("Purchase successful.");

            handlePaymentSuccess();

            return NavigationDecision.prevent;
          } else {
            debugPrint("Purchase failed with status: $status.");
            Navigator.pop(context);
            Fluttertoast.showToast(msg: status, timeInSecForIosWeb: 4);
            return NavigationDecision.prevent;
          }
        }
        return NavigationDecision.navigate;
      },
    ));
  }
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: SizedBox(
              height: Get.height * 0.13,
              child: Column(
                children: [
                  GetBuilder<PaymentgatewayController>(builder: (context) {
                    return Center(
                      child: AppButton(
                        buttonColor: green,
                        width: Get.width * 0.7,
                        buttontext:
                            "Proceed to pay ${homedata.homeDataList["currency"]}${double.parse(totelbill).toStringAsFixed(2)}",
                        onTap: () {
                          paymentSheett();
                        },
                      ),
                    );
                  }),
                  SizedBox(height: Get.height * 0.02),
                  Column(
                    children: [
                      Text(
                          "Offers above can't be clubbed with any other offline offers.",
                          style: TextStyle(
                              fontFamily: "Gilroy Medium",
                              color: greycolor,
                              fontSize: 12)),
                      InkWell(
                        onTap: () {},
                        child: Text(
                          "Read more on our T&C pages",
                          style: TextStyle(
                              fontFamily: "Gilroy Medium",
                              color: greycolor,
                              fontSize: 13,
                              decoration: TextDecoration.underline),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )),
        backgroundColor: notifier.background,
        appBar: PreferredSize(
            child: appbar(
              background: notifier.background,
                color: notifier.textColor,
                titletext: "You're paying at",
                centertext: widget.hotelname,
                subtitletext: widget.address),
            preferredSize: const Size.fromHeight(65)),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Get.height * 0.02),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          stops: const [
                            0.15,
                            0.25,
                            2
                          ],
                          colors: [
                            Colors.blue.withOpacity(0.1),
                            Colors.red.withOpacity(0.1),
                            Red.withOpacity(0.08),
                          ]),
                      border: Border.all(color: boxcolor),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Gold ',
                              style: TextStyle(
                                  fontFamily: "Gilroy ExtraBold",
                                  color: goldColor,
                                  fontSize: 18),
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'Benefits applied',
                                    style: TextStyle(
                                        fontFamily: "Gilroy Medium",
                                        fontSize: 16,
                                        color: orangeColor)),
                              ],
                            ),
                          ),
                          SizedBox(height: Get.height * 0.01),
                          RichText(
                            text: TextSpan(
                              text:
                                  "${homedata.homeDataList["currency"]}$billdiscount",
                              style: TextStyle(
                                  fontFamily: "Gilroy ExtraBold",
                                  color: notifier.textColor,
                                  fontSize: 18),
                              children: <TextSpan>[
                                TextSpan(
                                    text: ' saved on this bill!',
                                    style: TextStyle(
                                        fontFamily: "Gilroy Medium",
                                        fontSize: 16,
                                        color: notifier.textColor)),
                              ],
                            ),
                          ),
                          SizedBox(height: Get.height * 0.01),
                          Text("${widget.tip}% Welcome discount applied :)",
                              style: TextStyle(
                                  fontFamily: "Gilroy Medium",
                                  fontSize: 14,
                                  color: greycolor))
                        ],
                      ),
                      Image.asset("assets/emoji.png", height: 50)
                    ],
                  ),
                ),
                SizedBox(height: Get.height * 0.02),
                Text("Add tip",
                    style: TextStyle(
                        fontFamily: "Gilroy Medium",
                        fontSize: 16,
                        color: WhiteColor)),
                SizedBox(height: Get.height * 0.02),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12), color: notifier.containerColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Enjoyed your visit? add a tip to show some love:)",
                          style: TextStyle(
                              fontFamily: "Gilroy Medium",
                              fontSize: 13,
                              color: greycolor)),
                      TextField(
                        cursorColor: notifier.textColor,
                        keyboardType: TextInputType.number,
                        controller: tipcontroller,
                        onChanged: (value) {
                          print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" "$value");
                          print("==============================" "$paytip");
                          setState(() {
                            paytip = "0";
                            print("===============paytip==============="
                                "$paytip");
                            totelbill =
                                "${(double.parse(totelamount) - double.parse(billdiscount) + double.parse(paytip))}";
                            setState(() {});
                            paytip = value;
                          });
                          totelbill =
                              "${(double.parse(totelamount) - double.parse(billdiscount) + double.parse(paytip))}";
                          print("=============totelbill================="
                              "$totelbill");
                        },
                        style: TextStyle(
                            fontFamily: "Gilroy Medium",
                            fontSize: 16,
                            color: notifier.textColor),
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: greycolor),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: notifier.textColor),
                            ),
                            prefix: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                "${homedata.homeDataList["currency"]}",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: notifier.textColor,
                                    fontFamily: "Gilroy Bold"),
                              ),
                            ),
                            suffixIcon: InkWell(
                                onTap: () {
                                  tipcontroller.text = "";
                                  paytip = "0";
                                  totelbill =
                                      "${(double.parse(totelamount) - double.parse(billdiscount) + double.parse(paytip))}";
                                  setState(() {});
                                },
                                child: Icon(
                                  Icons.highlight_remove_outlined,
                                  color: orangeColor,
                                )),
                            hintText: "Enter tip amount",
                            hintStyle: TextStyle(
                                fontFamily: "Gilroy Medium",
                                fontSize: 16,
                                color: greycolor)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Get.height * 0.02),
                checkLogin == true && wallet != "0"
                    ? walletDetail()
                    : SizedBox(),
                Text("Bill details",
                    style: TextStyle(
                        fontFamily: "Gilroy Medium",
                        fontSize: 16,
                        color: WhiteColor)),
                SizedBox(height: Get.height * 0.02),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12), color: notifier.containerColor),
                  child: Column(
                    children: [
                      billdetails(
                          titletext: "Totel restaurant bill",
                          subtitletext:
                              "${homedata.homeDataList["currency"]}$totelamount",
                          fontsize: 16,
                          titlecolor: notifier.textColor,
                          subtitlecolor: notifier.textColor,
                          fontFamily: "Gilroy Medium"),
                      SizedBox(height: Get.height * 0.01),
                      billdetails(
                          titletext: "Gold",
                          subtitletext:
                              "-${homedata.homeDataList["currency"]}$billdiscount",
                          fontsize: 20,
                          titlecolor: notifier.textColor,
                          subtitlecolor: notifier.textColor,
                          DiscountText: "  ${widget.tip}% welcome discount",
                          fontFamily: "Gilroy ExtraBold"),
                      SizedBox(height: Get.height * 0.01),
                      billdetails(
                          titletext: "Waiter tip",
                          subtitletext:
                              "${homedata.homeDataList["currency"]}$paytip",
                          fontsize: 16,
                          titlecolor: greycolor,
                          subtitlecolor: greycolor,
                          fontFamily: "Gilroy Medium"),
                      SizedBox(height: Get.height * 0.01),
                      Divider(color: greycolor),
                      SizedBox(height: Get.height * 0.01),
                      billdetails(
                          titletext: "To pay",
                          subtitletext:
                              "${homedata.homeDataList["currency"]}${double.parse(totelbill).toStringAsFixed(2)}",
                          fontsize: 16,
                          titlecolor: notifier.textColor,
                          subtitlecolor: notifier.textColor,
                          fontFamily: "Gilroy Medium"),
                    ],
                  ),
                ),
                SizedBox(height: Get.height * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }

  billdetails(
      {String? titletext,
      subtitletext,
      fontFamily,
      DiscountText,
      Color? titlecolor,
      subtitlecolor,
      double? fontsize}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            RichText(
              text: TextSpan(
                text: titletext,
                style: TextStyle(
                    fontFamily: fontFamily,
                    color: titlecolor,
                    fontSize: fontsize),
                children: <TextSpan>[
                  TextSpan(
                      text: DiscountText,
                      style: TextStyle(
                          fontFamily: "Gilroy Medium",
                          fontSize: 16,
                          color: notifier.textColor)),
                ],
              ),
            ),
          ],
        ),
        Text(subtitletext,
            style: TextStyle(
                fontFamily: "Gilroy Medium",
                fontSize: 16,
                color: subtitlecolor)),
      ],
    );
  }

  Future paymentSheett() {
    return showModalBottomSheet(
      backgroundColor: notifier.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (context) {
        return Wrap(children: [
          StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Center(
                  child: Container(
                    height: Get.height / 80,
                    width: Get.width / 5,
                    decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                  ),
                ),
                SizedBox(height: Get.height / 50),
                Row(children: [
                  SizedBox(width: Get.width / 14),
                  Text("Select Payment Method",
                      style: TextStyle(
                          color: notifier.textColor,
                          fontSize: Get.height / 40,
                          fontFamily: "Gilroy Medium")),
                ]),
                SizedBox(height: Get.height / 50),
                //! --------- List view paymente ----------
                SizedBox(
                  height: Get.height * 0.50,
                  child:
                      GetBuilder<PaymentgatewayController>(builder: (context) {
                    return payment.isLoading
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: payment.paymentGetway.length,
                            itemBuilder: (ctx, i) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: sugestlocationtype(
                                  borderColor: selectidPay ==
                                          payment.paymentGetway[i]["id"]
                                      ? orangeColor
                                      : const Color(0xffD6D6D6)
                                          .withOpacity(0.5),
                                  title: payment.paymentGetway[i]["title"],
                                  titleColor: notifier.textColor,
                                  val: 0,
                                  image: AppUrl.imageurl +
                                      payment.paymentGetway[i]["img"],
                                  adress: payment.paymentGetway[i]["subtitle"],
                                  ontap: () async {
                                    setState(() {
                                      razorpaykey = payment.paymentGetway[i]
                                          ["attributes"];
                                      paymenttital =
                                          payment.paymentGetway[i]["title"];
                                      selectidPay =
                                          payment.paymentGetway[i]["id"];
                                      _groupValue = i;
                                    });
                                  },
                                  radio: Radio(
                                    activeColor: orangeColor,
                                    value: i,
                                    groupValue: _groupValue,
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: CircularProgressIndi(),
                          );
                  }),
                ),
                Container(
                  height: 80,
                  width: Get.size.width,
                  alignment: Alignment.center,
                  child: GestButton(
                    Width: Get.size.width,
                    height: 50,
                    buttoncolor: orangeColor,
                    margin: EdgeInsets.only(top: 10, left: 30, right: 30),
                    buttontext: "Continue",
                    style: TextStyle(
                      fontFamily: "",
                      color: WhiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    onclick: () {
                      // !---- Stripe Payment ------

                      if (paymenttital == "Razorpay")  {
                        Get.back();
                        openCheckout();
                      }
                      else if (paymenttital == "Pay TO Owner") {
                        Discountorder.discountnow(
                            discountamount: billdiscount,
                            discountvalue: widget.tip,
                            payedamount:
                            double.parse(totelbill).toStringAsFixed(2),
                            paymentid: selectidPay,
                            restid: widget.restid,
                            tipamount: paytip,
                            totelamount: totelamount,
                            transactionid: "0",
                            tipcmt: tipcontroller.text,
                            wallatamount: "0");
                        Get.back();
                        Get.to(() => BillPaid(
                          address: widget.address,
                          hotelname: widget.hotelname,
                          restid: widget.restid,
                          discountvalue: widget.tip,
                          tipamt: paytip,
                          totelbill: totelamount,
                          discountamt: billdiscount,
                          payedamt:
                          double.parse(totelbill).toStringAsFixed(2),
                          walletamt: "0",
                          selectidPay: selectidPay,
                          transactionid: "0",
                        ));
                      }
                      else if (paymenttital == "Paypal") {
                        // payplepayment(onSuccess: (Map params) {
                        //   Get.back();
                        //   Discountorder.discountnow(
                        //       discountamount: billdiscount,
                        //       discountvalue: widget.tip,
                        //       payedamount:
                        //       double.parse(totelbill).toStringAsFixed(2),
                        //       paymentid: selectidPay,
                        //       restid: widget.restid,
                        //       tipamount: paytip,
                        //       totelamount: totelamount,
                        //       transactionid: params["paymentId"],
                        //       wallatamount: "0",
                        //       tipcmt: tipcontroller.text);
                        //   Get.to(() => BillPaid(
                        //     address: widget.address,
                        //     hotelname: widget.hotelname,
                        //     restid: widget.restid,
                        //     discountvalue: widget.tip,
                        //     tipamt: paytip,
                        //     totelbill: totelamount,
                        //     discountamt: billdiscount,
                        //     payedamt:
                        //     double.parse(totelbill).toStringAsFixed(2),
                        //     walletamt: "0",
                        //     selectidPay: selectidPay,
                        //     transactionid: params["paymentId"],
                        //   ));
                        //   Get.back();
                        //   Get.back();
                        //   Get.back();
                        //   Get.back();
                        // });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("PayPal payment is currently disabled"))
                        );
                      }
                      else if (paymenttital == "Stripe") {
                        Get.back();
                        stripePayment();
                      }
                      else if (paymenttital == "PayStack") {
                        paystackController.getPaystack(amount: totelbill).then((value) {
                          Get.to(() => PaymentWebVIew(
                            initialUrl: value["data"]["authorization_url"],
                            navigationDelegate:
                                (NavigationRequest request) async {
                              Uri.parse(request.url);

                              print("PAYSTACK RESPONSE ${request}");
                              print("PAYSTACK URL  ${request.url}");

                              Discountorder.discountnow(
                                  discountamount: billdiscount,
                                  discountvalue: widget.tip,
                                  payedamount: double.parse(totelbill)
                                      .toStringAsFixed(2),
                                  paymentid: selectidPay,
                                  restid: widget.restid,
                                  tipamount: paytip,
                                  totelamount: totelamount,
                                  transactionid: "0",
                                  tipcmt: tipcontroller.text,
                                  wallatamount: "0");
                              Get.to(() => BillPaid(
                                address: widget.address,
                                hotelname: widget.hotelname,
                                restid: widget.restid,
                                discountvalue: widget.tip,
                                tipamt: paytip,
                                totelbill: totelamount,
                                discountamt: billdiscount,
                                payedamt: double.parse(totelbill)
                                    .toStringAsFixed(2),
                                walletamt: "0",
                                selectidPay: selectidPay,
                                transactionid: "0",
                              ));
                              return NavigationDecision.navigate;
                            },
                          ))!
                              .then((otid) {
                            Get.back();

                          });
                        },
                        );
                      }
                      else if (paymenttital == "Payfast") {
                        Get.to(() => PaymentWebVIew(
                          initialUrl: "${AppUrl.paymentBaseUrl}Payfast/index.php?amt=${totelbill}",
                          navigationDelegate: (NavigationRequest request) async {
                            print("=========== initial ${AppUrl.paymentBaseUrl}Payfast/index.php?amt=${totelbill}");
                            final uri = Uri.parse(request.url);

                            if (uri.queryParameters["status"] == null) {
                              accessToken = uri.queryParameters["Transaction_id"];
                            } else {
                              if (uri.queryParameters["status"] == "success") {
                                payerID = uri.queryParameters["Transaction_id"];
                                Discountorder.discountnow(
                                    discountamount: billdiscount,
                                    discountvalue: widget.tip,
                                    payedamount: double.parse(totelbill)
                                        .toStringAsFixed(2),
                                    paymentid: selectidPay,
                                    restid: widget.restid,
                                    tipamount: paytip,
                                    totelamount: totelamount,
                                    transactionid: "0",
                                    tipcmt: tipcontroller.text,
                                    wallatamount: "0");
                                Get.to(() => BillPaid(
                                  address: widget.address,
                                  hotelname: widget.hotelname,
                                  restid: widget.restid,
                                  discountvalue: widget.tip,
                                  tipamt: paytip,
                                  totelbill: totelamount,
                                  discountamt: billdiscount,
                                  payedamt: double.parse(totelbill)
                                      .toStringAsFixed(2),
                                  walletamt: "0",
                                  selectidPay: selectidPay,
                                  transactionid: "transactionid",
                                ));
                                // Get.back(result: payerID);
                                print('payerID');
                              } else {
                                Get.back();
                                Fluttertoast.showToast(msg: "${uri.queryParameters["status"]}", timeInSecForIosWeb: 4);
                              }
                            }

                            return NavigationDecision.navigate;
                          },))!
                            .then((otid) {
                          Get.back();
                          if (otid != null) {
                          } else {
                            Get.back();
                          }
                        });

                      }
                      else if (paymenttital == "Midtrans") {
                        webViewWalletAddAmount(
                          initialUrl: "${AppUrl.paymentBaseUrl}Midtrans/index.php?name=test&email=${getData.read("UserLogin")["email"]}&phone=${getData.read("UserLogin")["ccode"] + getData.read("UserLogin")["mobile"]}&amt=${totelbill}",
                          status1: "status_code",
                          status2: "200",
                        );
                      }
                      else if (paymenttital == "Khalti Payment") {
                        Get.to(() => PaymentWebVIew(
                          initialUrl: "${AppUrl.paymentBaseUrl}Khalti/index.php?amt=${totelbill}" ,
                          navigationDelegate: (NavigationRequest request) async {
                            print("=========== initial ${AppUrl.paymentBaseUrl}Khalti/index.php?amt=${totelbill}");
                            final uri = Uri.parse(request.url);

                            if (uri.queryParameters["status"] == null) {
                              accessToken = uri.queryParameters["Transaction_id"];
                            } else {
                              if (uri.queryParameters["status"] == "Completed") {
                                payerID = uri.queryParameters["Transaction_id"];
                                Discountorder.discountnow(
                                    discountamount: billdiscount,
                                    discountvalue: widget.tip,
                                    payedamount: double.parse(totelbill)
                                        .toStringAsFixed(2),
                                    paymentid: selectidPay,
                                    restid: widget.restid,
                                    tipamount: paytip,
                                    totelamount: totelamount,
                                    transactionid: "0",
                                    tipcmt: tipcontroller.text,
                                    wallatamount: "0");
                                Get.to(() => BillPaid(
                                  address: widget.address,
                                  hotelname: widget.hotelname,
                                  restid: widget.restid,
                                  discountvalue: widget.tip,
                                  tipamt: paytip,
                                  totelbill: totelamount,
                                  discountamt: billdiscount,
                                  payedamt: double.parse(totelbill)
                                      .toStringAsFixed(2),
                                  walletamt: "0",
                                  selectidPay: selectidPay,
                                  transactionid: "transactionid",
                                ));
                                // Get.back(result: payerID);
                                print('payerID');
                              } else {
                                Get.back();
                                showToastMessage("${uri.queryParameters["ResponseMsg"]}");
                              }
                            }

                            return NavigationDecision.navigate;
                          },)
                        );
                      }
                      else if (paymenttital == "2checkout") {
                        Get.to(() => PaymentWebVIew(
                          initialUrl:  "${AppUrl.paymentBaseUrl}2checkout/index.php?amt=${totelbill}",
                          navigationDelegate: (NavigationRequest request) async {
                            final uri = Uri.parse(request.url);
                            print("URL + ${uri.queryParameters}");
                            if (uri.queryParameters["status"] == null) {
                              accessToken = uri.queryParameters["token"];
                            } else {
                              if (uri.queryParameters["status"] == "successful") {
                                payerID = uri.queryParameters["transaction_id"];
                                Discountorder.discountnow(
                                    discountamount: billdiscount,
                                    discountvalue: widget.tip,
                                    payedamount: double.parse(totelbill)
                                        .toStringAsFixed(2),
                                    paymentid: selectidPay,
                                    restid: widget.restid,
                                    tipamount: paytip,
                                    totelamount: totelamount,
                                    transactionid: "0",
                                    tipcmt: tipcontroller.text,
                                    wallatamount: "0");
                                Get.to(() => BillPaid(
                                  address: widget.address,
                                  hotelname: widget.hotelname,
                                  restid: widget.restid,
                                  discountvalue: widget.tip,
                                  tipamt: paytip,
                                  totelbill: totelamount,
                                  discountamt: billdiscount,
                                  payedamt: double.parse(totelbill)
                                      .toStringAsFixed(2),
                                  walletamt: "0",
                                  selectidPay: selectidPay,
                                  transactionid: "transactionid",
                                ));
                              } else {
                                Get.back();
                                Fluttertoast.showToast(msg: "${uri.queryParameters["status"]}", timeInSecForIosWeb: 4);
                              }
                            }
                            return NavigationDecision.navigate;
                          },
                        ))
                        !.then((otid) {
                          Get.back();

                          if (otid != null) {
                            Discountorder.discountnow(
                                discountamount: billdiscount,
                                tipcmt: tipcontroller.text,
                                discountvalue: widget.tip,
                                payedamount:
                                double.parse(totelbill).toStringAsFixed(2),
                                paymentid: selectidPay,
                                restid: widget.restid,
                                tipamount: paytip,
                                totelamount: totelamount,
                                transactionid: otid,
                                wallatamount: "0");
                            Get.to(() => BillPaid(
                              address: widget.address,
                              hotelname: widget.hotelname,
                              restid: widget.restid,
                              discountvalue: widget.tip,
                              tipamt: paytip,
                              totelbill: totelamount,
                              discountamt: billdiscount,
                              payedamt: double.parse(totelbill)
                                  .toStringAsFixed(2),
                              walletamt: "0",
                              selectidPay: selectidPay,
                              transactionid: otid,
                            ));
                          } else {
                            Get.back();
                          }
                        });
                      }
                      //========================================= done.
                      else if (paymenttital == "MercadoPago") {
                        Get.to(() => PaymentWebVIew(
                          initialUrl: "${AppUrl.paymentBaseUrl}merpago/index.php?amt=${totelbill}",
                          navigationDelegate: (NavigationRequest request) async {
                            final uri = Uri.parse(request.url);
                            print("URL + ${uri.queryParameters}");
                            if (uri.queryParameters["status"] == null) {
                              print("%%%%%%%%%%%%%:-------------${status}");
                              accessToken = uri.queryParameters["token"];
                            } else {
                              if (uri.queryParameters["status"] == "successful") {
                                payerID = uri.queryParameters["transaction_id"];
                                Discountorder.discountnow(
                                    discountamount: billdiscount,
                                    discountvalue: widget.tip,
                                    payedamount: double.parse(totelbill)
                                        .toStringAsFixed(2),
                                    paymentid: selectidPay,
                                    restid: widget.restid,
                                    tipamount: paytip,
                                    totelamount: totelamount,
                                    transactionid: "0",
                                    tipcmt: tipcontroller.text,
                                    wallatamount: "0");
                                Get.to(() => BillPaid(
                                  address: widget.address,
                                  hotelname: widget.hotelname,
                                  restid: widget.restid,
                                  discountvalue: widget.tip,
                                  tipamt: paytip,
                                  totelbill: totelamount,
                                  discountamt: billdiscount,
                                  payedamt: double.parse(totelbill)
                                      .toStringAsFixed(2),
                                  walletamt: "0",
                                  selectidPay: selectidPay,
                                  transactionid: "transactionid",
                                ));
                              } else {
                                Get.back();
                                Fluttertoast.showToast(msg: "${uri.queryParameters["status"]}", timeInSecForIosWeb: 4);
                              }
                            }
                            return NavigationDecision.navigate;
                          },
                        ))!
                            .then((otid) {
                          Get.back();
                          setState((){
                            if (otid != null) {

                              Discountorder.discountnow(
                                  discountamount: billdiscount,
                                  tipcmt: tipcontroller.text,
                                  discountvalue: widget.tip,
                                  payedamount:
                                  double.parse(totelbill).toStringAsFixed(2),
                                  paymentid: selectidPay,
                                  restid: widget.restid,
                                  tipamount: paytip,
                                  totelamount: totelamount,
                                  transactionid: otid,
                                  wallatamount: "0");

                              Get.to(() => BillPaid(
                                address: widget.address,
                                hotelname: widget.hotelname,
                                restid: widget.restid,
                                discountvalue: widget.tip,
                                tipamt: paytip,
                                totelbill: totelamount,
                                discountamt: billdiscount,
                                payedamt: double.parse(totelbill)
                                    .toStringAsFixed(2),
                                walletamt: "0",
                                selectidPay: selectidPay,
                                transactionid: otid,
                              ));
                            } else {
                              Get.back();
                            }
                          });

                        });
                      }
                      else if (paymenttital == "FlutterWave") {
                        Get.to(() => Flutterwave(
                          totalAmount: double.parse(totelbill)
                              .toStringAsFixed(2)
                              .toString(),
                          email: getData
                              .read("UserLogin")["email"]
                              .toString(),
                        ))!
                            .then((otid) {
                          if (otid != null) {
                            Discountorder.discountnow(
                                discountamount: billdiscount,
                                tipcmt: tipcontroller.text,
                                discountvalue: widget.tip,
                                payedamount:
                                double.parse(totelbill).toStringAsFixed(2),
                                paymentid: selectidPay,
                                restid: widget.restid,
                                tipamount: paytip,
                                totelamount: totelamount,
                                transactionid: otid,
                                wallatamount: "0");
                            Get.to(() => BillPaid(
                              address: widget.address,
                              hotelname: widget.hotelname,
                              restid: widget.restid,
                              discountvalue: widget.tip,
                              tipamt: paytip,
                              totelbill: totelamount,
                              discountamt: billdiscount,
                              payedamt: double.parse(totelbill)
                                  .toStringAsFixed(2),
                              walletamt: "0",
                              selectidPay: selectidPay,
                              transactionid: otid,
                            ));
                          } else {
                            Get.back();
                          }
                        });
                      }
                      else if (paymenttital == "Paytm") {
                        Get.to(() => PayTmPayment(
                            totalAmount: double.parse(totelbill)
                                .toStringAsFixed(2)
                                .toString(),
                            uid: getData.read("UserLogin")["id"]))!
                            .then((otid) {
                          if (otid != null) {
                            Discountorder.discountnow(
                                discountamount: billdiscount,
                                tipcmt: tipcontroller.text,
                                discountvalue: widget.tip,
                                payedamount:
                                double.parse(totelbill).toStringAsFixed(2),
                                paymentid: selectidPay,
                                restid: widget.restid,
                                tipamount: paytip,
                                totelamount: totelamount,
                                transactionid: otid,
                                wallatamount: "0");
                            Get.to(() => BillPaid(
                              address: widget.address,
                              hotelname: widget.hotelname,
                              restid: widget.restid,
                              discountvalue: widget.tip,
                              tipamt: paytip,
                              totelbill: totelamount,
                              discountamt: billdiscount,
                              payedamt: double.parse(totelbill)
                                  .toStringAsFixed(2),
                              walletamt: "0",
                              selectidPay: selectidPay,
                              transactionid: otid,
                            ));
                          } else {
                            Get.back();
                          }
                        });
                      }
                      else if (paymenttital == "SenangPay") {
                        "https://www.easystore.co/en-my/payments/senangpay";
                        print(paymenttital.toString());
                      }

                    },
                  ),
                  decoration: BoxDecoration(
                    color: BlackColor,
                  ),
                ),
              ],
            );
          }),
        ]);
      },
    );
  }

  Widget sugestlocationtype(
      {Function()? ontap,
      title,
      val,
      image,
      adress,
      radio,
      Color? borderColor,
      Color? titleColor}) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return InkWell(
        splashColor: Colors.transparent,
        onTap: ontap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Get.width / 18),
          child: Container(
            height: Get.height / 10,
            decoration: BoxDecoration(
                border: Border.all(color: borderColor!, width: 1),
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(11)),
            child: Row(
              children: [
                SizedBox(width: Get.width / 55),
                Container(
                    height: Get.height / 12,
                    width: Get.width / 5.5,
                    decoration: BoxDecoration(
                        color: const Color(0xffF2F4F9),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: FadeInImage(
                          placeholder: const AssetImage("assets/loading2.gif"),
                          image: NetworkImage(image)),
                      // Image.network(image, height: Get.height / 08)
                    )),
                SizedBox(width: Get.width / 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Get.height * 0.01),
                    Text(title,
                        style: TextStyle(
                          fontSize: Get.height / 55,
                          fontFamily: "Gilroy Bold",
                          color: titleColor,
                        )),
                    SizedBox(
                      width: Get.width * 0.50,
                      child: Text(adress,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: Get.height / 65,
                              fontFamily: "Gilroy Medium",
                              color: Colors.grey)),
                    ),
                  ],
                ),
                const Spacer(),
                radio
              ],
            ),
          ),
        ),
      );
    });
  }

  //!-------- Razorpay ----------//

  void openCheckout() async {
    var username = getData.read("UserLogin")["name"] ?? "";
    var mobile = getData.read("UserLogin")["mobile"] ?? "";
    var email = getData.read("UserLogin")["email"] ?? "";
    var options = {
      'key': razorpaykey,
      'amount': (double.parse(totelbill.split(".").first) * 100)
          .toStringAsFixed(2)
          .toString(),
      'name': username,
      'description': "",
      'timeout': 300,
      'prefill': {'contact': mobile, 'email': email},
    };
    print("#################" "$username");
    print("%%%%%%%%%%%%%%%%%" "$mobile");
    print("&&&&&&&&&&&&&&&&&" "$email");
    print("*****************" "$options");
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  stripePayment() {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: boxcolor,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Ink(
                child: Column(
                  children: [
                    SizedBox(height: Get.height / 45),
                    Center(
                      child: Container(
                        height: Get.height / 85,
                        width: Get.width / 5,
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.4),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: Get.height * 0.03),
                          Text("Add Your payment information",
                              style: TextStyle(
                                  color: WhiteColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5)),
                          SizedBox(height: Get.height * 0.02),
                          Form(
                            key: _formKey,
                            autovalidateMode: _autoValidateMode,
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                TextFormField(
                                  style: TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(19),
                                    CardNumberInputFormatter()
                                  ],
                                  controller: numberController,
                                  onSaved: (String? value) {
                                    _paymentCard.number =
                                        CardUtils.getCleanedNumber(value!);

                                    CardTypee cardType =
                                        CardUtils.getCardTypeFrmNumber(
                                            _paymentCard.number.toString());
                                    setState(() {
                                      _card.name = cardType.toString();
                                      _paymentCard.type = cardType;
                                    });
                                  },
                                  onChanged: (val) {
                                    CardTypee cardType =
                                        CardUtils.getCardTypeFrmNumber(val);
                                    setState(() {
                                      _card.name = cardType.toString();
                                      _paymentCard.type = cardType;
                                    });
                                  },
                                  validator: CardUtils.validateCardNum,
                                  decoration: InputDecoration(
                                    prefixIcon: SizedBox(
                                      height: 10,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                          horizontal: 6,
                                        ),
                                        child: CardUtils.getCardIcon(
                                          _paymentCard.type,
                                        ),
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: orangeColor,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: orangeColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: orangeColor,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: orangeColor,
                                      ),
                                    ),
                                    hintText: "What number is written on card?",
                                    hintStyle: TextStyle(color: Colors.white),
                                    labelStyle: TextStyle(color: Colors.white),
                                    labelText: "Number",
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Flexible(
                                      flex: 4,
                                      child: TextFormField(
                                        style: TextStyle(color: Colors.white),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(4),
                                        ],
                                        decoration: InputDecoration(
                                            prefixIcon: SizedBox(
                                              height: 10,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14),
                                                child: Image.asset(
                                                  'assets/card_cvv.png',
                                                  width: 6,
                                                  color: orangeColor,
                                                ),
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: orangeColor,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: orangeColor,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: orangeColor,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: orangeColor)),
                                            hintText: "Number behind the card",
                                            hintStyle:
                                                TextStyle(color: Colors.white),
                                            labelStyle:
                                                TextStyle(color: Colors.white),
                                            labelText: 'CVV'),
                                        validator: CardUtils.validateCVV,
                                        keyboardType: TextInputType.number,
                                        onSaved: (value) {
                                          _paymentCard.cvv = int.parse(value!);
                                        },
                                      ),
                                    ),
                                    SizedBox(width: Get.width * 0.03),
                                    Flexible(
                                      flex: 4,
                                      child: TextFormField(
                                        style: TextStyle(color: Colors.white),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(4),
                                          CardMonthInputFormatter()
                                        ],
                                        decoration: InputDecoration(
                                          prefixIcon: SizedBox(
                                            height: 10,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 14),
                                              child: Image.asset(
                                                'assets/calender.png',
                                                width: 10,
                                                color: orangeColor,
                                              ),
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: orangeColor,
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: orangeColor,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: orangeColor,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: orangeColor,
                                            ),
                                          ),
                                          hintText: 'MM/YY',
                                          hintStyle:
                                              TextStyle(color: Colors.white),
                                          labelStyle:
                                              TextStyle(color: Colors.white),
                                          labelText: "Expiry Date",
                                        ),
                                        validator: CardUtils.validateDate,
                                        keyboardType: TextInputType.number,
                                        onSaved: (value) {
                                          List<int> expiryDate =
                                              CardUtils.getExpiryDate(value!);
                                          _paymentCard.month = expiryDate[0];
                                          _paymentCard.year = expiryDate[1];
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: Get.height * 0.055),
                                Container(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: Get.width,
                                    child: CupertinoButton(
                                      onPressed: () {
                                        _validateInputs();
                                      },
                                      color: orangeColor,
                                      child: Text(
                                        "Pay ${homedata.homeDataList["currency"]}${(double.parse(totelbill).toStringAsFixed(2))}",
                                        style: TextStyle(fontSize: 17.0),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: Get.height * 0.065),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void _validateInputs() {
    final FormState form = _formKey.currentState!;
    if (!form.validate()) {
      setState(() {
        _autoValidateMode =
            AutovalidateMode.always; // Start validating on every change.
      });
      showToastMessage("Please fix the errors in red before submitting.");
    } else {
      var username = getData.read("UserLogin")["name"];
      var email = getData.read("UserLogin")["email"];
      _paymentCard.name = username;
      _paymentCard.email = email;
      _paymentCard.amount = double.parse(totelbill).toStringAsFixed(2);
      form.save();

      Get.to(() => StripePaymentWeb(paymentCard: _paymentCard))!.then((otid) {
        Get.back();
        //! order Api call
        if (otid != null) {
          //! Api Call Payment Success
          Discountorder.discountnow(
              discountamount: billdiscount,
              discountvalue: widget.tip,
              payedamount: double.parse(totelbill).toStringAsFixed(2),
              paymentid: selectidPay,
              restid: widget.restid,
              tipamount: paytip,
              totelamount: totelamount,
              transactionid: otid["id"],
              wallatamount: "0");
          Get.to(() => BillPaid(
                address: widget.address,
                hotelname: widget.hotelname,
                restid: widget.restid,
                discountvalue: widget.tip,
                tipamt: paytip,
                totelbill: totelamount,
                discountamt: billdiscount,
                payedamt: double.parse(totelbill).toStringAsFixed(2),
                walletamt: "0",
                selectidPay: selectidPay,
                transactionid: otid["id"],
              ));
        }
      });

      showToastMessage("Payment card is valid");
    }
  }

  // ignore: unused_element
  String _getReference() {
    var platform = (Platform.isIOS) ? 'iOS' : 'Android';
    final thisDate = DateTime.now().millisecondsSinceEpoch;
    return 'ChargedFrom${platform}_$thisDate';
  }

  // payplepayment({required Function onSuccess}) {
  //   return Navigator.of(context).push(MaterialPageRoute(
  //     builder: (context) {
  //       return UsePaypal(
  //           sandboxMode: true,
  //           clientId:
  //               "Aa0Yim_XLAz89S4cqO-kT4pK3QbFsruHvEm8zDYX_Y-wIKgsGyv4TzL84dGgtWYUoJqTvKUh0JonIaKa",
  //           secretKey:
  //               "ECZEZmIjx0j_3_RStM7eT3Bc0Ehdd_yW4slqTnCtNI8WtVOVL1qwRh__u1W_8qKygnPDs0XaviNlb7-z",
  //           returnURL:
  //               "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=EC-35S7886705514393E",
  //           cancelURL: "https://dineout.zozostudio.tech/paypal/cancle.php",
  //           transactions: [
  //             {
  //               "amount": {
  //                 "total": double.parse(totelbill).toStringAsFixed(2),
  //                 "currency": "USD",
  //                 "details": {
  //                   "subtotal": double.parse(totelbill).toStringAsFixed(2),
  //                   "shipping": '0',
  //                   "shipping_discount": 0
  //                 }
  //               },
  //               "description": "The payment transaction description.",
  //               // "payment_options": {
  //               //   "allowed_payment_method":
  //               //       "INSTANT_FUNDING_SOURCE"
  //               // },
  //               "item_list": {
  //                 "items": [
  //                   {
  //                     "name": "A demo product",
  //                     "quantity": 1,
  //                     "price": double.parse(totelbill).toStringAsFixed(2),
  //                     "currency": "USD"
  //                   }
  //                 ],

  //                 // shipping address is not required though
  //                 "shipping_address": {
  //                   "recipient_name": "Jane Foster",
  //                   "line1": "Travis County",
  //                   "line2": "",
  //                   "city": "Austin",
  //                   "country_code": "US",
  //                   "postal_code": "73301",
  //                   "phone": "+00000000",
  //                   "state": "Texas"
  //                 },
  //               }
  //             }
  //           ],
  //           note: "Contact us for any questions on your order.",
  //           onSuccess: onSuccess,
  //           onError: (error) {
  //             print("onError: $error");
  //           },
  //           onCancel: (params) {
  //             print('cancelled: $params');
  //           });
  //     },
  //   ));
  // }

  Widget walletDetail() {
    return wallet != "0"
        ? Container(
            width: Get.width,
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200, width: 1)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pay from Wallet".tr,
                    style: TextStyle(
                        fontSize: 16,
                        color: WhiteColor,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: Get.height * 0.01),
                  Text("Wallet Balance".tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: WhiteColor,
                      )),
                  SizedBox(height: Get.height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(height: Get.height * 0.01),
                          Text("Available for Payment ".tr,
                              style: TextStyle(color: greycolor)),
                          Text(
                            "${homedata.homeDataList["currency"]}${tempWallet.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: WhiteColor,
                            ),
                          ),
                        ],
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          activeColor: orangeColor,
                          value: status ?? false,
                          onChanged: (value) {
                            setState(() {});
                            status = value;
                            walletCalculation(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        : SizedBox();
  }

  walletCalculation(value) {
    if (value == true) {
      if (double.parse(wallet.toString()) <
          double.parse(totelbill.toString())) {
        tempWallet = double.parse(totelbill.toString()) -
            double.parse(wallet.toString());

        useWallet = double.parse(wallet.toString());
        totelbill = (double.parse(totelbill.toString()) -
                double.parse(wallet.toString()))
            .toString();
        tempWallet = 0;
        setState(() {});
      } else {
        tempWallet = double.parse(wallet.toString()) -
            double.parse(totelbill.toString());
        useWallet = double.parse(wallet.toString()) - tempWallet;
        totelbill = "0";
      }
    } else {
      tempWallet = double.parse(wallet.toString());
      totelbill = valuePlus(totelbill, useWallet);
      useWallet = 0;
      setState(() {});
    }
  }

  valuePlus(first, second) {
    return (double.parse(first.toString()) + double.parse(second.toString()))
        .toStringAsFixed(2);
  }

  checkLoginOrContinue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      print(homedata.currentIndex);

      checkLogin = prefs.getBool('Firstuser') ?? false;
    });
  }
}
