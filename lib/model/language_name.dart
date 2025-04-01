class LanguageName {
  String? name;
  String? type;

  LanguageName({ this.name, this.type});

  LanguageName.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    return data;
  }
}
