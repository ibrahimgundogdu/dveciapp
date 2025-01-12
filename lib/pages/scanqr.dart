import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../database/db_helper.dart';
import '../models/basket.dart';
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
  String scannedQr = "";
  String messageState = "Wait For Scan Result";
  String message = "";

  Future<void> scanQRCode() async {
    String barcodeScanRes;

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      scannedQr = barcodeScanRes == "-1" ? "" : barcodeScanRes;
      messageState = "Barcode Read Success";

      if (scannedQr.length > 0 && scannedQr.split(".").length == 5) {
        await addbasket(scannedQr);
        message = "Barcode Added Basket";
      } else {
        message = "Barcode Not Added Basket!";
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
      scannedQr = barcodeScanRes;
      messageState = "Barcode Cannot Be Read";
    }
    setState(() {});
    if (!mounted) return;
  }

  @override
  void initState() {
    super.initState();
    scanQRCode();
  }

  @override
  Widget build(BuildContext context) {
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
            "Scan QR",
            style: TextStyle(
                color: Color(0xFFB79C91),
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                child: Text(
                  messageState,
                  style: TextStyle(color: Color(0xFFB79C91)),
                ),
              ),
              SizedBox(
                height: 60,
                child: Text(
                  scannedQr,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange),
                ),
              ),
              SizedBox(
                height: 50,
                child: Text(
                  message,
                  style: TextStyle(color: Color(0xFFB79C91)),
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> addbasket(String qrcode) async {
    final now = DateTime.now();
    var basket = Basket(1, qrcode, '', 1, now);

    var count = await _dbHelper.addBasket(basket);
    if (count > 0) {
      debugPrint("Baskete eklendi : ${qrcode}");
    }
  }
}
