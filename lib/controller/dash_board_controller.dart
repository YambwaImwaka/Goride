import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/ui/auth_screen/login_screen.dart';
import 'package:driver/ui/bank_details/bank_details_screen.dart';
import 'package:driver/ui/chat_screen/inbox_screen.dart';
import 'package:driver/ui/freight/freight_screen.dart';
import 'package:driver/ui/home_screens/home_screen.dart';
import 'package:driver/ui/intercity_screen/home_intercity_screen.dart';
import 'package:driver/ui/online_registration/online_registartion_screen.dart';
import 'package:driver/ui/profile_screen/profile_screen.dart';
import 'package:driver/ui/settings_screen/setting_screen.dart';
import 'package:driver/ui/subscription_plan_screen/subscription_history.dart';
import 'package:driver/ui/subscription_plan_screen/subscription_list_screen.dart';
import 'package:driver/ui/vehicle_information/vehicle_information_screen.dart';
import 'package:driver/ui/wallet/wallet_screen.dart';
import 'package:driver/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class DashBoardController extends GetxController {
  RxList<DrawerItem> drawerItems = <DrawerItem>[].obs;

  getDrawerItemWidget(int pos) {
    if(Constant.isSubscriptionModelApplied == true){
      switch (pos) {
        case 0:
          return const HomeScreen();
      // case 1:
      //   return const OrderScreen();
        case 1:
          return const HomeIntercityScreen();
      // case 2:
      //   return const OrderIntercityScreen();
        case 2:
          return const FreightScreen();
        case 3:
          return const WalletScreen();
        case 4:
          return const BankDetailsScreen();
        case 5:
          return const InboxScreen();
        case 6:
          return const ProfileScreen();
        case 7:
          return const OnlineRegistrationScreen();
        case 8:
          return const VehicleInformationScreen();
        case 9:
          return const SettingScreen();
        case 10:
          return const SubscriptionListScreen();
        case 11:
          return const SubscriptionHistory();
        default:
          return const Text("Error");
      }
    }else{
      switch (pos) {
        case 0:
          return const HomeScreen();
      // case 1:
      //   return const OrderScreen();
        case 1:
          return const HomeIntercityScreen();
      // case 2:
      //   return const OrderIntercityScreen();
        case 2:
          return const FreightScreen();
        case 3:
          return const WalletScreen();
        case 4:
          return const BankDetailsScreen();
        case 5:
          return const InboxScreen();
        case 6:
          return const ProfileScreen();
        case 7:
          return const OnlineRegistrationScreen();
        case 8:
          return const VehicleInformationScreen();
        case 9:
          return const SettingScreen();
        case 10:
          return const SubscriptionHistory();
        default:
          return const Text("Error");
      }
    }
  }

  RxInt selectedDrawerIndex = 0.obs;

  onSelectItem(int index) async {
    if(Constant.isSubscriptionModelApplied == true){
      if (index == 12) {
        await FirebaseAuth.instance.signOut();
        Get.offAll(const LoginScreen());
      } else {
        selectedDrawerIndex.value = index;
      }
    }else{
      if (index == 11) {
        await FirebaseAuth.instance.signOut();
        Get.offAll(const LoginScreen());
      } else {
        selectedDrawerIndex.value = index;
      }
    }

    Get.back();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    setDrawerList();
    getLocation();
    super.onInit();
  }

  setDrawerList(){
    if(Constant.isSubscriptionModelApplied == true){
      drawerItems.value = [
        DrawerItem('City'.tr, "assets/icons/ic_city.svg"),
        // DrawerItem('Rides'.tr, "assets/icons/ic_order.svg"),
        DrawerItem('OutStation'.tr, "assets/icons/ic_intercity.svg"),
        // DrawerItem('OutStation Rides'.tr, "assets/icons/ic_order.svg"),
        DrawerItem('Freight'.tr, "assets/icons/ic_freight.svg"),
        DrawerItem('My Wallet'.tr, "assets/icons/ic_wallet.svg"),
        DrawerItem('Bank Details'.tr, "assets/icons/ic_profile.svg"),
        DrawerItem('Inbox'.tr, "assets/icons/ic_inbox.svg"),
        DrawerItem('Profile'.tr, "assets/icons/ic_profile.svg"),
        DrawerItem('Online Registration'.tr, "assets/icons/ic_document.svg"),
        DrawerItem('Vehicle Information'.tr, "assets/icons/ic_city.svg"),
        DrawerItem('Settings'.tr, "assets/icons/ic_settings.svg"),
        DrawerItem('Subscription'.tr, "assets/icons/ic_subscription.svg"),
        DrawerItem('Subscription History'.tr, "assets/icons/ic_subscription_history.svg"),
        DrawerItem('Log out'.tr, "assets/icons/ic_logout.svg"),
      ];
    }else{
      drawerItems.value = [
        DrawerItem('City'.tr, "assets/icons/ic_city.svg"),
        // DrawerItem('Rides'.tr, "assets/icons/ic_order.svg"),
        DrawerItem('OutStation'.tr, "assets/icons/ic_intercity.svg"),
        // DrawerItem('OutStation Rides'.tr, "assets/icons/ic_order.svg"),
        DrawerItem('Freight'.tr, "assets/icons/ic_freight.svg"),
        DrawerItem('My Wallet'.tr, "assets/icons/ic_wallet.svg"),
        DrawerItem('Bank Details'.tr, "assets/icons/ic_profile.svg"),
        DrawerItem('Inbox'.tr, "assets/icons/ic_inbox.svg"),
        DrawerItem('Profile'.tr, "assets/icons/ic_profile.svg"),
        DrawerItem('Online Registration'.tr, "assets/icons/ic_document.svg"),
        DrawerItem('Vehicle Information'.tr, "assets/icons/ic_city.svg"),
        DrawerItem('Settings'.tr, "assets/icons/ic_settings.svg"),
        DrawerItem('Subscription History'.tr, "assets/icons/ic_subscription_history.svg"),
        DrawerItem('Log out'.tr, "assets/icons/ic_logout.svg"),
      ];
    }
  }

  getLocation() async {
    await Utils.determinePosition();
  }

  Rx<DateTime> currentBackPressTime = DateTime.now().obs;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime.value) > const Duration(seconds: 2)) {
      currentBackPressTime.value = now;
      ShowToastDialog.showToast("Double press to exit", position: EasyLoadingToastPosition.center);
      return Future.value(false);
    }
    return Future.value(true);
  }
}

class DrawerItem {
  String title;
  String icon;

  DrawerItem(this.title, this.icon);
}
