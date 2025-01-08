import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../models/dveciprefix.dart';
import '../models/dvecisize.dart';
import '../models/employee.dart';
import '../models/customer.dart';
import '../models/dvecicolor.dart';
import '../models/saleorderstatus.dart';
import '../models/saleordertype.dart';

class SyncRepository {
  Future<List<DveciColor>> getColors() async {
    var url = Uri.https('app.d-veci.net', '/api/Sync/GetColors');
    List<DveciColor> colors = <DveciColor>[];
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final List result = json.decode(response.body);
      debugPrint("Result : $result");
      return result.map((e) => DveciColor.fromMap(e)).toList();
    }
    return colors;
  }

  Future<List<DveciSize>> getSizes() async {
    var url = Uri.https('app.d-veci.net', '/api/Sync/GetSizes');
    List<DveciSize> sizes = <DveciSize>[];
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final List result = json.decode(response.body);
      return result.map((e) => DveciSize.fromMap(e)).toList();
    }
    return sizes;
  }

  Future<List<DveciPrefix>> getPrefix() async {
    var url = Uri.https('app.d-veci.net', '/api/Product/GetPrefix');
    List<DveciPrefix> prefixes = <DveciPrefix>[];
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final List result = json.decode(response.body);
      return result.map((e) => DveciPrefix.fromMap(e)).toList();
    }
    return prefixes;
  }

  Future<List<Employee>> getEmployees() async {
    var url = Uri.https('app.d-veci.net', '/api/Employee/GetEmployees');
    List<Employee> employees = <Employee>[];
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final List result = json.decode(response.body);
      return result.map((e) => Employee.fromMap(e)).toList();
    }
    return employees;
  }

  Future<List<Customer>> getCustomers() async {
    var url = Uri.https('app.d-veci.net', '/api/Customer/GetAllCustomer');
    List<Customer> customers = <Customer>[];
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final List result = json.decode(response.body);
      return result.map((e) => Customer.fromMap(e)).toList();
    }
    return customers;
  }

  Future<List<SaleOrderStatus>> getOrderStatus() async {
    var url = Uri.https('app.d-veci.net', '/api/Sync/GetOrderStatus');
    List<SaleOrderStatus> statuses = <SaleOrderStatus>[];
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final List result = json.decode(response.body);
      return result.map((e) => SaleOrderStatus.fromMap(e)).toList();
    }
    return statuses;
  }

  Future<List<SaleOrderType>> getOrderType() async {
    var url = Uri.https('app.d-veci.net', '/api/Sync/GetOrderTypes');
    List<SaleOrderType> ordertypes = <SaleOrderType>[];
    var response = await http.get(url);
    if (response.statusCode == 200) {
      final List result = json.decode(response.body);
      return result.map((e) => SaleOrderType.fromMap(e)).toList();
    }
    return ordertypes;
  }
}
