import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../database/db_helper.dart';
import '../models/order_document.dart';
import '../models/orderresponse.dart';
import 'package:mime/mime.dart';

class Apirepository {
  Future<String> sendAppOrder(String uid) async {
    final DbHelper dbHelper = DbHelper.instance;

    var apiUrl = Uri.https('app.d-veci.net', 'api/Order/SaveOrder');

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    var order = await dbHelper.getOrder(uid);
    var orderRows = await dbHelper.getOrderRows(uid);
    var orderDocuments = await dbHelper.getOrderAllDocuments(uid);

    if (order == null) {
      return "Gönderilecek sipariş bulunamadı.";
    }

    List<OrderDocument> orderDocumentsForPayload = [];
    if (orderDocuments != null) {
      for (var saleDoc in orderDocuments) {
        if (saleDoc.pathName != null && saleDoc.pathName!.isNotEmpty) {
          try {
            File file = File(saleDoc.pathName!);
            if (await file.exists()) {
              List<int> imageBytes = await file.readAsBytes();
              String base64Image = base64Encode(imageBytes);

              orderDocumentsForPayload.add(OrderDocument(
                saleOrderUid: uid,
                saleOrderRowUid: saleDoc.saleOrderRowUid,
                pathName: saleDoc.pathName ??
                    Uri.file(saleDoc.pathName!).pathSegments.last,
                documentName: saleDoc.documentName,
                documentBase64: base64Image,
                mimeType: lookupMimeType(saleDoc.pathName!) ?? 'image/jpeg',
              ));
            } else {
              //print('Dosya bulunamadı: ${saleDoc.pathName}');
            }
          } catch (e) {
            // print('Dosya okunurken veya Base64\'e çevrilirken hata (${saleDoc.pathName}): $e');
          }
        }
      }
    }

    var body = jsonEncode({
      'order': order.toJson(),
      'orderRows': orderRows.map((e) => e.toJson()).toList(),
      'orderDocuments': orderDocumentsForPayload.map((e) => e.toJson()).toList()
    });

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
        message = "Order Sent Successfully.";
      }
    } else {
      message = "Order Send Error.";
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
