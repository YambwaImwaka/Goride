import 'package:driver/model/intercity_order_model.dart';
import 'package:get/get.dart';

class ParcelDetailsController extends GetxController{


  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  Rx<InterCityOrderModel> orderModel = InterCityOrderModel().obs;
  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
    }
    isLoading.value = false;
    update();
  }


}