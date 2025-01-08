class Document {
  int id;
  String? customerCode;
  int? orderId;
  String fileName;
  String description;

  Document(this.id, this.customerCode, this.orderId, this.fileName,
      this.description);

  Document.fromMap(Map<String, dynamic> m)
      : this(m['id'], m['customerCode'], m['orderId'], m['fileName'],
            m['description']);
}
