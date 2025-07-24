import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/customer.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';

class DveciCustomers extends StatefulWidget {
  const DveciCustomers({super.key});

  @override
  State<DveciCustomers> createState() => _DveciCustomersState();
}

class _DveciCustomersState extends State<DveciCustomers> {
  final DbHelper _dbHelper = DbHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      drawer: drawerMenu(context, "D-Veci"),
      bottomNavigationBar: bottomWidget(context, 1),
      appBar: AppBar(
        title: const Text(
          "Actual Customers",
          style: TextStyle(
              color: Color(0xFFB79C91),
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
          child: FutureBuilder(
        future: _dbHelper.getCustomers(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Customer>> snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                return _customerInfo(snapshot.data![index]);
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      )),
    );
  }

  Widget _customerInfo(Customer customer) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.amber[50], borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListTile(
          leading: const Icon(Icons.business),
          title: Text(
            customer.customerName ?? "",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
              "Address : ${customer.address ?? ""} \nAccountCode : ${customer.accountCode} \nTax Office : ${customer.taxOffice ?? ""} \nTax Number : ${customer.taxNumber ?? ""}"),
          isThreeLine: true,
        ),
      ),
    );
  }
}
