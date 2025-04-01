import 'package:driver/lang/app_ar.dart';
import 'package:driver/lang/app_en.dart';
import 'package:driver/lang/app_fr.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalizationService extends Translations {
  // Default locale
  static const locale = Locale('en', 'US');

  static final locales = [
    const Locale('en'),
    const Locale('ar'),
    const Locale('fr'),
  ];

  // Keys and their translations
  // Translations are separated maps in `lang` file
  @override
  Map<String, Map<String, String>> get keys => {
        'en': enUS,
        'ar': arAR,
        'fr': trFr,
      };

  // Gets locale from language, and updates the locale
  void changeLocale(String lang) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.updateLocale(Locale(lang));
    });
  }
}
