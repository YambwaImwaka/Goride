class LanguageTermsCondition {
  String? termsAndConditions;
  String? type;

  LanguageTermsCondition({ this.termsAndConditions, this.type});

  LanguageTermsCondition.fromJson(Map<String, dynamic> json) {
    termsAndConditions = json['termsAndConditions'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = termsAndConditions;
    data['type'] = type;
    return data;
  }
}
