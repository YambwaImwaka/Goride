import 'package:driver/model/document_model.dart';
import 'package:driver/model/driver_document_model.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class OnlineRegistrationController extends GetxController {
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getDocument();
    super.onInit();
  }

  RxList documentList = <DocumentModel>[].obs;
  RxList driverDocumentList = <Documents>[].obs;

  getDocument() async {
    await FireStoreUtils.getDocumentList().then((value) {
      documentList.value = value;
      isLoading.value = false;
    });

    await FireStoreUtils.getDocumentOfDriver().then((value) {
      if(value != null){
        driverDocumentList.value = value.documents!;
      }
    });
    update();
  }
}
