import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/bank_details_controller.dart';
import 'package:driver/model/bank_details_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/themes/text_field_them.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class BankDetailsScreen extends StatelessWidget {
  const BankDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<BankDetailsController>(
        init: BankDetailsController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.primary,
            body: Column(
              children: [
                SizedBox(
                  height: Responsive.width(12, context),
                  width: Responsive.width(100, context),
                ),
                Expanded(
                  child: Container(
                    height: Responsive.height(100, context),
                    width: Responsive.width(100, context),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                    child: controller.isLoading.value
                        ? Constant.loader(context)
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Bank Name".tr, style: GoogleFonts.poppins()),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  TextFieldThem.buildTextFiled(context, hintText: 'Bank Name'.tr, controller: controller.bankNameController.value),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text("Branch Name".tr, style: GoogleFonts.poppins()),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  TextFieldThem.buildTextFiled(context, hintText: 'Branch Name'.tr, controller: controller.branchNameController.value),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text("Holder Name".tr, style: GoogleFonts.poppins()),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  TextFieldThem.buildTextFiled(context, hintText: 'Holder Name'.tr, controller: controller.holderNameController.value),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text("Account Number".tr, style: GoogleFonts.poppins()),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  TextFieldThem.buildTextFiled(context, hintText: 'Account Number'.tr, controller: controller.accountNumberController.value),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text("Other Information".tr, style: GoogleFonts.poppins()),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  TextFieldThem.buildTextFiled(context, hintText: 'Other Information'.tr, controller: controller.otherInformationController.value),
                                  const SizedBox(
                                    height: 40,
                                  ),
                                  ButtonThem.buildButton(
                                    context,
                                    title: "Save".tr,
                                    onPress: () async {
                                      if (controller.bankNameController.value.text.isEmpty) {
                                        ShowToastDialog.showToast("Please enter bank name".tr);
                                      } else if (controller.branchNameController.value.text.isEmpty) {
                                        ShowToastDialog.showToast("Please enter branch name".tr);
                                      } else if (controller.holderNameController.value.text.isEmpty) {
                                        ShowToastDialog.showToast("Please enter holder name".tr);
                                      } else if (controller.accountNumberController.value.text.isEmpty) {
                                        ShowToastDialog.showToast("Please enter account number".tr);
                                      } else {
                                        ShowToastDialog.showLoader("Please wait".tr);
                                        BankDetailsModel bankDetailsModel = controller.bankDetailsModel.value;

                                        bankDetailsModel.userId = FireStoreUtils.getCurrentUid();
                                        bankDetailsModel.bankName = controller.bankNameController.value.text;
                                        bankDetailsModel.branchName = controller.branchNameController.value.text;
                                        bankDetailsModel.holderName = controller.holderNameController.value.text;
                                        bankDetailsModel.accountNumber = controller.accountNumberController.value.text;
                                        bankDetailsModel.otherInformation = controller.otherInformationController.value.text;

                                        await FireStoreUtils.updateBankDetails(bankDetailsModel).then((value) {
                                          ShowToastDialog.closeLoader();
                                          ShowToastDialog.showToast("Bank details update successfully".tr);
                                        });
                                      }
                                    },
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
}
