class Product {
  String productCode;
  double? taxRate = 0;
  String currency;
  String uid;
  String image;

  Product(this.productCode, this.taxRate, this.currency, this.uid, this.image);

  Product.fromMap(Map<String, dynamic> m)
      : this(m['productCode'], m['taxRate'], m['currency'], m['uid'],
            m['image']);
}
