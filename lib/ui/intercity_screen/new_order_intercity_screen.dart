import 'package:bottom_picker/bottom_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/intercity_controller.dart';
import 'package:driver/model/intercity_order_model.dart';
import 'package:driver/model/order/driverId_accept_reject.dart';
import 'package:driver/model/place_picker_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/themes/text_field_them.dart';
import 'package:driver/ui/intercity_screen/pacel_details_screen.dart';
import 'package:driver/widget/osm_map_search_place.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/widget/google_map_search_place.dart';
import 'package:driver/widget/location_view.dart';
import 'package:driver/widget/user_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewOrderInterCityScreen extends StatelessWidget {
  const NewOrderInterCityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<IntercityController>(
        init: IntercityController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.primary,
            resizeToAvoidBottomInset: true,
            body: Column(
              children: [
                SizedBox(
                  height: Responsive.width(8, context),
                  width: Responsive.width(100, context),
                ),
                Expanded(
                  child: Container(
                    height: Responsive.height(100, context),
                    width: Responsive.width(100, context),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            InkWell(
                                onTap: () async {
                                  if (Constant.selectedMapType == 'osm') {
                                    Get.to(const OsmSearchPlacesApi())?.then((value) {
                                      if (value != null) {
                                        SearchInfo place = value;
                                        controller.sourceCityController.value.text = place.address.toString();
                                      }
                                    });
                                  } else {
                                    Get.to(const GoogleMapSearchPlacesApi())!.then((value) async {
                                      if (value != null) {
                                        PlaceDetailsModel placeDetailsModel = value;
                                        controller.sourceCityController.value.text = placeDetailsModel.result!.vicinity.toString();
                                      }
                                    });
                                  }
                                },
                                child: TextFieldThem.buildTextFiled(
                                  context,
                                  hintText: 'From'.tr,
                                  controller: controller.sourceCityController.value,
                                  enable: false,
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            InkWell(
                                onTap: () async {
                                  if (Constant.selectedMapType == 'osm') {
                                    Get.to(const OsmSearchPlacesApi())?.then((value) {
                                      if (value != null) {
                                        SearchInfo place = value;
                                        controller.destinationCityController.value.text = place.address.toString();
                                      }
                                    });
                                  } else {
                                    Get.to(const GoogleMapSearchPlacesApi())!.then((value) async {
                                      if (value != null) {
                                        PlaceDetailsModel placeDetailsModel = value;
                                        controller.destinationCityController.value.text = placeDetailsModel.result!.vicinity.toString();
                                      }
                                    });
                                  }
                                },
                                child: TextFieldThem.buildTextFiled(
                                  context,
                                  hintText: 'To'.tr,
                                  controller: controller.destinationCityController.value,
                                  enable: false,
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            InkWell(
                                onTap: () async {
                                  BottomPicker.date(
                                    onSubmit: (index) {
                                      controller.dateAndTime = index;
                                      DateFormat dateFormat = DateFormat("EEE, dd MMMM");
                                      String string = dateFormat.format(index);

                                      controller.whenController.value.text = string;
                                    },
                                    minDateTime: DateTime.now(),
                                    buttonAlignment: MainAxisAlignment.center,
                                    displaySubmitButton: true,
                                    buttonSingleColor: AppColors.primary,
                                    pickerTitle: const Text(''),
                                  ).show(context);
                                },
                                child: TextFieldThem.buildTextFiledWithSuffixIcon(
                                  context,
                                  hintText: 'Select date'.tr,
                                  controller: controller.whenController.value,
                                  enable: false,
                                  suffixIcon: const Icon(
                                    Icons.calendar_month,
                                    color: Colors.grey,
                                  ),
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            ButtonThem.buildButton(
                              context,
                              title: "Search".tr,
                              onPress: () {
                                controller.getOrder();
                              },
                            ),
                            Expanded(
                              child: controller.isLoading.value
                                  ? Constant.loader(context)
                                  : controller.intercityServiceOrder.isEmpty
                                      ? Center(
                                          child: Text("No Rides found".tr),
                                        )
                                      : ListView.builder(
                                          itemCount: controller.intercityServiceOrder.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            InterCityOrderModel orderModel = controller.intercityServiceOrder[index];
                                            String amount;
                                            if (Constant.distanceType == "Km") {
                                              amount = Constant.amountCalculate(orderModel.intercityService!.kmCharge.toString(), orderModel.distance.toString())
                                                  .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
                                            } else {
                                              amount = Constant.amountCalculate(orderModel.intercityService!.kmCharge.toString(), orderModel.distance.toString())
                                                  .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
                                            }
                                            return InkWell(
                                              onTap: () {
                                                if (orderModel.acceptedDriverId != null && orderModel.acceptedDriverId!.contains(FireStoreUtils.getCurrentUid())) {
                                                  ShowToastDialog.showToast("Ride already accepted".tr);
                                                } else {
                                                  controller.newAmount.value = orderModel.offerRate.toString();
                                                  DateTime start = DateFormat("HH:mm").parse(orderModel.whenTime.toString());
                                                  controller.suggestedTime = start;
                                                  controller.suggestedTimeController.value.text = DateFormat("hh:mm aa").format(controller.suggestedTime!);
                                                  controller.enterOfferRateController.value.text = orderModel.offerRate.toString();
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
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(Constant.amountShow(amount: orderModel.offerRate.toString()),
                                                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                                                            orderModel.intercityServiceId == "647f350983ba2"
                                                                ? const SizedBox()
                                                                : Text(" For ${orderModel.numberOfPassenger} Person".tr,
                                                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                                                          ],
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
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.grey.withOpacity(0.30), borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                      child: Text(orderModel.paymentType.toString()),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        color: AppColors.primary.withOpacity(0.30), borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                      child: Text(Constant.localizationName(orderModel.intercityService!.name)),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Visibility(
                                                              visible: orderModel.intercityServiceId == "647f350983ba2",
                                                              child: InkWell(
                                                                  onTap: () {
                                                                    Get.to(const ParcelDetailsScreen(), arguments: {
                                                                      "orderModel": orderModel,
                                                                    });
                                                                  },
                                                                  child: Text(
                                                                    "View details".tr,
                                                                    style: GoogleFonts.poppins(),
                                                                  )),
                                                            )
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                color: themeChange.getThem() ? AppColors.darkGray : AppColors.gray,
                                                                borderRadius: const BorderRadius.all(Radius.circular(10))),
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
                                        ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  offerAcceptDialog(BuildContext context, IntercityController controller, InterCityOrderModel orderModel) {
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
                        InkWell(
                            onTap: () {
                              BottomPicker.time(
                                onSubmit: (index) {
                                  controller.suggestedTime = index;
                                  DateFormat dateFormat = DateFormat("hh:mm aa");
                                  String string = dateFormat.format(index);

                                  controller.suggestedTimeController.value.text = string;
                                },
                                initialTime: Time.now(),
                                buttonAlignment: MainAxisAlignment.center,
                                pickerTitle: const Text(''),
                                displaySubmitButton: true,
                                buttonSingleColor: AppColors.primary,
                              ).show(context);
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.access_time),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: TextFieldThem.buildTextFiled(
                                    context,
                                    enable: false,
                                    hintText: "Enter Fare rate".tr,
                                    controller: controller.suggestedTimeController.value,
                                    keyBoardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                                  ),
                                )
                              ],
                            )),
                        const SizedBox(
                          height: 10,
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
