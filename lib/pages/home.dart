import '../models/userauthentication.dart';

import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../services/sharedpreferences.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/floating_button.dart';
import 'basketlist.dart';
import 'orderlist.dart';
import 'customerlist.dart';
import 'syncronize.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //String? _token;
  UserAuthentication? _employee;
  final DbHelper _dbHelper = DbHelper.instance;

  _HomeState() {
    getEmployee().then((value) => setState(() {
          _employee = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    // GetToken();

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
          _employee?.employeeName ?? "",
          style: const TextStyle(
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
                  Navigator.of(context).push<String>(MaterialPageRoute(
                    builder: (context) => const CustomerList(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(
                        side: BorderSide(
                            style: BorderStyle.solid,
                            width: 6,
                            color: Color(0xFFDCCEC8))),
                    padding: const EdgeInsets.all(36),
                    backgroundColor: const Color(0xFFB79C91)),
                child: const Column(
                  children: [
                    Icon(
                      Icons.contacts_outlined,
                      color: Colors.white,
                      size: 30.0,
                    ),
                    Text("Customer")
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push<String>(MaterialPageRoute(
                    builder: (context) => const BasketList(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(
                        side: BorderSide(
                            style: BorderStyle.solid,
                            width: 6,
                            color: Color(0xFFDCCEC8))),
                    padding: const EdgeInsets.all(36),
                    backgroundColor: const Color(0xFFB79C91)),
                child: const Column(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 30.0,
                    ),
                    Text("Basket")
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push<String>(MaterialPageRoute(
                    builder: (context) => const OrderList(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(
                        side: BorderSide(
                            style: BorderStyle.solid,
                            width: 6,
                            color: Color(0xFFDCCEC8))),
                    padding: const EdgeInsets.all(36),
                    backgroundColor: const Color(0xFFB79C91)),
                child: const Column(
                  children: [
                    Icon(
                      Icons.widgets_outlined,
                      color: Colors.white,
                      size: 30.0,
                    ),
                    Text("Order List")
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push<String>(MaterialPageRoute(
                    builder: (context) => const Syncronize(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(
                        side: BorderSide(
                            style: BorderStyle.solid,
                            width: 6,
                            color: Color(0xFFDCCEC8))),
                    padding: const EdgeInsets.all(36),
                    backgroundColor: const Color(0xFFB79C91)),
                child: const Column(
                  children: [
                    Icon(
                      Icons.cloud_sync_outlined,
                      color: Colors.white,
                      size: 30.0,
                    ),
                    Text("Synronize")
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<UserAuthentication?> getEmployee() async {
    var _token = await ServiceSharedPreferences.getSharedString("token");
    var authUser = await _dbHelper.getUserAuthentication(_token!);
    return authUser;
  }
}
