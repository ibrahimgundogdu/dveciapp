import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/saleorder.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/floating_button.dart';
import 'addbasket.dart';

class OrderList extends StatefulWidget {
  const OrderList({Key? key}) : super(key: key);

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  final DbHelper _dbHelper = DbHelper.instance;
  List<SaleOrder>? customerItems;

  @override
  Widget build(BuildContext context) {
    getOrders().then((value) => setState(() {
          customerItems = value;
        }));

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      drawer: drawerMenu(context, "D-Veci"),
      floatingActionButton: floatingButton(context),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      bottomNavigationBar: bottomWidget(context),
      appBar: AppBar(
        title: const Text(
          "Order List",
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
              itemCount: customerItems?.length ?? 0,
              itemBuilder: (context, index) {
                return orderItemInfo(customerItems![index]);
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
            )),
          )
        ],
      ),
    );
  }

  Widget orderItemInfo(SaleOrder orderitem) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.amber, borderRadius: BorderRadius.circular(8)),
      child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListTile(
            leading: const Icon(Icons.person_off_outlined),
            title: Text(
              orderitem.orderNumber,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(orderitem.accountCode),
            trailing: Text(
              orderitem.orderDate.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          )),
    );
  }

  Future<List<SaleOrder>> getOrders() async {
    var items = await _dbHelper.getOrders();
    return items;
  }
}
