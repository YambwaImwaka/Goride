import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/active_order_controller.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/model/order_model.dart';
import 'package:driver/model/user_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
import 'package:driver/ui/chat_screen/chat_screen.dart';
import 'package:driver/ui/home_screens/live_tracking_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/utils/utils.dart';
import 'package:driver/widget/location_view.dart';
import 'package:driver/widget/user_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class ActiveOrderScreen extends StatelessWidget {
  const ActiveOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetBuilder<ActiveOrderController>(
        init: ActiveOrderController(),
        builder: (controller) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(CollectionName.orders)
                .where('driverId', isEqualTo: FireStoreUtils.getCurrentUid())
                .where('status', whereIn: [Constant.rideInProgress, Constant.rideActive]).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong'.tr);
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Constant.loader(context);
              }
              return snapshot.data!.docs.isEmpty
                  ? Center(
                      child: Text("No active rides Found".tr),
                    )
                  : ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        OrderModel orderModel = OrderModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                        return InkWell(
                          onTap: () {
                            if (Constant.mapType == "inappmap") {
                              if (orderModel.status == Constant.rideActive || orderModel.status == Constant.rideInProgress) {
                                Get.to(const LiveTrackingScreen(), arguments: {
                                  "orderModel": orderModel,
                                  "type": "orderModel",
                                });
                              }
                            } else {
                              if (orderModel.status == Constant.rideInProgress) {
                                Utils.redirectMap(
                                    latitude: orderModel.destinationLocationLAtLng!.latitude!,
                                    longLatitude: orderModel.destinationLocationLAtLng!.longitude!,
                                    name: orderModel.destinationLocationName.toString());
                              } else {
                                Utils.redirectMap(
                                    latitude: orderModel.sourceLocationLAtLng!.latitude!,
                                    longLatitude: orderModel.sourceLocationLAtLng!.longitude!,
                                    name: orderModel.destinationLocationName.toString());
                              }
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
                                      amount: orderModel.finalRate,
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: orderModel.status == Constant.rideInProgress
                                              ? ButtonThem.buildBorderButton(
                                                  context,
                                                  title: "Complete Ride".tr,
                                                  btnHeight: 44,
                                                  iconVisibility: false,
                                                  onPress: () async {
                                                    orderModel.status = Constant.rideComplete;

                                                    await FireStoreUtils.getCustomer(orderModel.userId.toString()).then((value) async {
                                                      if (value != null) {
                                                        if (value.fcmToken != null) {
                                                          Map<String, dynamic> playLoad = <String, dynamic>{"type": "city_order_complete", "orderId": orderModel.id};

                                                          await SendNotification.sendOneNotification(
                                                              token: value.fcmToken.toString(),
                                                              title: 'Ride complete!'.tr,
                                                              body: 'Please complete your payment.'.tr,
                                                              payload: playLoad);
                                                        }
                                                      }
                                                    });

                                                    await FireStoreUtils.setOrder(orderModel).then((value) {
                                                      if (value == true) {
                                                        ShowToastDialog.showToast("Ride Complete successfully".tr);
                                                        controller.homeController.selectedIndex.value = 3;
                                                      }
                                                    });
                                                  },
                                                )
                                              : ButtonThem.buildBorderButton(
                                                  context,
                                                  title: "Pickup Customer".tr,
                                                  btnHeight: 44,
                                                  iconVisibility: false,
                                                  onPress: () async {
                                                    showDialog(context: context, builder: (BuildContext context) => otpDialog(context, controller, orderModel));
                                                  },
                                                ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                UserModel? customer = await FireStoreUtils.getCustomer(orderModel.userId.toString());
                                                DriverUserModel? driver = await FireStoreUtils.getDriverProfile(orderModel.driverId.toString());

                                                Get.to(ChatScreens(
                                                  driverId: driver!.id,
                                                  customerId: customer!.id,
                                                  customerName: customer.fullName,
                                                  customerProfileImage: customer.profilePic,
                                                  driverName: driver.fullName,
                                                  driverProfileImage: driver.profilePic,
                                                  orderId: orderModel.id,
                                                  token: customer.fcmToken,
                                                ));
                                              },
                                              child: Container(
                                                height: 44,
                                                width: 44,
                                                decoration: BoxDecoration(
                                                    color: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary, borderRadius: BorderRadius.circular(5)),
                                                child: Icon(Icons.chat, color: themeChange.getThem() ? Colors.black : Colors.white),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                UserModel? customer = await FireStoreUtils.getCustomer(orderModel.userId.toString());
                                                Constant.makePhoneCall("${customer!.countryCode}${customer.phoneNumber}");
                                              },
                                              child: Container(
                                                height: 44,
                                                width: 44,
                                                decoration: BoxDecoration(
                                                    color: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary, borderRadius: BorderRadius.circular(5)),
                                                child: Icon(Icons.call, color: themeChange.getThem() ? Colors.black : Colors.white),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      });
            },
          );
        });
  }

  otpDialog(BuildContext context, ActiveOrderController controller, OrderModel orderModel) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), //this right here
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text("OTP verify from customer".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: PinCodeTextField(
                length: 6,
                appContext: context,
                keyboardType: TextInputType.phone,
                pinTheme: PinTheme(
                  fieldHeight: 40,
                  fieldWidth: 40,
                  activeColor: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder,
                  selectedColor: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder,
                  inactiveColor: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder,
                  activeFillColor: themeChange.getThem() ? AppColors.darkTextField : AppColors.textField,
                  inactiveFillColor: themeChange.getThem() ? AppColors.darkTextField : AppColors.textField,
                  selectedFillColor: themeChange.getThem() ? AppColors.darkTextField : AppColors.textField,
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                ),
                enableActiveFill: true,
                cursorColor: AppColors.primary,
                controller: controller.otpController.value,
                onCompleted: (v) async {},
                onChanged: (value) {},
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ButtonThem.buildButton(context, title: "OTP verify".tr, onPress: () async {
              if (orderModel.otp.toString() == controller.otpController.value.text) {
                Get.back();
                ShowToastDialog.showLoader("Please wait...".tr);
                orderModel.status = Constant.rideInProgress;

                await FireStoreUtils.getCustomer(orderModel.userId.toString()).then((value) async {
                  if (value != null) {
                    await SendNotification.sendOneNotification(
                        token: value.fcmToken.toString(),
                        title: 'Ride Started'.tr,
                        body: 'The ride has officially started. Please follow the designated route to the destination.'.tr,
                        payload: {});
                  }
                });

                await FireStoreUtils.setOrder(orderModel).then((value) {
                  if (value == true) {
                    ShowToastDialog.closeLoader();
                    ShowToastDialog.showToast("Customer pickup successfully".tr);
                  }
                });
              } else {
                ShowToastDialog.showToast("OTP Invalid".tr, position: EasyLoadingToastPosition.center);
              }
            }),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
