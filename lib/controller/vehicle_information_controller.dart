import 'package:driver/constant/constant.dart';
import 'package:driver/model/driver_rules_model.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/model/service_model.dart';
import 'package:driver/model/vehicle_type_model.dart';
import 'package:driver/model/zone_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class VehicleInformationController extends GetxController {
  Rx<TextEditingController> vehicleNumberController = TextEditingController().obs;
  Rx<TextEditingController> seatsController = TextEditingController().obs;
  Rx<TextEditingController> registrationDateController = TextEditingController().obs;
  Rx<TextEditingController> driverRulesController = TextEditingController().obs;
  Rx<TextEditingController> zoneNameController = TextEditingController().obs;
  Rx<DateTime?> selectedDate = DateTime.now().obs;

  RxBool isLoading = true.obs;

  Rx<String> selectedColor = "".obs;
  List<String> carColorList = <String>['Red', 'Black', 'White', 'Blue', 'Green', 'Orange', 'Silver', 'Gray', 'Yellow', 'Brown', 'Gold', 'Beige', 'Purple'].obs;
  List<String> sheetList = <String>['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15'].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getVehicleTye();
    super.onInit();
  }

  List<VehicleTypeModel> vehicleList = <VehicleTypeModel>[].obs;
  Rx<VehicleTypeModel> selectedVehicle = VehicleTypeModel().obs;
  var colors = [
    AppColors.serviceColor1,
    AppColors.serviceColor2,
    AppColors.serviceColor3,
  ];
  Rx<DriverUserModel> driverModel = DriverUserModel().obs;
  RxList<DriverRulesModel> driverRulesList = <DriverRulesModel>[].obs;
  RxList<DriverRulesModel> selectedDriverRulesList = <DriverRulesModel>[].obs;

  RxList<ServiceModel> serviceList = <ServiceModel>[].obs;
  RxList<ZoneModel> zoneList = <ZoneModel>[].obs;
  RxList selectedZone = <String>[].obs;

  Rx<String?> selectedServiceId = "".obs;
  RxString zoneString = "".obs;

  getVehicleTye() async {
    await FireStoreUtils.getService().then((value) {
      serviceList.value = value;
    });

    await FireStoreUtils.getZone().then((value) {
      if (value != null) {
        zoneList.value = value;
      }
    });

    await FireStoreUtils.getDriverProfile(FireStoreUtils.getCurrentUid()).then((value) {
      driverModel.value = value!;
      if (driverModel.value.vehicleInformation != null) {
        vehicleNumberController.value.text = driverModel.value.vehicleInformation!.vehicleNumber.toString();
        selectedDate.value = driverModel.value.vehicleInformation!.registrationDate!.toDate();
        registrationDateController.value.text = DateFormat("dd-MM-yyyy").format(selectedDate.value!);
        selectedColor.value = driverModel.value.vehicleInformation!.vehicleColor.toString();
        seatsController.value.text = driverModel.value.vehicleInformation!.seats ?? "2";
      }

      if(driverModel.value.zoneIds != null){
        for (var element in driverModel.value.zoneIds!) {
          List<ZoneModel> list = zoneList.where((p0) => p0.id == element).toList();
          if(list.isNotEmpty){
            selectedZone.add(element);
            zoneString.value = "$zoneString${zoneString.isEmpty ? "" : ","} ${Constant.localizationName(list.first.name)}";
          }
        }
        zoneNameController.value.text = zoneString.value;
      }

    });

    if (driverModel.value.serviceId != null) {
      selectedServiceId.value = driverModel.value.serviceId;
    }
    await FireStoreUtils.getVehicleType().then((value) {
      vehicleList = value!;
      if (driverModel.value.vehicleInformation != null) {
        for (var element in vehicleList) {
          if (element.id == driverModel.value.vehicleInformation!.vehicleTypeId) {
            selectedVehicle.value = element;
          }
        }
      }
    });

    await FireStoreUtils.getDriverRules().then((value) {
      if (value != null) {
        driverRulesList.value = value;
        if (driverModel.value.vehicleInformation != null) {
          if (driverModel.value.vehicleInformation!.driverRules != null) {
            for (var element in driverModel.value.vehicleInformation!.driverRules!) {
              selectedDriverRulesList.add(element);
            }
          }
        }
      }
    });
    isLoading.value = false;
    update();
  }
}
