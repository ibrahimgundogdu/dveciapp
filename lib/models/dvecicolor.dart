class DveciColor {
  int? id;
  String? colorNumber;
  String? colorName;
  String? manufactureType;

  DveciColor(this.id, this.colorNumber, this.colorName, this.manufactureType);

  DveciColor.fromMap(Map<String, dynamic> m)
      : this(m['id'], m['colorNumber'], m['colorName'], m['manufactureType']);

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['colorNumber'] = colorNumber;
    data['colorName'] = colorName;
    data['manufactureType'] = manufactureType;
    return data;
  }
}
