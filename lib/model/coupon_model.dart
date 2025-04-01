import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/model/language_title.dart';

class CouponModel {
  List<LanguageTitle>? title;
  String? amount;
  String? code;
  bool? enable;
  String? id;
  Timestamp? validity;
  String? type;

  CouponModel({this.title, this.amount, this.code, this.enable, this.id, this.validity, this.type});

  CouponModel.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    code = json['code'];
    enable = json['enable'];
    id = json['id'];
    validity = json['validity'];
    type = json['type'];
    if (json['title'] != null) {
      title = <LanguageTitle>[];
      json['title'].forEach((v) {
        title!.add(LanguageTitle.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (title != null) {
      data['title'] = title!.map((v) => v.toJson()).toList();
    }
    data['amount'] = amount;
    data['code'] = code;
    data['enable'] = enable;
    data['id'] = id;
    data['validity'] = validity;
    data['type'] = type;
    return data;
  }
}
