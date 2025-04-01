import 'package:driver/model/language_description.dart';
import 'package:driver/model/language_name.dart';

class FreightVehicle {
  String? image;
  bool? enable;
  String? kmCharge;
  String? width;
  String? length;
  List<LanguageName>? name;
  List<LanguageDescription>? description;
  String? id;
  String? height;

  FreightVehicle(
      {this.image,
        this.enable,
        this.kmCharge,
        this.width,
        this.length,
        this.name,
        this.id,
        this.height,this.description});

  FreightVehicle.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    enable = json['enable'];
    kmCharge = json['kmCharge'];
    width = json['width'];
    length = json['length'];
    if (json['name'] != null) {
      name = <LanguageName>[];
      json['name'].forEach((v) {
        name!.add(LanguageName.fromJson(v));
      });
    }

    if (json['description'] != null) {
      description = <LanguageDescription>[];
      json['description'].forEach((v) {
        description!.add(LanguageDescription.fromJson(v));
      });
    }

    id = json['id'];
    height = json['height'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['enable'] = enable;
    data['kmCharge'] = kmCharge;
    data['width'] = width;
    data['length'] = length;
    if (name != null) {
      data['name'] = name!.map((v) => v.toJson()).toList();
    }
    if (description != null) {
      data['description'] = description!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['height'] = height;
    return data;
  }
}
