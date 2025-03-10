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

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //String? _token;
  UserAuthentication? _employee;
  final DbHelper _dbHelper = DbHelper.instance;
  int orderCount = 0;
  int basketCount = 0;
  int customerCount = 0;
  bool _isLoading = true;

  _HomeState() {
    getEmployee().then((value) => setState(() {
          _employee = value;
        }));
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() async {
      orderCount = await _dbHelper.getOrderCount();
      basketCount = await _dbHelper.getBasketCount();
      customerCount = await _dbHelper.getCustomerCount();
      _isLoading = false;
    });
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push<String>(MaterialPageRoute(
                          builder: (context) => const BasketList(),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: const BorderSide(
                              style: BorderStyle.none,
                            ),
                          ),
                          padding: const EdgeInsets.all(20),
                          backgroundColor: Colors.grey.shade100),
                      child: Column(
                        children: [
                          Text(
                            "${basketCount}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.black),
                          ),
                          const SizedBox(
                            width: 100,
                            height: 10,
                          ),
                          const Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.deepOrange,
                            size: 30.0,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Basket Item",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey),
                          )
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: const BorderSide(
                              style: BorderStyle.none,
                            ),
                          ),
                          padding: const EdgeInsets.all(20),
                          backgroundColor: Colors.grey.shade100),
                      child: Column(
                        children: [
                          Text(
                            "${orderCount}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.black),
                          ),
                          const SizedBox(
                            width: 100,
                            height: 10,
                          ),
                          const Icon(
                            Icons.widgets_outlined,
                            color: Colors.deepOrange,
                            size: 30.0,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Orders",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push<String>(MaterialPageRoute(
                          builder: (context) => const CustomerList(),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: const BorderSide(
                              style: BorderStyle.none,
                            ),
                          ),
                          padding: const EdgeInsets.all(20),
                          backgroundColor: Colors.grey.shade100),
                      child: Column(
                        children: [
                          Text(
                            "${customerCount}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.black),
                          ),
                          const SizedBox(
                            width: 100,
                            height: 10,
                          ),
                          const Icon(
                            Icons.contacts_outlined,
                            color: Colors.deepOrange,
                            size: 30.0,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Customer",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 8,
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
