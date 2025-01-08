import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/dvecisize.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/floating_button.dart';

class DveciSizes extends StatefulWidget {
  const DveciSizes({Key? key}) : super(key: key);

  @override
  State<DveciSizes> createState() => _DveciSizesState();
}

class _DveciSizesState extends State<DveciSizes> {
  final DbHelper _dbHelper = DbHelper.instance;

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
            "Actual Sizes",
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
          future: _dbHelper.getSizes(),
          builder:
              (BuildContext context, AsyncSnapshot<List<DveciSize>> snapshot) {
            if (snapshot.hasData) {
              return ListView.separated(
                padding: EdgeInsets.all(8),
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (context, index) {
                  return _sizeInfo(snapshot.data![index]);
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
              );
            } else {
              return const Center(
                  child: CircularProgressIndicator() //Text("No Size"),
                  );
            }
          },
        )));
  }

  Widget _sizeInfo(DveciSize size) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.amber[50], borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListTile(
          leading: const Icon(Icons.straighten_outlined),
          title: Text(
            size.code.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text("Digit : ${size.digit}  Unit : ${size.unit}"),
          trailing: Text(
            "#${size.id}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
