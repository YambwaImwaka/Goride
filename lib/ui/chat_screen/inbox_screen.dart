import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/model/inbox_model.dart';
import 'package:driver/model/user_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/ui/chat_screen/chat_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/widget/firebase_pagination/src/firestore_pagination.dart';
import 'package:driver/widget/firebase_pagination/src/models/view_type.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          SizedBox(
            height: Responsive.width(6, context),
            width: Responsive.width(100, context),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
              child: Padding(
                padding: const EdgeInsets.only(top: 10,left: 10,right: 10),
                child: FirestorePagination(
                  //item builder type is compulsory.
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, documentSnapshots, index) {
                    final data = documentSnapshots[index].data() as Map<String, dynamic>?;
                    InboxModel inboxModel = InboxModel.fromJson(data!);
                    return InkWell(
                      onTap: () async {
                        UserModel? customer = await FireStoreUtils.getCustomer(inboxModel.customerId.toString());
                        DriverUserModel? driver = await FireStoreUtils.getDriverProfile(inboxModel.driverId.toString());

                        Get.to(ChatScreens(
                          driverId: driver!.id,
                          customerId: customer!.id,
                          customerName: customer.fullName,
                          customerProfileImage: customer.profilePic,
                          driverName: driver.fullName,
                          driverProfileImage: driver.profilePic,
                          orderId: inboxModel.orderId,
                          token: customer.fcmToken,
                        ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
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
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              leading: ClipOval(
                                child: CachedNetworkImage(
                                    width: 40,
                                    height: 40,
                                    imageUrl: inboxModel.driverProfileImage.toString(),
                                    imageBuilder: (context, imageProvider) => Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          )),
                                        ),
                                    errorWidget: (context, url, error) => ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Image.network(
                                          Constant.userPlaceHolder,
                                          fit: BoxFit.cover,
                                        ))),
                              ),
                              title: Row(
                                children: [
                                  Expanded(child: Text(inboxModel.customerName.toString(),style: GoogleFonts.poppins(fontWeight: FontWeight.w600),)),
                                  Text(Constant.dateFormatTimestamp(inboxModel.createdAt), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400)),
                                ],
                              ),
                              subtitle: Text("Ride Id : #${inboxModel.orderId}".tr),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  shrinkWrap: true,
                  onEmpty:  Center(child: Text("No Conversion found".tr)),
                  // orderBy is compulsory to enable pagination
                  query: FirebaseFirestore.instance.collection(CollectionName.chat).where("driverId", isEqualTo: FireStoreUtils.getCurrentUid()).orderBy('createdAt', descending: true),
                  //Change types customerId
                  viewType: ViewType.list,
                  initialLoader: const CircularProgressIndicator(),
                  // to fetch real-time data
                  isLive: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
