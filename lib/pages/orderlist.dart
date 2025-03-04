import 'package:dveci_app/models/saleordertype.dart';
import 'package:dveci_app/pages/orderdetail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/db_helper.dart';
import '../models/saleorder.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/floating_button.dart';

class OrderList extends StatefulWidget {
  const OrderList({Key? key}) : super(key: key);

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  final DbHelper _dbHelper = DbHelper.instance;

  List<SaleOrder>? saleOrders = [];
  List<SaleOrderType>? saleOrderTypes = [];

  Future<void> _loadSaleOrders() async {
    saleOrders = await _dbHelper.getOrders();
    setState(() {});
  }

  Future<void> _loadOrderTypes() async {
    saleOrderTypes = await _dbHelper.getSaleOrderType();
    setState(() {});
  }

  Future<void> _showDeleteConfirmationDialog(int id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Order'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You want to delete Order?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Diyaloğu kapat
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Diyaloğu kapat
                //removeAllBasket(); // Silme işlemini gerçekleştir
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSaleOrders();
    _loadOrderTypes();
  }

  String getSaleOrderTypeName(
      int targetId, List<SaleOrderType>? saleOrderTypes) {
    if (saleOrderTypes == null || saleOrderTypes.isEmpty) {
      return "No Type";
    }
    try {
      SaleOrderType foundType = saleOrderTypes.firstWhere(
        (type) => type.id == targetId,
        orElse: () =>
            SaleOrderType(-2, "Not Found", "0"), // Default if not found
      );

      return foundType.typeName;
    } catch (e) {
      return "Error: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      drawer: drawerMenu(context, "D-Veci"),
      floatingActionButton: floatingButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        title: const Text(
          "ORDER LIST",
          style: TextStyle(
              color: Color(0xFFB79C91),
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Center(
                child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: saleOrders?.length ?? 0,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _showDeleteConfirmationDialog(saleOrders![index].id);
                  },
                  child: ListTile(
                      leading: Text('#${saleOrders?[index].id.toString()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: saleOrders?[index].orderStatusId == 0
                                ? Colors.deepOrange
                                : saleOrders?[index].orderStatusId == -1
                                    ? Colors.grey
                                    : Colors.black,
                          )),
                      title: Text(
                        saleOrders![index].orderNumber,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              saleOrders![index].accountCode,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.blueGrey),
                              textAlign: TextAlign.start,
                            ),
                            Text(
                              getSaleOrderTypeName(
                                  saleOrders![index].orderTypeId!,
                                  saleOrderTypes),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                              textAlign: TextAlign.start,
                            ),
                            Text(DateFormat('yyyy-MM-dd HH:mm:ss')
                                .format(saleOrders![index].orderDate!)),
                            const SizedBox(
                              width: 20,
                            ),
                            saleOrders![index].description.isNotEmpty
                                ? const Icon(
                                    Icons.speaker_notes_rounded,
                                    size: 18,
                                    color: Colors.grey,
                                  )
                                : const Text(""),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ),
                      trailing: Text(
                        saleOrders![index].statusName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      onTap: () async {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => OrderDetail(
                            orderUid: saleOrders![index].uid,
                          ),
                        ));
                      },
                      tileColor: Colors.white54),
                );
              },
              separatorBuilder: (context, index) {
                return Divider(
                  color: Colors.brown[50],
                  height: 3,
                );
              },
            )),
          ),
          const SizedBox(
            height: 20,
            child: Center(),
          )
        ],
      ),
      bottomNavigationBar: bottomWidget(context),
    );
  }
}
