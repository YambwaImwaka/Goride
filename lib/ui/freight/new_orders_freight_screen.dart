import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/freight_controller.dart';
import 'package:driver/model/intercity_order_model.dart';
import 'package:driver/model/order/driverId_accept_reject.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/themes/text_field_them.dart';
import 'package:driver/ui/intercity_screen/pacel_details_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/widget/location_view.dart';
import 'package:driver/widget/user_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewOrderFreightScreen extends StatelessWidget {
  const NewOrderFreightScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<FreightController>(
        init: FreightController(),
        dispose: (state) {
          FireStoreUtils().closeStream();
        },
        builder: (controller) {
          return controller.isLoading.value
              ? Constant.loader(context)
              : controller.driverModel.value.isOnline == false
                  ? Center(
                      child: Text("You are Now offline so you can't get nearest order.".tr),
                    )
                  : StreamBuilder<List<InterCityOrderModel>>(
                      stream: FireStoreUtils().getFreightOrders(Constant.currentLocation!.latitude, Constant.currentLocation!.longitude),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Constant.loader(context);
                        }
                        if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                          return Center(
                            child: Text("New Rides Not found".tr),
                          );
                        } else {
                          // ordersList = snapshot.data!;
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              InterCityOrderModel orderModel = snapshot.data![index];
                              String amount;
                              if (Constant.distanceType == "Km") {
                                amount = Constant.amountCalculate(orderModel.freightVehicle!.kmCharge.toString(), orderModel.distance.toString())
                                    .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
                              } else {
                                amount = Constant.amountCalculate(orderModel.freightVehicle!.kmCharge.toString(), orderModel.distance.toString())
                                    .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
                              }

                              return InkWell(
                                onTap: () {
                                  if (orderModel.acceptedDriverId != null && orderModel.acceptedDriverId!.contains(FireStoreUtils.getCurrentUid())) {
                                    ShowToastDialog.showToast("Ride already accepted".tr);
                                  } else {
                                    controller.newAmount.value = orderModel.offerRate.toString();
                                    controller.enterOfferRateController.value.text = orderModel.offerRate.toString();
                                    DateTime start = DateFormat("HH:mm").parse(orderModel.whenTime.toString());
                                    controller.suggestedTime = start;
                                    controller.suggestedTimeController.value.text = DateFormat("hh:mm aa").format(controller.suggestedTime!);
                                    offerAcceptDialog(context, controller, orderModel);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
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
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                      child: Column(
                                        children: [
                                          UserView(
                                            userId: orderModel.userId,
                                            amount: orderModel.offerRate,
                                            distance: orderModel.distance,
                                            distanceType: orderModel.distanceType,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              Constant.amountShow(amount: orderModel.offerRate.toString()),
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.30), borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                        child: Text(orderModel.paymentType.toString()),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Container(
                                                      decoration:
                                                          BoxDecoration(color: AppColors.primary.withOpacity(0.30), borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                        child: Text(Constant.localizationName(orderModel.intercityService!.name)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              InkWell(
                                                  onTap: () {
                                                    Get.to(const ParcelDetailsScreen(), arguments: {
                                                      "orderModel": orderModel,
                                                    });
                                                  },
                                                  child: Text(
                                                    "View details".tr,
                                                    style: GoogleFonts.poppins(),
                                                  ))
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(children: [
                                            const Icon(Icons.fire_truck),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              Constant.localizationName(orderModel.freightVehicle!.name),
                                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                                            )
                                          ]),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: themeChange.getThem() ? AppColors.darkGray : AppColors.gray, borderRadius: const BorderRadius.all(Radius.circular(10))),
                                              child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(orderModel.whenDates.toString(), style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(orderModel.whenTime.toString(), style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                                    ],
                                                  )),
                                            ),
                                          ),
                                          LocationView(
                                            sourceLocation: orderModel.sourceLocationName.toString(),
                                            destinationLocation: orderModel.destinationLocationName.toString(),
                                          ),
                                          Column(
                                            children: [
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                child: Container(
                                                  width: Responsive.width(100, context),
                                                  decoration: BoxDecoration(
                                                      color: themeChange.getThem() ? AppColors.darkGray : AppColors.gray,
                                                      borderRadius: const BorderRadius.all(Radius.circular(10))),
                                                  child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                      child: Center(
                                                        child: Text(
                                                          'Recommended Price is ${Constant.amountShow(amount: amount)}. Approx distance ${double.parse(orderModel.distance.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} ${Constant.distanceType}'
                                                              .tr,
                                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                                        ),
                                                      )),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      });
        });
  }

  offerAcceptDialog(BuildContext context, FreightController controller, InterCityOrderModel orderModel) {
    return showModalBottomSheet(
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15))),
            child: StatefulBuilder(builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
                child: Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        UserView(
                          userId: orderModel.userId,
                          amount: orderModel.offerRate,
                          distance: orderModel.distance,
                          distanceType: orderModel.distanceType,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Divider(),
                        ),
                        LocationView(
                          sourceLocation: orderModel.sourceLocationName.toString(),
                          destinationLocation: orderModel.destinationLocationName.toString(),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Visibility(
                          visible: orderModel.intercityService!.offerRate == true,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (double.parse(controller.newAmount.value) >= 10) {
                                      controller.newAmount.value = (double.parse(controller.newAmount.value) - 10).toString();

                                      controller.enterOfferRateController.value.text = controller.newAmount.value;
                                    } else {
                                      controller.newAmount.value = "0";
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(border: Border.all(color: AppColors.textFieldBorder), borderRadius: const BorderRadius.all(Radius.circular(30))),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                      child: Text(
                                        "- 10",
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Text(Constant.amountShow(amount: controller.newAmount.toString()), style: GoogleFonts.poppins()),
                                const SizedBox(
                                  width: 20,
                                ),
                                ButtonThem.roundButton(
                                  context,
                                  title: "+ 10",
                                  btnWidthRatio: 0.22,
                                  onPress: () {
                                    controller.newAmount.value = (double.parse(controller.newAmount.value) + 10).toStringAsFixed(Constant.currencyModel!.decimalDigits!);
                                    controller.enterOfferRateController.value.text = controller.newAmount.value;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Visibility(
                          visible: orderModel.intercityService!.offerRate == true,
                          child: TextFieldThem.buildTextFiledWithPrefixIcon(
                            context,
                            hintText: "Enter Fare rate".tr,
                            controller: controller.enterOfferRateController.value,
                            keyBoardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                controller.newAmount.value = "0.0";
                              } else {
                                controller.newAmount.value = value;
                              }
                            },
                            prefix: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text(Constant.currencyModel!.symbol.toString()),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ButtonThem.buildButton(
                          context,
                          title: "Accept fare on ${Constant.amountShow(amount: controller.newAmount.value)}".tr,
                          onPress: () async {
                            if (controller.newAmount.value.isNotEmpty && double.parse(controller.newAmount.value.toString()) > 0) {
                              if (controller.driverModel.value.subscriptionTotalOrders == "-1") {
                                controller.acceptOrder(orderModel);
                              } else {
                                if (Constant.isSubscriptionModelApplied == false && Constant.adminCommission!.isEnabled == false) {
                                  controller.acceptOrder(orderModel);
                                } else {
                                  if ((controller.driverModel.value.subscriptionExpiryDate != null &&
                                          controller.driverModel.value.subscriptionExpiryDate!.toDate().isBefore(DateTime.now()) == false) ||
                                      controller.driverModel.value.subscriptionPlan?.expiryDay == '-1') {
                                    if (controller.driverModel.value.subscriptionTotalOrders != '0') {
                                      controller.acceptOrder(orderModel);
                                    } else {
                                      ShowToastDialog.showToast("Your order limit has reached their maximum order capacity. Please subscribe another subscription");
                                    }
                                  } else {
                                    ShowToastDialog.showToast("Your order limit has reached their maximum order capacity. Please subscribe another subscription");
                                  }
                                }
                              }
                            } else {
                              ShowToastDialog.showToast("Please enter valid offer rate".tr);
                            }
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        });
  }
}
