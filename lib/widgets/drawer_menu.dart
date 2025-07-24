import '../pages/home.dart';
import 'package:flutter/material.dart';

import '../pages/customerlist.dart';
import '../pages/dveciolors.dart';
import '../pages/dveciprefixes.dart';
import '../pages/dvecisizes.dart';
import '../pages/login.dart';
import '../pages/orderlist.dart';
import '../pages/syncronize.dart';

Widget drawerMenu(BuildContext context, String employeeName) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Colors.brown,
          ),
          child: Row(
            children: [
              Text(
                employeeName,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
            ],
          ),
        ),
        ListTile(
          title: const Text('Home'),
          leading: const Icon(
            Icons.home_filled,
            color: Colors.brown,
            size: 20,
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const Home();
            }));
          },
        ),
        ListTile(
          title: const Text('Orders'),
          leading: const Icon(
            Icons.dataset_outlined,
            color: Colors.brown,
            size: 20,
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const OrderList();
            }));
          },
        ),
        ListTile(
          title: const Text('Customers'),
          leading: const Icon(
            Icons.corporate_fare_rounded,
            color: Colors.brown,
            size: 20,
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const CustomerList();
            }));
          },
        ),
        ListTile(
          title: const Text('Synchronise'),
          leading: const Icon(
            Icons.data_saver_off_rounded,
            color: Colors.brown,
            size: 20,
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const Syncronize();
            }));
          },
        ),
        ListTile(
          title: const Text('Size List'),
          leading: const Icon(
            Icons.storage_rounded,
            color: Colors.brown,
            size: 20,
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const DveciSizes();
            }));
          },
        ),
        ListTile(
          title: const Text('Color List'),
          leading: const Icon(
            Icons.storage_rounded,
            color: Colors.brown,
            size: 20,
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const DveciColors();
            }));
          },
        ),
        ListTile(
          title: const Text('Prefix List'),
          leading: const Icon(
            Icons.storage_rounded,
            color: Colors.brown,
            size: 20,
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const DveciPrefixes();
            }));
          },
        ),
        ListTile(
          leading: Icon(
            Icons.logout_outlined,
            color: Colors.red[700],
            size: 20,
          ),
          title: const Text('Logout'),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const LoginPage();
            }));
          },
        ),
      ],
    ),
  );
}
