import 'package:flutter/material.dart';

import '../pages/basketlist.dart';
import '../pages/customerlist.dart';
import '../pages/home.dart';
import '../pages/orderlist.dart';

Widget bottomWidget(BuildContext context) {
  return Container(
    height: 60,
    child: BottomAppBar(
      color: Colors.transparent,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push<String>(MaterialPageRoute(
                  builder: (context) => const Home(),
                ));
              },
              icon: const Icon(
                Icons.home_filled,
                size: 24,
                color: Color(0xFF854B34),
              )),
          IconButton(
              onPressed: () {
                Navigator.of(context).push<String>(MaterialPageRoute(
                  builder: (context) => const OrderList(),
                ));
              },
              icon: const Icon(
                Icons.dataset_outlined,
                size: 24,
                semanticLabel: "Orders",
                color: Color(0xFF854B34),
              )),
          const SizedBox(
            width: 50,
          ),
          IconButton(
              onPressed: () {
                Navigator.of(context).push<String>(MaterialPageRoute(
                  builder: (context) => const CustomerList(),
                ));
              },
              icon: const Icon(
                Icons.contacts_outlined,
                size: 24,
                color: Color(0xFF854B34),
              )),
          IconButton(
              onPressed: () {
                Navigator.of(context).push<String>(MaterialPageRoute(
                  builder: (context) => const BasketList(),
                ));
              },
              icon: const Icon(
                Icons.shopping_bag_outlined,
                size: 24,
                color: Color(0xFF854B34),
              )),
        ],
      ),
    ),
  );
}
