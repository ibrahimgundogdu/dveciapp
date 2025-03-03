class SaleOrder {
  int id;
  String orderNumber;
  String accountCode;
  int? customerUserId;
  int? saleEmployeeId;
  DateTime orderDate;
  DateTime orderSyncDate;
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

  // fromMap method
  SaleOrder.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        orderNumber = map['orderNumber'],
        accountCode = map['accountCode'],
        customerUserId = map['customerUserId'],
        saleEmployeeId = map['saleEmployeeId'],
        orderDate = DateTime.fromMillisecondsSinceEpoch(map['orderDate']),
        orderSyncDate =
            DateTime.fromMillisecondsSinceEpoch(map['orderSyncDate']),
        orderTypeId = map['orderTypeId'],
        description = map['description'],
        orderStatusId = map['orderStatusId'],
        statusName = map['statusName'],
        netTotal = map['netTotal'],
        taxTotal = map['taxTotal'],
        grossTotal = map['grossTotal'],
        uid = map['uid'],
        recordEmployeeId = map['recordEmployeeId'],
        recordIp = map['recordIp'];

  // toMap method
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'accountCode': accountCode,
      'customerUserId': customerUserId,
      'saleEmployeeId': saleEmployeeId,
      'orderDate': orderDate.millisecondsSinceEpoch,
      'orderSyncDate': orderSyncDate.millisecondsSinceEpoch,
      'orderTypeId': orderTypeId,
      'description': description,
      'orderStatusId': orderStatusId,
      'statusName': statusName,
      'netTotal': netTotal,
      'taxTotal': taxTotal,
      'grossTotal': grossTotal,
      'uid': uid,
      'recordEmployeeId': recordEmployeeId,
      'recordIp': recordIp,
    };
  }
}
