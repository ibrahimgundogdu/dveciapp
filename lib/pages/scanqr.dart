import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../database/db_helper.dart';
import '../models/basket.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';

class ScanQR extends StatefulWidget {
  const ScanQR({super.key});

  @override
  State<ScanQR> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  final DbHelper _dbHelper = DbHelper.instance;
  String scannedQr = "";
  String messageState = "Wait For Scan Result";
  String message = "";
  bool isBarcodeProcessed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      drawer: drawerMenu(context, "D-Veci"),
      bottomNavigationBar: bottomWidget(context,2),
      appBar: AppBar(
        title: const Text(
          "SCAN QR",
          style: TextStyle(
              color: Color(0xFFB79C91),
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: const Color(0xFFB79C91).withValues(alpha: 0.5),
                      width: 0.0,
                    ),

                  ),
                  child: MobileScanner(

                    controller: MobileScannerController(),
                onDetect: (BarcodeCapture capture) {
                  if (isBarcodeProcessed) return;
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isEmpty) return;

                  final String? code = barcodes.first.rawValue;
                  if (code == null) return;

                  setState(() {
                    scannedQr = code;
                    messageState = "Barcode Read Success";
                    message = '';
                    isBarcodeProcessed = true;
                  });

                  if (scannedQr.isNotEmpty && scannedQr.split(".").length == 5) {
                    addbasket(scannedQr).then((_) {
                      setState(() {
                        message = "Barcode Added Basket";
                      });
                    });
                  } else {
                    setState(() {
                      message = "Barcode Not Added Basket!";
                    });
                  }
                },
              ),
                ),
              ),
            ),
          ),
          // Sonuç mesajları
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 40,
                    child: Text(
                      messageState,
                      style: const TextStyle(color: Color(0xFFB79C91)),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: Text(
                      scannedQr,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: Text(
                      message,
                      style: const TextStyle(color: Color(0xFFB79C91)),
                    ),
                  ),
                  // Tekrar tarama butonu
                  if (isBarcodeProcessed)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          scannedQr = "";
                          messageState = "Wait For Scan Result";
                          message = "";
                          isBarcodeProcessed = false;
                        });
                      },
                      child: const Text('SCAN NEW QR'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> addbasket(String qrcode) async {
    final now = DateTime.now();
    var basket = Basket(1, qrcode, '', 1, now);

    var count = await _dbHelper.addBasket(basket);
    if (count > 0) {
      debugPrint("Baskete eklendi : $qrcode");
    }
  }
}