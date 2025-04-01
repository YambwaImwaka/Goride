import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/dash_board_controller.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/model/intercity_order_model.dart';
import 'package:driver/model/order/driverId_accept_reject.dart';
import 'package:driver/model/order/location_lat_lng.dart';
import 'package:driver/model/order/positions.dart';
import 'package:driver/ui/freight/accepted_freight_orders.dart';
import 'package:driver/ui/freight/active_freight_order_screen.dart';
import 'package:driver/ui/freight/new_orders_freight_screen.dart';
import 'package:driver/ui/freight/order_freight_screen.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/widget/geoflutterfire/src/geoflutterfire.dart';
import 'package:driver/widget/geoflutterfire/src/models/point.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class FreightController extends GetxController {
  RxInt selectedIndex = 0.obs;
  List<Widget> widgetOptions = <Widget>[const NewOrderFreightScreen(), const AcceptedFreightOrders(), const ActiveFreightOrderScreen(),const OrderFreightScreen()];
  DashBoardController dashboardController = Get.put(DashBoardController());


  Rx<TextEditingController> whenController = TextEditingController().obs;
  Rx<TextEditingController> suggestedTimeController = TextEditingController().obs;
  DateTime? suggestedTime = DateTime.now();
  DateTime? dateAndTime = DateTime.now();
  RxString newAmount = "0.0".obs;
  Rx<TextEditingController> enterOfferRateController = TextEditingController().obs;


  void onItemTapped(int index) {
    selectedIndex.value = index;
  }


  @override
  void onInit() {
    // TODO: implement onInit
    getDriver();
    getActiveRide();
    // getLocation();
    super.onInit();
  }

  acceptOrder(InterCityOrderModel orderModel) async {
    if (double.parse(driverModel.value.walletAmount.toString()) >= double.parse(Constant.minimumAmountToWithdrawal)) {
      ShowToastDialog.showLoader("Please wait".tr);
      List<dynamic> newAcceptedDriverId = [];
      if (orderModel.acceptedDriverId != null) {
        newAcceptedDriverId = orderModel.acceptedDriverId!;
      } else {
        newAcceptedDriverId = [];
      }
      newAcceptedDriverId.add(FireStoreUtils.getCurrentUid());
      orderModel.acceptedDriverId = newAcceptedDriverId;
      orderModel.offerRate = newAmount.value;
      await FireStoreUtils.setInterCityOrder(orderModel);

      DriverIdAcceptReject driverIdAcceptReject = DriverIdAcceptReject(
          driverId: FireStoreUtils.getCurrentUid(),
          acceptedRejectTime: Timestamp.now(),
          offerAmount: newAmount.value,
          suggestedDate: orderModel.whenDates,
          suggestedTime: DateFormat("HH:mm").format(suggestedTime!));
      await FireStoreUtils.getCustomer(orderModel.userId.toString()).then((value) async {
        if (value != null) {
          await SendNotification.sendOneNotification(
              token: value.fcmToken.toString(), title: 'New Bids'.tr, body: 'Driver requested your ride.'.tr, payload: {});
        }
      });

      await FireStoreUtils.acceptInterCityRide(orderModel, driverIdAcceptReject).then((value) async {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Ride Accepted".tr);
        Get.back();
        if (value != null && value == true) {
          if(driverModel.value.subscriptionTotalOrders != "-1"){
            driverModel.value.subscriptionTotalOrders = (int.parse(driverModel.value.subscriptionTotalOrders.toString()) - 1).toString();
            await FireStoreUtils.updateDriverUser(driverModel.value);
            getDriver();
          }
          selectedIndex.value = 1;
        }
      });
    } else {
      ShowToastDialog.showToast(
          "You have to minimum ${Constant.amountShow(amount: Constant.minimumDepositToRideAccept)} wallet amount to Accept Order and place a bid".tr);
    }
  }
  Rx<DriverUserModel> driverModel = DriverUserModel().obs;
  RxBool isLoading = true.obs;

  getDriver() async {
    updateCurrentLocation();
    FireStoreUtils.fireStore.collection(CollectionName.driverUsers).doc(FireStoreUtils.getCurrentUid()).snapshots().listen((event) {
      if (event.exists) {
        driverModel.value = DriverUserModel.fromJson(event.data()!);
      }
    });
  }

  RxInt isActiveValue = 0.obs;

  getActiveRide() {
    FirebaseFirestore.instance
        .collection(CollectionName.ordersIntercity)
        .where('driverId', isEqualTo: FireStoreUtils.getCurrentUid())
        .where('status', whereIn: [Constant.rideInProgress, Constant.rideActive])
        .snapshots()
        .listen((event) {
      isActiveValue.value = event.size;
        });
  }

  Location location = Location();

  updateCurrentLocation() async {
    PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.granted) {
      location.enableBackgroundMode(enable: true);
      location.changeSettings(accuracy: LocationAccuracy.high, distanceFilter: double.parse(Constant.driverLocationUpdate.toString()),interval: 2000);
      location.onLocationChanged.listen((locationData) {
        print("------>");
        print(locationData);
        Constant.currentLocation = LocationLatLng(latitude: locationData.latitude, longitude: locationData.longitude);
        FireStoreUtils.getDriverProfile(FireStoreUtils.getCurrentUid()).then((value) {
          DriverUserModel driverUserModel = value!;
          if (driverUserModel.isOnline == true) {
            driverUserModel.location = LocationLatLng(latitude: locationData.latitude, longitude: locationData.longitude);
            GeoFirePoint position = Geoflutterfire().point(latitude: locationData.latitude!, longitude: locationData.longitude!);

            driverUserModel.position = Positions(geoPoint: position.geoPoint, geohash: position.hash);
            driverUserModel.rotation = locationData.heading;
            FireStoreUtils.updateDriverUser(driverUserModel);
          }
        });
      });
    } else {
      location.requestPermission().then((permissionStatus) {
        if (permissionStatus == PermissionStatus.granted) {
          location.enableBackgroundMode(enable: true);
          location.changeSettings(accuracy: LocationAccuracy.high, distanceFilter: double.parse(Constant.driverLocationUpdate.toString()),interval: 2000);
          location.onLocationChanged.listen((locationData) async {
            Constant.currentLocation = LocationLatLng(latitude: locationData.latitude, longitude: locationData.longitude);

            FireStoreUtils.getDriverProfile(FireStoreUtils.getCurrentUid()).then((value) {
              DriverUserModel driverUserModel = value!;
              if (driverUserModel.isOnline == true) {
                driverUserModel.location = LocationLatLng(latitude: locationData.latitude, longitude: locationData.longitude);
                driverUserModel.rotation = locationData.heading;
                GeoFirePoint position = Geoflutterfire().point(latitude: locationData.latitude!, longitude: locationData.longitude!);

                driverUserModel.position = Positions(geoPoint: position.geoPoint, geohash: position.hash);

                FireStoreUtils.updateDriverUser(driverUserModel);
              }
            });
          });
        }
      });
    }
    isLoading.value = false;
    update();
  }

// Location location = Location();
// RxBool isLocation = false.obs;
//
// getLocation() async {
//   bool serviceEnabled;
//   PermissionStatus permissionGranted;
//
//   serviceEnabled = await location.serviceEnabled();
//   if (!serviceEnabled) {
//     serviceEnabled = await location.requestService();
//     if (!serviceEnabled) {
//       return;
//     }
//   }
//
//   permissionGranted = await location.hasPermission();
//   if (permissionGranted == PermissionStatus.denied) {
//     permissionGranted = await location.requestPermission();
//     if (permissionGranted != PermissionStatus.granted) {
//       return;
//     }
//   }
//
//   await location.getLocation().then((value) {
//     print("location-->${value.toString()}");
//     Constant.currentLocation = value;
//     isLocation.value = true;
//     update();
//   });
// }
}
