import '../pages/scanqr.dart';
import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';
import 'addbasketitem.dart';

class AddBasket extends StatelessWidget {
  const AddBasket({super.key});

  @override
  Widget build(BuildContext context) {
    final DbHelper dbHelper = DbHelper.instance;

    Future removeAllBasket() async {
      await dbHelper.removeAllBasket();
    }

    return Scaffold(
        backgroundColor: const Color(0XFFF4F5F7),
        drawer: drawerMenu(context, "D-Veci"),
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            "Add Item to Basket",
            style: TextStyle(
                color: Color(0xFFB79C91),
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return const AddBasketItem();
                    }));
                  },
                  style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(
                          side: BorderSide(
                              style: BorderStyle.solid,
                              width: 6,
                              color: Color(0xFFEAEFFF))),
                      padding: const EdgeInsets.all(36),
                      backgroundColor: const Color(0xFF6E7B89)),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.touch_app_outlined,
                        color: Colors.white,
                        size: 40.0,
                      ),
                      Text("Manuel")
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return const ScanQR();
                    }));
                  },
                  style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(
                          side: BorderSide(
                              style: BorderStyle.solid,
                              width: 6,
                              color: Color(0xFFDCCEC8))),
                      padding: const EdgeInsets.all(33),
                      backgroundColor: const Color(0xFFB79C91)),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.qr_code_2_outlined,
                        color: Colors.white,
                        size: 40.0,
                      ),
                      Text("Scan QR")
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await removeAllBasket();
                    // if (await confirm(context,
                    //     title: Text("Clear to Basket"),
                    //     content: Text("Are you sure that Clean a Basket?"))) {
                    //   await removeAllBasket();
                    // }
                  },
                  style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(
                          side: BorderSide(
                              style: BorderStyle.solid,
                              width: 6,
                              color: Color(0xFFFF9797))),
                      padding: const EdgeInsets.all(40),
                      backgroundColor: const Color(0xFFD60000)),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.delete_forever_outlined,
                        color: Colors.white,
                        size: 40.0,
                      ),
                      Text("Clean")
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: bottomWidget(context, 2));
  }

//void _onItemTapped(int value) {}
}
