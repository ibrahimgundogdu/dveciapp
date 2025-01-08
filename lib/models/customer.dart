class Customer {
  String accountCode;
  String? customerName;
  String? address;
  String? taxOffice;
  String? taxNumber;
  String? uid;

  Customer(this.accountCode, this.customerName, this.address, this.taxOffice,
      this.taxNumber, this.uid);

  Customer.fromMap(Map<String, dynamic> m)
      : this(m['accountCode'], m['customerName'], m['address'], m['taxOffice'],
            m['taxNumber'], m['uid']);
}
