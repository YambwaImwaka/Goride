import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/model/intercity_order_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/ui/intercity_screen/pacel_details_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/widget/location_view.dart';
import 'package:driver/widget/user_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AcceptedFreightOrders extends StatelessWidget {
  const AcceptedFreightOrders({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(CollectionName.ordersIntercity)
          .where('intercityServiceId', isEqualTo: "Kn2VEnPI3ikF58uK8YqY")
          .where('acceptedDriverId', arrayContains: FireStoreUtils.getCurrentUid())
          .snapshots(),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            Text(
                              Constant.amountShow(amount: orderModel.offerRate.toString()),
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
                              textAlign: TextAlign.left,
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
                                decoration:
                                    BoxDecoration(color: themeChange.getThem() ? AppColors.darkGray : AppColors.gray, borderRadius: const BorderRadius.all(Radius.circular(10))),
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
                          ],
                        ),
                      ),
                    ),
                  );
                });
      },
    );
  }
}
