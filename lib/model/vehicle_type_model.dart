import 'package:driver/model/language_name.dart';

class VehicleTypeModel {
  bool? enable;
  List<LanguageName>? name;
  String? id;

  VehicleTypeModel({this.enable, this.name, this.id});

  VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    enable = json['enable'];
    if (json['name'] != null) {
      name = <LanguageName>[];
      json['name'].forEach((v) {
        name!.add(LanguageName.fromJson(v));
      });
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['enable'] = enable;
    if (name != null) {
      data['name'] = name!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    return data;
  }
}
