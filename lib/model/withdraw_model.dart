import 'package:cloud_firestore/cloud_firestore.dart';

class WithdrawModel {
  String? id;
  String? userId;
  String? note;
  String? adminNote;
  String? paymentStatus;
  Timestamp? createdDate;
  Timestamp? paymentDate;
  String? amount;

  WithdrawModel(
      {this.id,
        this.userId,
        this.note,
        this.adminNote,
        this.paymentStatus,
        this.createdDate,
        this.paymentDate,this.amount});

  WithdrawModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    note = json['note'];
    adminNote = json['adminNote'];
    paymentStatus = json['paymentStatus'];
    createdDate = json['createdDate'];
    paymentDate = json['paymentDate'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['note'] = note;
    data['adminNote'] = adminNote;
    data['paymentStatus'] = paymentStatus;
    data['createdDate'] = createdDate;
    data['paymentDate'] = paymentDate;
    data['amount'] = amount;
    return data;
  }
}
