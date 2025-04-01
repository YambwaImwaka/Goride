import 'package:driver/model/language_title.dart';

class DocumentModel {
  bool? backSide;
  bool? enable;
  bool? expireAt;
  String? id;
  bool? frontSide;
  List<LanguageTitle>?  title;

  DocumentModel({this.backSide, this.enable, this.id, this.frontSide, this.title, this.expireAt});

  DocumentModel.fromJson(Map<String, dynamic> json) {
    backSide = json['backSide'];
    enable = json['enable'];
    id = json['id'];
    frontSide = json['frontSide'];
    if (json['title'] != null) {
      title = <LanguageTitle>[];
      json['title'].forEach((v) {
        title!.add(LanguageTitle.fromJson(v));
      });
    }
    expireAt = json['expireAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['backSide'] = backSide;
    data['enable'] = enable;
    data['id'] = id;
    data['frontSide'] = frontSide;
    data['title'] = title;
    data['expireAt'] = expireAt;
    if (title != null) {
      data['title'] = title!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
