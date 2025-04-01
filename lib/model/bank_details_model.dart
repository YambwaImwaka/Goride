class BankDetailsModel {
  String? userId;
  String? bankName;
  String? holderName;
  String? branchName;
  String? accountNumber;
  String? otherInformation;

  BankDetailsModel(
      {this.userId,
      this.bankName,
        this.holderName,
        this.branchName,
        this.accountNumber,
        this.otherInformation});

  BankDetailsModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    bankName = json['bankName'];
    holderName = json['holderName'];
    branchName = json['branchName'];
    accountNumber = json['accountNumber'];
    otherInformation = json['otherInformation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['bankName'] = bankName;
    data['holderName'] = holderName;
    data['branchName'] = branchName;
    data['accountNumber'] = accountNumber;
    data['otherInformation'] = otherInformation;
    return data;
  }
}
