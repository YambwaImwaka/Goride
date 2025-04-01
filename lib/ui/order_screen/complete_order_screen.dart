import 'package:clipboard/clipboard.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/complete_order_controller.dart';
import 'package:driver/model/tax_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/widget/location_view.dart';
import 'package:driver/widget/user_order_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompleteOrderScreen extends StatelessWidget {
  const CompleteOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<CompleteOrderController>(
        init: CompleteOrderController(),
        builder: (controller) {
          return Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.primary,
                title:  Text("Ride Details".tr),
                leading: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(
                      Icons.arrow_back,
                    )),
              ),
              backgroundColor: AppColors.primary,
              body: Column(
                children: [
                  SizedBox(
                    height: Responsive.width(10, context),
                    width: Responsive.width(100, context),
                  ),
                  Expanded(
                    child: controller.isLoading.value
                        ? Constant.loader(context)
                        : Container(
                            decoration:
                                BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: themeChange.getThem() ? AppColors.darkContainerBackground : AppColors.containerBackground,
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(color: themeChange.getThem() ? AppColors.darkContainerBorder : AppColors.containerBorder, width: 0.5),
                                            boxShadow: themeChange.getThem()
                                                ? null
                                                : [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.10),
                                                      blurRadius: 5,
                                                      offset: const Offset(0, 4), // changes position of shadow
                                                    ),
                                                  ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "Ride ID".tr,
                                                        style: GoogleFonts.poppins(
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        FlutterClipboard.copy(controller.orderModel.value.id.toString()).then((value) {
                                                          ShowToastDialog.showToast("OrderId copied".tr);
                                                        });
                                                      },
                                                      child: DottedBorder(
                                                        borderType: BorderType.RRect,
                                                        radius: const Radius.circular(4),
                                                        dashPattern: const [6, 6, 6, 6],
                                                        color: AppColors.textFieldBorder,
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                                          child: Text(
                                                            "Copy".tr,
                                                            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  "#${controller.orderModel.value.id!.toUpperCase()}",
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        UserDriverView(userId: controller.orderModel.value.userId.toString(), amount: controller.orderModel.value.finalRate.toString()),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 5),
                                          child: Divider(thickness: 1),
                                        ),
                                        Text(
                                          "Pickup and drop-off locations".tr,
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: themeChange.getThem() ? AppColors.darkContainerBackground : AppColors.containerBackground,
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(color: themeChange.getThem() ? AppColors.darkContainerBorder : AppColors.containerBorder, width: 0.5),
                                            boxShadow: themeChange.getThem()
                                                ? null
                                                : [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.5),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 2), // changes position of shadow
                                                    ),
                                                  ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: LocationView(
                                              sourceLocation: controller.orderModel.value.sourceLocationName.toString(),
                                              destinationLocation: controller.orderModel.value.destinationLocationName.toString(),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: themeChange.getThem() ? AppColors.darkGray : AppColors.gray, borderRadius: const BorderRadius.all(Radius.circular(10))),
                                            child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                                child: Center(
                                                  child: Row(
                                                    children: [
                                                      Expanded(child: Text(controller.orderModel.value.status.toString(), style: GoogleFonts.poppins(fontWeight: FontWeight.w500))),
                                                      Text(Constant().formatTimestamp(controller.orderModel.value.createdDate), style: GoogleFonts.poppins()),
                                                    ],
                                                  ),
                                                )),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: themeChange.getThem() ? AppColors.darkContainerBackground : AppColors.containerBackground,
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(color: themeChange.getThem() ? AppColors.darkContainerBorder : AppColors.containerBorder, width: 0.5),
                                            boxShadow: themeChange.getThem()
                                                ? null
                                                : [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.5),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 2), // changes position of shadow
                                                    ),
                                                  ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Booking summary".tr,
                                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                                ),
                                                const Divider(
                                                  thickness: 1,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "Ride Amount".tr,
                                                        style: GoogleFonts.poppins(color: AppColors.subTitleColor),
                                                      ),
                                                    ),
                                                    Text(
                                                      Constant.amountShow(amount: controller.orderModel.value.finalRate.toString()),
                                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                                const Divider(
                                                  thickness: 1,
                                                ),
                                                controller.orderModel.value.taxList == null
                                                    ? const SizedBox()
                                                    : ListView.builder(
                                                        itemCount: controller.orderModel.value.taxList!.length,
                                                        shrinkWrap: true,
                                                        padding: EdgeInsets.zero,
                                                        itemBuilder: (context, index) {
                                                          TaxModel taxModel = controller.orderModel.value.taxList![index];
                                                          return Column(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      "${taxModel.title.toString()} (${taxModel.type == "fix" ? Constant.amountShow(amount: taxModel.tax) : "${taxModel.tax}%"})",
                                                                      style: GoogleFonts.poppins(color: AppColors.subTitleColor),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    Constant.amountShow(
                                                                        amount: Constant()
                                                                            .calculateTax(
                                                                                amount: (double.parse(controller.orderModel.value.finalRate.toString()) -
                                                                                        double.parse(controller.couponAmount.value.toString()))
                                                                                    .toString(),
                                                                                taxModel: taxModel)
                                                                            .toString()),
                                                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                                                  ),
                                                                ],
                                                              ),
                                                              const Divider(
                                                                thickness: 1,
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "Discount".tr,
                                                        style: GoogleFonts.poppins(color: AppColors.subTitleColor),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "(-${controller.couponAmount.value == "0.0" ? Constant.amountShow(amount: "0.0") : Constant.amountShow(amount: controller.couponAmount.value)})",
                                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.red),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const Divider(
                                                  thickness: 1,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "Payable amount".tr,
                                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                                      ),
                                                    ),
                                                    Text(
                                                      Constant.amountShow(amount: controller.calculateAmount().toString()),
                                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: themeChange.getThem() ? AppColors.darkContainerBackground : AppColors.containerBackground,
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(color: themeChange.getThem() ? AppColors.darkContainerBorder : AppColors.containerBorder, width: 0.5),
                                            boxShadow: themeChange.getThem()
                                                ? null
                                                : [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.10),
                                                      blurRadius: 5,
                                                      offset: const Offset(0, 4), // changes position of shadow
                                                    ),
                                                  ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Admin Commission".tr,
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "Admin commission".tr,
                                                        style: GoogleFonts.poppins(color: AppColors.subTitleColor),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "(-${Constant.amountShow(amount: Constant.calculateAdminCommission(amount: (double.parse(controller.orderModel.value.finalRate.toString()) - double.parse(controller.couponAmount.value.toString())).toString(), adminCommission: controller.orderModel.value.adminCommission).toString())})",
                                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.red),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  "Note : Admin commission will be debited from your wallet balance. \n Admin commission will apply on Ride Amount minus Discount(if applicable).".tr,
                                                  style: GoogleFonts.poppins(color: Colors.red),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ));
        });
  }
}
