import 'package:driver/constant/constant.dart';
import 'package:driver/controller/home_controller.dart';
import 'package:driver/model/order_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/ui/home_screens/order_map_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/widget/location_view.dart';
import 'package:driver/widget/user_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NewOrderScreen extends StatelessWidget {
  const NewOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<HomeController>(
        init: HomeController(),
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
                  : StreamBuilder<List<OrderModel>>(
                      stream: FireStoreUtils().getOrders(controller.driverModel.value, Constant.currentLocation?.latitude, Constant.currentLocation?.longitude),
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
                              OrderModel orderModel = snapshot.data![index];
                              String amount;
                              if (Constant.distanceType == "Km") {
                                amount = Constant.amountCalculate(orderModel.service!.kmCharge.toString(), orderModel.distance.toString())
                                    .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
                              } else {
                                amount = Constant.amountCalculate(orderModel.service!.kmCharge.toString(), orderModel.distance.toString())
                                    .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
                              }
                              return InkWell(
                                onTap: () {
                                  Get.to(const OrderMapScreen(), arguments: {"orderModel": orderModel.id.toString()})!.then((value) {
                                    if (value != null && value == true) {
                                      controller.selectedIndex.value = 1;
                                    }
                                  });
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
                                          const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 5),
                                            child: Divider(),
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
                                                      color: themeChange.getThem() ? AppColors.darkGray : AppColors.gray, borderRadius: BorderRadius.all(Radius.circular(10))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                    child: Center(
                                                      child: Text(
                                                        'Recommended Price is ${Constant.amountShow(amount: amount)}. Approx distance ${double.parse(orderModel.distance.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} ${Constant.distanceType}',
                                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                                      ),
                                                    ),
                                                  ),
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
}
