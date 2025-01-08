class ProductItem {
  String itemCode;
  String productCode;
  String size;

  ProductItem(this.itemCode, this.productCode, this.size);

  ProductItem.fromMap(Map<String, dynamic> m)
      : this(m['itemCode'], m['productCode'], m['size']);
}
