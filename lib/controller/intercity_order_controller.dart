import 'package:driver/model/payment_model.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class InterCityOrderController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit\
    getPayment();
    super.onInit();
  }
  Rx<PaymentModel> paymentModel = PaymentModel().obs;
  RxBool isLoading = true.obs;

  getPayment() async {
    await FireStoreUtils().getPayment().then((value) {
      if (value != null) {
        paymentModel.value = value;
        isLoading.value = false;
      }
    });
  }
}
