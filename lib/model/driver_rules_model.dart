import 'package:driver/model/language_name.dart';

class DriverRulesModel {
  String? image;
  bool? isDeleted;
  bool? enable;
  List<LanguageName>? name;
  String? id;

  DriverRulesModel(
      {this.image, this.isDeleted, this.enable, this.name, this.id});

  DriverRulesModel.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    isDeleted = json['isDeleted'];
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
    data['image'] = image;
    data['isDeleted'] = isDeleted;
    data['enable'] = enable;
    if (name != null) {
      data['name'] = name!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    return data;
  }
}
