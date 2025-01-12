import '../models/customer.dart';
import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/floating_button.dart';

class CustomerList extends StatefulWidget {
  const CustomerList({super.key});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  final DbHelper _dbHelper = DbHelper.instance;
  List<Customer>? customerItems;

  List<Customer>? customerItemList = <Customer>[];
  TextEditingController editingController = TextEditingController();

  void filterSearchResults(String query) {
    List<Customer> customerItemsDummy = <Customer>[];
    customerItemsDummy.addAll(customerItems!);

    if (query.isNotEmpty) {
      List<Customer> basket = <Customer>[];

      customerItemsDummy.forEach((item) {
        if ((item.customerName ?? "")
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            (item.accountCode).toLowerCase().contains(query.toLowerCase()) ||
            (item.address ?? "").toLowerCase().contains(query.toLowerCase()) ||
            (item.taxOffice ?? "")
                .toLowerCase()
                .contains(query.toLowerCase())) {
          basket.add(item);
        }
      });

      setState(() {
        customerItemList?.clear();
        customerItemList?.addAll(basket);
      });

      return;
    } else {
      setState(() {
        customerItemList?.clear();
        customerItemList?.addAll(customerItems!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    getCustomers().then((value) => setState(() {
          customerItems = value;
        }));

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
          "CUSTOMERS",
          style: const TextStyle(
              color: Color(0xFFB79C91),
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 90,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    suffix: GestureDetector(
                      onTap: () {
                        editingController.clear();
                      },
                      child: const Icon(Icons.clear),
                    ),
                    floatingLabelAlignment: FloatingLabelAlignment.center),
              ),
            ),
          ),
          SizedBox(
            height: 30,
            child: Text((customerItemList?.length ?? 0) > 0
                ? "${customerItemList?.length ?? 0} Customers Found"
                : "Please Filter Customer"),
          ),
          Expanded(
            flex: 6,
            child: Center(
                child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: customerItemList?.length ?? 0,
              itemBuilder: (context, index) {
                return customerItemInfo(customerItemList![index]);
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
            )),
          )
        ],
      ),
    );
  }

  Widget customerItemInfo(Customer customeritem) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.amber, borderRadius: BorderRadius.circular(8)),
      child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: ListTile(
            title: Text(
              customeritem.customerName ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
                "${customeritem.accountCode} \n${customeritem.taxOffice ?? ""}  ${customeritem.taxNumber ?? ""} \n${customeritem.address ?? ""}"),
            isThreeLine: true,
          )),
    );
  }

  Future<List<Customer>> getCustomers() async {
    var items = await _dbHelper.getCustomers();
    return items;
  }
}
