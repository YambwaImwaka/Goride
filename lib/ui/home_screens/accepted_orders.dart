import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/controller/accepted_orders_controller.dart';
import 'package:driver/model/order/driverId_accept_reject.dart';
import 'package:driver/model/order_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/widget/location_view.dart';
import 'package:driver/widget/user_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AcceptedOrders extends StatelessWidget {
  const AcceptedOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetBuilder<AcceptedOrdersController>(
        init: AcceptedOrdersController(),
        dispose: (state) {
          FireStoreUtils().closeStream();
        },
        builder: (controller) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection(CollectionName.orders).where('acceptedDriverId', arrayContains: FireStoreUtils.getCurrentUid()).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return  Text('Something went wrong'.tr);
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Constant.loader(context);
              }
              return snapshot.data!.docs.isEmpty
                  ?  Center(
                      child: Text("No accepted ride found".tr),
                    )
                  : ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        OrderModel orderModel = OrderModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                        return Padding(
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
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Divider(),
                                  ),
                                  FutureBuilder<DriverIdAcceptReject?>(
                                      future: FireStoreUtils.getAcceptedOrders(orderModel.id.toString(), FireStoreUtils.getCurrentUid()),
                                      builder: (context, snapshot) {
                                        switch (snapshot.connectionState) {
                                          case ConnectionState.waiting:
                                            return Constant.loader(context);
                                          case ConnectionState.done:
                                            if (snapshot.hasError) {
                                              return Text(snapshot.error.toString());
                                            } else {
                                              DriverIdAcceptReject driverIdAcceptReject = snapshot.data!;
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Container(
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
                                                    child: Row(
                                                      children: [
                                                        Expanded(child: Text("Offer Rate".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                                                        Text(Constant.amountShow(amount:driverIdAcceptReject.offerAmount.toString())),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          default:
                                            return  Text('Error'.tr);
                                        }
                                      }),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  LocationView(
                                    sourceLocation: orderModel.sourceLocationName.toString(),
                                    destinationLocation: orderModel.destinationLocationName.toString(),
                                  ),
                                ],
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
