import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../repositories/syncrepository.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';

class Syncronize extends StatefulWidget {
  const Syncronize({super.key});

  @override
  State<Syncronize> createState() => _SyncronizeState();
}

class _SyncronizeState extends State<Syncronize> {
  final DbHelper _dbHelper = DbHelper.instance;
  late SyncRepository _repository;

  bool _isColorLoading = false;
  bool _isSizeLoading = false;
  bool _isPrefixLoading = false;
  bool _isEmployeeLoading = false;
  bool _isCustomerLoading = false;
  bool _isUserLoading = false;
  bool _isStatusLoading = false;

  @override
  void initState() {
    _repository = SyncRepository();
    super.initState();
  }

  Widget _buildColorChild() {
    if (_isColorLoading) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              strokeWidth: 4.0,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Colors Synchronizing...',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      );
    } else {
      return const Text(
        'Get Colors',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
      );
    }
  }

  Widget _buildSizeChild() {
    if (_isSizeLoading) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              strokeWidth: 4.0,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Sizes Synchronizing...',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      );
    } else {
      return const Text(
        'Get Sizes',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
      );
    }
  }

  Widget _buildPrefixChild() {
    if (_isPrefixLoading) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              strokeWidth: 4.0,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Prefixes Synchronizing...',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      );
    } else {
      return const Text(
        'Get Prefixes',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
      );
    }
  }

  Widget _buildEmployeeChild() {
    if (_isEmployeeLoading) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              strokeWidth: 4.0,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Employees Synchronizing...',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      );
    } else {
      return const Text(
        'Get Employees',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
      );
    }
  }

  Widget _buildCustomerChild() {
    if (_isCustomerLoading) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              strokeWidth: 4.0,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Customers Synchronizing...',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      );
    } else {
      return const Text(
        'Get Customers',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
      );
    }
  }

  Widget _buildUserChild() {
    if (_isUserLoading) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              strokeWidth: 4.0,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Users Synchronizing...',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      );
    } else {
      return const Text(
        'Get CUsers',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
      );
    }
  }

  Widget _buildStatusChild() {
    if (_isStatusLoading) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              strokeWidth: 4.0,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Status & Types Synchronizing...',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      );
    } else {
      return const Text(
        'Get Status & Types',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      drawer: drawerMenu(context, "D-Veci"),
      bottomNavigationBar: bottomWidget(context, 0),
      appBar: AppBar(
        title: const Text(
          "Synchronise",
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
                  onPressed: _isColorLoading
                      ? null
                      : () async {
                          setState(() {
                            _isColorLoading = true;
                          });

                          int count = await _getColor();
                          var message = "$count Colors Synchronized";
                          setState(() {
                            _isColorLoading = false;
                          });

                          if (!context.mounted) {
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text(message), // Mesajı SnackBar'da göster
                              duration: const Duration(
                                  seconds:
                                      3), // SnackBar'ın görünme süresi (isteğe bağlı)
                              behavior: SnackBarBehavior
                                  .floating, // SnackBar'ın davranışını ayarla (isteğe bağlı)
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent[700],
                      fixedSize: const Size(300, 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  child: _buildColorChild()),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                  onPressed: _isSizeLoading
                      ? null
                      : () async {
                          setState(() {
                            _isSizeLoading = true;
                          });

                          int count = await _getSize();
                          var message = "$count Sizes Synchronized";
                          setState(() {
                            _isSizeLoading = false;
                          });
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text(message), // Mesajı SnackBar'da göster
                              duration: const Duration(
                                  seconds:
                                      3), // SnackBar'ın görünme süresi (isteğe bağlı)
                              behavior: SnackBarBehavior
                                  .floating, // SnackBar'ın davranışını ayarla (isteğe bağlı)
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent[700],
                      fixedSize: const Size(300, 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  child: _buildSizeChild()),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: _isPrefixLoading
                    ? null
                    : () async {
                        setState(() {
                          _isPrefixLoading = true;
                        });

                        int count = await _getPrefix();
                        var message = "$count Prefixes Synchronized";
                        setState(() {
                          _isPrefixLoading = false;
                        });
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            duration: const Duration(seconds: 3),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent[700],
                    fixedSize: const Size(300, 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                child: _buildPrefixChild(),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                  onPressed: _isEmployeeLoading
                      ? null
                      : () async {
                          setState(() {
                            _isEmployeeLoading = true;
                          });

                          int count = await _getEmployees();
                          var message = "$count Employees Synchronized";
                          setState(() {
                            _isEmployeeLoading = false;
                          });

                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent[700],
                      fixedSize: const Size(300, 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  child: _buildEmployeeChild()),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                  onPressed: _isCustomerLoading
                      ? null
                      : () async {
                          setState(() {
                            _isCustomerLoading = true;
                          });

                          int count = await _getCustomers();
                          var message = "$count Customers Synchronized";
                          setState(() {
                            _isCustomerLoading = false;
                          });

                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent[700],
                      fixedSize: const Size(300, 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  child: _buildCustomerChild()),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                  onPressed: _isUserLoading
                      ? null
                      : () async {
                          setState(() {
                            _isUserLoading = true;
                          });

                          int count = await _getCustomerUsers();
                          var message = "$count Users Synchronized";
                          setState(() {
                            _isUserLoading = false;
                          });

                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent[700],
                      fixedSize: const Size(300, 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  child: _buildUserChild()),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                  onPressed: _isStatusLoading
                      ? null
                      : () async {
                          setState(() {
                            _isStatusLoading = true;
                          });

                          String count = await _getOrderLookups();
                          var message = "$count Status|Types Synchronized";
                          setState(() {
                            _isStatusLoading = false;
                          });

                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent[700],
                      fixedSize: const Size(300, 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  child: _buildStatusChild()),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int> _getColor() async {
    var colors = await _repository.getColors();

    int count = colors.length;

    if (colors.isNotEmpty) {
      await _dbHelper.addColors(colors);
    }
    return count;
  }

  Future<int> _getSize() async {
    var sizes = await _repository.getSizes();
    int count = sizes.length;
    if (sizes.isNotEmpty) {
      await _dbHelper.addSizes(sizes);
    }
    return count;
  }

  Future<int> _getPrefix() async {
    var prefixes = await _repository.getPrefix();
    int count = prefixes.length;
    if (prefixes.isNotEmpty) {
      await _dbHelper.addPrefixes(prefixes);
    }
    return count;
  }

  Future<int> _getEmployees() async {
    var employees = await _repository.getEmployees();
    int count = employees.length;
    await _dbHelper.resetEmployee();

    for (var c in employees) {
      _dbHelper.addEmployee(c);
    }
    return count;
  }

  Future<int> _getCustomers() async {
    var customer = await _repository.getCustomers();
    int count = customer.length;
    await _dbHelper.resetCustomer();

    for (var c in customer) {
      _dbHelper.addCustomer(c);
    }
    return count;
  }

  Future<int> _getCustomerUsers() async {
    var users = await _repository.getCustomerAllUsers();
    int count = users.length;
    await _dbHelper.resetCustomerUser();

    for (var c in users) {
      _dbHelper.addCustomerUser(c);
    }
    return count;
  }

  Future<String> _getOrderLookups() async {
    var statuses = await _repository.getOrderStatus();
    int count1 = statuses.length;

    for (var c in statuses) {
      _dbHelper.addSaleOrderStatus(c);
    }

    var types = await _repository.getOrderType();
    int count2 = types.length;
    for (var c in types) {
      _dbHelper.addSaleOrderType(c);
    }
    return "$count1 | $count2";
  }
}
