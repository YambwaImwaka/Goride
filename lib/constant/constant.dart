import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/model/ChatVideoContainer.dart';
import 'package:driver/model/admin_commission.dart';
import 'package:driver/model/conversation_model.dart';
import 'package:driver/model/currency_model.dart';
import 'package:driver/model/language_description.dart';
import 'package:driver/model/language_model.dart';
import 'package:driver/model/language_name.dart';
import 'package:driver/model/language_privacy_policy.dart';
import 'package:driver/model/language_terms_condition.dart';
import 'package:driver/model/language_title.dart';
import 'package:driver/model/map_model.dart' as mapModels;
import 'package:driver/model/order/location_lat_lng.dart';
import 'package:driver/model/tax_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/Preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class Constant {
  static const String phoneLoginType = "phone";
  static const String googleLoginType = "google";
  static const String appleLoginType = "apple";
  static LocationLatLng? currentLocation;

  static String mapAPIKey = "";
  static String senderId = '';
  static String jsonNotificationFileURL = '';
  static String radius = "";
  static String distanceType = "";
  static String minimumAmountToWithdrawal = "0.0";
  static String minimumDepositToRideAccept = "0.0";
  static List<LanguageTermsCondition> termsAndConditions = [];
  static List<LanguagePrivacyPolicy> privacyPolicy = [];
  static String? supportURL = "";
  static String appVersion = "";
  static bool isVerifyDocument = false;
  static bool isSubscriptionModelApplied = false;
  static AdminCommission? adminCommission;
  static const commissionSubscriptionID = "J0RwvxCWhZzQQD7Kc2Ll";


  static String mapType = "google";
  static String selectedMapType = 'osm';
  static String driverLocationUpdate = "10";

  static CurrencyModel? currencyModel;

  static const String ridePlaced = "Ride Placed";
  static const String rideActive = "Ride Active";
  static const String rideInProgress = "Ride InProgress";
  static const String rideComplete = "Ride Completed";
  static const String rideCanceled = "Ride Canceled";

  static String? referralAmount = "0";

  static const globalUrl = "https://goride.siswebapp.com/";

  static const userPlaceHolder =
      "https://firebasestorage.googleapis.com/v0/b/goride-1a752.appspot.com/o/placeholderImages%2Fuser-placeholder.jpeg?alt=media&token=34a73d67-ba1d-4fe4-a29f-271d3e3ca115";

  static Widget loader(BuildContext context) {
    // final themeChange = Provider.of<DarkThemeProvider>(context);
    return const Center(
      child: CircularProgressIndicator(color: AppColors.darkModePrimary),
    );
  }



  static String localizationName(List<LanguageName>? name) {
    if (name!.firstWhere((element) => element.type == Constant.getLanguage().code).name!.isNotEmpty) {
      return name.firstWhere((element) => element.type == Constant.getLanguage().code).name!;
    } else {
      return name.firstWhere((element) => element.type == "en").name.toString();
    }
  }

  static String localizationTitle(List<LanguageTitle>? name) {
    if (name!.firstWhere((element) => element.type == Constant.getLanguage().code).title!.isNotEmpty) {
      return name.firstWhere((element) => element.type == Constant.getLanguage().code).title!;
    } else {
      return name.firstWhere((element) => element.type == "en").title.toString();
    }
  }

  static String localizationDescription(List<LanguageDescription>? name) {
    if (name!.firstWhere((element) => element.type == Constant.getLanguage().code).description!.isNotEmpty) {
      return name.firstWhere((element) => element.type == Constant.getLanguage().code).description!;
    } else {
      return name.firstWhere((element) => element.type == "en").description.toString();
    }
  }

  static String timestampToDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM dd,yyyy hh:mm aa').format(dateTime);
  }

  static Widget showEmptyView({required String message}) {
    return Center(
      child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red,fontWeight: FontWeight.w600, fontSize: 18)),
    );
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  static String localizationPrivacyPolicy(List<LanguagePrivacyPolicy>? name) {
    if (name!.firstWhere((element) => element.type == Constant.getLanguage().code).privacyPolicy!.isNotEmpty) {
      return name.firstWhere((element) => element.type == Constant.getLanguage().code).privacyPolicy!;
    } else {
      return name.firstWhere((element) => element.type == "en").privacyPolicy.toString();
    }
  }

  static String localizationTermsCondition(List<LanguageTermsCondition>? name) {
    if (name!.firstWhere((element) => element.type == Constant.getLanguage().code).termsAndConditions!.isNotEmpty) {
      return name.firstWhere((element) => element.type == Constant.getLanguage().code).termsAndConditions!;
    } else {
      return name.firstWhere((element) => element.type == "en").termsAndConditions.toString();
    }
  }

  static Future<mapModels.MapModel?> getDurationDistance(LatLng departureLatLong, LatLng destinationLatLong) async {
    String url = 'https://maps.googleapis.com/maps/api/distancematrix/json';
    http.Response restaurantToCustomerTime = await http.get(Uri.parse('$url?units=metric&origins=${departureLatLong.latitude},'
        '${departureLatLong.longitude}&destinations=${destinationLatLong.latitude},${destinationLatLong.longitude}&key=${Constant.mapAPIKey}'));
    mapModels.MapModel mapModel = mapModels.MapModel.fromJson(jsonDecode(restaurantToCustomerTime.body));

    if (mapModel.status == 'OK' && mapModel.rows!.first.elements!.first.status == "OK") {
      return mapModel;
    } else {
      ShowToastDialog.showToast(mapModel.errorMessage);
    }
    return null;
  }

  static double amountCalculate(String amount, String distance) {
    double finalAmount = 0.0;
    finalAmount = double.parse(amount) * double.parse(distance);
    return finalAmount;
  }

  static bool? validateEmail(String? value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value ?? '')) {
      return false;
    } else {
      return true;
    }
  }

  static Future<String> uploadUserImageToFireStorage(File image, String filePath, String fileName) async {
    Reference upload = FirebaseStorage.instance.ref().child('$filePath/$fileName');
    UploadTask uploadTask = upload.putFile(image);
    var downloadUrl = await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  bool hasValidUrl(String value) {
    String pattern = r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return false;
    } else if (!regExp.hasMatch(value)) {
      return false;
    }
    return true;
  }

  static Future<DateTime?> selectFetureDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2200),
      builder: (context, child) {
        final themeChange = Provider.of<DarkThemeProvider>(context);
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
            colorScheme: ColorScheme.light(primary: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      return pickedDate;
    }
    return null;
  }

  static Future<DateTime?> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final themeChange = Provider.of<DarkThemeProvider>(context);
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary,
            colorScheme: ColorScheme.light(primary: themeChange.getThem() ? AppColors.darkModePrimary : AppColors.primary),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      return pickedDate;
    }
    return null;
  }

  double calculateTax({String? amount, TaxModel? taxModel}) {
    double taxAmount = 0.0;
    if (taxModel != null && taxModel.enable == true) {
      if (taxModel.type == "fix") {
        taxAmount = double.parse(taxModel.tax.toString());
      } else {
        taxAmount = (double.parse(amount.toString()) * double.parse(taxModel.tax!.toString())) / 100;
      }
    }
    return taxAmount;
  }

  static double calculateAdminCommission({String? amount, AdminCommission? adminCommission}) {
    double taxAmount = 0.0;
    if (adminCommission != null) {
      if (adminCommission.type == "fix") {
        taxAmount = double.parse(adminCommission.amount.toString());
      } else {
        taxAmount = (double.parse(amount.toString()) * double.parse(adminCommission.amount!.toString())) / 100;
      }
    }
    return taxAmount;
  }

  String formatTimestamp(Timestamp? timestamp) {
    var format = DateFormat('dd-MM-yyyy hh:mm aa'); // <- use skeleton here
    return format.format(timestamp!.toDate());
  }

  static String getUuid() {
    return const Uuid().v4();
  }

  static String dateFormatTimestamp(Timestamp? timestamp) {
    var format = DateFormat('dd MMM yyyy'); // <- use skeleton here
    return format.format(timestamp!.toDate());
  }

  static String dateAndTimeFormatTimestamp(Timestamp? timestamp) {
    var format = DateFormat('dd MMM yyyy hh:mm aa'); // <- use skeleton here
    return format.format(timestamp!.toDate());
  }

  static bool IsNegative(double number) {
    return number < 0;
  }

  static String calculateReview({required String? reviewCount, required String? reviewSum}) {
    if (reviewCount == "0.0" && reviewSum == "0.0") {
      return "0.0";
    }

    return (double.parse(reviewSum.toString()) / double.parse(reviewCount.toString())).toStringAsFixed(Constant.currencyModel!.decimalDigits!);
  }

  static String amountShow({required String? amount}) {
    if (Constant.currencyModel!.symbolAtRight == true) {
      return "${double.parse(amount.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} ${Constant.currencyModel!.symbol.toString()}";
    } else {
      return "${Constant.currencyModel!.symbol.toString()} ${double.parse(amount.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)}";
    }
  }

  static LanguageModel getLanguage() {
    final String user = Preferences.getString(Preferences.languageCodeKey);
    Map<String, dynamic> userMap = jsonDecode(user);
    return LanguageModel.fromJson(userMap);
  }

  Future<Url> uploadChatImageToFireStorage(File image) async {
    ShowToastDialog.showLoader('Uploading image...');
    var uniqueID = const Uuid().v4();
    Reference upload = FirebaseStorage.instance.ref().child('/chat/images/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(image);
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    ShowToastDialog.closeLoader();
    return Url(mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  Future<ChatVideoContainer?> uploadChatVideoToFireStorage(File video) async {
    try {
      ShowToastDialog.showLoader("Uploading video...");
      final String uniqueID = const Uuid().v4();
      final Reference videoRef = FirebaseStorage.instance.ref('videos/$uniqueID.mp4');
      final UploadTask uploadTask = videoRef.putFile(
        video,
        SettableMetadata(contentType: 'video/mp4'),
      );
      await uploadTask;
      final String videoUrl = await videoRef.getDownloadURL();
      ShowToastDialog.showLoader("Generating thumbnail...");
      final Uint8List? thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: video.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        maxWidth: 200,
        quality: 75,
      );

      if (thumbnailBytes == null || thumbnailBytes.isEmpty) {
        throw Exception("Failed to generate thumbnail.");
      }

      final String thumbnailID = const Uuid().v4();
      final Reference thumbnailRef = FirebaseStorage.instance.ref('thumbnails/$thumbnailID.jpg');
      final UploadTask thumbnailUploadTask = thumbnailRef.putData(
        thumbnailBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      await thumbnailUploadTask;
      final String thumbnailUrl = await thumbnailRef.getDownloadURL();
      var metaData = await thumbnailRef.getMetadata();
      ShowToastDialog.closeLoader();

      return ChatVideoContainer(videoUrl: Url(url: videoUrl.toString(), mime: metaData.contentType ?? 'video', videoThumbnail: thumbnailUrl), thumbnailUrl: thumbnailUrl);
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error: ${e.toString()}");
      return null;
    }
  }

  Future<String> uploadVideoThumbnailToFireStorage(File file) async {
    var uniqueID = const Uuid().v4();
    Reference upload = FirebaseStorage.instance.ref().child('/thumbnails/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(file);
    var downloadUrl = await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Timestamp? addDayInTimestamp({required String? days, required Timestamp date}) {
    if (days?.isNotEmpty == true && days != '0') {
      Timestamp now = date;
      DateTime dateTime = now.toDate();
      DateTime newDateTime = dateTime.add(Duration(days: int.parse(days!)));
      Timestamp newTimestamp = Timestamp.fromDate(newDateTime);
      return newTimestamp;
    } else {
      return null;
    }
  }

}
extension StringExtension on String {
  String capitalizeString() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

