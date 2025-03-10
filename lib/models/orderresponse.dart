class OrderResponse {
  int? orderId;
  String? orderNumber;
  String? accountCode;
  int? customerUserId;
  int? saleEmployeeId;
  String? orderDate;
  int? orderTypeId;
  String? description;
  int? orderStatusId;
  String? statusName;
  String? uid;
  bool? isSuccess;
  String? message;

  OrderResponse(
      this.orderId,
      this.orderNumber,
      this.accountCode,
      this.customerUserId,
      this.saleEmployeeId,
      this.orderDate,
      this.orderTypeId,
      this.description,
      this.orderStatusId,
      this.statusName,
      this.uid,
      this.isSuccess,
      this.message);

  OrderResponse.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    orderNumber = json['orderNumber'];
    accountCode = json['accountCode'];
    customerUserId = json['customerUserId'];
    saleEmployeeId = json['saleEmployeeId'];
    orderDate = json['orderDate'];
    orderTypeId = json['orderTypeId'];
    description = json['description'];
    orderStatusId = json['orderStatusId'];
    statusName = json['statusName'];
    uid = json['uid'];
    isSuccess = json['isSuccess'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderId'] = orderId;
    data['orderNumber'] = orderNumber;
    data['accountCode'] = accountCode;
    data['customerUserId'] = customerUserId;
    data['saleEmployeeId'] = saleEmployeeId;
    data['orderDate'] = orderDate;
    data['orderTypeId'] = orderTypeId;
    data['description'] = description;
    data['orderStatusId'] = orderStatusId;
    data['statusName'] = statusName;
    data['uid'] = uid;
    data['isSuccess'] = isSuccess;
    data['message'] = message;
    return data;
  }
}
