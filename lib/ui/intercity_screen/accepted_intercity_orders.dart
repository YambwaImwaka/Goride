import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/model/intercity_order_model.dart';
import 'package:driver/model/order/driverId_accept_reject.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/ui/intercity_screen/pacel_details_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/widget/location_view.dart';
import 'package:driver/widget/user_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AcceptedIntercityOrders extends StatelessWidget {
  const AcceptedIntercityOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
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
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(CollectionName.ordersIntercity)
                      .where('acceptedDriverId', arrayContains: FireStoreUtils.getCurrentUid())
                      .where('intercityServiceId', whereIn: ["647f340e35553", '647f350983ba2', 'UmQ2bjWTnlwoKqdCIlTr']).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong'.tr);
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Constant.loader(context);
                    }
                    return snapshot.data!.docs.isEmpty
                        ? Center(
                            child: Text("No accepted ride found".tr),
                          )
                        : ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              InterCityOrderModel orderModel = InterCityOrderModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
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
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            FutureBuilder<DriverIdAcceptReject?>(
                                                future: FireStoreUtils.getInterCItyAcceptedOrders(orderModel.id.toString(), FireStoreUtils.getCurrentUid()),
                                                builder: (context, snapshot) {
                                                  switch (snapshot.connectionState) {
                                                    case ConnectionState.waiting:
                                                      return Constant.loader(context);
                                                    case ConnectionState.done:
                                                      if (snapshot.hasError) {
                                                        return Text(snapshot.error.toString());
                                                      } else {
                                                        DriverIdAcceptReject driverIdAcceptReject = snapshot.data!;
                                                        return Text(Constant.amountShow(amount: driverIdAcceptReject.offerAmount.toString()),
                                                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18));
                                                      }
                                                    default:
                                                      return Text('Error'.tr);
                                                  }
                                                }),
                                            orderModel.intercityServiceId == "647f350983ba2"
                                                ? const SizedBox()
                                                : Text(" For ${orderModel.numberOfPassenger} Person".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
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
                                                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.30), borderRadius: const BorderRadius.all(Radius.circular(5))),
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
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
