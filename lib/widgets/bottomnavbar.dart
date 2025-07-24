import 'package:flutter/material.dart';

import '../pages/basketlist.dart';
import '../pages/customerlist.dart';
import '../pages/home.dart';
import '../pages/orderlist.dart';
import '../pages/scanqr.dart';

Widget bottomWidget(BuildContext context, int currentIndex) {


  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.radio_button_checked_outlined),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.corporate_fare_outlined),
        label: 'Customer',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.qr_code_rounded),
        label: 'Scan QR',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag_outlined),
        label: 'Basket',
      ),

      BottomNavigationBarItem(
        icon: Icon(Icons.folder_copy_outlined),
        label: 'Orders',
      ),
    ],
    elevation: 0,
    currentIndex: currentIndex,
    backgroundColor: Colors.white,
    selectedItemColor: Colors.deepOrange,
    unselectedItemColor: Colors.grey,
    iconSize: 24,
    selectedFontSize: 11,
    unselectedFontSize: 11,
    onTap: (index) {
      if (index == 0) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return const Home();
        }));
      }
      if (index == 1) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return const CustomerList();
        }));
      }
      if (index == 2) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return const ScanQR();
        }));
      }
      if (index == 3) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return const BasketList();
        }));
      }

      if (index == 4) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return const OrderList();
        }));
      }
    },
  );
}
