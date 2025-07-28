class OrderDocument {
  String saleOrderUid;
  String? saleOrderRowUid;
  String? pathName;
  String? documentName;
  String documentBase64;
  String mimeType;

  OrderDocument(
      {required this.saleOrderUid,
      this.saleOrderRowUid,
      this.pathName,
      this.documentName,
      required this.documentBase64,
      this.mimeType = ''});

  OrderDocument.fromMap(Map<String, dynamic> m)
      : this(
            saleOrderUid: m['saleOrderUid'],
            saleOrderRowUid: m['saleOrderRowUid'],
            pathName: m['pathName'],
            documentName: m['documentName'],
            documentBase64: m['documentBase64'],
            mimeType: m['mimeType']);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map["saleOrderUid"] = saleOrderUid;
    map["saleOrderRowUid"] = saleOrderRowUid;
    map["pathName"] = pathName;
    map["documentName"] = documentName;
    map["documentBase64"] = documentBase64;
    map["mimeType"] = mimeType;

    return map;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};

    map["saleOrderUid"] = saleOrderUid;
    map["saleOrderRowUid"] = saleOrderRowUid;
    map["pathName"] = pathName;
    map["documentName"] = documentName;
    map["documentBase64"] = documentBase64;
    map["mimeType"] = mimeType;

    return map;
  }
}
