import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/controller/parcel_details_controller.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ParcelDetailsScreen extends StatelessWidget {
  const ParcelDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<ParcelDetailsController>(
        init: ParcelDetailsController(),
        builder: (controller) {
          return Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.primary,
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
                    height: Responsive.width(8, context),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Visibility(
                                      visible: controller.orderModel.value.intercityServiceId == "Kn2VEnPI3ikF58uK8YqY" ? false : true,
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
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "Parcel Weight".tr,
                                                      style: GoogleFonts.poppins(color: AppColors.subTitleColor),
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "${controller.orderModel.value.parcelWeight} Kg.".tr,
                                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const Divider(),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      "Parcel dimension".tr,
                                                      style: GoogleFonts.poppins(color: AppColors.subTitleColor),
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "${controller.orderModel.value.parcelDimension} ft.".tr,
                                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: controller.orderModel.value.parcelImage!.isEmpty
                                          ? const Center(child: Text("No Image available"))
                                          : GridView.builder(
                                              itemCount: controller.orderModel.value.parcelImage!.length,
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: (MediaQuery.of(context).orientation == Orientation.portrait) ? 2 : 3),
                                              itemBuilder: (BuildContext context, int index) {
                                                return Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: CachedNetworkImage(
                                                      imageUrl: controller.orderModel.value.parcelImage![index].toString(),
                                                      imageBuilder: (context, imageProvider) => Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
                                                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                        ),
                                                      ),
                                                      placeholder: (context, url) => const Center(
                                                        child: CircularProgressIndicator(),
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ],
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
