class ProductImage {
  String productCode;
  String fileName;
  String sortBy;

  ProductImage(this.productCode, this.fileName, this.sortBy);

  ProductImage.fromMap(Map<String, dynamic> m)
      : this(m['productCode'], m['fileName'], m['sortBy']);
}
