class SaleOrderDocument {
  int id;
  String saleOrderUid;
  String saleOrderRowUid;
  String pathName;
  String documentName;

  SaleOrderDocument(this.id, this.saleOrderUid, this.saleOrderRowUid,
      this.pathName, this.documentName);

  SaleOrderDocument.fromMap(Map<String, dynamic> m)
      : this(m['id'], m['saleOrderUid'], m['saleOrderRowUid'], m['pathName'],
            m['documentName']);
}
