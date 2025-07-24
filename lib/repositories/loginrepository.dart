import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/employeeresult.dart';
import '../models/loginresult.dart';

class LoginRepository {
  Future<LoginResult?> getToken(String email, String password) async {
    var url = Uri.https('app.d-veci.net', '/api/Employee/GetUserToken',
        {'email': email, 'password': password});

    var response = await http.get(url);
    if (response.statusCode == 200) {
      return LoginResult.fromMap(
          json.decode(response.body) as Map<String, dynamic>);
    }
    return null;
  }

  Future<EmployeeResult?> getEmployee(String? token) async {
    var url = Uri.https(
        'app.d-veci.net', '/api/Employee/CheckUserToken', {'token': token});

    var response = await http.get(url);

    if (response.statusCode == 200) {
      return EmployeeResult.fromJsonMap(
          json.decode(response.body) as Map<String, dynamic>);
    }
    return null;
  }
}
