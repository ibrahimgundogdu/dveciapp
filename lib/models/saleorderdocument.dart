class SaleOrderDocument {
  int id;
  int saleOrderId;
  int saleOrderRowId;
  String pathName;
  String documentName;

  SaleOrderDocument(this.id, this.saleOrderId, this.saleOrderRowId,
      this.pathName, this.documentName);

  SaleOrderDocument.fromMap(Map<String, dynamic> m)
      : this(m['id'], m['saleOrderId'], m['saleOrderRowId'], m['pathName'],
            m['documentName']);
}
