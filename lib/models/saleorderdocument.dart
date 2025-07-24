class SaleOrderDocument {
  int id;
  String saleOrderUid;
  String? saleOrderRowUid;
  String? pathName;
  String? documentName;

  SaleOrderDocument(
      {required this.id,
      required this.saleOrderUid,
      this.saleOrderRowUid,
      this.pathName,
      this.documentName});

  SaleOrderDocument.fromMap(Map<String, dynamic> m)
      : this(
            id: m['id'],
            saleOrderUid: m['saleOrderUid'],
            saleOrderRowUid: m['saleOrderRowUid'],
            pathName: m['pathName'],
            documentName: m['documentName']);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map["id"] = id;
    map["saleOrderUid"] = saleOrderUid;
    map["saleOrderRowUid"] = saleOrderRowUid;
    map["pathName"] = pathName;
    map["documentName"] = documentName;

    return map;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};

    map["id"] = id;
    map["saleOrderUid"] = saleOrderUid;
    map["saleOrderRowUid"] = saleOrderRowUid;
    map["pathName"] = pathName;
    map["documentName"] = documentName;

    return map;
  }
}
