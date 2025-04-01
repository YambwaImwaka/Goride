import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/intercity_order_controller.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/model/intercity_order_model.dart';
import 'package:driver/model/user_model.dart';
import 'package:driver/model/wallet_transaction_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
import 'package:driver/ui/chat_screen/chat_screen.dart';
import 'package:driver/ui/order_intercity_screen/complete_intecity_order_screen.dart';
import 'package:driver/ui/review/review_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/widget/location_view.dart';
import 'package:driver/widget/user_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OrderFreightScreen extends StatelessWidget {
  const OrderFreightScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<InterCityOrderController>(
        init: InterCityOrderController(),
        builder: (controller) {
          return controller.isLoading.value
              ? Constant.loader(context)
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(CollectionName.ordersIntercity)
                      .where('driverId', isEqualTo: FireStoreUtils.getCurrentUid())
                      .where('intercityServiceId', isEqualTo: "Kn2VEnPI3ikF58uK8YqY")
                      .orderBy("createdDate", descending: true)
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Something went wrong'.tr));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Constant.loader(context);
                    }

                    return snapshot.data!.docs.isEmpty
                        ? Center(
                            child: Text("No Ride found".tr),
                          )
                        : ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              InterCityOrderModel orderModel = InterCityOrderModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                              return InkWell(
                                onTap: () {
                                  Get.to(const CompleteIntercityOrderScreen(), arguments: {
                                    "orderModel": orderModel,
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
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
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          UserView(
                                            userId: orderModel.userId,
                                            amount: orderModel.finalRate,
                                            distance: orderModel.distance,
                                            distanceType: orderModel.distanceType,
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
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          LocationView(
                                            sourceLocation: orderModel.sourceLocationName.toString(),
                                            destinationLocation: orderModel.destinationLocationName.toString(),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          orderModel.status == Constant.rideComplete || orderModel.status == Constant.rideActive
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                      color: themeChange.getThem() ? AppColors.darkGray : AppColors.gray,
                                                      borderRadius: const BorderRadius.all(Radius.circular(10))),
                                                  child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                      child: Row(
                                                        children: [
                                                          Expanded(child: Text(orderModel.status.toString(), style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                                                          Text(Constant().formatTimestamp(orderModel.createdDate), style: GoogleFonts.poppins()),
                                                        ],
                                                      )),
                                                )
                                              : Container(
                                                  decoration: BoxDecoration(
                                                      color: themeChange.getThem() ? AppColors.darkGray : AppColors.gray,
                                                      borderRadius: const BorderRadius.all(Radius.circular(10))),
                                                  child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          const Icon(Icons.access_time_outlined),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(Constant().formatTimestamp(orderModel.createdDate), style: GoogleFonts.poppins()),
                                                        ],
                                                      )),
                                                ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ButtonThem.buildBorderButton(
                                                  context,
                                                  title: "Review".tr,
                                                  btnHeight: 44,
                                                  iconVisibility: false,
                                                  onPress: () async {
                                                    Get.to(const ReviewScreen(), arguments: {
                                                      "type": "interCityOrderModel",
                                                      "interCityOrderModel": orderModel,
                                                    });
                                                  },
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Visibility(
                                                visible: orderModel.status == Constant.rideComplete ? false : true,
                                                child: Row(
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
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          ButtonThem.buildButton(
                                            context,
                                            title: orderModel.paymentStatus == true ? "Payment completed".tr : "Payment Pending".tr,
                                            btnHeight: 44,
                                            onPress: () async {},
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Visibility(
                                              visible: controller.paymentModel.value.cash!.name == orderModel.paymentType.toString() && orderModel.paymentStatus == false,
                                              child: ButtonThem.buildButton(
                                                context,
                                                title: "Confirm cash payment".tr,
                                                btnHeight: 44,
                                                onPress: () async {
                                                  ShowToastDialog.showLoader("Please wait..".tr);
                                                  orderModel.paymentStatus = true;
                                                  orderModel.status = Constant.rideComplete;
                                                  orderModel.updateDate = Timestamp.now();

                                                  String? couponAmount = "0.0";
                                                  if (orderModel.coupon != null) {
                                                    if (orderModel.coupon?.code != null) {
                                                      if (orderModel.coupon!.type == "fix") {
                                                        couponAmount = orderModel.coupon!.amount.toString();
                                                      } else {
                                                        couponAmount =
                                                            ((double.parse(orderModel.finalRate.toString()) * double.parse(orderModel.coupon!.amount.toString())) / 100).toString();
                                                      }
                                                    }
                                                  }

                                                  WalletTransactionModel adminCommissionWallet = WalletTransactionModel(
                                                      id: Constant.getUuid(),
                                                      amount:
                                                          "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.finalRate.toString()) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.adminCommission)}",
                                                      createdDate: Timestamp.now(),
                                                      paymentType: "wallet".tr,
                                                      transactionId: orderModel.id,
                                                      orderType: "intercity",
                                                      userId: orderModel.driverId.toString(),
                                                      userType: "driver",
                                                      note: "Admin commission debited".tr);

                                                  await FireStoreUtils.setWalletTransaction(adminCommissionWallet).then((value) async {
                                                    if (value == true) {
                                                      await FireStoreUtils.updatedDriverWallet(
                                                          amount:
                                                              "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.finalRate.toString()) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.adminCommission)}");
                                                    }
                                                  });

                                                  await FireStoreUtils.getCustomer(orderModel.userId.toString()).then((value) async {
                                                    if (value != null) {
                                                      await SendNotification.sendOneNotification(
                                                          token: value.fcmToken.toString(),
                                                          title: 'Cash Payment confirmed'.tr,
                                                          body: 'Driver has confirmed your cash payment'.tr,
                                                          payload: {});
                                                    }
                                                  });

                                                  await FireStoreUtils.getIntercityFirstOrderOrNOt(orderModel).then((value) async {
                                                    if (value == true) {
                                                      await FireStoreUtils.updateIntercityReferralAmount(orderModel);
                                                    }
                                                  });

                                                  await FireStoreUtils.setInterCityOrder(orderModel).then((value) {
                                                    if (value == true) {
                                                      ShowToastDialog.closeLoader();
                                                      ShowToastDialog.showToast("Payment Confirm successfully".tr);
                                                    }
                                                  });
                                                },
                                              ))
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
}
