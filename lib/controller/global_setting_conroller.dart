import 'dart:convert';
import 'dart:developer';

import 'package:driver/constant/constant.dart';
import 'package:driver/model/currency_model.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/model/language_model.dart';
import 'package:driver/services/localization_service.dart';
import 'package:driver/utils/Preferences.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/utils/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class GlobalSettingController extends GetxController {
  RxBool isLoading = true.obs;
  @override
  void onInit() {
    // TODO: implement onInit
    notificationInit();
    getCurrentCurrency();
    super.onInit();
  }

  getCurrentCurrency() async {
    if (Preferences.getString(Preferences.languageCodeKey).toString().isNotEmpty) {
      LanguageModel languageModel = Constant.getLanguage();
      LocalizationService().changeLocale(languageModel.code.toString());
    } else {
      await FireStoreUtils.getLanguage().then((value) {
        if (value != null) {
          List<LanguageModel> languageList = value;
          if(languageList.where((element) => element.isDefault == true).isNotEmpty){
            LanguageModel languageModel = languageList.firstWhere((element) => element.isDefault == true);
            Preferences.setString(Preferences.languageCodeKey, jsonEncode(languageModel));
            LocalizationService().changeLocale(languageModel.code.toString());
          }
        }
      });
    }

    await FireStoreUtils().getCurrency().then((value) {
      if (value != null) {
        Constant.currencyModel = value;
      } else {
        Constant.currencyModel =
            CurrencyModel(id: "", code: "USD", decimalDigits: 2, enable: true, name: "US Dollar", symbol: "\$", symbolAtRight: false);
      }
    });

     FireStoreUtils().getGoogleAPIKey();


    isLoading.value = false;
    update();
  }

  NotificationService notificationService = NotificationService();

  notificationInit() {
    notificationService.initInfo().then((value) async {
      String token = await NotificationService.getToken();
      log(":::::::TOKEN:::::: $token");

      if (FirebaseAuth.instance.currentUser != null) {
        await FireStoreUtils.getDriverProfile(FireStoreUtils.getCurrentUid()).then((value) {
          if (value != null) {
            DriverUserModel driverUserModel = value;
            driverUserModel.fcmToken = token;
            FireStoreUtils.updateDriverUser(driverUserModel);
          }
        });
      }
    });
  }
}
