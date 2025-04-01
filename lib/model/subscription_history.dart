import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/model/subscription_plan_model.dart';

class SubscriptionHistoryModel {
  String? id;
  String? userId;
  Timestamp? expiryDate;
  Timestamp? createdAt;
  SubscriptionPlanModel? subscriptionPlan;
  String? paymentType;

  SubscriptionHistoryModel({
    this.id,
    this.userId,
    this.expiryDate,
    this.createdAt,
    this.subscriptionPlan,
    this.paymentType,
  });

  factory SubscriptionHistoryModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistoryModel(
      id: json['id'],
      userId: json['user_id'],
      expiryDate: json['expiry_date'],
      createdAt: json['createdAt'],
      subscriptionPlan: json['subscription_plan'] != null ? SubscriptionPlanModel.fromJson(json['subscription_plan']) : null,
      paymentType: json['payment_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'expiry_date': expiryDate,
      'createdAt': createdAt,
      'subscription_plan': subscriptionPlan?.toJson(),
      'payment_type': paymentType.toString(),
    };
  }
}
