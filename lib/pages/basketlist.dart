import 'package:intl/intl.dart';

import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/floating_button.dart';
import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/basket.dart';

import 'addbasketitem.dart';
import 'detailbasketitem.dart';

class BasketList extends StatefulWidget {
  const BasketList({Key? key}) : super(key: key);

  @override
  State<BasketList> createState() => _BasketListState();
}

class _BasketListState extends State<BasketList> {
  final DbHelper _dbHelper = DbHelper.instance;
  List<Basket>? basketItems = [];

  Future<void> _loadBasketItems() async {
    basketItems = await getBasketItems();
    setState(() {});
  }

  Future removeAllBasket() async {
    await _dbHelper.removeAllBasket();
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Kullanıcı butonlara tıklamalı
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You want to delete all the Basket List?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Diyaloğu kapat
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Diyaloğu kapat
                removeAllBasket(); // Silme işlemini gerçekleştir
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialogItem(Basket item) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Kullanıcı butonlara tıklamalı
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Do you want to delete item?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Diyaloğu kapat
                removeBasketItem(item); // Silme işlemini gerçekleştir
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadBasketItems(); // Sayfa ilk açıldığında basket öğelerini yükle
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      drawer: drawerMenu(context, "D-Veci"),
      floatingActionButton: floatingButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        title: const Text(
          "Basket List",
          style: const TextStyle(
              color: Color(0xFFB79C91),
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.playlist_add_outlined,
              color: Colors.black54,
              size: 24,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const AddBasketItem();
              }));
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete_rounded,
              color: Colors.red[700],
              size: 18,
            ),
            onPressed: () {
              _deleteItem();
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Center(
                child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: basketItems?.length ?? 0,
              itemBuilder: (context, index) {
                final basketitem = basketItems?[index];

                return Dismissible(
                  key: UniqueKey(), // Her öğe için benzersiz bir key
                  direction: DismissDirection.endToStart, // Sola kaydırma
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _showDeleteConfirmationDialogItem(basketitem);
                  },
                  child: ListTile(
                      leading: Text('#${basketitem?.id.toString()}',
                          style: const TextStyle(fontSize: 16)),
                      title: Text(
                        basketitem!.qrCode,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Row(
                        children: [
                          Text(DateFormat('yyyy-MM-dd HH:mm:ss')
                              .format(basketitem.recordDate!)),
                          SizedBox(
                            width: 20,
                          ),
                          basketitem.description.length > 0
                              ? Icon(
                                  Icons.speaker_notes_rounded,
                                  size: 18,
                                  color: Colors.grey,
                                )
                              : Text("")
                        ],
                      ),
                      trailing: Text(
                        basketitem.quantity.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      onTap: () async {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DetailBasketItem(
                            itemId: basketitem.id,
                          ),
                        ));
                      },
                      tileColor: Colors.white54),
                );
              },
              separatorBuilder: (context, index) {
                return Divider(
                  color: Colors.brown[50],
                  height: 3,
                );
              },
            )),
          )
        ],
      ),
      bottomNavigationBar: bottomWidget(context),
    );
  }

  void _deleteItem() async {
    await _showDeleteConfirmationDialog();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Basket List Cleaned!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<List<Basket>> getBasketItems() async {
    var items = await _dbHelper.getBasket();
    return items;
  }

  Future removeBasketItem(Basket item) async {
    await _dbHelper.removeBasket(item.id);

    setState(() {
      basketItems?.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Item deleted!')),
    );
  }
}
