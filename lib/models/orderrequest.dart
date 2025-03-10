import 'package:dveci_app/models/saleorder.dart';
import 'package:dveci_app/models/saleorderdocument.dart';
import 'package:dveci_app/models/saleorderrow.dart';

class OrderRequest {
  SaleOrder order;
  List<SaleOrderRow> orderRows;
  List<SaleOrderDocument>? orderDocuments;

  OrderRequest({
    required this.order,
    required this.orderRows,
    this.orderDocuments,
  });

  Map<String, dynamic> toJson() => {
        'order': order.toJson(),
        'orderRows': orderRows.map((e) => e.toJson()).toList(),
        'orderDocuments': orderDocuments?.map((e) => e.toJson()).toList(),
      };
}
