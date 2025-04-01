import 'package:driver/model/language_description.dart';
import 'package:driver/model/language_title.dart';

class OnBoardingModel {
  String? image;
  List<LanguageDescription>? description;
  String? id;
  List<LanguageTitle>? title;

  OnBoardingModel({this.image, this.description, this.id, this.title});

  OnBoardingModel.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    id = json['id'];
    if (json['title'] != null) {
      title = <LanguageTitle>[];
      json['title'].forEach((v) {
        title!.add(LanguageTitle.fromJson(v));
      });
    }

    if (json['description'] != null) {
      description = <LanguageDescription>[];
      json['description'].forEach((v) {
        description!.add(LanguageDescription.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    if (description != null) {
      data['description'] = description!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    if (title != null) {
      data['title'] = title!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
