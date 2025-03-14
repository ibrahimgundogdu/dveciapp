import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/dvecicolor.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/floating_button.dart';

class DveciColors extends StatefulWidget {
  const DveciColors({Key? key}) : super(key: key);

  @override
  State<DveciColors> createState() => _DveciColorsState();
}

class _DveciColorsState extends State<DveciColors> {
  final DbHelper _dbHelper = DbHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        drawer: drawerMenu(context, "D-Veci"),
        floatingActionButton: floatingButton(context),
        bottomNavigationBar: bottomWidget(context),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
        appBar: AppBar(
          title: const Text(
            "Actual Colors",
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
          future: _dbHelper.getColors(),
          builder:
              (BuildContext context, AsyncSnapshot<List<DveciColor>> snapshot) {
            if (snapshot.hasData) {
              return ListView.separated(
                padding: EdgeInsets.all(8),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return _colorInfo(snapshot.data![index]);
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
        )));
  }

  Widget _colorInfo(DveciColor color) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.amber[50], borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: Text(
            color.colorName.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(color.manufactureType.toString()),
          trailing: Text(
            "#${color.colorNumber}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
