class SaleOrderStatus {
  int id;
  String statusName;
  String sortBy;

  SaleOrderStatus(this.id, this.statusName, this.sortBy);

  SaleOrderStatus.fromMap(Map<String, dynamic> m)
      : this(m['id'], m['statusName'], m['sortBy']);

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['statusName'] = statusName;
    data['sortBy'] = sortBy;
    return data;
  }
}
