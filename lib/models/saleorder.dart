class SaleOrder {
  int id;
  int orderId;
  String orderNumber;
  String accountCode;
  int? customerUserId;
  int? saleEmployeeId;
  DateTime? orderDate;
  DateTime? orderSyncDate;
  int? orderTypeId;
  String description;
  int? orderStatusId;
  String statusName;
  double netTotal = 0;
  double taxTotal = 0;
  double grossTotal = 0;
  String uid;
  int? recordEmployeeId;
  String recordIp;

  SaleOrder(
      this.id,
      this.orderId,
      this.orderNumber,
      this.accountCode,
      this.customerUserId,
      this.saleEmployeeId,
      this.orderDate,
      this.orderSyncDate,
      this.orderTypeId,
      this.description,
      this.orderStatusId,
      this.statusName,
      this.netTotal,
      this.taxTotal,
      this.grossTotal,
      this.uid,
      this.recordEmployeeId,
      this.recordIp);

  SaleOrder.fromMap(Map<String, dynamic> m)
      : this(
            m['id'],
            m['orderId'],
            m['orderNumber'],
            m['accountCode'],
            m['customerUserId'],
            m['saleEmployeeId'],
            DateTime.fromMillisecondsSinceEpoch(m['orderDate'] as int),
            DateTime.fromMillisecondsSinceEpoch(m['orderSyncDate'] as int),
            m['orderTypeId'],
            m['description'],
            m['orderStatusId'],
            m['statusName'],
            m['netTotal'],
            m['taxTotal'],
            m['grossTotal'],
            m['uid'],
            m['recordEmployeeId'],
            m['recordIp']);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map["id"] = id;
    map["orderId"] = orderId;
    map["orderNumber"] = orderNumber;
    map["accountCode"] = accountCode;
    map["customerUserId"] = customerUserId;
    map["saleEmployeeId"] = saleEmployeeId;
    map["orderDate"] = orderDate?.millisecondsSinceEpoch;
    map["orderSyncDate"] = orderSyncDate?.millisecondsSinceEpoch;
    map["orderTypeId"] = orderTypeId;
    map["description"] = description;
    map["orderStatusId"] = orderStatusId;
    map["statusName"] = statusName;
    map["netTotal"] = netTotal;
    map["taxTotal"] = taxTotal;
    map["grossTotal"] = grossTotal;
    map["uid"] = uid;
    map["recordEmployeeId"] = recordEmployeeId;
    map["recordIp"] = recordIp;

    return map;
  }

  Map<String, dynamic> toJson() {
    var map = Map<String, dynamic>();

    map["id"] = id;
    map["orderId"] = orderId;
    map["orderNumber"] = orderNumber;
    map["accountCode"] = accountCode;
    map["customerUserId"] = customerUserId;
    map["saleEmployeeId"] = saleEmployeeId;
    map["orderDate"] = orderDate?.toIso8601String();
    map["orderSyncDate"] = orderSyncDate?.toIso8601String();
    map["orderTypeId"] = orderTypeId;
    map["description"] = description;
    map["orderStatusId"] = orderStatusId;
    map["statusName"] = statusName;
    map["netTotal"] = netTotal;
    map["taxTotal"] = taxTotal;
    map["grossTotal"] = grossTotal;
    map["uid"] = uid;
    map["recordEmployeeId"] = recordEmployeeId;
    map["recordIp"] = recordIp;

    return map;
  }
}
