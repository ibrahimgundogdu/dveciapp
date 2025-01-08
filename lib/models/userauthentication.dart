class UserAuthentication {
  int id;
  int? employeeId;
  String? employeeName;
  DateTime? authenticationDate;
  DateTime? expireDate;
  String? uid;

  UserAuthentication(this.id, this.employeeId, this.employeeName,
      this.authenticationDate, this.expireDate, this.uid);

  UserAuthentication.fromMap(Map<String, dynamic> m)
      : this(
            m['id'],
            m['employeeId'],
            m['employeeName'],
            DateTime.tryParse(m['authenticationDate']),
            DateTime.tryParse(m['expireDate']),
            m['uid']);
}
