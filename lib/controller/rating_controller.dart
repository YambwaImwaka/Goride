import 'package:driver/model/intercity_order_model.dart';
import 'package:driver/model/order_model.dart';
import 'package:driver/model/user_model.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/review_model.dart';

class RatingController extends GetxController {
  RxBool isLoading = true.obs;
  RxDouble rating = 0.0.obs;
  Rx<TextEditingController> commentController = TextEditingController().obs;

  Rx<ReviewModel> reviewModel = ReviewModel().obs;
  Rx<UserModel> userModel = UserModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getArgument();
  }

  Rx<OrderModel> orderModel = OrderModel().obs;
  Rx<InterCityOrderModel> intercityOrderModel = InterCityOrderModel().obs;

  RxString type = "".obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      type.value = argumentData['type'];
      if (type.value == "orderModel") {
        orderModel.value = argumentData['orderModel'];
      } else {
        intercityOrderModel.value = argumentData['interCityOrderModel'];
      }
    }
    await FireStoreUtils.getCustomer(type.value == "orderModel" ? orderModel.value.userId.toString() : intercityOrderModel.value.userId.toString()).then((value) {
      if (value != null) {
        userModel.value = value;
      }
    });
    await FireStoreUtils.getReview(type.value == "orderModel" ? orderModel.value.id.toString() : intercityOrderModel.value.id.toString()).then((value) {
      if (value != null) {
        reviewModel.value = value;
        rating.value = double.parse(reviewModel.value.rating.toString());
        commentController.value.text = reviewModel.value.comment.toString();
      }
    });
    isLoading.value = false;
    update();
  }
}
