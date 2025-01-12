import 'package:flutter/material.dart';

import '../pages/scanqr.dart';

Widget floatingButton(BuildContext context) {
  return FloatingActionButton(
    onPressed: () async {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return const ScanQR();
      }));
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
