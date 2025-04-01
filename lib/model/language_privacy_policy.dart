class LanguagePrivacyPolicy {
  String? privacyPolicy;
  String? type;

  LanguagePrivacyPolicy({ this.privacyPolicy, this.type});

  LanguagePrivacyPolicy.fromJson(Map<String, dynamic> json) {
    privacyPolicy = json['privacyPolicy'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['privacyPolicy'] = privacyPolicy;
    data['type'] = type;
    return data;
  }
}
