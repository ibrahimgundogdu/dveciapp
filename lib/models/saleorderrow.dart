class SaleOrderRow {
  int id;
  int orderId;
  String productCode;
  String itemCode;
  String qrCode;
  String itemColorNumber;
  String itemColorName;
  String itemSize;
  String itemPageNumber;
  String unit;
  double? quantity = 1.0;
  double? unitPrice = 0.0;
  double? total;
  double? taxRate;
  double? tax;
  double? amount;
  String currency;
  String description;
  int? rowStatusId;
  String uid;
  String orderUid;

  SaleOrderRow(
      this.id,
      this.orderId,
      this.productCode,
      this.itemCode,
      this.qrCode,
      this.itemColorNumber,
      this.itemColorName,
      this.itemSize,
      this.itemPageNumber,
      this.unit,
      this.quantity,
      this.unitPrice,
      this.total,
      this.taxRate,
      this.tax,
      this.amount,
      this.currency,
      this.description,
      this.rowStatusId,
      this.orderUid,
      this.uid);

  SaleOrderRow.fromMap(Map<String, dynamic> m)
      : this(
            m['id'],
            m['orderId'],
            m['productCode'],
            m['itemCode'],
            m['qrCode'],
            m['itemColorNumber'],
            m['itemColorName'],
            m['itemSize'],
            m['itemPageNumber'],
            m['unit'],
            (m['quantity'] as num).toDouble(),
            m['unitPrice'],
            m['total'],
            m['taxRate'],
            m['tax'],
            m['amount'],
            m['currency'],
            m['description'],
            m['rowStatusId'],
            m['orderUid'],
            m['uid']);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};

    map["id"] = id;
    map["orderId"] = orderId;
    map["productCode"] = productCode;
    map["itemCode"] = itemCode;
    map["qrCode"] = qrCode;
    map["itemColorNumber"] = itemColorNumber;
    map["itemColorName"] = itemColorName;
    map["itemSize"] = itemSize;
    map["itemPageNumber"] = itemPageNumber;
    map["unit"] = unit;
    map["quantity"] = quantity;
    map["unitPrice"] = unitPrice;
    map["total"] = total;
    map["taxRate"] = taxRate;
    map["tax"] = tax;
    map["amount"] = amount;
    map["currency"] = currency;
    map["description"] = description;
    map["rowStatusId"] = rowStatusId;
    map["orderUid"] = orderUid;
    map["uid"] = uid;

    return map;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};

    map["id"] = id;
    map["orderId"] = orderId;
    map["productCode"] = productCode;
    map["itemCode"] = itemCode;
    map["qrCode"] = qrCode;
    map["itemColorNumber"] = itemColorNumber;
    map["itemColorName"] = itemColorName;
    map["itemSize"] = itemSize;
    map["itemPageNumber"] = itemPageNumber;
    map["unit"] = unit;
    map["quantity"] = quantity;
    map["unitPrice"] = unitPrice;
    map["total"] = total;
    map["taxRate"] = taxRate;
    map["tax"] = tax;
    map["amount"] = amount;
    map["currency"] = currency;
    map["description"] = description;
    map["rowStatusId"] = rowStatusId;
    map["orderUid"] = orderUid;
    map["uid"] = uid;

    return map;
  }
}
