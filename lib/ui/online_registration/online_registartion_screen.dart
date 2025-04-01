import 'package:driver/constant/constant.dart';
import 'package:driver/controller/online_registration_controller.dart';
import 'package:driver/model/document_model.dart';
import 'package:driver/model/driver_document_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/ui/online_registration/details_upload_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class OnlineRegistrationScreen extends StatelessWidget {
  const OnlineRegistrationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetBuilder<OnlineRegistrationController>(
        init: OnlineRegistrationController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.primary,
            body: controller.isLoading.value
                ? Constant.loader(context)
                : Column(
                    children: [
                      SizedBox(
                        height: Responsive.width(10, context),
                        width: Responsive.width(100, context),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                          child: controller.isLoading.value
                              ? Constant.loader(context)
                              : Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: ListView.builder(
                                    itemCount: controller.documentList.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      DocumentModel documentModel = controller.documentList[index];
                                      Documents documents = Documents();

                                      var contain = controller.driverDocumentList.where((element) => element.documentId == documentModel.id);
                                      if (contain.isNotEmpty) {
                                        documents = controller.driverDocumentList.firstWhere((itemToCheck) => itemToCheck.documentId == documentModel.id);
                                      }

                                      return InkWell(
                                        onTap: () {
                                          Get.to(const DetailsUploadScreen(), arguments: {'documentModel': documentModel});
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
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(child: Text(Constant.localizationTitle(documentModel.title))),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey)
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Container(
                                                    decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.all(Radius.circular(10))),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                      child: Text(
                                                        documents.verified == true ? "Verified".tr : "Unverified".tr,
                                                        style: const TextStyle(color: Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
          );
        });
  }
}
