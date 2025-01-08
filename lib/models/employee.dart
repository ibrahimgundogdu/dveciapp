class Employee {
  int? id;
  String? employeeName;
  String? email;
  String? phoneNumber;
  String? uid;

  Employee(this.id, this.employeeName, this.email, this.phoneNumber, this.uid);

  Employee.fromMap(Map<String, dynamic> m)
      : this(
          m['id'] as int,
          m['employeeName'] as String,
          m['email'] as String?,
          m['phoneNumber'] as String?,
          m['uid'] as String?,
        );
}
