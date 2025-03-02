import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../models/customer.dart';
import '../models/customeruser.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../database/db_helper.dart';
import '../models/basket.dart';

import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/floating_button.dart';

import '../pages/basketlist.dart';

class CheckoutBasket extends StatefulWidget {
  const CheckoutBasket({super.key});

  @override
  State<CheckoutBasket> createState() => _CheckoutBasketState();
}

class _CheckoutBasketState extends State<CheckoutBasket> {
  final DbHelper _dbHelper = DbHelper.instance;

  TextEditingController customerCode = TextEditingController();
  TextEditingController customerCodeFull = TextEditingController();

  TextEditingController userId = TextEditingController();
  TextEditingController userName = TextEditingController();

  TextEditingController description = TextEditingController();

  late List<Customer>? customers = [];
  late List<CustomerUser>? customerUsers = [];
  late List<CustomerUser>? filteredCustomerUsers = [];
  late List<Basket>? basketItems = [];
  late List<Customer>? _filteredCustomers = [];
  String _searchQuery = '';

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    customerCodeFull.text = "120.00.00 - No Customer";
    userName.text = "#0 - No Contact";

    _loadCustomers();
    _loadCustomerUsers();
    _loadBasketItems();

    InitBasketLookup();
  }

  void InitBasketLookup() async {
    description.text = "";
    setState(() {});
  }

  Future<void> _loadCustomers() async {
    customers = await _dbHelper.getCustomers();
    _filteredCustomers = customers;
  }

  Future<List<CustomerUser>?> _loadCustomerUsers() async {
    customerUsers = await _dbHelper.getCustomerUsers();
    return customerUsers;
  }

  Future<void> _loadBasketItems() async {
    basketItems = await _dbHelper.getBasket();
  }

  Future<void> _filterCustomerUsers() async {
    filteredCustomerUsers = customerUsers
        ?.where((user) => user.accountCode == customerCode.text)
        .toList();
    setState(() {});
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
        elevation: 0,
        centerTitle: true,
        title: const Text("MAKE AN ORDER",
            style: TextStyle(
                color: Color(0xFFB79C91),
                fontSize: 14,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: formKey,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Column(
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  "COSTUMER",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0XFF1B5E20),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: customerCodeFull,
                              readOnly: true,
                              onTap: () {
                                _showCustomerBottomSheet(context);
                              },
                              textAlign: TextAlign.start,
                              validator: (value) {
                                if (value != null) {
                                  if (value.isEmpty) {
                                    return 'Customer Code Required';
                                  }
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                counterText: '',
                                fillColor: Color(0xFFF4F5F7),
                                alignLabelWithHint: true,
                                hintText: "120.00.00",
                                hintStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0XFFC0C7D1)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 1, vertical: 12),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            ),
                          ],
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Column(
                          children: [
                            Container(
                              child: const Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text("CUSTOMER USER",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0XFF1B5E20),
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                            Container(
                              child: TextFormField(
                                controller: userName,
                                readOnly: true,
                                onTap: () {
                                  _showUserBottomSheet(context);
                                },
                                textAlign: TextAlign.start,
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: true,
                                  fillColor: Color(0xFFF4F5F7),
                                  alignLabelWithHint: true,
                                  hintText: "#0",
                                  hintStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0XFFC0C7D1)),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 1, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value != null) {
                                    if (value.isEmpty) {
                                      userId.text = "0";
                                      return null;
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text("DESCRIPTION",
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0XFF1B5E20),
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Color(0XFFF4F5F7),
                          ),
                          child: TextFormField(
                            controller: description,
                            onChanged: (value) {},
                            keyboardType: TextInputType.multiline,
                            maxLines: 6,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF4F5F7),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ), //TextArea
                        const SizedBox(
                          height: 16.0,
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    shape: StadiumBorder())
                                .copyWith(
                                    elevation:
                                        ButtonStyleButton.allOrNull(0.0)),
                            onPressed: () async {
                              final formIsValid =
                                  formKey.currentState?.validate();
                              if (formIsValid == true) {
                                //addbasket(itemCode, description.text);

                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return const BasketList();
                                }));
                              }
                            },
                            child: const Text(
                              'SAVE AN ORDER',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ), //Button
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomerBottomSheet(BuildContext context) {
    _filteredCustomers = List.from(customers ?? []);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(// StatefulBuilder ekleyin
            builder: (BuildContext context, StateSetter setState) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                height: constraints.maxHeight * 0.8,
                child: Column(children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Select Customer',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Customer',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _filteredCustomers = customers!
                              .where((customer) =>
                                  customer.accountCode
                                      .toLowerCase()
                                      .contains(_searchQuery.toLowerCase()) ||
                                  customer.customerName!
                                      .toLowerCase()
                                      .contains(_searchQuery.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _filteredCustomers?.length ?? 0,
                      itemBuilder: (context, index) {
                        return ListTile(
                          tileColor: Colors.transparent,
                          leading: Text(
                            _filteredCustomers![index].accountCode,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: customerCode.text ==
                                        _filteredCustomers?[index].accountCode
                                    ? Colors.green[700]
                                    : Colors.black),
                          ),
                          title: Text(
                            _filteredCustomers![index].customerName ?? "",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: customerCode.text ==
                                        _filteredCustomers![index].accountCode
                                    ? FontWeight.w900
                                    : FontWeight.normal,
                                color: customerCode.text ==
                                        _filteredCustomers![index].accountCode
                                    ? Colors.green[700]
                                    : Colors.black),
                          ),
                          onTap: () {
                            customerCode.text =
                                _filteredCustomers![index].accountCode;
                            customerCodeFull.text =
                                "${_filteredCustomers![index].accountCode} - ${_filteredCustomers![index].customerName}";

                            userId.text = '0';
                            userName.text = '#0 - No User';
                            Navigator.pop(context);
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          color: Colors.grey[200],
                          thickness: 1,
                          height: 1,
                        );
                      },
                    ),
                  ),
                ]),
              );
            },
          );
        });
      },
    );
  }

  void _showUserBottomSheet(BuildContext context) {
    _filterCustomerUsers();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              height: constraints.maxHeight * 0.69, // Ekranın %60'ı
              child: Column(children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Select Customer User',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: filteredCustomerUsers?.length ?? 0,
                    itemBuilder: (context, index) {
                      return ListTile(
                        tileColor: Colors.transparent,
                        leading: Text(
                          '#${filteredCustomerUsers![index].id}',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: userId.text ==
                                      '${filteredCustomerUsers![index].id}'
                                  ? Colors.green[700]
                                  : Colors.black),
                        ),
                        title: Text(filteredCustomerUsers![index].contactName,
                            style: TextStyle(
                                fontSize: 16,
                                color: userId.text ==
                                        '${filteredCustomerUsers![index].id}'
                                    ? Colors.green[700]
                                    : Colors.black)),
                        subtitle: Text(
                            '${filteredCustomerUsers![index].departmentName} - <${filteredCustomerUsers![index].emailAddress}>',
                            style: TextStyle(
                                fontSize: 12,
                                color: userId.text ==
                                        '${filteredCustomerUsers![index].id}'
                                    ? Colors.green[700]
                                    : Colors.black)),
                        onTap: () {
                          userId.text = '${filteredCustomerUsers![index].id}';
                          userName.text =
                              '#${filteredCustomerUsers![index].id} - ${filteredCustomerUsers![index].contactName}';

                          Navigator.pop(context);
                        },
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider(
                        color: Colors.grey[200],
                        thickness: 1,
                        height: 1,
                      );
                    },
                  ),
                ),
              ]),
            );
          },
        );
      },
    );
  }
}
