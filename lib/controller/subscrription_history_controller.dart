import 'package:driver/model/subscription_history.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class SubscriptionHistoryController extends GetxController{

  RxBool isLoading = true.obs;
  RxList<SubscriptionHistoryModel> subscriptionHistoryList = <SubscriptionHistoryModel>[].obs;

  @override
  void onInit() {
    getAllSubscriptionList();
    super.onInit();
  }

  getAllSubscriptionList() async {
    subscriptionHistoryList.value = await FireStoreUtils.getSubscriptionHistory();
    isLoading.value = false;
  }
}