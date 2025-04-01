import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/subscription_controller.dart';
import 'package:driver/model/subscription_plan_model.dart';
import 'package:driver/payment/createRazorPayOrderModel.dart';
import 'package:driver/payment/rozorpayConroller.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SubscriptionListScreen extends StatelessWidget {
  const SubscriptionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<SubscriptionController>(
        init: SubscriptionController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.primary,
            appBar: controller.isShowing.value == false
                ? null
                : AppBar(
                    backgroundColor: AppColors.primary,
                    title: Text(
                      "Choose Subscription Plan",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                      ),
                    ),
                    centerTitle: true,
                  ),
            body: Column(
              children: [
                SizedBox(
                  height: Responsive.width(12, context),
                  width: Responsive.width(100, context),
                ),
                Expanded(
                  child: Container(
                    height: Responsive.height(100, context),
                    width: Responsive.width(100, context),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                    child: controller.isLoading.value
                        ? Constant.loader(context)
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: SingleChildScrollView(
                              child: controller.subscriptionPlanList.isEmpty
                                  ? SizedBox(
                                      width: Responsive.width(100, context),
                                      height: Responsive.height(80, context),
                                      child: Constant.showEmptyView(message: "Subscription Plan Not Found.".tr))
                                  : ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      primary: false,
                                      itemCount: controller.subscriptionPlanList.length,
                                      itemBuilder: (context, index) {
                                        final subscriptionPlanModel = controller.subscriptionPlanList[index];
                                        return SubscriptionPlanWidget(
                                          onContainClick: () {
                                            controller.selectedSubscriptionPlan.value = subscriptionPlanModel;
                                            controller.totalAmount.value = double.parse(subscriptionPlanModel.price ?? '0.0');
                                            controller.update();
                                          },
                                          onClick: () {
                                            if(controller.selectedSubscriptionPlan.value.id  == subscriptionPlanModel.id){
                                              if (controller.selectedSubscriptionPlan.value.type == 'free' ||
                                                  controller.selectedSubscriptionPlan.value.id == Constant.commissionSubscriptionID) {
                                                controller.selectedPaymentMethod.value = 'free';
                                                controller.placeOrder();
                                              } else {
                                                paymentMethodDialog(context, controller);
                                              }
                                            }

                                          },
                                          type: 'Plan',
                                          subscriptionPlanModel: subscriptionPlanModel,
                                        );
                                      }),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  paymentMethodDialog(BuildContext context, SubscriptionController controller) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        builder: (context1) {
          final themeChange = Provider.of<DarkThemeProvider>(context1);

          return FractionallySizedBox(
            heightFactor: 0.9,
            child: StatefulBuilder(builder: (context1, setState) {
              return Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            InkWell(
                                onTap: () {
                                  Get.back();
                                },
                                child: const Icon(Icons.arrow_back_ios)),
                            Expanded(
                                child: Center(
                                    child: Text(
                              "Subscription plan purchase".tr,
                              style: GoogleFonts.poppins(),
                            ))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Select Payment Option".tr,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.wallet!.enable == true,
                                  child: Obx(
                                    () => Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            controller.selectedPaymentMethod.value = controller.paymentModel.value.wallet!.name.toString();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                              border: Border.all(
                                                  color: controller.selectedPaymentMethod.value == controller.paymentModel.value.wallet!.name.toString()
                                                      ? themeChange.getThem()
                                                          ? AppColors.darkModePrimary
                                                          : AppColors.primary
                                                      : AppColors.textFieldBorder,
                                                  width: 1),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 40,
                                                    width: 80,
                                                    decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: SvgPicture.asset('assets/icons/ic_wallet.svg', color: AppColors.primary),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      controller.paymentModel.value.wallet!.name.toString(),
                                                      style: GoogleFonts.poppins(),
                                                    ),
                                                  ),
                                                  Radio(
                                                    value: controller.paymentModel.value.wallet!.name.toString(),
                                                    groupValue: controller.selectedPaymentMethod.value,
                                                    activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                    onChanged: (value) {
                                                      controller.selectedPaymentMethod.value = controller.paymentModel.value.wallet!.name.toString();
                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.strip!.enable == true,
                                  child: Obx(
                                    () => Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            controller.selectedPaymentMethod.value = controller.paymentModel.value.strip!.name.toString();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                              border: Border.all(
                                                  color: controller.selectedPaymentMethod.value == controller.paymentModel.value.strip!.name.toString()
                                                      ? themeChange.getThem()
                                                          ? AppColors.darkModePrimary
                                                          : AppColors.primary
                                                      : AppColors.textFieldBorder,
                                                  width: 1),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 40,
                                                    width: 80,
                                                    decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Image.asset('assets/images/stripe.png'),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      controller.paymentModel.value.strip!.name.toString(),
                                                      style: GoogleFonts.poppins(),
                                                    ),
                                                  ),
                                                  Radio(
                                                    value: controller.paymentModel.value.strip!.name.toString(),
                                                    groupValue: controller.selectedPaymentMethod.value,
                                                    activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                    onChanged: (value) {
                                                      controller.selectedPaymentMethod.value = controller.paymentModel.value.strip!.name.toString();
                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.paypal!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.paypal!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.paypal!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darkModePrimary
                                                        : AppColors.primary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/paypal.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.paypal!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.paypal!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.paypal!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.payStack!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.payStack!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.payStack!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darkModePrimary
                                                        : AppColors.primary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/paystack.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.payStack!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.payStack!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.payStack!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.mercadoPago!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.mercadoPago!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.mercadoPago!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darkModePrimary
                                                        : AppColors.primary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/mercadopago.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.mercadoPago!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.mercadoPago!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.mercadoPago!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.flutterWave!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.flutterWave!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.flutterWave!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darkModePrimary
                                                        : AppColors.primary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/flutterwave.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.flutterWave!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.flutterWave!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.flutterWave!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.payfast!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.payfast!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.payfast!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darkModePrimary
                                                        : AppColors.primary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/payfast.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.payfast!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.payfast!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.payfast!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.paytm!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.paytm!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.paytm!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darkModePrimary
                                                        : AppColors.primary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/paytam.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.paytm!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.paytm!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.paytm!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.razorpay!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.razorpay!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.razorpay!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darkModePrimary
                                                        : AppColors.primary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/razorpay.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.razorpay!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.razorpay!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.razorpay!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                controller.paymentModel.value.midtrans != null && controller.paymentModel.value.midtrans!.enable == true
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              controller.selectedPaymentMethod.value = controller.paymentModel.value.midtrans!.name.toString();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                border: Border.all(
                                                    color: controller.selectedPaymentMethod.value == controller.paymentModel.value.midtrans!.name.toString()
                                                        ? themeChange.getThem()
                                                            ? AppColors.darkModePrimary
                                                            : AppColors.primary
                                                        : AppColors.textFieldBorder,
                                                    width: 1),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 40,
                                                      width: 80,
                                                      decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Image.asset('assets/images/midtrans.png'),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        controller.paymentModel.value.midtrans!.name.toString(),
                                                        style: GoogleFonts.poppins(),
                                                      ),
                                                    ),
                                                    Radio(
                                                      value: controller.paymentModel.value.midtrans!.name.toString(),
                                                      groupValue: controller.selectedPaymentMethod.value,
                                                      activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                      onChanged: (value) {
                                                        controller.selectedPaymentMethod.value = controller.paymentModel.value.midtrans!.name.toString();
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                                controller.paymentModel.value.xendit != null && controller.paymentModel.value.xendit!.enable == true
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              controller.selectedPaymentMethod.value = controller.paymentModel.value.xendit!.name.toString();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                border: Border.all(
                                                    color: controller.selectedPaymentMethod.value == controller.paymentModel.value.xendit!.name.toString()
                                                        ? themeChange.getThem()
                                                            ? AppColors.darkModePrimary
                                                            : AppColors.primary
                                                        : AppColors.textFieldBorder,
                                                    width: 1),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 40,
                                                      width: 80,
                                                      decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Image.asset('assets/images/xendit.png'),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        controller.paymentModel.value.xendit!.name.toString(),
                                                        style: GoogleFonts.poppins(),
                                                      ),
                                                    ),
                                                    Radio(
                                                      value: controller.paymentModel.value.xendit!.name.toString(),
                                                      groupValue: controller.selectedPaymentMethod.value,
                                                      activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                      onChanged: (value) {
                                                        controller.selectedPaymentMethod.value = controller.paymentModel.value.xendit!.name.toString();
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                                controller.paymentModel.value.orangePay != null && controller.paymentModel.value.orangePay!.enable == true
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              controller.selectedPaymentMethod.value = controller.paymentModel.value.orangePay!.name.toString();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                border: Border.all(
                                                    color: controller.selectedPaymentMethod.value == controller.paymentModel.value.orangePay!.name.toString()
                                                        ? themeChange.getThem()
                                                            ? AppColors.darkModePrimary
                                                            : AppColors.primary
                                                        : AppColors.textFieldBorder,
                                                    width: 1),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 40,
                                                      width: 80,
                                                      decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Image.asset('assets/images/orange_money.png'),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        controller.paymentModel.value.orangePay!.name.toString(),
                                                        style: GoogleFonts.poppins(),
                                                      ),
                                                    ),
                                                    Radio(
                                                      value: controller.paymentModel.value.orangePay!.name.toString(),
                                                      groupValue: controller.selectedPaymentMethod.value,
                                                      activeColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
                                                      onChanged: (value) {
                                                        controller.selectedPaymentMethod.value = controller.paymentModel.value.orangePay!.name.toString();
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ButtonThem.buildButton(context, title: "Pay Now".tr, onPress: () {
                        if (controller.selectedPaymentMethod.value == '') {
                          ShowToastDialog.showToast("Please Select Payment Method.");
                        } else {
                          if (controller.selectedPaymentMethod.value == controller.paymentModel.value.wallet!.name) {
                            if (double.parse(controller.driverUserModel.value.walletAmount.toString()) >= controller.totalAmount.value) {
                              Get.back();
                              controller.placeOrder();
                            } else {
                              ShowToastDialog.showToast("Wallet Amount Insufficient".tr);
                            }
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.strip!.name) {
                            Get.back();
                            controller.stripeMakePayment(amount: controller.totalAmount.value.toString());
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.paypal!.name) {
                            Get.back();
                            controller.paypalPaymentSheet(controller.totalAmount.value.toString(), context1);
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.payStack!.name) {
                            Get.back();
                            controller.payStackPayment(controller.totalAmount.value.toString());
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.mercadoPago!.name) {
                            Get.back();
                            controller.mercadoPagoMakePayment(context: context, amount: controller.totalAmount.value.toString());
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.flutterWave!.name) {
                            Get.back();
                            controller.flutterWaveInitiatePayment(context: context, amount: controller.totalAmount.value.toString());
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.payfast!.name) {
                            Get.back();
                            controller.payFastPayment(context: context, amount: controller.totalAmount.value.toString());
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.paytm!.name) {
                            Get.back();
                            controller.getPaytmCheckSum(context, amount: double.parse(controller.totalAmount.value.toString()));
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.razorpay!.name) {
                            RazorPayController()
                                .createOrderRazorPay(amount: int.parse(controller.totalAmount.value.toString()), razorpayModel: controller.paymentModel.value.razorpay)
                                .then((value) {
                              if (value == null) {
                                Get.back();
                                ShowToastDialog.showToast("Something went wrong, please contact admin.".tr);
                              } else {
                                CreateRazorPayOrderModel result = value;
                                controller.openCheckout(amount: controller.totalAmount.value.toString(), orderId: result.id);
                              }
                            });
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.midtrans!.name) {
                            Get.back();
                            controller.midtransMakePayment(context: context, amount: controller.totalAmount.value.toString());
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.orangePay!.name) {
                            Get.back();
                            controller.orangeMakePayment(context: context, amount: controller.totalAmount.value.toString());
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.xendit!.name) {
                            Get.back();
                            controller.xenditPayment(context, controller.totalAmount.value.toString());
                          } else {
                            ShowToastDialog.showToast("Please select payment method".tr);
                          }
                        }
                      }),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }
}

class SubscriptionPlanWidget extends StatelessWidget {
  final VoidCallback onClick;
  final VoidCallback onContainClick;
  final String type;
  final SubscriptionPlanModel subscriptionPlanModel;

  const SubscriptionPlanWidget({super.key, required this.onClick, required this.type, required this.subscriptionPlanModel, required this.onContainClick});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX(
        init: SubscriptionController(),
        builder: (controller) {
          return InkWell(
            splashColor: Colors.transparent,
            onTap: onContainClick,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: themeChange.getThem() ? AppColors.grey800 : AppColors.grey200),
                color: controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                    ? themeChange.getThem()
                        ? AppColors.grey50
                        : AppColors.grey800
                    : themeChange.getThem()
                        ? AppColors.grey900
                        : AppColors.grey50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        NetworkImageWidget(
                          imageUrl: subscriptionPlanModel.image ?? '',
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subscriptionPlanModel.name ?? '',
                                style: TextStyle(
                                  color: controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                      ? themeChange.getThem()
                                          ? AppColors.grey900
                                          : AppColors.grey50
                                      : themeChange.getThem()
                                          ? AppColors.grey50
                                          : AppColors.grey900,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${subscriptionPlanModel.description}",
                                maxLines: 2,
                                softWrap: true,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.grey400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        controller.driverUserModel.value.subscriptionPlanId == subscriptionPlanModel.id
                            ? ButtonThem.buildButton(
                                context,
                                btnWidthRatio: 0.24,
                                btnHeight: 34,
                                txtSize: 12,
                                title: "Active".tr,
                                onPress: () => null,
                                textColor: AppColors.grey100,
                                bgColors: Colors.green,
                              )
                            : SizedBox(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        subscriptionPlanModel.type == "free" ? "Free" : Constant.amountShow(amount: double.parse(subscriptionPlanModel.price ?? '0.0').toString()),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                              ? themeChange.getThem()
                                  ? AppColors.grey800
                                  : AppColors.grey200
                              : themeChange.getThem()
                                  ? AppColors.grey200
                                  : AppColors.grey800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subscriptionPlanModel.expiryDay == "-1" ? "LifeTime" : "${subscriptionPlanModel.expiryDay} Days",
                        style: TextStyle(
                          fontSize: 14,
                          color: controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                              ? themeChange.getThem()
                                  ? AppColors.grey500
                                  : AppColors.grey500
                              : themeChange.getThem()
                                  ? AppColors.grey500
                                  : AppColors.grey500,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ]),
                    const SizedBox(height: 10),
                    if (subscriptionPlanModel.id == Constant.commissionSubscriptionID)
                      Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Text('•  ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: themeChange.getThem()
                                        ? controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                            ? AppColors.grey800
                                            : AppColors.grey200
                                        : controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                            ? AppColors.grey200
                                            : AppColors.grey800,
                                  )),
                              Expanded(
                                child: Text(
                                    'Pay a commission of ${Constant.adminCommission?.type == 'percentage' ? "${Constant.adminCommission?.amount}%" : "${Constant.amountShow(amount: Constant.adminCommission?.amount)} Flat"} on each order.',
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: themeChange.getThem()
                                          ? controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                              ? AppColors.grey800
                                              : AppColors.grey200
                                          : controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                              ? AppColors.grey200
                                              : AppColors.grey800,
                                    )),
                              ),
                            ],
                          )),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: subscriptionPlanModel.planPoints?.length,
                      itemBuilder: (BuildContext? context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Text('•  ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: themeChange.getThem()
                                        ? controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                            ? AppColors.grey800
                                            : AppColors.grey200
                                        : controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                            ? AppColors.grey200
                                            : AppColors.grey800,
                                  )),
                              Expanded(
                                child: Text(subscriptionPlanModel.planPoints?[index] ?? '',
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: themeChange.getThem()
                                          ? controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                              ? AppColors.grey800
                                              : AppColors.grey200
                                          : controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                              ? AppColors.grey200
                                              : AppColors.grey800,
                                    )),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Divider(
                        color: controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                            ? themeChange.getThem()
                                ? AppColors.grey200
                                : AppColors.grey700
                            : themeChange.getThem()
                                ? AppColors.grey700
                                : AppColors.grey200),
                    const SizedBox(height: 10),
                    Text('Accept booking limits : ${subscriptionPlanModel.bookingLimit == '-1' ? 'Unlimited' : subscriptionPlanModel.bookingLimit ?? '0'}',
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 14,
                            color: themeChange.getThem()
                                ? controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                    ? AppColors.grey900
                                    : AppColors.grey50
                                : controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                                    ? AppColors.grey50
                                    : AppColors.grey900)),
                    const SizedBox(height: 20),
                    ButtonThem.buildButton(
                      context,
                      title: controller.driverUserModel.value.subscriptionPlanId == subscriptionPlanModel.id
                          ? "Renew"
                          : controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                              ? "Active".tr
                              : "Select Plan".tr,
                      onPress: onClick,
                      textColor: controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                          ? AppColors.grey900
                          : themeChange.getThem()
                              ? AppColors.grey500
                              : AppColors.grey500,
                      bgColors: controller.selectedSubscriptionPlan.value.id == subscriptionPlanModel.id
                          ? AppColors.darkModePrimary
                          : themeChange.getThem()
                              ? AppColors.grey800
                              : AppColors.grey200,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class FeatureItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final bool selectedPlan;

  const FeatureItem({super.key, required this.title, required this.isActive, required this.selectedPlan});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isActive == true
              ? SvgPicture.asset(
                  'assets/icons/ic_check.svg',
                )
              : SvgPicture.asset(
                  'assets/icons/ic_close.svg',
                  colorFilter: const ColorFilter.mode(
                    AppColors.danger200,
                    BlendMode.srcIn,
                  ),
                ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title == 'chat'
                  ? 'Chat'
                  : title == 'dineIn'
                      ? "DineIn"
                      : title == 'qrCodeGenerate'
                          ? 'QR Code Generate'
                          : title == 'restaurantMobileApp'
                              ? 'Restaurant Mobile App'
                              : '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: themeChange.getThem()
                    ? selectedPlan == true
                        ? AppColors.grey900
                        : AppColors.grey50
                    : selectedPlan == true
                        ? AppColors.grey50
                        : AppColors.grey900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
