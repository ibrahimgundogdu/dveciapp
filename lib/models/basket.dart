class Basket {
  int id;
  String qrCode;
  String description;
  int quantity;
  DateTime? recordDate;

  Basket(
      this.id, this.qrCode, this.description, this.quantity, this.recordDate);

  Basket.fromMap(Map<String, dynamic> m)
      : this(m['id'], m['qrCode'], m['description'], m['quantity'],
            DateTime.tryParse(m['recordDate']));

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map["id"] = id;
    map["qrCode"] = qrCode;
    map["description"] = description;
    map["quantity"] = quantity;
    map["recordDate"] = recordDate;

    return map;
  }
}
