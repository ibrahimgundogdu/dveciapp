class SaleOrderType {
  int id;
  String typeName;
  String sortBy;

  SaleOrderType(this.id, this.typeName, this.sortBy);

  SaleOrderType.fromMap(Map<String, dynamic> m)
      : this(m['id'], m['typeName'], m['sortBy']);

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['typeName'] = typeName;
    data['sortBy'] = sortBy;
    return data;
  }
}
