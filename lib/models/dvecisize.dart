class DveciSize {
  int id;
  String code;
  String digit;
  String unit;

  DveciSize(this.id, this.code, this.digit, this.unit);

  DveciSize.fromMap(Map<String, dynamic> m)
      : this(m['id'], m['code'], m['digit'], m['unit']);

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['digit'] = digit;
    data['unit'] = unit;
    return data;
  }

  Map<String, dynamic> map() {
    var map = <String, dynamic>{};

    map['id'] = id;
    map['code'] = code;
    map['digit'] = digit;
    map['unit'] = unit;

    return map;
  }
}
