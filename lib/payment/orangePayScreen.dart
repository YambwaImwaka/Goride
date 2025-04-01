// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'package:driver/model/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class OrangeMoneyScreen extends StatefulWidget {
  String initialURl;
  OrangePay orangePay;
  String accessToken = '';
  String payToken = '';
  String orderId = '';
  String amount = '';

  OrangeMoneyScreen({
    super.key,
    required this.initialURl,
    required this.orangePay,
    required this.accessToken,
    required this.payToken,
    required this.orderId,
    required this.amount,
  });

  @override
  State<OrangeMoneyScreen> createState() => _OrangeMoneyScreenState();
}

class _OrangeMoneyScreenState extends State<OrangeMoneyScreen> {
  WebViewController controller = WebViewController();
  bool isLoading = true;
  @override
  void initState() {
    initController();
    callTransaction();
    super.initState();
  }

  callTransaction() {
    Timer.periodic(const Duration(seconds: 3), (Timer t) {
      transactionstatus(accessToken: widget.accessToken, amount: widget.amount, orderId: widget.orderId, payToken: widget.payToken).then((value) {
        if (value == 'SUCCESS') {
          Navigator.of(context).pop(true);
        } else if (value == 'FAILED') {
          Navigator.of(context).pop(false);
        }
      });
    });
  }

  initController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: ((url) {
            setState(() {
              isLoading = false;
            });
          }),
          onNavigationRequest: (NavigationRequest navigation) async {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialURl));
  }

  Future transactionstatus({
    required String orderId,
    required String amount,
    required String payToken,
    required String accessToken,
  }) async {
    String apiUrl = widget.orangePay.isSandbox == true
        ? 'https://api.orange.com/orange-money-webpay/dev/v1/transactionstatus'
        : 'https://api.orange.com/orange-money-webpay/cm/v1/transactionstatus';
    Map<String, String> requestBody = {
      "order_id": orderId,
      "amount": amount, // "OUV",
      "pay_token": payToken
    };

    var response = await http.post(Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody));

    // Handle the response
    if (response.statusCode == 201) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData['status'];
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
        onWillPop: () async {
          _showMyDialog();
          return false;
        },
        child: Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.black,
                centerTitle: false,
                leading: GestureDetector(
                  onTap: () {
                    _showMyDialog();
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                )),
            body: Stack(alignment: Alignment.center, children: [
              WebViewWidget(controller: controller),
              Visibility(
                  visible: isLoading,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ))
            ])));
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Payment'.tr),
          content: SingleChildScrollView(
            child: Text("cancelPayment?".tr),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel'.tr,
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                'Continue'.tr,
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }
}
