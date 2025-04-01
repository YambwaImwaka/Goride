import 'package:driver/constant/constant.dart';
import 'package:driver/model/withdraw_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WithDrawHistoryScreen extends StatelessWidget {
  const WithDrawHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

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
            height: Responsive.width(10, context),
            width: Responsive.width(100, context),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                child: FutureBuilder<List<WithdrawModel>?>(
                    future: FireStoreUtils.getWithDrawRequest(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Constant.loader(context);
                        case ConnectionState.done:
                          if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          } else {
                            return snapshot.data!.isEmpty
                                ?  Center(child: Text("No transaction found".tr))
                                : ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      WithdrawModel walletTransactionModel = snapshot.data![index];
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
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                      decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(50)),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(12.0),
                                                        child: SvgPicture.asset(
                                                          'assets/icons/ic_wallet.svg',
                                                          width: 24,
                                                          color: Colors.black,
                                                        ),
                                                      )),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                DateFormat('KK:mm:ss a, dd MMM yyyy').format(walletTransactionModel.createdDate!.toDate()).toUpperCase(),
                                                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                                              ),
                                                            ),
                                                            Text(
                                                              "- ${Constant.amountShow(amount: walletTransactionModel.amount.toString().replaceAll("-", ""))}",
                                                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.red),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                walletTransactionModel.note.toString(),
                                                                style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
                                                              ),
                                                            ),
                                                            Text(
                                                              walletTransactionModel.paymentStatus.toString().toUpperCase(),
                                                              style: GoogleFonts.poppins(
                                                                  fontWeight: FontWeight.w400, color: walletTransactionModel.paymentStatus == "approved" ? Colors.green : Colors.red),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                      );
                                    },
                                  );
                          }
                        default:
                          return  Text('Error'.tr);
                      }
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
