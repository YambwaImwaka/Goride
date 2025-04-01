import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/model/language_name.dart';

class ZoneModel {
  List<GeoPoint>? area;
  bool? publish;
  double? latitude;
  List<LanguageName>? name;
  String? id;
  double? longitude;

  ZoneModel({this.area, this.publish, this.latitude, this.name, this.id, this.longitude});

  ZoneModel.fromJson(Map<String, dynamic> json) {
    if (json['area'] != null) {
      area = <GeoPoint>[];
      json['area'].forEach((v) {
        area!.add(v);
      });
    }

    if (json['name'] != null) {
      name = <LanguageName>[];
      json['name'].forEach((v) {
        name!.add(LanguageName.fromJson(v));
      });
    }

    publish = json['publish'];
    latitude = json['latitude'];
    id = json['id'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (area != null) {
      data['area'] = area!.map((v) => v).toList();
    }
    if (name != null) {
      data['name'] = name!.map((v) => v.toJson()).toList();
    }
    data['publish'] = publish;
    data['latitude'] = latitude;
    data['id'] = id;
    data['longitude'] = longitude;
    return data;
  }
}
