import 'package:driver/constant/constant.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controller/subscrription_history_controller.dart';
import '../../utils/network_image_widget.dart';

class SubscriptionHistory extends StatelessWidget {
  const SubscriptionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: SubscriptionHistoryController(),
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
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                    child: controller.isLoading.value
                        ? Constant.loader(context)
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SingleChildScrollView(
                              child: controller.subscriptionHistoryList.isEmpty
                                  ? SizedBox(
                                      width: Responsive.width(100, context),
                                      height: Responsive.height(80, context),
                                      child: Constant.showEmptyView(message: "Subscription History Not Found.".tr))
                                  : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.subscriptionHistoryList.length,
                                  itemBuilder: (context, index) {
                                    final subscriptionHistoryModel = controller.subscriptionHistoryList[index];
                                    return Container(
                                      margin: const EdgeInsets.only(left: 16, right: 16, top: 20),
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem() ? AppColors.grey900 : AppColors.grey50,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        shadows: const [
                                          BoxShadow(
                                            color: Color(0x07000000),
                                            blurRadius: 20,
                                            offset: Offset(0, 0),
                                            spreadRadius: 0,
                                          )
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      NetworkImageWidget(
                                                        imageUrl: subscriptionHistoryModel.subscriptionPlan?.image ?? '',
                                                        fit: BoxFit.cover,
                                                        width: 45,
                                                        height: 45,
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                        subscriptionHistoryModel.subscriptionPlan?.name ?? '',
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.normal,
                                                          fontSize: 16,
                                                          color: themeChange.getThem() ? AppColors.grey50 : AppColors.grey900,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (index == 0)
                                                    const Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Icon(
                                                          Icons.check_circle_outlined,
                                                          color: Colors.green,
                                                        ),
                                                        SizedBox(width: 5),
                                                        Text(
                                                          'Active',
                                                          textAlign: TextAlign.start,
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 16,
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Divider(color: themeChange.getThem() ? AppColors.grey800 : AppColors.grey100),
                                            const SizedBox(height: 5),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('Validity',
                                                          textAlign: TextAlign.end,
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.normal,
                                                            color: themeChange.getThem() ? AppColors.grey200 : AppColors.grey900,
                                                          )),
                                                      Text(
                                                          subscriptionHistoryModel.subscriptionPlan?.expiryDay == '-1'
                                                              ? "Unlimited"
                                                              : '${subscriptionHistoryModel.subscriptionPlan?.expiryDay ?? '0'}  Days',
                                                          textAlign: TextAlign.end,
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                             fontWeight: FontWeight.w600,
                                                            color: themeChange.getThem() ? AppColors.grey50 : AppColors.grey800,
                                                          )),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('Price',
                                                          textAlign: TextAlign.end,
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.normal,
                                                            color: themeChange.getThem() ? AppColors.grey200 : AppColors.grey900,
                                                          )),
                                                      Text(Constant.amountShow(amount: subscriptionHistoryModel.subscriptionPlan?.price ?? '0'),
                                                          textAlign: TextAlign.end,
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                             fontWeight: FontWeight.w600,
                                                            color: themeChange.getThem() ? AppColors.grey50 : AppColors.grey800,
                                                          )),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('Payment Type',
                                                          textAlign: TextAlign.end,
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.normal,
                                                            color: themeChange.getThem() ? AppColors.grey200 : AppColors.grey900,
                                                          )),
                                                      Text((subscriptionHistoryModel.paymentType ?? '').capitalizeString(),
                                                          textAlign: TextAlign.end,
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                             fontWeight: FontWeight.w600,
                                                            color: themeChange.getThem() ? AppColors.grey50 : AppColors.grey800,
                                                          )),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('Purchase Date',
                                                          textAlign: TextAlign.end,
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.normal,
                                                            color: themeChange.getThem() ? AppColors.grey200 : AppColors.grey900,
                                                          )),
                                                      Text(Constant.timestampToDateTime(subscriptionHistoryModel.subscriptionPlan!.createdAt!),
                                                          textAlign: TextAlign.end,
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                             fontWeight: FontWeight.w600,
                                                            color: themeChange.getThem() ? AppColors.grey50 : AppColors.grey800,
                                                          )),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text('Expiry Date',
                                                          textAlign: TextAlign.end,
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.normal,
                                                            color: themeChange.getThem() ? AppColors.grey200 : AppColors.grey900,
                                                          )),
                                                      Text(subscriptionHistoryModel.expiryDate == null ? "Unlimited" : Constant.timestampToDateTime(subscriptionHistoryModel.expiryDate!),
                                                          textAlign: TextAlign.end,
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                             fontWeight: FontWeight.w600,
                                                            color: themeChange.getThem() ? AppColors.grey50 : AppColors.grey800,
                                                          )),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
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
