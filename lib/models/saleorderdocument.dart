class SaleOrderDocument {
  int id;
  String saleOrderUid;
  String? saleOrderRowUid;
  String pathName;
  String? documentName;

  SaleOrderDocument(this.id, this.saleOrderUid, this.saleOrderRowUid,
      this.pathName, this.documentName);

  SaleOrderDocument.fromMap(Map<String, dynamic> m)
      : this(m['id'], m['saleOrderUid'], m['saleOrderRowUid'], m['pathName'],
            m['documentName']);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map["id"] = id;
    map["saleOrderUid"] = saleOrderUid;
    map["saleOrderRowUid"] = saleOrderRowUid;
    map["pathName"] = pathName;
    map["documentName"] = documentName;

    return map;
  }

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map["id"] = id;
    map["saleOrderUid"] = saleOrderUid;
    map["saleOrderRowUid"] = saleOrderRowUid;
    map["pathName"] = pathName;
    map["documentName"] = documentName;

    return map;
  }
}
