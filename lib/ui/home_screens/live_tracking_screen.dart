import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/live_tracking_controller.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class LiveTrackingScreen extends StatelessWidget {
  const LiveTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<LiveTrackingController>(
      init: LiveTrackingController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            elevation: 2,
            backgroundColor: AppColors.primary,
            title: Text("Map view".tr),
            leading: InkWell(
                onTap: () {
                  Get.back();
                },
                child: const Icon(
                  Icons.arrow_back,
                )),
          ),
          body: Constant.selectedMapType == 'osm'
              ? OSMFlutter(
                  controller: controller.mapOsmController,
                  onLocationChanged: (geopoint) {
                    // controller.getOSMPolyline(
                    //   geopoint,
                    // );
                  },
                  osmOption: OSMOption(
                    userLocationMarker: UserLocationMaker(
                      directionArrowMarker: MarkerIcon(
                        iconWidget: controller.driverOsmIcon,
                      ),
                      personMarker: MarkerIcon(
                        iconWidget: controller.driverOsmIcon,
                      ),
                    ),
                    userTrackingOption: const UserTrackingOption(
                      enableTracking: true,
                      unFollowUser: false,
                    ),
                    zoomOption: const ZoomOption(
                      initZoom: 16,
                      minZoomLevel: 2,
                      maxZoomLevel: 19,
                      stepZoom: 1.0,
                    ),
                    roadConfiguration: const RoadOption(
                      roadColor: Colors.yellowAccent,
                    ),
                  ),
                  onMapIsReady: (active) async {
                    if (active) {
                      // controller.getOSMPolyline();
                      ShowToastDialog.closeLoader();
                    }
                  })
              : Obx(
                  () => GoogleMap(
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    mapType: MapType.terrain,
                    zoomControlsEnabled: false,
                    polylines: Set<Polyline>.of(controller.polyLines.values),
                    padding: const EdgeInsets.only(
                      top: 22.0,
                    ),
                    markers: Set<Marker>.of(controller.markers.values),
                    onMapCreated: (GoogleMapController mapController) {
                      controller.mapController = mapController;
                    },
                    initialCameraPosition: CameraPosition(
                      zoom: 15,
                      target: LatLng(Constant.currentLocation != null ? Constant.currentLocation!.latitude! : 45.521563,
                          Constant.currentLocation != null ? Constant.currentLocation!.longitude! : -122.677433),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
