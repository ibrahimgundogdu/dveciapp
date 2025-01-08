class CustomerUser {
  int id;
  String accountCode;
  String contactName;
  String positionName;
  String departmentName;
  String phoneNumber;
  String emailAddress;
  String? uid;

  CustomerUser(this.id, this.accountCode, this.contactName, this.positionName,
      this.departmentName, this.phoneNumber, this.emailAddress, this.uid);

  CustomerUser.fromMap(Map<String, dynamic> m)
      : this(m['id'], m['accountCode'], m['contactName'], m['positionName'],
            m['departmentName'], m['phoneNumber'], m['emailAddress'], m['uid']);
}
