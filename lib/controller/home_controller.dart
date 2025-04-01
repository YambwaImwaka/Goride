import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/controller/dash_board_controller.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/model/order/location_lat_lng.dart';
import 'package:driver/model/order/positions.dart';
import 'package:driver/ui/home_screens/accepted_orders.dart';
import 'package:driver/ui/home_screens/active_order_screen.dart';
import 'package:driver/ui/home_screens/new_orders_screen.dart';
import 'package:driver/ui/order_screen/order_screen.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/widget/geoflutterfire/src/geoflutterfire.dart';
import 'package:driver/widget/geoflutterfire/src/models/point.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';

class HomeController extends GetxController {
  RxInt selectedIndex = 0.obs;
  List<Widget> widgetOptions = <Widget>[const NewOrderScreen(), const AcceptedOrders(), const ActiveOrderScreen(),const OrderScreen()];
  DashBoardController dashboardController = Get.put(DashBoardController());

  void onItemTapped(int index) {
    selectedIndex.value = index;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    getDriver();
    getActiveRide();
    super.onInit();
  }

  Rx<DriverUserModel> driverModel = DriverUserModel().obs;
  RxBool isLoading = true.obs;

  getDriver() async {

    FireStoreUtils.fireStore.collection(CollectionName.driverUsers).doc(FireStoreUtils.getCurrentUid()).snapshots().listen((event) {
      if (event.exists) {
        driverModel.value = DriverUserModel.fromJson(event.data()!);
      }
    });
    updateCurrentLocation();
  }

  RxInt isActiveValue = 0.obs;

  getActiveRide() {
    FirebaseFirestore.instance
        .collection(CollectionName.orders)
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

}
