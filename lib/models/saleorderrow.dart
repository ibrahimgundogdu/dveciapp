class SaleOrderRow {
  int id;
  int orderId;
  String productCode;
  String itemCode;
  String qrCode;
  String itemColorNumber;
  String itemColorName;
  String itemSize;
  int? itemPageNumber = 0;
  String unit;
  double? quantity = 1;
  double? unitPrice = 0;
  double? total;
  double? taxRate;
  double? tax;
  double? amount;
  String currency;
  String description;
  int? rowStatusId;
  String uid;

  SaleOrderRow(
      this.id,
      this.orderId,
      this.productCode,
      this.itemCode,
      this.qrCode,
      this.itemColorNumber,
      this.itemColorName,
      this.itemSize,
      this.itemPageNumber,
      this.unit,
      this.quantity,
      this.unitPrice,
      this.total,
      this.taxRate,
      this.tax,
      this.amount,
      this.currency,
      this.description,
      this.rowStatusId,
      this.uid);

  SaleOrderRow.fromMap(Map<String, dynamic> m)
      : this(
            m['id'],
            m['orderId'],
            m['productCode'],
            m['itemCode'],
            m['qrCode'],
            m['itemColorNumber'],
            m['itemColorName'],
            m['itemSize'],
            m['itemPageNumber'],
            m['unit'],
            m['quantity'],
            m['unitPrice'],
            m['total'],
            m['taxRate'],
            m['tax'],
            m['amount'],
            m['currency'],
            m['description'],
            m['rowStatusId'],
            m['uid']);
}

//CREATE TABLE SaleOrderRow (
// ID INTEGER PRIMARY KEY AUTOINCREMENT,
// OrderId INTEGER,
// ProductCode NVARCHAR(40),
// ItemCode NVARCHAR(50),
// QRCode NVARCHAR(50),
// ItemColorNumber NVARCHAR(10),
// ItemColorName NVARCHAR(150),
// ItemSize NVARCHAR(50),
// ItemPageNumber NVARCHAR(4),
// Unit NVARCHAR(20),
// Quantity REAL,
// UnitPrice REAL,
// Total REAL,
// TaxRate REAL,
// Tax REAL,
// Amount REAL,
// Currency NVARCHAR(4),
// Description TEXT,
// RowStatusID INTEGER,
// UID TEXT
// )
