import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/model/document_model.dart';
import 'package:driver/model/driver_document_model.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class DetailsUploadController extends GetxController {
  Rx<DocumentModel> documentModel = DocumentModel().obs;

  Rx<TextEditingController> documentNumberController = TextEditingController().obs;
  Rx<TextEditingController> expireAtController = TextEditingController().obs;
  Rx<DateTime?> selectedDate = DateTime.now().obs;

  RxString frontImage = "".obs;
  RxString backImage = "".obs;

  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      documentModel.value = argumentData['documentModel'];
    }
    getDocument();
    update();
  }

  Rx<Documents> documents = Documents().obs;

  getDocument() async {
    await FireStoreUtils.getDocumentOfDriver().then((value) {
      isLoading.value = false;
      if (value != null) {
        var contain = value.documents!.where((element) => element.documentId == documentModel.value.id);
        if (contain.isNotEmpty) {
          documents.value = value.documents!.firstWhere((itemToCheck) => itemToCheck.documentId == documentModel.value.id);

          documentNumberController.value.text = documents.value.documentNumber!;
          frontImage.value = documents.value.frontImage!;
          backImage.value = documents.value.backImage!;
          if (documents.value.expireAt != null) {
            selectedDate.value = documents.value.expireAt!.toDate();
            expireAtController.value.text = DateFormat("dd-MM-yyyy").format(selectedDate.value!);
          }
        }
      }
    });
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future pickFile({required ImageSource source, required String type}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();

      if (type == "front") {
        frontImage.value = image.path;
      } else {
        backImage.value = image.path;
      }
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("Failed to Pick : \n $e");
    }
  }


  uploadDocument() async {
    String frontImageFileName = File(frontImage.value).path.split('/').last;
    String backImageFileName = File(backImage.value).path.split('/').last;

    if(frontImage.value.isNotEmpty && Constant().hasValidUrl(frontImage.value) == false){
      frontImage.value = await Constant.uploadUserImageToFireStorage(File(frontImage.value), "driverDocument/${FireStoreUtils.getCurrentUid()}", frontImageFileName);
    }

    if(backImage.value.isNotEmpty && Constant().hasValidUrl(backImage.value) == false){
      backImage.value = await Constant.uploadUserImageToFireStorage(File(backImage.value), "driverDocument/${FireStoreUtils.getCurrentUid()}", backImageFileName);
    }
    documents.value.frontImage = frontImage.value;
    documents.value.documentId = documentModel.value.id;
    documents.value.documentNumber = documentNumberController.value.text;
    documents.value.backImage = backImage.value;
    documents.value.verified = false;
    if (documentModel.value.expireAt == true) {
      documents.value.expireAt = Timestamp.fromDate(selectedDate.value!);
    }

    await FireStoreUtils.uploadDriverDocument(documents.value).then((value) {
      if (value) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Document upload successfully");

        Get.back();
      }
    });
  }
}
