import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/model/admin_commission.dart';
import 'package:driver/model/bank_details_model.dart';
import 'package:driver/model/conversation_model.dart';
import 'package:driver/model/currency_model.dart';
import 'package:driver/model/document_model.dart';
import 'package:driver/model/driver_document_model.dart';
import 'package:driver/model/driver_rules_model.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/model/inbox_model.dart';
import 'package:driver/model/intercity_order_model.dart';
import 'package:driver/model/language_model.dart';
import 'package:driver/model/language_privacy_policy.dart';
import 'package:driver/model/language_terms_condition.dart';
import 'package:driver/model/on_boarding_model.dart';
import 'package:driver/model/order/driverId_accept_reject.dart';
import 'package:driver/model/order_model.dart';
import 'package:driver/model/payment_model.dart';
import 'package:driver/model/referral_model.dart';
import 'package:driver/model/review_model.dart';
import 'package:driver/model/service_model.dart';
import 'package:driver/model/subscription_history.dart';
import 'package:driver/model/subscription_plan_model.dart';
import 'package:driver/model/user_model.dart';
import 'package:driver/model/vehicle_type_model.dart';
import 'package:driver/model/wallet_transaction_model.dart';
import 'package:driver/model/withdraw_model.dart';
import 'package:driver/model/zone_model.dart';
import 'package:driver/widget/geoflutterfire/src/geoflutterfire.dart';
import 'package:driver/widget/geoflutterfire/src/models/point.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class FireStoreUtils {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static Future<bool> isLogin() async {
    bool isLogin = false;
    if (FirebaseAuth.instance.currentUser != null) {
      isLogin = await userExitOrNot(FirebaseAuth.instance.currentUser!.uid);
    } else {
      isLogin = false;
    }
    return isLogin;
  }

  getGoogleAPIKey() async {
    await fireStore.collection(CollectionName.settings).doc("globalKey").get().then((value) {
      if (value.exists) {
        Constant.mapAPIKey = value.data()!["googleMapKey"];
      }
    });

    await fireStore.collection(CollectionName.settings).doc("notification_setting").get().then((value) {
      if (value.exists) {
        if (value.data() != null) {
          Constant.senderId = value.data()!['senderId'].toString();
          Constant.jsonNotificationFileURL = value.data()!['serviceJson'].toString();
        }
      }
    });

    await fireStore.collection(CollectionName.settings).doc("globalValue").get().then((value) {
      if (value.exists) {
        Constant.distanceType = value.data()!["distanceType"];
        Constant.radius = value.data()!["radius"];
        Constant.minimumAmountToWithdrawal = value.data()!["minimumAmountToWithdrawal"];
        Constant.minimumDepositToRideAccept = value.data()!["minimumDepositToRideAccept"];
        Constant.mapType = value.data()!["mapType"];
        Constant.selectedMapType = value.data()!["selectedMapType"];
        Constant.driverLocationUpdate = value.data()!["driverLocationUpdate"];
        Constant.isVerifyDocument = value.data()!["isVerifyDocument"];
        Constant.isSubscriptionModelApplied = value.data()!["subscription_model"];
      }
    });

    await fireStore.collection(CollectionName.settings).doc("adminCommission").get().then((value) {
      if (value.data() != null) {
        AdminCommission adminCommission = AdminCommission.fromJson(value.data()!);
        Constant.adminCommission = adminCommission;
      }
    });

    await fireStore.collection(CollectionName.settings).doc("referral").get().then((value) {
      if (value.exists) {
        Constant.referralAmount = value.data()!["referralAmount"];
      }
    });

    await fireStore.collection(CollectionName.settings).doc("global").get().then((value) {
      if (value.exists) {
        if (value.data()!["privacyPolicy"] != null) {
          Constant.privacyPolicy = <LanguagePrivacyPolicy>[];
          value.data()!["privacyPolicy"].forEach((v) {
            Constant.privacyPolicy.add(LanguagePrivacyPolicy.fromJson(v));
          });
        }

        if (value.data()!["termsAndConditions"] != null) {
          Constant.termsAndConditions = <LanguageTermsCondition>[];
          value.data()!["termsAndConditions"].forEach((v) {
            Constant.termsAndConditions.add(LanguageTermsCondition.fromJson(v));
          });
        }
        Constant.appVersion = value.data()!["appVersion"];
      }
    });

    await fireStore.collection(CollectionName.settings).doc("contact_us").get().then((value) {
      if (value.exists) {
        Constant.supportURL = value.data()!["supportURL"];
      }
    });
  }

  static String getCurrentUid() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  static Future<DriverUserModel?> getDriverProfile(String uuid) async {
    DriverUserModel? driverModel;
    await fireStore.collection(CollectionName.driverUsers).doc(uuid).get().then((value) {
      if (value.exists) {
        driverModel = DriverUserModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      driverModel = null;
    });
    return driverModel;
  }

  static Future<UserModel?> getCustomer(String uuid) async {
    UserModel? userModel;
    await fireStore.collection(CollectionName.users).doc(uuid).get().then((value) {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      userModel = null;
    });
    return userModel;
  }

  static Future<bool> updateUser(UserModel userModel) async {
    bool isUpdate = false;
    await fireStore.collection(CollectionName.users).doc(userModel.id).set(userModel.toJson()).whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  Future<PaymentModel?> getPayment() async {
    PaymentModel? paymentModel;
    await fireStore.collection(CollectionName.settings).doc("payment").get().then((value) {
      paymentModel = PaymentModel.fromJson(value.data()!);
    });
    return paymentModel;
  }

  Future<CurrencyModel?> getCurrency() async {
    CurrencyModel? currencyModel;
    await fireStore.collection(CollectionName.currency).where("enable", isEqualTo: true).get().then((value) {
      if (value.docs.isNotEmpty) {
        currencyModel = CurrencyModel.fromJson(value.docs.first.data());
      }
    });
    return currencyModel;
  }

  static Future<bool> updateDriverUser(DriverUserModel userModel) async {
    bool isUpdate = false;
    await fireStore.collection(CollectionName.driverUsers).doc(userModel.id).set(userModel.toJson()).whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<DriverIdAcceptReject?> getAcceptedOrders(String orderId, String driverId) async {
    DriverIdAcceptReject? driverIdAcceptReject;
    await fireStore.collection(CollectionName.orders).doc(orderId).collection("acceptedDriver").doc(driverId).get().then((value) async {
      if (value.exists) {
        driverIdAcceptReject = DriverIdAcceptReject.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      driverIdAcceptReject = null;
    });
    return driverIdAcceptReject;
  }

  static Future<DriverIdAcceptReject?> getInterCItyAcceptedOrders(String orderId, String driverId) async {
    DriverIdAcceptReject? driverIdAcceptReject;
    await fireStore.collection(CollectionName.ordersIntercity).doc(orderId).collection("acceptedDriver").doc(driverId).get().then((value) async {
      if (value.exists) {
        driverIdAcceptReject = DriverIdAcceptReject.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      driverIdAcceptReject = null;
    });
    return driverIdAcceptReject;
  }

  static Future<bool> userExitOrNot(String uid) async {
    bool isExit = false;

    await fireStore.collection(CollectionName.driverUsers).doc(uid).get().then(
      (value) {
        if (value.exists) {
          isExit = true;
        } else {
          isExit = false;
        }
      },
    ).catchError((error) {
      log("Failed to update user: $error");
      isExit = false;
    });
    return isExit;
  }

  static Future<List<DocumentModel>> getDocumentList() async {
    List<DocumentModel> documentList = [];
    await fireStore.collection(CollectionName.documents).where('enable', isEqualTo: true).where('isDeleted', isEqualTo: false).get().then((value) {
      for (var element in value.docs) {
        DocumentModel documentModel = DocumentModel.fromJson(element.data());
        documentList.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return documentList;
  }

  static Future<List<ServiceModel>> getService() async {
    List<ServiceModel> serviceList = [];
    await fireStore.collection(CollectionName.service).where('enable', isEqualTo: true).get().then((value) {
      for (var element in value.docs) {
        ServiceModel documentModel = ServiceModel.fromJson(element.data());
        serviceList.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return serviceList;
  }

  static Future<DriverDocumentModel?> getDocumentOfDriver() async {
    DriverDocumentModel? driverDocumentModel;
    await fireStore.collection(CollectionName.driverDocument).doc(getCurrentUid()).get().then((value) async {
      if (value.exists) {
        driverDocumentModel = DriverDocumentModel.fromJson(value.data()!);
      }
    });
    return driverDocumentModel;
  }

  static Future<bool> uploadDriverDocument(Documents documents) async {
    bool isAdded = false;
    DriverDocumentModel driverDocumentModel = DriverDocumentModel();
    List<Documents> documentsList = [];
    await fireStore.collection(CollectionName.driverDocument).doc(getCurrentUid()).get().then((value) async {
      if (value.exists) {
        DriverDocumentModel newDriverDocumentModel = DriverDocumentModel.fromJson(value.data()!);
        documentsList = newDriverDocumentModel.documents!;
        var contain = newDriverDocumentModel.documents!.where((element) => element.documentId == documents.documentId);
        if (contain.isEmpty) {
          documentsList.add(documents);

          driverDocumentModel.id = getCurrentUid();
          driverDocumentModel.documents = documentsList;
        } else {
          var index = newDriverDocumentModel.documents!.indexWhere((element) => element.documentId == documents.documentId);

          driverDocumentModel.id = getCurrentUid();
          documentsList.removeAt(index);
          documentsList.insert(index, documents);
          driverDocumentModel.documents = documentsList;
          isAdded = false;
          ShowToastDialog.showToast("Document is under verification");
        }
      } else {
        documentsList.add(documents);
        driverDocumentModel.id = getCurrentUid();
        driverDocumentModel.documents = documentsList;
      }
    });

    await fireStore.collection(CollectionName.driverDocument).doc(getCurrentUid()).set(driverDocumentModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      isAdded = false;
      log(error.toString());
    });

    return isAdded;
  }

  static Future<List<VehicleTypeModel>?> getVehicleType() async {
    List<VehicleTypeModel> vehicleList = [];
    await fireStore.collection(CollectionName.vehicleType).where('enable', isEqualTo: true).get().then((value) async {
      for (var element in value.docs) {
        VehicleTypeModel vehicleModel = VehicleTypeModel.fromJson(element.data());
        vehicleList.add(vehicleModel);
      }
    });
    return vehicleList;
  }

  static Future<List<DriverRulesModel>?> getDriverRules() async {
    List<DriverRulesModel> driverRulesModel = [];
    await fireStore
        .collection(CollectionName.driverRules)
        .where('enable', isEqualTo: true)
        .where('isDeleted', isEqualTo: false)
        .get()
        .then((value) async {
      for (var element in value.docs) {
        DriverRulesModel vehicleModel = DriverRulesModel.fromJson(element.data());
        driverRulesModel.add(vehicleModel);
      }
    });
    return driverRulesModel;
  }

  StreamController<List<OrderModel>>? getNearestOrderRequestController;

  Stream<List<OrderModel>> getOrders(DriverUserModel driverUserModel, double? latitude, double? longLatitude) async* {
    getNearestOrderRequestController = StreamController<List<OrderModel>>.broadcast();
    List<OrderModel> ordersList = [];
    Query<Map<String, dynamic>> query = fireStore
        .collection(CollectionName.orders)
        .where('serviceId', isEqualTo: driverUserModel.serviceId)
        .where('zoneId', whereIn: driverUserModel.zoneIds)
        .where('status', isEqualTo: Constant.ridePlaced);
    GeoFirePoint center = Geoflutterfire().point(latitude: latitude ?? 0.0, longitude: longLatitude ?? 0.0);
    Stream<List<DocumentSnapshot>> stream = Geoflutterfire()
        .collection(collectionRef: query)
        .within(center: center, radius: double.parse(Constant.radius), field: 'position', strictMode: true);

    stream.listen((List<DocumentSnapshot> documentList) {
      ordersList.clear();
      for (var document in documentList) {
        final data = document.data() as Map<String, dynamic>;
        OrderModel orderModel = OrderModel.fromJson(data);
        if (orderModel.acceptedDriverId != null && orderModel.acceptedDriverId!.isNotEmpty) {
          if (!orderModel.acceptedDriverId!.contains(FireStoreUtils.getCurrentUid())) {
            ordersList.add(orderModel);
          }
        } else {
          ordersList.add(orderModel);
        }
      }
      getNearestOrderRequestController!.sink.add(ordersList);
    });

    yield* getNearestOrderRequestController!.stream;
  }

  StreamController<List<InterCityOrderModel>>? getNearestFreightOrderRequestController;

  Stream<List<InterCityOrderModel>> getFreightOrders(double? latitude, double? longLatitude) async* {
    getNearestFreightOrderRequestController = StreamController<List<InterCityOrderModel>>.broadcast();
    List<InterCityOrderModel> ordersList = [];
    Query<Map<String, dynamic>> query = fireStore
        .collection(CollectionName.ordersIntercity)
        .where('intercityServiceId', isEqualTo: "Kn2VEnPI3ikF58uK8YqY")
        .where('status', isEqualTo: Constant.ridePlaced);
    GeoFirePoint center = Geoflutterfire().point(latitude: latitude ?? 0.0, longitude: longLatitude ?? 0.0);
    Stream<List<DocumentSnapshot>> stream = Geoflutterfire()
        .collection(collectionRef: query)
        .within(center: center, radius: double.parse(Constant.radius), field: 'position', strictMode: true);

    stream.listen((List<DocumentSnapshot> documentList) {
      ordersList.clear();
      for (var document in documentList) {
        final data = document.data() as Map<String, dynamic>;
        InterCityOrderModel orderModel = InterCityOrderModel.fromJson(data);
        if (orderModel.acceptedDriverId != null && orderModel.acceptedDriverId!.isNotEmpty) {
          if (!orderModel.acceptedDriverId!.contains(FireStoreUtils.getCurrentUid())) {
            ordersList.add(orderModel);
          }
        } else {
          ordersList.add(orderModel);
        }
      }
      getNearestFreightOrderRequestController!.sink.add(ordersList);
    });

    yield* getNearestFreightOrderRequestController!.stream;
  }

  closeStream() {
    if (getNearestOrderRequestController != null) {
      getNearestOrderRequestController!.close();
    }
  }

  closeFreightStream() {
    if (getNearestFreightOrderRequestController != null) {
      getNearestFreightOrderRequestController!.close();
    }
  }

  static Future<bool?> setOrder(OrderModel orderModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.orders).doc(orderModel.id).set(orderModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> bankDetailsIsAvailable() async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.bankDetails).doc(FireStoreUtils.getCurrentUid()).get().then((value) {
      if (value.exists) {
        isAdded = true;
      } else {
        isAdded = false;
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<OrderModel?> getOrder(String orderId) async {
    OrderModel? orderModel;
    await fireStore.collection(CollectionName.orders).doc(orderId).get().then((value) {
      if (value.data() != null) {
        orderModel = OrderModel.fromJson(value.data()!);
      }
    });
    return orderModel;
  }

  static Future<InterCityOrderModel?> getInterCityOrder(String orderId) async {
    InterCityOrderModel? orderModel;
    await fireStore.collection(CollectionName.ordersIntercity).doc(orderId).get().then((value) {
      if (value.data() != null) {
        orderModel = InterCityOrderModel.fromJson(value.data()!);
      }
    });
    return orderModel;
  }

  static Future<bool?> acceptRide(OrderModel orderModel, DriverIdAcceptReject driverIdAcceptReject) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.orders)
        .doc(orderModel.id)
        .collection("acceptedDriver")
        .doc(driverIdAcceptReject.driverId)
        .set(driverIdAcceptReject.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> setReview(ReviewModel reviewModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.reviewCustomer).doc(reviewModel.id).set(reviewModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<ReviewModel?> getReview(String orderId) async {
    ReviewModel? reviewModel;
    await fireStore.collection(CollectionName.reviewCustomer).doc(orderId).get().then((value) {
      if (value.data() != null) {
        reviewModel = ReviewModel.fromJson(value.data()!);
      }
    });
    return reviewModel;
  }

  static Future<bool?> setInterCityOrder(InterCityOrderModel orderModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.ordersIntercity).doc(orderModel.id).set(orderModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> acceptInterCityRide(InterCityOrderModel orderModel, DriverIdAcceptReject driverIdAcceptReject) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.ordersIntercity)
        .doc(orderModel.id)
        .collection("acceptedDriver")
        .doc(driverIdAcceptReject.driverId)
        .set(driverIdAcceptReject.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<WalletTransactionModel>?> getWalletTransaction() async {
    List<WalletTransactionModel> walletTransactionModel = [];

    await fireStore
        .collection(CollectionName.walletTransaction)
        .where('userId', isEqualTo: FireStoreUtils.getCurrentUid())
        .orderBy('createdDate', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        WalletTransactionModel taxModel = WalletTransactionModel.fromJson(element.data());
        walletTransactionModel.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return walletTransactionModel;
  }

  static Future<bool?> setWalletTransaction(WalletTransactionModel walletTransactionModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.walletTransaction).doc(walletTransactionModel.id).set(walletTransactionModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> updatedDriverWallet({required String amount}) async {
    bool isAdded = false;
    await getDriverProfile(FireStoreUtils.getCurrentUid()).then((value) async {
      if (value != null) {
        DriverUserModel userModel = value;
        userModel.walletAmount = (double.parse(userModel.walletAmount.toString()) + double.parse(amount)).toString();
        await FireStoreUtils.updateDriverUser(userModel).then((value) {
          isAdded = value;
        });
      }
    });
    return isAdded;
  }

  static Future<List<LanguageModel>?> getLanguage() async {
    List<LanguageModel> languageList = [];

    await fireStore.collection(CollectionName.languages).where("enable", isEqualTo: true).where("isDeleted", isEqualTo: false).get().then((value) {
      for (var element in value.docs) {
        LanguageModel taxModel = LanguageModel.fromJson(element.data());
        languageList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return languageList;
  }

  static Future<List<OnBoardingModel>> getOnBoardingList() async {
    List<OnBoardingModel> onBoardingModel = [];
    await fireStore.collection(CollectionName.onBoarding).where("type", isEqualTo: "driverApp").get().then((value) {
      for (var element in value.docs) {
        OnBoardingModel documentModel = OnBoardingModel.fromJson(element.data());
        onBoardingModel.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return onBoardingModel;
  }

  static Future addInBox(InboxModel inboxModel) async {
    return await fireStore.collection(CollectionName.chat).doc(inboxModel.orderId).set(inboxModel.toJson()).then((document) {
      return inboxModel;
    });
  }

  static Future addChat(ConversationModel conversationModel) async {
    return await fireStore
        .collection(CollectionName.chat)
        .doc(conversationModel.orderId)
        .collection("thread")
        .doc(conversationModel.id)
        .set(conversationModel.toJson())
        .then((document) {
      return conversationModel;
    });
  }

  static Future<BankDetailsModel?> getBankDetails() async {
    BankDetailsModel? bankDetailsModel;
    await fireStore.collection(CollectionName.bankDetails).doc(FireStoreUtils.getCurrentUid()).get().then((value) {
      if (value.data() != null) {
        bankDetailsModel = BankDetailsModel.fromJson(value.data()!);
      }
    });
    return bankDetailsModel;
  }

  static Future<bool?> updateBankDetails(BankDetailsModel bankDetailsModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.bankDetails).doc(bankDetailsModel.userId).set(bankDetailsModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> setWithdrawRequest(WithdrawModel withdrawModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.withdrawalHistory).doc(withdrawModel.id).set(withdrawModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<WithdrawModel>> getWithDrawRequest() async {
    List<WithdrawModel> withdrawalList = [];
    await fireStore
        .collection(CollectionName.withdrawalHistory)
        .where('userId', isEqualTo: getCurrentUid())
        .orderBy('createdDate', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        WithdrawModel documentModel = WithdrawModel.fromJson(element.data());
        withdrawalList.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return withdrawalList;
  }

  static Future<bool?> deleteUser() async {
    bool? isDelete;
    try {
      await fireStore.collection(CollectionName.driverUsers).doc(FireStoreUtils.getCurrentUid()).delete();

      // delete user  from firebase auth
      await FirebaseAuth.instance.currentUser!.delete().then((value) {
        isDelete = true;
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isDelete;
  }

  static Future<bool> getIntercityFirstOrderOrNOt(InterCityOrderModel orderModel) async {
    bool isFirst = true;
    await fireStore.collection(CollectionName.ordersIntercity).where('userId', isEqualTo: orderModel.userId).get().then((value) {
      if (value.size == 1) {
        isFirst = true;
      } else {
        isFirst = false;
      }
    });
    return isFirst;
  }

  static Future updateIntercityReferralAmount(InterCityOrderModel orderModel) async {
    ReferralModel? referralModel;
    await fireStore.collection(CollectionName.referral).doc(orderModel.userId).get().then((value) {
      if (value.data() != null) {
        referralModel = ReferralModel.fromJson(value.data()!);
      } else {
        return;
      }
    });
    if (referralModel != null) {
      if (referralModel!.referralBy != null && referralModel!.referralBy!.isNotEmpty) {
        await fireStore.collection(CollectionName.users).doc(referralModel!.referralBy).get().then((value) async {
          DocumentSnapshot<Map<String, dynamic>> userDocument = value;
          if (userDocument.data() != null && userDocument.exists) {
            try {
              UserModel user = UserModel.fromJson(userDocument.data()!);
              user.walletAmount = (double.parse(user.walletAmount.toString()) + double.parse(Constant.referralAmount.toString())).toString();
              updateUser(user);

              WalletTransactionModel transactionModel = WalletTransactionModel(
                  id: Constant.getUuid(),
                  amount: Constant.referralAmount.toString(),
                  createdDate: Timestamp.now(),
                  paymentType: "Wallet",
                  transactionId: orderModel.id,
                  userId: orderModel.driverId.toString(),
                  orderType: "intercity",
                  userType: "customer",
                  note: "Referral Amount");

              await FireStoreUtils.setWalletTransaction(transactionModel);
            } catch (error) {}
          }
        });
      } else {
        return;
      }
    }
  }

  static Future<bool> getFirestOrderOrNOt(OrderModel orderModel) async {
    bool isFirst = true;
    await fireStore.collection(CollectionName.orders).where('userId', isEqualTo: orderModel.userId).get().then((value) {
      if (value.size == 1) {
        isFirst = true;
      } else {
        isFirst = false;
      }
    });
    return isFirst;
  }

  static Future updateReferralAmount(OrderModel orderModel) async {
    ReferralModel? referralModel;
    await fireStore.collection(CollectionName.referral).doc(orderModel.userId).get().then((value) {
      if (value.data() != null) {
        referralModel = ReferralModel.fromJson(value.data()!);
      } else {
        return;
      }
    });
    if (referralModel != null) {
      if (referralModel!.referralBy != null && referralModel!.referralBy!.isNotEmpty) {
        await fireStore.collection(CollectionName.users).doc(referralModel!.referralBy).get().then((value) async {
          DocumentSnapshot<Map<String, dynamic>> userDocument = value;
          if (userDocument.data() != null && userDocument.exists) {
            try {
              UserModel user = UserModel.fromJson(userDocument.data()!);
              user.walletAmount = (double.parse(user.walletAmount.toString()) + double.parse(Constant.referralAmount.toString())).toString();
              updateUser(user);

              WalletTransactionModel transactionModel = WalletTransactionModel(
                  id: Constant.getUuid(),
                  amount: Constant.referralAmount.toString(),
                  createdDate: Timestamp.now(),
                  paymentType: "Wallet",
                  transactionId: orderModel.id,
                  userId: orderModel.driverId.toString(),
                  orderType: "city",
                  userType: "customer",
                  note: "Referral Amount");

              await FireStoreUtils.setWalletTransaction(transactionModel);
            } catch (error) {
              print(error);
            }
          }
        });
      } else {
        return;
      }
    }
  }

  static Future<List<ZoneModel>?> getZone() async {
    List<ZoneModel> airPortList = [];
    await fireStore.collection(CollectionName.zone).where('publish', isEqualTo: true).get().then((value) {
      for (var element in value.docs) {
        ZoneModel ariPortModel = ZoneModel.fromJson(element.data());
        airPortList.add(ariPortModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return airPortList;
  }

  static Future<List<SubscriptionPlanModel>> getAllSubscriptionPlans() async {
    List<SubscriptionPlanModel> subscriptionPlanModels = [];
    await fireStore.collection(CollectionName.subscriptionPlans).where('isEnable', isEqualTo: true).orderBy('place', descending: false).get().then((value) async {
      if (value.docs.isNotEmpty) {
        for (var element in value.docs) {
          SubscriptionPlanModel subscriptionPlanModel = SubscriptionPlanModel.fromJson(element.data());
          if (subscriptionPlanModel.id != Constant.commissionSubscriptionID) {
            subscriptionPlanModels.add(subscriptionPlanModel);
          }
        }
      }
    });
    return subscriptionPlanModels;
  }

  static Future<SubscriptionPlanModel?> getSubscriptionPlanById({required String planId}) async {
    SubscriptionPlanModel? subscriptionPlanModel = SubscriptionPlanModel();
    if (planId.isNotEmpty) {
      await fireStore.collection(CollectionName.subscriptionPlans).doc(planId).get().then((value) async {
        if (value.exists) {
          subscriptionPlanModel = SubscriptionPlanModel.fromJson(value.data() as Map<String, dynamic>);
        }
      });
    }
    return subscriptionPlanModel;
  }


  static Future<SubscriptionPlanModel> setSubscriptionPlan(SubscriptionPlanModel subscriptionPlanModel) async {
    if (subscriptionPlanModel.id?.isEmpty == true) {
      subscriptionPlanModel.id = const Uuid().v4();
    }
    await fireStore.collection(CollectionName.subscriptionPlans).doc(subscriptionPlanModel.id).set(subscriptionPlanModel.toJson()).then((value) async {});
    return subscriptionPlanModel;
  }

  static Future<bool?> setSubscriptionTransaction(SubscriptionHistoryModel subscriptionPlan) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.subscriptionHistory).doc(subscriptionPlan.id).set(subscriptionPlan.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<SubscriptionHistoryModel>> getSubscriptionHistory() async {
    List<SubscriptionHistoryModel> subscriptionHistoryList = [];
    await fireStore.collection(CollectionName.subscriptionHistory).where('user_id', isEqualTo: getCurrentUid()).orderBy('createdAt', descending: true).get().then((value) async {
      if (value.docs.isNotEmpty) {
        for (var element in value.docs) {
          SubscriptionHistoryModel subscriptionHistoryModel = SubscriptionHistoryModel.fromJson(element.data());
          subscriptionHistoryList.add(subscriptionHistoryModel);
        }
      }
    });
    return subscriptionHistoryList;
  }
}
