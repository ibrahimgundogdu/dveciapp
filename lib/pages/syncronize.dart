import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../repositories/syncrepository.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/floating_button.dart';

import 'dvecicustomers.dart';
import 'dveciemployees.dart';
import 'dveciolors.dart';
import 'dveciprefixes.dart';
import 'dvecisizes.dart';

class Syncronize extends StatefulWidget {
  const Syncronize({Key? key}) : super(key: key);

  @override
  State<Syncronize> createState() => _SyncronizeState();
}

class _SyncronizeState extends State<Syncronize> {
  final DbHelper _dbHelper = DbHelper.instance;
  late SyncRepository _repository;

  @override
  void initState() {
    _repository = SyncRepository();
    super.initState();
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
          "Syncronise",
          style: TextStyle(
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
                  onPressed: () async {
                    await _getColor();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const DveciColors()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent[700],
                      fixedSize: const Size(300, 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  child: const Text(
                    "Get Color",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                  onPressed: () async {
                    await _getSize();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const DveciSizes()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent[700],
                      fixedSize: const Size(300, 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  child: const Text(
                    "Get Sizes",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                  onPressed: () async {
                    await _getPrefix();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const DveciPrefixes()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent[700],
                      fixedSize: const Size(300, 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  child: const Text(
                    "Get Prefix",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                  onPressed: () async {
                    await _getEmployees();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const DveciEmployees()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent[700],
                      fixedSize: const Size(300, 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  child: const Text(
                    "Get Employees",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                  onPressed: () async {
                    await _getCustomers();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const DveciCustomers()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent[700],
                      fixedSize: const Size(300, 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  child: const Text(
                    "Get Customers",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                  onPressed: () {
                    _getOrderLookups();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent[700],
                      fixedSize: const Size(300, 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  child: const Text(
                    "Get Order Status & Types",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getColor() async {
    var colors = await _repository.getColors();

    if (colors.length > 0) {
      await _dbHelper.addColors(colors);
    }
  }

  Future<void> _getSize() async {
    var sizes = await _repository.getSizes();

    if (sizes.length > 0) {
      await _dbHelper.addSizes(sizes);
    }
  }

  Future<void> _getPrefix() async {
    var prefixes = await _repository.getPrefix();

    if (prefixes.length > 0) {
      await _dbHelper.addPrefixes(prefixes);
    }
  }

  Future<void> _getEmployees() async {
    var sizes = await _repository.getEmployees();

    await _dbHelper.resetEmployee();

    for (var c in sizes) {
      _dbHelper.addEmployee(c);
    }
  }

  Future<void> _getCustomers() async {
    var sizes = await _repository.getCustomers();

    await _dbHelper.resetCustomer();

    for (var c in sizes) {
      _dbHelper.addCustomer(c);
    }
  }

  void _getOrderLookups() async {
    var statuses = await _repository.getOrderStatus();

    for (var c in statuses) {
      _dbHelper.addSaleOrderStatus(c);
    }

    var types = await _repository.getOrderType();

    for (var c in types) {
      _dbHelper.addSaleOrderType(c);
    }
  }
}
