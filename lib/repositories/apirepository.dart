import 'dart:convert';

import 'package:http/http.dart' as http;

import '../database/db_helper.dart';
import '../models/orderresponse.dart';

class Apirepository {
  Future<String> sendAppOrder(String uid) async {
    final DbHelper dbHelper = DbHelper.instance;

    var apiUrl = Uri.https('app.d-veci.net', 'api/Order/SaveOrder');

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    var order = await dbHelper.getOrder(uid);
    var orderRows = await dbHelper.getOrderRows(uid);
    var orderDocuments = await dbHelper.getOrderDocuments(uid);

    var body = jsonEncode({
      'order': order?.toJson(),
      'orderRows': orderRows.map((e) => e.toJson()).toList(),
      'orderDocuments': orderDocuments?.map((e) => e.toJson()).toList()
    });

    // var jsn = orderRequest.toJson();
    // final body = jsonEncode(jsn);
    //print(body);

    final response = await http.post(
      apiUrl,
      headers: headers,
      body: body,
    );

    String message = "";

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonMap = jsonDecode(response.body);
      OrderResponse orderResponse = OrderResponse.fromJson(jsonMap);
      message = orderResponse.message ?? "";
      if (orderResponse.isSuccess == true && orderResponse.uid != null) {
        await dbHelper.updateOrderFromCloud(orderResponse);
      }
    }

    return message;
  }

  Future<String> getAppOrder(String uid) async {
    final DbHelper dbHelper = DbHelper.instance;

    var apiUrl =
        Uri.https('app.d-veci.net', 'api/Order/GetOrderInfo', {'uid': uid});

    final response = await http.get(apiUrl);
    String message = "";

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonMap = jsonDecode(response.body);
      OrderResponse orderResponse = OrderResponse.fromJson(jsonMap);
      message = orderResponse.message ?? "";
      if (orderResponse.isSuccess == true && orderResponse.uid != null) {
        await dbHelper.updateOrderFromCloud(orderResponse);
      }
    }
    return message;
  }
}
