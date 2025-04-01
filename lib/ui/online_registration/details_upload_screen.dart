import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/details_upload_controller.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/themes/text_field_them.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class DetailsUploadScreen extends StatelessWidget {
  const DetailsUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<DetailsUploadController>(
        init: DetailsUploadController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              centerTitle: true,
              title: Text(Constant.localizationTitle(controller.documentModel.value.title), style: GoogleFonts.poppins(color: Colors.white)),
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
                  child: Container(
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                    child: controller.isLoading.value
                        ? Constant.loader(context)
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                                  child: TextFieldThem.buildTextFiled(context,
                                      hintText: Constant.localizationTitle(controller.documentModel.value.title), controller: controller.documentNumberController.value),
                                ),
                                Visibility(
                                  visible: controller.documentModel.value.expireAt == true ? true : false,
                                  child: InkWell(
                                    onTap: () async {
                                      await Constant.selectFetureDate(context).then((value) {
                                        if (value != null) {
                                          controller.selectedDate.value = value;
                                          controller.expireAtController.value.text = DateFormat("dd-MM-yyyy").format(value);
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                                      child: TextFieldThem.buildTextFiledWithSuffixIcon(context,
                                          hintText: "Select Expire date".tr, controller: controller.expireAtController.value, enable: false, suffixIcon: Icon(Icons.calendar_month)),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Visibility(
                                  visible: controller.documentModel.value.frontSide == true ? true : false,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Front Side of ${Constant.localizationTitle(controller.documentModel.value.title)}".tr, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        controller.frontImage.value.isNotEmpty
                                            ? InkWell(
                                                onTap: () {
                                                  if (controller.documents.value.verified == null ||controller.documents.value.verified == false) {
                                                    buildBottomSheet(context, controller, "front");
                                                  }
                                                },
                                                child: SizedBox(
                                                  height: Responsive.height(20, context),
                                                  width: Responsive.width(90, context),
                                                  child: ClipRRect(
                                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                    child: Constant().hasValidUrl(controller.frontImage.value) == false
                                                        ? Image.file(
                                                            File(controller.frontImage.value),
                                                            height: Responsive.height(20, context),
                                                            width: Responsive.width(80, context),
                                                            fit: BoxFit.fill,
                                                          )
                                                        : CachedNetworkImage(
                                                            imageUrl: controller.frontImage.value.toString(),
                                                            fit: BoxFit.fill,
                                                            height: Responsive.height(20, context),
                                                            width: Responsive.width(80, context),
                                                            placeholder: (context, url) => Constant.loader(context),
                                                            errorWidget: (context, url, error) => Image.network(
                                                                'https://firebasestorage.googleapis.com/v0/b/goride-1a752.appspot.com/o/placeholderImages%2Fuser-placeholder.jpeg?alt=media&token=34a73d67-ba1d-4fe4-a29f-271d3e3ca115'),
                                                          ),
                                                  ),
                                                ),
                                              )
                                            : InkWell(
                                                onTap: () {
                                                  buildBottomSheet(context, controller, "front");
                                                },
                                                child: DottedBorder(
                                                  borderType: BorderType.RRect,
                                                  radius: const Radius.circular(12),
                                                  dashPattern: const [6, 6, 6, 6],
                                                  color: AppColors.textFieldBorder,
                                                  child: SizedBox(
                                                      height: Responsive.height(20, context),
                                                      width: Responsive.width(90, context),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Container(
                                                            height: Responsive.height(8, context),
                                                            width: Responsive.width(20, context),
                                                            decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.all(Radius.circular(10))),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(10),
                                                              child: Image.asset(
                                                                'assets/icons/document_placeholder.png',
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                           Text("Add photo".tr)
                                                        ],
                                                      )),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: controller.documentModel.value.backSide == true ? true : false,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Back side of ${Constant.localizationTitle(controller.documentModel.value.title)}".tr, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        controller.backImage.value.isNotEmpty
                                            ? InkWell(
                                                onTap: () {
                                                  if (controller.documents.value.verified == null ||controller.documents.value.verified == false) {
                                                    buildBottomSheet(context, controller, "back");
                                                  }
                                                },
                                                child: SizedBox(
                                                  height: Responsive.height(20, context),
                                                  width: Responsive.width(90, context),
                                                  child: ClipRRect(
                                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                    child: Constant().hasValidUrl(controller.backImage.value) == false
                                                        ? Image.file(
                                                            File(controller.backImage.value),
                                                            height: Responsive.height(20, context),
                                                            width: Responsive.width(80, context),
                                                            fit: BoxFit.fill,
                                                          )
                                                        : CachedNetworkImage(
                                                            imageUrl: controller.backImage.value.toString(),
                                                            fit: BoxFit.fill,
                                                            height: Responsive.height(20, context),
                                                            width: Responsive.width(80, context),
                                                            placeholder: (context, url) => Constant.loader(context),
                                                            errorWidget: (context, url, error) => Image.network(
                                                                'https://firebasestorage.googleapis.com/v0/b/goride-1a752.appspot.com/o/placeholderImages%2Fuser-placeholder.jpeg?alt=media&token=34a73d67-ba1d-4fe4-a29f-271d3e3ca115'),
                                                          ),
                                                  ),
                                                ),
                                              )
                                            : InkWell(
                                                onTap: () {
                                                  buildBottomSheet(context, controller, "back");
                                                },
                                                child: DottedBorder(
                                                  borderType: BorderType.RRect,
                                                  radius: const Radius.circular(12),
                                                  dashPattern: const [6, 6, 6, 6],
                                                  color: AppColors.textFieldBorder,
                                                  child: SizedBox(
                                                      height: Responsive.height(20, context),
                                                      width: Responsive.width(90, context),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Container(
                                                            height: Responsive.height(8, context),
                                                            width: Responsive.width(20, context),
                                                            decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.all(Radius.circular(10))),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(10),
                                                              child: Image.asset(
                                                                'assets/icons/document_placeholder.png',
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                           Text("Add photo".tr)
                                                        ],
                                                      )),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Visibility(
                                  visible: controller.documents.value.verified == true ? false : true,
                                  child: ButtonThem.buildButton(
                                    context,
                                    title: "Done".tr,
                                    onPress: () {
                                      if (controller.documentNumberController.value.text.isEmpty) {
                                        ShowToastDialog.showToast("Please enter document number".tr);
                                      } else {
                                        if (controller.documentModel.value.frontSide == true && controller.frontImage.value.isEmpty) {
                                          ShowToastDialog.showToast("Please upload front side of document.".tr);
                                        } else if (controller.documentModel.value.backSide == true && controller.backImage.value.isEmpty) {
                                          ShowToastDialog.showToast("Please upload back side of document.".tr);
                                        } else {
                                          ShowToastDialog.showLoader("Please wait..".tr);
                                          controller.uploadDocument();
                                        }
                                      }
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  buildBottomSheet(BuildContext context, DetailsUploadController controller, String type) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SizedBox(
              height: Responsive.height(22, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      "Please Select".tr,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(source: ImageSource.camera, type: type),
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 32,
                                )),
                             Padding(
                              padding: EdgeInsets.only(top: 3),
                              child: Text("Camera".tr),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(source: ImageSource.gallery, type: type),
                                icon: const Icon(
                                  Icons.photo_library_sharp,
                                  size: 32,
                                )),
                             Padding(
                              padding: EdgeInsets.only(top: 3),
                              child: Text("Gallery".tr),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          });
        });
  }
}
