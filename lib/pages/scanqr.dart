import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../database/db_helper.dart';
import '../models/basket.dart';
import 'detailbasketitem.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/floating_button.dart';

class ScanQR extends StatefulWidget {
  const ScanQR({Key? key}) : super(key: key);

  @override
  State<ScanQR> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  final DbHelper _dbHelper = DbHelper.instance;
  List<Basket>? basketItems;
  var getResult = "QR Code Read";

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
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      bottomNavigationBar: bottomWidget(context),
      appBar: AppBar(
        title: Text(
          getResult,
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
                return _BasketItemInfo(basketItems![index]);
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

  Future<void> addbasket(String qrcode) async {
    final now = DateTime.now();
    var basket = Basket(1, qrcode, '', 1, now);

    var count = await _dbHelper.addBasket(basket);
    if (count > 0) {
      debugPrint("Baskete eklendi : ${qrcode}");
      getBasketItems().then((value) => setState(() {
            basketItems = value;
          }));
    }
  }

  Widget _BasketItemInfo(Basket basketitem) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.amber, borderRadius: BorderRadius.circular(8)),
      child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListTile(
            leading: Icon(Icons.qr_code_outlined),
            title: Text(
              basketitem.qrCode,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(basketitem.recordDate.toString()),
            trailing: Text(
              basketitem.quantity.toString(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

  void scanQRCode() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      if (!mounted) return;

      if (qrCode != "-1") {
        await addbasket(qrCode);

        setState(() {
          getResult = qrCode;
        });
      }

      debugPrint("QR KOD OKUNDU : ${qrCode}");
    } on PlatformException {
      getResult = "No Read";
    }
  }
}
