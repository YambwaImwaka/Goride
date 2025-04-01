import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransScreen extends StatefulWidget {
  final String initialURl;

  const MidtransScreen({super.key, required this.initialURl});

  @override
  State<MidtransScreen> createState() => _MidtransScreenState();
}

class _MidtransScreenState extends State<MidtransScreen> {
  WebViewController controller = WebViewController();
  bool isLoading = true;
  @override
  void initState() {
    initController();

    super.initState();
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
            log("URL :: ${navigation.url}");
            String? orderId = Uri.parse(navigation.url).queryParameters['merchant_order_id'];
            await Future.delayed(const Duration(seconds: 2));
            if (orderId != null) {
              Navigator.of(context).pop(true);
            } else {
              Navigator.of(context).pop(false);
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialURl));
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
            body: Stack(
                alignment: Alignment.center,
                children: [WebViewWidget(controller: controller), Visibility(visible: isLoading, child: const Center(child: CircularProgressIndicator()))])));
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
                style: const TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                'Continue'.tr,
                style: const TextStyle(color: Colors.green),
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
