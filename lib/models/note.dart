class Note {
  int id;
  int? customerId;
  int? orderId;
  String detail;

  Note(this.id, this.customerId, this.orderId, this.detail);

  Note.fromMap(Map<String, dynamic> m)
      : this(m['id'], m['customerId'], m['orderId'], m['detail']);
}
