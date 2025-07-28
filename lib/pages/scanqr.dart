import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../database/db_helper.dart';
import '../models/basket.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';

class ScanQR extends StatefulWidget {
  const ScanQR({super.key});

  @override
  State<ScanQR> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> with WidgetsBindingObserver {
  final DbHelper _dbHelper = DbHelper.instance;
  String scannedQr = "";
  String messageState = "Wait For Scan Result";
  String message = "";
  bool isBarcodeProcessed = false;

  late final MobileScannerController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    controller = MobileScannerController(
      autoStart: false,
      formats: [BarcodeFormat.qrCode],
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        _attemptStartCamera("initStatePostFrame");
      } else {}
    });
  }

  Future<void> _attemptStartCamera(String source) async {
    if (!mounted) {
      return;
    }

    var cameraPermissionStatus = await Permission.camera.status;

    if (!cameraPermissionStatus.isGranted) {
      cameraPermissionStatus = await Permission.camera.request();

      if (!cameraPermissionStatus.isGranted) {
        if (mounted) {
          setState(() {
            messageState = "Kamera İzni Reddedildi";
            message = "QR kod tarama özelliği için kamera izni gereklidir.";
          });
        }
        return;
      }
    }

    if (controller.value.isRunning) {
      if (mounted) {
        setState(() {
          messageState = "Kamera Aktif (Zaten Çalışıyordu)";
          message = "";
        });
      }
      return;
    }

    try {
      await controller.start();

      if (mounted) {
        if (controller.value.isRunning) {
          setState(() {
            messageState = "Camera is active";
            message = "";
          });
        } else {
          setState(() {
            messageState = "Kamera Başlatılamadı";
            message =
                "Hata: ${controller.value.error?.toString() ?? 'Bilinmeyen kamera hatası'}";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          messageState = "Kamera Başlatma Exception";
          message = e.toString();
        });
      }
    }
  }

  Future<void> _stopCamera() async {
    if (mounted && controller.value.isRunning) {
      try {
        await controller.stop();
      } catch (e) {
        //print("HATA: Kamera durdurulurken: $e");
      }
    }
  }

  Future<void> _attemptStopCamera() async {
    if (mounted && controller.value.isRunning) {
      try {
        await controller.stop();
      } catch (e) {
//
      }
    }
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _attemptStopCamera();
    await controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (!controller.value.hasCameraPermission &&
        !controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.resumed:
        _attemptStartCamera("resumedState");
        break;
      case AppLifecycleState.inactive:
        _stopCamera();
        break;
      case AppLifecycleState.paused:
        _stopCamera();
        break;
      case AppLifecycleState.detached:
        _stopCamera();
        break;
      case AppLifecycleState.hidden:
        _stopCamera();
        break;
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (isBarcodeProcessed) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null) return;

    if (mounted) {
      setState(() {
        scannedQr = code;
        messageState = "Barcode Read Success";
        message = '';
        isBarcodeProcessed = true;
      });
    }

    _processScannedCode(code);
  }

  Future<void> _processScannedCode(String code) async {
    String successMessage = "Barcode Not Added Basket!";
    if (code.isNotEmpty && code.split(".").length == 5) {
      try {
        await addbasket(code);
        successMessage = "Barcode Added Basket";
      } catch (e) {
        successMessage = "Error adding to basket!";
      }
    }

    if (mounted) {
      setState(() {
        message = successMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      drawer: drawerMenu(context, "D-Veci"),
      bottomNavigationBar: bottomWidget(context, 2),
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
                    controller: controller,
                    // <--- Oluşturulan controller'ı kullan
                    onDetect: _onDetect, // <--- onDetect metodunu kullan
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
