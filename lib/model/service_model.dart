import 'package:driver/model/admin_commission.dart';
import 'package:driver/model/language_title.dart';

class ServiceModel {
  String? image;
  bool? enable;
  bool? offerRate;
  bool? intercityType;
  String? id;
  List<LanguageTitle>? title;
  String? kmCharge;
  AdminCommission? adminCommission;

  ServiceModel({this.image, this.enable, this.intercityType, this.offerRate, this.id, this.title, this.kmCharge, this.adminCommission});

  ServiceModel.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    enable = json['enable'];
    offerRate = json['offerRate'];
    id = json['id'];
    kmCharge = json['kmCharge'];
    intercityType = json['intercityType'];
    adminCommission =
    json['adminCommission'] != null ? AdminCommission.fromJson(json['adminCommission']) : AdminCommission(isEnabled: true, amount: "", type: "");
    if (json['title'] != null) {
      title = <LanguageTitle>[];
      json['title'].forEach((v) {
        title!.add(LanguageTitle.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['enable'] = enable;
    data['offerRate'] = offerRate;
    data['id'] = id;
    data['title'] = title;
    data['kmCharge'] = kmCharge;
    data['intercityType'] = intercityType;
    if (title != null) {
      data['title'] = title!.map((v) => v.toJson()).toList();
    }
    if (adminCommission != null) {
      data['adminCommission'] = adminCommission!.toJson();
    }
    return data;
  }
}
