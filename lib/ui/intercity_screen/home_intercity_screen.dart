import 'package:driver/controller/home_intercity_controller.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;

class HomeIntercityScreen extends StatelessWidget {
  const HomeIntercityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<HomeIntercityController>(
        init: HomeIntercityController(),
        dispose: (state) {
          FireStoreUtils().closeStream();
        },
        builder: (controller) {
          return controller.selectedService.value.intercityType == null || controller.selectedService.value.intercityType == false
              ? Scaffold(
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
                          decoration:
                              BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text("Intercity/Outstation feature is disable for ${controller.selectedService.value.title}".tr)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Scaffold(
                  body: controller.widgetOptions.elementAt(controller.selectedIndex.value),
                  bottomNavigationBar: BottomNavigationBar(
                      items: <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                          icon: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Image.asset("assets/icons/ic_new.png", width: 18, color: controller.selectedIndex.value == 0 ? AppColors.darkModePrimary : Colors.white),
                          ),
                          label: 'New'.tr,
                        ),
                        BottomNavigationBarItem(
                          icon: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Image.asset("assets/icons/ic_accepted.png", width: 18, color: controller.selectedIndex.value == 1 ? AppColors.darkModePrimary : Colors.white),
                          ),
                          label: 'Accepted'.tr,
                        ),
                        BottomNavigationBarItem(
                          icon: badges.Badge(
                            badgeContent: Text(controller.isActiveValue.value.toString()),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Image.asset("assets/icons/ic_active.png", width: 18, color: controller.selectedIndex.value == 2 ? AppColors.darkModePrimary : Colors.white),
                            ),
                          ),
                          label: 'Active'.tr,
                        ),
                        BottomNavigationBarItem(
                          icon: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Image.asset("assets/icons/ic_completed.png", width: 18, color: controller.selectedIndex.value == 3 ? AppColors.darkModePrimary : Colors.white),
                          ),
                          label: 'Completed'.tr,
                        ),
                      ],
                      backgroundColor: AppColors.primary,
                      type: BottomNavigationBarType.fixed,
                      currentIndex: controller.selectedIndex.value,
                      selectedItemColor: AppColors.darkModePrimary,
                      unselectedItemColor: Colors.white,
                      selectedFontSize: 12,
                      unselectedFontSize: 12,
                      elevation: 5,
                      onTap: controller.onItemTapped),
                );
        });
  }
}
