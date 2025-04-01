import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/rating_controller.dart';
import 'package:driver/model/user_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
import 'package:driver/themes/text_field_them.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/widget/my_separator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<RatingController>(
        init: RatingController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              title: Text("Review".tr),
              leading: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: const Icon(
                    Icons.arrow_back,
                  )),
            ),
            backgroundColor: AppColors.primary,
            body: controller.isLoading.value == true
                ? Constant.loader(context)
                : Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 42, bottom: 20),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 80,
                                  ),
                                  Text(
                                    '${controller.userModel.value.fullName}',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(letterSpacing: 0.8, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 22,
                                        color: AppColors.ratingColour,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                          Constant.calculateReview(
                                                  reviewCount: controller.userModel.value.reviewsCount.toString(), reviewSum: controller.userModel.value.reviewsSum.toString())
                                              .toString(),
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  const MySeparator(color: Colors.grey),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Text(
                                      'Rate for'.tr,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(letterSpacing: 0.8),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      "${controller.userModel.value.fullName}",
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 2),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: RatingBar.builder(
                                      initialRating: controller.rating.value,
                                      minRating: 0,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) {
                                        controller.rating(rating);
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30),
                                    child: TextFieldThem.buildTextFiled(context, hintText: 'Comment..'.tr, controller: controller.commentController.value, maxLine: 5),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ButtonThem.buildButton(context, title: "Submit".tr, onPress: () async {
                                    if (controller.rating.value > 0 && controller.commentController.value.text.isNotEmpty) {
                                      ShowToastDialog.showLoader("Please wait".tr);

                                      await FireStoreUtils.getCustomer(controller.type.value == "orderModel"
                                              ? controller.orderModel.value.userId.toString()
                                              : controller.intercityOrderModel.value.userId.toString())
                                          .then((value) async {
                                        if (value != null) {
                                          UserModel userModel = value;

                                          if (controller.reviewModel.value.id != null) {
                                            userModel.reviewsSum =
                                                (double.parse(userModel.reviewsSum.toString()) - double.parse(controller.reviewModel.value.rating.toString())).toString();
                                            userModel.reviewsCount = (double.parse(userModel.reviewsCount.toString()) - 1).toString();
                                          }
                                          userModel.reviewsSum = (double.parse(userModel.reviewsSum.toString()) + double.parse(controller.rating.value.toString())).toString();
                                          userModel.reviewsCount = (double.parse(userModel.reviewsCount.toString()) + 1).toString();
                                          await FireStoreUtils.updateUser(userModel);
                                        }
                                      });

                                      controller.reviewModel.value.id =
                                          controller.type.value == "orderModel" ? controller.orderModel.value.id : controller.intercityOrderModel.value.id;
                                      controller.reviewModel.value.comment = controller.commentController.value.text;
                                      controller.reviewModel.value.rating = controller.rating.value.toString();
                                      controller.reviewModel.value.customerId = FireStoreUtils.getCurrentUid();
                                      controller.reviewModel.value.driverId =
                                          controller.type.value == "orderModel" ? controller.orderModel.value.driverId : controller.intercityOrderModel.value.driverId;
                                      controller.reviewModel.value.date = Timestamp.now();
                                      controller.reviewModel.value.type = controller.type.value == "orderModel" ? "city" : "intercity";

                                      FireStoreUtils.setReview(controller.reviewModel.value).then((value) {
                                        if (value != null && value == true) {
                                          ShowToastDialog.closeLoader();
                                          ShowToastDialog.showToast("Review submit successfully".tr);
                                          Get.back();
                                        }
                                      });
                                    } else {
                                      ShowToastDialog.showToast("Please give rate in star and add feedback comment.".tr);
                                    }
                                  }),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(60),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.15),
                                    blurRadius: 8,
                                    spreadRadius: 6,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: CachedNetworkImage(
                                  imageUrl: controller.userModel.value.profilePic.toString(),
                                  height: 110,
                                  width: 110,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Constant.loader(context),
                                  errorWidget: (context, url, error) => Image.network(Constant.userPlaceHolder),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          );
        });
  }
}
