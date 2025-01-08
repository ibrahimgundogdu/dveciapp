import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/floating_button.dart';
import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/basket.dart';
import 'addbasket.dart';
import 'detailbasketitem.dart';

class BasketList extends StatefulWidget {
  const BasketList({Key? key}) : super(key: key);

  @override
  State<BasketList> createState() => _BasketListState();
}

class _BasketListState extends State<BasketList> {
  final DbHelper _dbHelper = DbHelper.instance;
  List<Basket>? basketItems;

  @override
  Widget build(BuildContext context) {
    getBasketItems().then((value) => setState(() {
          basketItems = value;
        }));

    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        drawer: drawerMenu(context, "D-Veci"),
        floatingActionButton: floatingButton(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        appBar: AppBar(
          title: const Text(
            "Basket List",
            style: const TextStyle(
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
                itemCount: basketItems?.length ?? 0,
                itemBuilder: (context, index) {
                  return basketItemInfo(basketItems![index]);
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
              )),
            )
          ],
        ),
        bottomNavigationBar: bottomWidget(context));
  }

  Widget basketItemInfo(Basket basketitem) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.amber, borderRadius: BorderRadius.circular(8)),
      child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListTile(
            leading: const Icon(Icons.qr_code_outlined),
            title: Text(
              basketitem.qrCode,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(basketitem.recordDate.toString()),
            trailing: Text(
              basketitem.quantity.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onLongPress: () async {
              removeBasketItem(basketitem.id).then((value) => (value) => null);
              getBasketItems().then((value) => setState(() {
                    basketItems = value;
                  }));

              // if (await confirm(context,
              //     content: const Text("Are you sure delete this item?"))) {
              //
              // }
            },
            onTap: () async {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DetailBasketItem(
                  itemCode: basketitem.qrCode,
                ),
              ));
              // if (await confirm(context,
              //     content: const Text("Are you sure go to detail?"))) {
              //
              // }
            },
          )),
    );
  }

  Future<List<Basket>> getBasketItems() async {
    var items = await _dbHelper.getBasket();
    return items;
  }

  Future removeBasketItem(int id) async {
    await _dbHelper.removeBasket(id);
  }
}
