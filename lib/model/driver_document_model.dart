import 'package:cloud_firestore/cloud_firestore.dart';

class DriverDocumentModel {
  List<Documents>? documents;
  String? id;

  DriverDocumentModel({this.documents, this.id});

  DriverDocumentModel.fromJson(Map<String, dynamic> json) {
    if (json['documents'] != null) {
      documents = <Documents>[];
      json['documents'].forEach((v) {
        documents!.add(Documents.fromJson(v));
      });
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (documents != null) {
      data['documents'] = documents!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    return data;
  }
}

class Documents {
  String? frontImage;
  String? documentNumber;
  bool? verified;
  String? documentId;
  String? backImage;
  Timestamp? expireAt;

  Documents({this.frontImage, this.documentNumber, this.verified, this.documentId, this.backImage, this.expireAt});

  Documents.fromJson(Map<String, dynamic> json) {
    frontImage = json['frontImage'];
    documentNumber = json['documentNumber'];
    verified = json['verified'];
    documentId = json['documentId'];
    backImage = json['backImage'];
    expireAt = json['expireAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['frontImage'] = frontImage;
    data['documentNumber'] = documentNumber;
    data['verified'] = verified;
    data['documentId'] = documentId;
    data['backImage'] = backImage;
    data['expireAt'] = expireAt;
    return data;
  }
}
