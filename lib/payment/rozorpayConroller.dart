import 'dart:convert';

import 'package:driver/constant/constant.dart';
import 'package:driver/model/payment_model.dart';
import 'package:driver/payment/createRazorPayOrderModel.dart';
import 'package:http/http.dart' as http;

class RazorPayController {
  Future<CreateRazorPayOrderModel?> createOrderRazorPay({required int amount, required RazorpayModel? razorpayModel}) async {
    final String orderId = DateTime.now().millisecondsSinceEpoch.toString();
    RazorpayModel razorPayData = razorpayModel!;
    print("============");
    print(razorPayData.razorpayKey);
    print("we Enter In");
    const url = "${Constant.globalUrl}payments/razorpay/createorder";
    print(orderId);
    final response = await http.post(
      Uri.parse(url),
      body: {
        "amount": (amount * 100).toString(),
        "receipt_id": orderId,
        "currency": "INR",
        "razorpaykey": razorPayData.razorpayKey,
        "razorPaySecret": razorPayData.razorpaySecret,
        "isSandBoxEnabled": razorPayData.isSandbox.toString(),
      },
    );

    if (response.statusCode == 500) {
      return null;
    } else {
      final data = jsonDecode(response.body);
      print(data);

      return CreateRazorPayOrderModel.fromJson(data);
    }
  }
}
