import 'dart:async';
import 'dart:io' show Directory;

import 'package:dveci_app/models/customeruser.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/basket.dart';
import '../models/basketfile.dart';
import '../models/dveciprefix.dart';
import '../models/saleorderrow.dart';
import '../models/userauthentication.dart';
import '../models/customer.dart';
import '../models/dvecicolor.dart';
import '../models/dvecisize.dart';
import '../models/employee.dart';
import '../models/saleorder.dart';
import '../models/saleorderstatus.dart';
import '../models/saleordertype.dart';
import '../services/sharedpreferences.dart';

class DbHelper {
  static const _databaseName = "Order.db";
  static const _databaseVersion = 1;

  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  // this opens the database (and creates it if it doesn't exist)
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    debugPrint("DB Path : $path");
    return await openDatabase(path,
        version: _databaseVersion, onCreate: createDb);
  }

  void createDb(Database db, int version) async {
    await db.execute(
        "CREATE TABLE Basket (id INTEGER PRIMARY KEY AUTOINCREMENT, qrCode NVARCHAR(50), description NVARCHAR(250), quantity INTEGER, recordDate INTEGER )");
    await db.execute(
        "CREATE TABLE BasketFile (id INTEGER PRIMARY KEY AUTOINCREMENT, basketId INTEGER, imageFile NVARCHAR(250) )");
    await db.execute(
        "CREATE TABLE Color (id INTEGER PRIMARY KEY AUTOINCREMENT, colorNumber NVARCHAR(4),colorName NVARCHAR(50), manufactureType NVARCHAR(50))");
    await db.execute(
        "CREATE TABLE Customer (accountCode NVARCHAR(20) PRIMARY KEY, customerName NVARCHAR(120),address NVARCHAR(250),taxOffice NVARCHAR(60),taxNumber NVARCHAR(20),uid TEXT)");
    await db.execute(
        "CREATE TABLE CustomerUser (id INTEGER PRIMARY KEY AUTOINCREMENT,accountCode NVARCHAR(20), contactName NVARCHAR(120),positionName NVARCHAR(100),departmentName NVARCHAR(100),phoneNumber NVARCHAR(40),emailAddress NVARCHAR(120),uid TEXT)");
    await db.execute(
        "CREATE TABLE Employee (id INTEGER PRIMARY KEY AUTOINCREMENT, employeeName NVARCHAR(120),email NVARCHAR(120),phoneNumber NVARCHAR(20),uid TEXT)");
    await db.execute(
        "CREATE TABLE SaleOrder ( id INTEGER PRIMARY KEY AUTOINCREMENT, orderId INTEGER, orderNumber NVARCHAR(20), accountCode NVARCHAR(20), customerUserId INTEGER, saleEmployeeId INTEGER, orderDate INTEGER, orderSyncDate INTEGER, orderTypeId INTEGER, description TEXT, orderStatusId INTEGER, statusName NVARCHAR(50), netTotal REAL, taxTotal REAL, grossTotal REAL, uid TEXT, recordEmployeeId INTEGER, recordIp NVARCHAR(20))");
    await db.execute(
        "CREATE TABLE SaleOrderDocument (id INTEGER PRIMARY KEY AUTOINCREMENT,saleOrderUid TEXT, saleOrderRowUid TEXT,pathName NVARCHAR(250),documentName NVARCHAR(50))");
    await db.execute(
        "CREATE TABLE SaleOrderRow ( id INTEGER PRIMARY KEY AUTOINCREMENT, orderId INTEGER, productCode NVARCHAR(40), itemCode NVARCHAR(50), qrCode NVARCHAR(50), itemColorNumber NVARCHAR(10), itemColorName NVARCHAR(150), itemSize NVARCHAR(50), itemPageNumber NVARCHAR(4), unit NVARCHAR(20), quantity REAL, unitPrice REAL, total REAL, taxRate REAL, tax REAL, amount REAL, currency NVARCHAR(4), description TEXT, rowStatusId INTEGER, orderUid TEXT, uid TEXT)");
    await db.execute(
        "CREATE TABLE SaleOrderStatus (id INTEGER PRIMARY KEY AUTOINCREMENT,statusName NVARCHAR(40),sortBy NVARCHAR(2))");
    await db.execute(
        "CREATE TABLE SaleOrderType (id INTEGER PRIMARY KEY AUTOINCREMENT, typeName NVARCHAR(50),sortBy NVARCHAR(2))");
    await db.execute(
        "CREATE TABLE Size (id INTEGER PRIMARY KEY AUTOINCREMENT,code NVARCHAR(10),digit NVARCHAR(8),unit NVARCHAR(8))");
    await db.execute(
        "CREATE TABLE UserAuthentication (id INTEGER PRIMARY KEY AUTOINCREMENT, employeeId INTEGER, employeeName NVARCHAR(120), authenticationDate INTEGER, expireDate INTEGER, uid TEXT)");
    await db.execute("CREATE TABLE Prefix (prefix NVARCHAR(2))");
  }

  // Basket
  Future<List<Basket>> getBasket() async {
    Database? db = await instance.database;

    final List<Map<String, dynamic>> maps =
        await db.query("Basket", orderBy: "recordDate DESC");

    return List.generate(maps.length, (i) {
      return Basket(
          maps[i]['id'] as int,
          maps[i]['qrCode'],
          maps[i]['description'],
          maps[i]['quantity'] as int,
          DateTime.parse(maps[i]['recordDate']));
    });
  }

  Future<Basket> getBasketItem(int id) async {
    Database? db = await instance.database;

    final List<Map<String, dynamic>> maps =
        await db.query("Basket", where: "id=?", whereArgs: [id], limit: 1);

    Basket? basket = Basket.fromMap(maps.first);

    return basket;
  }

  Future<int> addBasket(Basket basket) async {
    Database db = await instance.database;
    String sql =
        "INSERT INTO Basket (qrCode,description ,quantity, recordDate) VALUES('${basket.qrCode}','${basket.description}' ,${basket.quantity},'${basket.recordDate}');";
    return await db.rawInsert(sql);
  }

  Future<int> updateBasket(Basket basket) async {
    Database db = await instance.database;

    String sql =
        "UPDATE Basket SET qrCode = ?, description = ?, quantity = ? WHERE id = ?";
    return await db.rawUpdate(sql, [
      basket.qrCode,
      basket.description,
      basket.quantity,
      basket.id,
    ]);

    // return await db.update("Basket", basket.toMap(),
    //     where: "id=?", whereArgs: [basket.id]);
  }

  Future<int> removeBasket(int id) async {
    Database db = await instance.database;
    return await db.delete("Basket", where: "id=?", whereArgs: [id]);
  }

  Future<int> removeAllBasket() async {
    Database db = await instance.database;
    return await db.delete("Basket");
  }

  // BasketItem

  Future<List<BasketFile>?> getBasketFilesAll() async {
    Database? db = await instance.database;

    final List<Map<String, dynamic>> maps =
        await db.query("BasketFile", orderBy: "id DESC");

    return List.generate(maps.length, (i) {
      return BasketFile(maps[i]['id'] as int, maps[i]['basketId'] as int,
          maps[i]['imageFile']);
    });
  }

  Future<List<BasketFile>> getBasketFiles(int id) async {
    Database? db = await instance.database;

    final List<Map<String, dynamic>> maps = await db.query("BasketFile",
        where: "basketId=?", whereArgs: [id], orderBy: "id DESC");

    return List.generate(maps.length, (i) {
      return BasketFile(maps[i]['id'] as int, maps[i]['basketId'] as int,
          maps[i]['imageFile']);
    });
  }

  Future<int> addBasketFile(int basketId, String imageFile) async {
    Database db = await instance.database;
    String sql =
        "INSERT INTO BasketFile (basketId,imageFile) VALUES($basketId,'$imageFile');";
    return await db.rawInsert(sql);
  }

  Future<int> removeBasketFile(int id) async {
    Database db = await instance.database;
    return await db.delete("BasketFile", where: "id=?", whereArgs: [id]);
  }

  // Color
  Future<List<DveciColor>> getColors() async {
    Database db = await instance.database;

    final List<Map<String, dynamic>> maps =
        await db.query("Color", orderBy: "colorNumber");

    return List.generate(maps.length, (i) {
      return DveciColor(maps[i]['id'] as int, maps[i]['colorNumber'],
          maps[i]['colorName'], maps[i]['manufactureType']);
    });
  }

  Future<int?> addColor(DveciColor color) async {
    Database db = await instance.database;
    if (color.id != null) {
      await removeColor(color.id!);
    }

    int inserted = await db.rawInsert(
        'INSERT INTO Color (colorNumber,colorName ,manufactureType) VALUES(?,?,?)',
        [
          color.colorNumber?.trim(),
          color.colorName?.trim(),
          color.manufactureType?.trim()
        ]);

    return inserted;
  }

  Future<int> addColors(List<DveciColor> colors) async {
    Database db = await instance.database;

    await resetColor();

    for (var color in colors) {
      await db.insert(
        'Color',
        color.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    return 0;
  }

  Future<int> removeColor(int id) async {
    Database db = await instance.database;
    return await db.delete("Color", where: "id=?", whereArgs: [id]);
  }

  Future resetColor() async {
    Database db = await instance.database;
    await db.execute('DELETE FROM Color; VACUUM;');
  }

  // Size
  Future<List<DveciSize>> getSizes() async {
    Database db = await instance.database;

    final List<Map<String, dynamic>> maps =
        await db.query("Size", orderBy: "code");

    var list = List.generate(maps.length, (i) {
      return DveciSize(
          maps[i]['id'], maps[i]['code'], maps[i]['digit'], maps[i]['unit']);
    });

    debugPrint("Size List : ${list.length}");

    return list;
  }

  Future<int> addSize(DveciSize size) async {
    Database db = await instance.database;

    String sql =
        "INSERT INTO Size (code,digit ,unit) VALUES('${size.code}','${size.digit}' ,'${size.unit}');";
    return await db.rawInsert(sql);
  }

  Future<int> addSizes(List<DveciSize> sizes) async {
    Database db = await instance.database;

    await resetSize();

    for (var size in sizes) {
      await db.insert(
        'Size',
        size.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    return 0;
  }

  Future resetSize() async {
    Database db = await instance.database;
    await db.execute('DELETE FROM Size; VACUUM;');
  }

  // Employee

  Future<List<Employee>> getEmployees() async {
    Database db = await instance.database;

    final List<Map<String, dynamic>> maps =
        await db.query("Employee", orderBy: "employeeName");

    var list = List.generate(maps.length, (i) {
      return Employee(maps[i]['id'], maps[i]['employeeName'], maps[i]['email'],
          maps[i]['phoneNumber'], maps[i]['uid']);
    });

    return list;
  }

  Future<int> addEmployee(Employee employee) async {
    Database db = await instance.database;

    String sql =
        "INSERT INTO Employee (id, employeeName,email ,phoneNumber, uid) VALUES(${employee.id},'${employee.employeeName}' ,'${employee.email}','${employee.phoneNumber}','${employee.uid}');";
    return await db.rawInsert(sql);
  }

  Future resetEmployee() async {
    Database db = await instance.database;
    await db.execute('DELETE FROM Employee; VACUUM;');
  }

// Customer

  Future<List<Customer>> getCustomers() async {
    Database db = await instance.database;

    final List<Map<String, dynamic>> maps =
        await db.query("Customer", orderBy: "customerName");

    var list = List.generate(maps.length, (i) {
      return Customer(
          maps[i]['accountCode'],
          maps[i]['customerName'],
          maps[i]['address'],
          maps[i]['taxOffice'],
          maps[i]['taxNumber'],
          maps[i]['uid']);
    });
    return list;
  }

  Future<int> addCustomer(Customer customer) async {
    Database db = await instance.database;

    String sql =
        "INSERT INTO Customer (accountCode, customerName,address ,taxOffice, taxNumber, uid) VALUES(?, ?, ?, ?, ?, ?)";
    return await db.rawInsert(sql, [
      customer.accountCode,
      customer.customerName,
      customer.address,
      customer.taxOffice,
      customer.taxNumber,
      customer.uid
    ]);
  }

  Future resetCustomer() async {
    Database db = await instance.database;
    await db.execute('DELETE FROM Customer; VACUUM;');
  }

  // CustomerUser

  Future<List<CustomerUser>> getCustomerUsers() async {
    Database db = await instance.database;

    final List<Map<String, dynamic>> maps =
        await db.query("CustomerUser", orderBy: "contactName");

    var list = List.generate(maps.length, (i) {
      return CustomerUser(
          maps[i]['id'],
          maps[i]['accountCode'],
          maps[i]['contactName'],
          maps[i]['positionName'],
          maps[i]['departmentName'],
          maps[i]['phoneNumber'],
          maps[i]['emailAddress'],
          maps[i]['uid']);
    });
    return list;
  }

  Future<int> addCustomerUser(CustomerUser customerUser) async {
    Database db = await instance.database;

    String sql =
        "INSERT INTO CustomerUser (accountCode, contactName,positionName ,departmentName, phoneNumber, emailAddress, uid) VALUES(?, ?, ?, ?, ?, ?, ?)";
    return await db.rawInsert(sql, [
      customerUser.accountCode,
      customerUser.contactName,
      customerUser.positionName,
      customerUser.departmentName,
      customerUser.phoneNumber,
      customerUser.emailAddress,
      customerUser.uid
    ]);
  }

  Future resetCustomerUser() async {
    Database db = await instance.database;
    await db.execute('DELETE FROM CustomerUser; VACUUM;');
  }

  // SaleOrderStatus
  Future<List<SaleOrderStatus>> getSaleOrderStatus() async {
    Database db = await instance.database;
    var result = await db.query("SaleOrderStatus", orderBy: "sortBy");
    var statuslist = List.generate(result.length, (i) {
      return SaleOrderStatus.fromMap(result[i]);
    }).toList();
    return statuslist;
  }

  Future<int> addSaleOrderStatus(SaleOrderStatus status) async {
    Database db = await instance.database;
    return await db.insert("SaleOrderStatus", status.toMap());
  }

  // SaleOrderType
  Future<List<SaleOrderType>> getSaleOrderType() async {
    Database db = await instance.database;
    var result = await db.query("SaleOrderType", orderBy: "sortBy");
    var typelist = List.generate(result.length, (i) {
      return SaleOrderType.fromMap(result[i]);
    }).toList();
    return typelist;
  }

  Future<int> addSaleOrderType(SaleOrderType ordertype) async {
    Database db = await instance.database;
    return await db.insert("SaleOrderType", ordertype.toMap());
  }

  Future<String> getOrderTypeName(int typeId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'SaleOrderType', // Replace 'type' with your actual type table name
      where: 'id = ?', // Assuming 'id' is the primary key in your type table
      whereArgs: [typeId],
    );

    if (maps.isNotEmpty) {
      return maps.first['typeName']
          as String; // Assuming 'name' is the column for type name
    } else {
      return 'Unknown Type'; // Or handle the case where the type is not found
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Order
  Future<List<SaleOrder>> getOrders() async {
    Database? db = await instance.database;

    var maps = await db.query("SaleOrder", orderBy: "orderDate DESC");

    var list = List.generate(maps.length, (i) {
      return SaleOrder.fromMap(maps[i]);
    }).toList();

    return list;
  }

  Future<SaleOrder?> getOrder(String uid) async {
    Database? db = await instance.database;

    final List<Map<String, dynamic>> maps =
        await db.query("SaleOrder", where: "uid=?", whereArgs: [uid], limit: 1);

    SaleOrder? order = SaleOrder.fromMap(maps.first);
    return order;
  }

  // Order
  Future<List<SaleOrderRow>> getOrderRows(int orderId) async {
    Database? db = await instance.database;

    final List<Map<String, dynamic>> maps = await db.query("SaleOrderRow",
        where: "orderId=?", whereArgs: [orderId], orderBy: "id");

    return List.generate(maps.length, (i) {
      return SaleOrderRow(
          maps[i]['id'] as int,
          maps[i]['orderId'] as int,
          maps[i]['productCode'],
          maps[i]['itemCode'],
          maps[i]['qrCode'],
          maps[i]['itemColorNumber'],
          maps[i]['itemColorName'],
          maps[i]['itemSize'],
          maps[i]['itemPageNumber'] as int?,
          maps[i]['unit'],
          maps[i]['quantity'] as double,
          maps[i]['unitPrice'] as double,
          maps[i]['total'] as double,
          maps[i]['taxRate'] as double,
          maps[i]['tax'] as double,
          maps[i]['amount'] as double,
          maps[i]['currency'],
          maps[i]['description'],
          maps[i]['rowStatusId'] as int?,
          maps[i]['orderUid'],
          maps[i]['uid']);
    });
  }

  Future<int> addOrder(String orderUid, String customerCode, String userId,
      String orderTypeId, String description) async {
    Database? db = await instance.database;
    DateTime now = DateTime.now();
    var uuid = const Uuid();

    try {
      int orderId = 0;
      var _orderId = await ServiceSharedPreferences.getSharedInt("orderId");

      if (_orderId != null && _orderId > 0) {
        orderId = _orderId + 1;
      } else {
        orderId = orderId + 1;
      }
      ServiceSharedPreferences.setSharedInt("orderId", orderId);

      int userIdInt = 0;
      int orderTypeIdInt = 1;

      try {
        userIdInt = int.parse(userId);
      } catch (e) {
        userIdInt = 0;
        print("Error parsing userId: $e");
      }

      try {
        orderTypeIdInt = int.parse(orderTypeId);
      } catch (e) {
        orderTypeIdInt = 1;
        print("Error parsing orderTypeId: $e");
      }

      var user = await getUserAuthenticated();
      var basketRows = await getBasket();

      if (basketRows.isNotEmpty) {
        // Add Order Header

        String sql =
            "INSERT INTO saleOrder (orderId, orderNumber, accountCode ,customerUserId, saleEmployeeId, orderDate, orderSyncDate, orderTypeId, description, orderStatusId, statusName, netTotal, taxTotal, grossTotal, uid, recordEmployeeId, recordIp) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        await db.rawInsert(sql, [
          orderId,
          "Temp-$orderId",
          customerCode,
          userIdInt,
          user?.employeeId ?? 0,
          now.millisecondsSinceEpoch,
          now.millisecondsSinceEpoch,
          orderTypeIdInt,
          description,
          0,
          "Recorded",
          0.0,
          0.0,
          0.0,
          orderUid,
          user?.employeeId ?? 0,
          "0:0:0:0"
        ]);

        // Add Order Rows
        var order = await getOrder(orderUid);
        var colors = await getColors();
        var sizes = await getSizes();

        if (order != null) {
          for (var item in basketRows) {
            String myQrCode = item.qrCode; //"A.04441.27.66.585";
            List<String> parts = myQrCode.split(".");
            int pageNumber = 1;
            DveciColor selectedColor = colors.first;
            DveciSize selectedSize = sizes.first;

            String orderRowUid = uuid.v4();

            var filteredColor =
                colors.where((color) => color.colorNumber == parts[3]);

            if (filteredColor.isNotEmpty) {
              selectedColor = filteredColor.first;
            }

            var filteredSize =
                sizes.where((size) => size.id.toString() == parts[2]);

            if (filteredSize.isNotEmpty) {
              selectedSize = filteredSize.first;
            }

            try {
              pageNumber = int.parse(parts[4]);
            } catch (e) {
              pageNumber = 1;
              print("Error parsing pageNumber: $e");
            }

            String sqlRow =
                "INSERT INTO SaleOrderRow (orderId, productCode, itemCode, qrCode, itemColorNumber, itemColorName, itemSize, itemPageNumber, unit, quantity, unitPrice, total, taxRate, tax, amount, currency, description, rowStatusId, orderUid, uid) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            await db.rawInsert(sqlRow, [
              order.orderId,
              "${parts[0]}.${parts[1]}",
              "${parts[0]}.${parts[1]}.${parts[2]}.${parts[3]}",
              item.qrCode,
              selectedColor.colorNumber,
              "${selectedColor.colorName} -${selectedColor.manufactureType}",
              selectedSize.code,
              pageNumber,
              "AD",
              item.quantity,
              0.0,
              0.0,
              0.0,
              0.0,
              0.0,
              "TRL",
              item.description,
              0,
              order.uid,
              orderRowUid
            ]);

            // Files
            var files = await getBasketFiles(item.id);
            if (files.isNotEmpty) {
              for (var file in files) {
                String sqlFile =
                    "INSERT INTO SaleOrderDocument (saleOrderUid, saleOrderRowUid, pathName, documentName) VALUES(?, ?, ?, ?)";
                await db.rawInsert(
                    sqlFile, [order.uid, orderRowUid, file.imageFile, ""]);
              }
            }
          }
        }
        // Clean Basket
        await removeAllBasket();
      }
    } catch (e) {
      print("Error Saving Order: $e");
    }
    return 1;
  }

//Authentication
  Future<int> addUserAuthentication(UserAuthentication auth) async {
    Database db = await instance.database;
    String sql =
        "INSERT INTO UserAuthentication (employeeId,employeeName ,authenticationDate, expireDate, uid) VALUES(${auth.employeeId},'${auth.employeeName}' ,'${auth.authenticationDate}','${auth.expireDate}','${auth.uid}' );";
    return await db.rawInsert(sql);
  }

  Future<UserAuthentication?> getUserAuthentication(String uid) async {
    Database? db = await instance.database;

    final List<Map<String, dynamic>> maps = await db.query("UserAuthentication",
        where: "uid=?", whereArgs: [uid], limit: 1);

    UserAuthentication? auth = UserAuthentication.fromMap(maps.first);

    return auth;
  }

  Future<UserAuthentication?> getUserAuthenticated() async {
    Database? db = await instance.database;
    //DateTime now = DateTime.now();
    //int timestamp = now.millisecondsSinceEpoch;

    final List<Map<String, dynamic>> maps = await db.query("UserAuthentication",
        //where: "authenticationDate <= ? AND expireDate > ?",
        //whereArgs: [timestamp, timestamp],
        orderBy: "id DESC",
        limit: 1);

    UserAuthentication? auth = UserAuthentication.fromMap(maps.first);

    return auth;
  }

  // Product
  Future<List<DveciPrefix>> getPrefixes() async {
    Database db = await instance.database;

    final List<Map<String, dynamic>> maps =
        await db.query("Prefix", orderBy: "prefix");

    var list = List.generate(maps.length, (i) {
      return DveciPrefix(maps[i]['prefix']);
    });
    return list;
  }

  Future<int> addPrefix(DveciPrefix prefix) async {
    Database db = await instance.database;

    String sql = "INSERT INTO Prefix (prefix) VALUES('${prefix.prefix}');";
    return await db.rawInsert(sql);
  }

  Future<int> addPrefixes(List<DveciPrefix> prefixes) async {
    Database db = await instance.database;

    await resetPrefix();
    prefixes.add(DveciPrefix('X'));

    for (var prefix in prefixes) {
      await db.insert(
        'Prefix',
        prefix.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    return 0;
  }

  Future resetPrefix() async {
    Database db = await instance.database;
    await db.execute('DELETE FROM Prefix; VACUUM;');
  }
}
