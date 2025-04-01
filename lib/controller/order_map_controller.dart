import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart' as cloudFirestore;
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/model/order/driverId_accept_reject.dart';
import 'package:driver/model/order_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart' as prefix;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderMapController extends GetxController {
  final Completer<GoogleMapController> mapController = Completer<GoogleMapController>();
  Rx<TextEditingController> enterOfferRateController = TextEditingController().obs;

  RxBool isLoading = true.obs;

  @override
  void onInit() {
    if (Constant.selectedMapType == 'osm') {
      ShowToastDialog.showLoader("Please wait");
      mapOsmController = MapController(initPosition: GeoPoint(latitude: 20.9153, longitude: -100.7439), useExternalTracking: false); //OSM
    }
    addMarkerSetup();
    getArgument();

    super.onInit();
  }

  @override
  void onClose() {
    ShowToastDialog.closeLoader();
    super.onClose();
  }

  acceptOrder() async {
    if (double.parse(driverModel.value.walletAmount.toString()) >= double.parse(Constant.minimumDepositToRideAccept)) {
      ShowToastDialog.showLoader("Please wait".tr);
      List<dynamic> newAcceptedDriverId = [];
      if (orderModel.value.acceptedDriverId != null) {
        newAcceptedDriverId = orderModel.value.acceptedDriverId!;
      } else {
        newAcceptedDriverId = [];
      }
      newAcceptedDriverId.add(FireStoreUtils.getCurrentUid());
      orderModel.value.acceptedDriverId = newAcceptedDriverId;
      // orderModel.value.offerRate = newAmount.value;
      await FireStoreUtils.setOrder(orderModel.value);

      await FireStoreUtils.getCustomer(orderModel.value.userId.toString()).then((value) async {
        if (value != null) {
          await SendNotification.sendOneNotification(
              token: value.fcmToken.toString(),
              title: 'New Driver Bid'.tr,
              body: 'Driver has offered ${Constant.amountShow(amount: newAmount.value)} for your journey.🚗'.tr,
              payload: {});
        }
      });

      DriverIdAcceptReject driverIdAcceptReject =
          DriverIdAcceptReject(driverId: FireStoreUtils.getCurrentUid(), acceptedRejectTime: cloudFirestore.Timestamp.now(), offerAmount: newAmount.value);
      FireStoreUtils.acceptRide(orderModel.value, driverIdAcceptReject).then((value) async {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Ride Accepted".tr);
        if(driverModel.value.subscriptionTotalOrders != "-1"){
          driverModel.value.subscriptionTotalOrders = (int.parse(driverModel.value.subscriptionTotalOrders.toString()) - 1).toString();
          await FireStoreUtils.updateDriverUser(driverModel.value);
        }
        Get.back(result: true);
      });
    } else {
      ShowToastDialog.showToast(
          "You have to minimum ${Constant.amountShow(amount: Constant.minimumDepositToRideAccept.toString())} wallet amount to Accept Order and place a bid".tr);
    }
  }

  Rx<OrderModel> orderModel = OrderModel().obs;
  Rx<DriverUserModel> driverModel = DriverUserModel().obs;

  RxString newAmount = "0.0".obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      String orderId = argumentData['orderModel'];
      await getData(orderId);
      newAmount.value = orderModel.value.offerRate.toString();
      enterOfferRateController.value.text = orderModel.value.offerRate.toString();
      if (Constant.selectedMapType == 'google') {
        getPolyline();
      }
    }

    FireStoreUtils.fireStore.collection(CollectionName.driverUsers).doc(FireStoreUtils.getCurrentUid()).snapshots().listen((event) {
      if (event.exists) {
        driverModel.value = DriverUserModel.fromJson(event.data()!);
      }
    });
    isLoading.value = false;
  }

  getData(String id) async {
    await FireStoreUtils.getOrder(id).then((value) {
      if (value != null) {
        orderModel.value = value;
      }
    });
  }

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;

  addMarkerSetup() async {
    if (Constant.selectedMapType == 'google') {
      final Uint8List departure = await Constant().getBytesFromAsset('assets/images/pickup.png', 100);
      final Uint8List destination = await Constant().getBytesFromAsset('assets/images/dropoff.png', 100);
      departureIcon = BitmapDescriptor.fromBytes(departure);
      destinationIcon = BitmapDescriptor.fromBytes(destination);
    } else {
      departureOsmIcon = Image.asset("assets/images/pickup.png", width: 30, height: 30); //OSM
      destinationOsmIcon = Image.asset("assets/images/dropoff.png", width: 30, height: 30); //OSM
    }
  }

  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;
  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  PolylinePoints polylinePoints = PolylinePoints();

  void getPolyline() async {
    if (orderModel.value.sourceLocationLAtLng != null && orderModel.value.destinationLocationLAtLng != null) {
      movePosition();
      List<LatLng> polylineCoordinates = [];
      PolylineRequest polylineRequest = PolylineRequest(
        origin: PointLatLng(orderModel.value.sourceLocationLAtLng!.latitude ?? 0.0, orderModel.value.sourceLocationLAtLng!.longitude ?? 0.0),
        destination: PointLatLng(orderModel.value.destinationLocationLAtLng!.latitude ?? 0.0, orderModel.value.destinationLocationLAtLng!.longitude ?? 0.0),
        mode: TravelMode.driving,
      );
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: Constant.mapAPIKey,
        request: polylineRequest,
      );
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        print(result.errorMessage.toString());
      }
      _addPolyLine(polylineCoordinates);
      addMarker(LatLng(orderModel.value.sourceLocationLAtLng!.latitude ?? 0.0, orderModel.value.sourceLocationLAtLng!.longitude ?? 0.0), "Source", departureIcon);
      addMarker(LatLng(orderModel.value.destinationLocationLAtLng!.latitude ?? 0.0, orderModel.value.destinationLocationLAtLng!.longitude ?? 0.0), "Destination", destinationIcon);
    }
  }

  double zoomLevel = 0;

  movePosition() async {
    double distance = double.parse((prefix.Geolocator.distanceBetween(
              orderModel.value.sourceLocationLAtLng!.latitude ?? 0.0,
              orderModel.value.sourceLocationLAtLng!.longitude ?? 0.0,
              orderModel.value.destinationLocationLAtLng!.latitude ?? 0.0,
              orderModel.value.destinationLocationLAtLng!.longitude ?? 0.0,
            ) /
            1609.32)
        .toString());
    LatLng center = LatLng(
      (orderModel.value.sourceLocationLAtLng!.latitude! + orderModel.value.destinationLocationLAtLng!.latitude!) / 2,
      (orderModel.value.sourceLocationLAtLng!.longitude! + orderModel.value.destinationLocationLAtLng!.longitude!) / 2,
    );

    double radiusElevated = (distance / 2) + ((distance / 2) / 2);
    double scale = radiusElevated / 500;

    zoomLevel = 5 - log(scale) / log(2);

    final GoogleMapController controller = await mapController.future;
    controller.moveCamera(CameraUpdate.newLatLngZoom(center, zoomLevel));
  }

  _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      width: 6,
    );
    polyLines[id] = polyline;
  }

  addMarker(LatLng? position, String id, BitmapDescriptor? descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(markerId: markerId, icon: descriptor!, position: position!);
    markers[markerId] = marker;
  }

  //OSM
  late MapController mapOsmController;
  Rx<RoadInfo> roadInfo = RoadInfo().obs;
  Map<String, GeoPoint> osmMarkers = <String, GeoPoint>{};
  Image? departureOsmIcon; //OSM
  Image? destinationOsmIcon; //OSM

  void getOSMPolyline(themeChange) async {
    try {
      if (orderModel.value.sourceLocationLAtLng != null && orderModel.value.destinationLocationLAtLng != null) {
        setOsmMarker(
          departure: GeoPoint(latitude: orderModel.value.sourceLocationLAtLng?.latitude ?? 0.0, longitude: orderModel.value.sourceLocationLAtLng?.longitude ?? 0.0),
          destination: GeoPoint(latitude: orderModel.value.destinationLocationLAtLng?.latitude ?? 0.0, longitude: orderModel.value.destinationLocationLAtLng?.longitude ?? 0.0),
        );
        await mapOsmController.removeLastRoad();
        roadInfo.value = await mapOsmController.drawRoad(
          GeoPoint(latitude: orderModel.value.sourceLocationLAtLng?.latitude ?? 0, longitude: orderModel.value.sourceLocationLAtLng?.longitude ?? 0),
          GeoPoint(latitude: orderModel.value.destinationLocationLAtLng?.latitude ?? 0, longitude: orderModel.value.destinationLocationLAtLng?.longitude ?? 0),
          roadType: RoadType.car,
          roadOption: RoadOption(
            roadWidth: 15,
            roadColor: themeChange ? AppColors.darkModePrimary : AppColors.primary,
            zoomInto: false,
          ),
        );

        updateCameraLocation(
            source: GeoPoint(latitude: orderModel.value.sourceLocationLAtLng?.latitude ?? 0, longitude: orderModel.value.sourceLocationLAtLng?.longitude ?? 0),
            destination: GeoPoint(latitude: orderModel.value.destinationLocationLAtLng?.latitude ?? 0, longitude: orderModel.value.destinationLocationLAtLng?.longitude ?? 0));
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> updateCameraLocation({required GeoPoint source, required GeoPoint destination}) async {
    BoundingBox bounds;

    if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
      bounds = BoundingBox(
        north: source.latitude,
        south: destination.latitude,
        east: source.longitude,
        west: destination.longitude,
      );
    } else if (source.longitude > destination.longitude) {
      bounds = BoundingBox(
        north: destination.latitude,
        south: source.latitude,
        east: source.longitude,
        west: destination.longitude,
      );
    } else if (source.latitude > destination.latitude) {
      bounds = BoundingBox(
        north: source.latitude,
        south: destination.latitude,
        east: destination.longitude,
        west: source.longitude,
      );
    } else {
      bounds = BoundingBox(
        north: destination.latitude,
        south: source.latitude,
        east: destination.longitude,
        west: source.longitude,
      );
    }

    await mapOsmController.zoomToBoundingBox(bounds, paddinInPixel: 300);
  }

  setOsmMarker({required GeoPoint departure, required GeoPoint destination}) async {
    if (osmMarkers.containsKey('Source')) {
      await mapOsmController.removeMarker(osmMarkers['Source']!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await mapOsmController
          .addMarker(departure,
              markerIcon: MarkerIcon(iconWidget: departureOsmIcon),
              angle: pi / 3,
              iconAnchor: IconAnchor(
                anchor: Anchor.top,
              ))
          .then((v) {
        osmMarkers['Source'] = departure;
      });

      if (osmMarkers.containsKey('Destination')) {
        await mapOsmController.removeMarker(osmMarkers['Destination']!);
      }

      await mapOsmController
          .addMarker(destination,
              markerIcon: MarkerIcon(iconWidget: destinationOsmIcon),
              angle: pi / 3,
              iconAnchor: IconAnchor(
                anchor: Anchor.top,
              ))
          .then((v) {
        osmMarkers['Destination'] = destination;
      });
    });
  }
}
