import 'employee.dart';

class EmployeeResult {
  Employee? employee;
  bool? isSuccess;
  String? message;

  EmployeeResult(this.employee, this.isSuccess, this.message);

  EmployeeResult.fromMap(Map<String, dynamic> m)
      : this(m['employee'] as Employee?, m['isSuccess'] as bool,
            m['message'] as String?);

  EmployeeResult.fromJsonMap(Map<String, dynamic> map)
      : employee = Employee.fromMap(map["employee"]),
        isSuccess = map['isSuccess'] as bool,
        message = map['message'] as String?;
}
