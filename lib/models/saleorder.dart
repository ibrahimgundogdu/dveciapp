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

  SaleOrder.fromMap(Map<String, dynamic> m)
      : this(
            m['id'],
            m['orderNumber'],
            m['accountCode'],
            m['customerUserId'],
            m['saleEmployeeId'],
            m['orderDate'],
            m['orderSyncDate'],
            m['orderTypeId'],
            m['description'],
            m['orderStatusID'],
            m['statusName'],
            m['netTotal'],
            m['taxTotal'],
            m['grossTotal'],
            m['uid'],
            m['recordEmployeeId'],
            m['recordIp']);
}
