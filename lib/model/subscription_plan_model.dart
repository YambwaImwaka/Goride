import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionPlanModel {
  Timestamp? createdAt;
  String? description;
  String? expiryDay;
  String? id;
  bool? isEnable;
  String? bookingLimit;
  String? name;
  String? price;
  String? place;
  String? image;
  String? type;
  List<String>? planPoints;

  SubscriptionPlanModel(
      {this.createdAt,
      this.description,
      this.expiryDay,
      this.id,
      this.isEnable,
      this.bookingLimit,
      this.name,
      this.price,
      this.place,
      this.image,
      this.type,
      this.planPoints});

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      createdAt: json['createdAt'],
      description: json['description'],
      expiryDay: json['expiryDay'],
      id: json['id'],
      isEnable: json['isEnable'],
      bookingLimit: json['bookingLimit'],
      name: json['name'],
      price: json['price'],
      place: json['place'],
      image: json['image'],
      type: json['type'],
      planPoints: json['plan_points'] == null ? [] : List<String>.from(json['plan_points']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'description': description,
      'expiryDay': expiryDay.toString(),
      'id': id,
      'isEnable': isEnable,
      'bookingLimit': bookingLimit.toString(),
      'name': name,
      'price': price.toString(),
      'place': place.toString(),
      'image': image.toString(),
      'type': type,
      'plan_points': planPoints
    };
  }
}

