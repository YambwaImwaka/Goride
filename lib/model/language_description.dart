class LanguageDescription {
  String? description;
  String? type;

  LanguageDescription({ this.description, this.type});

  LanguageDescription.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['type'] = type;
    return data;
  }
}
