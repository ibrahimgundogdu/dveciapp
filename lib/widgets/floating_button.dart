import 'package:flutter/material.dart';

import '../pages/addbasket.dart';

Widget floatingButton(BuildContext context) {
  return FloatingActionButton(
    onPressed: () async {
      //scanQRCode();
      var qrCode = await Navigator.of(context).push<String>(MaterialPageRoute(
        builder: (context) => const AddBasket(),
      ));

      if (qrCode != null) {
        debugPrint("Okunan Barkod : $qrCode");
      }
    },
    backgroundColor: Colors.black87,
    elevation: 4,
    mini: true,
    child: const Icon(
      Icons.qr_code_rounded,
      color: Color(0XFFFFFFFF),
      size: 24,
    ),
  );
}
