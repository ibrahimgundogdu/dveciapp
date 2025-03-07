import 'package:dveci_app/models/basketfile.dart';
import 'package:dveci_app/pages/checkoutbasket.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/floating_button.dart';
import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/basket.dart';

import '../pages/addbasketitem.dart';
import '../pages/detailbasketitem.dart';

class BasketList extends StatefulWidget {
  const BasketList({super.key});

  @override
  State<BasketList> createState() => _BasketListState();
}

class _BasketListState extends State<BasketList> {
  final DbHelper _dbHelper = DbHelper.instance;

  List<Basket>? basketItems = [];
  List<BasketFile>? basketItemFiles = [];

  Future<void> _loadBasketItems() async {
    basketItemFiles = await getBasketFileItems();
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
                Navigator.of(context).pop();
                removeBasketItem(item);
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
    _loadBasketItems();
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
          "BASKET LIST",
          style: TextStyle(
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
                BasketFile? foundItem = basketItemFiles?.firstWhereOrNull(
                    (item) => item.basketId == basketitem?.id);
                return Dismissible(
                  key: UniqueKey(), // Her öğe için benzersiz bir key
                  direction: DismissDirection.endToStart, // Sola kaydırma
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
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
                          const SizedBox(
                            width: 20,
                          ),
                          basketitem.description.isNotEmpty
                              ? const Icon(
                                  Icons.speaker_notes_rounded,
                                  size: 18,
                                  color: Colors.grey,
                                )
                              : const Text(""),
                          const SizedBox(
                            width: 10,
                          ),
                          foundItem != null
                              ? const Icon(
                                  Icons.insert_photo_outlined,
                                  size: 20,
                                  color: Colors.grey,
                                )
                              : const Text("")
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
          ),
          if (basketItems != null && basketItems!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          backgroundColor: Colors.red[700],
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: const StadiumBorder())
                      .copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                  onPressed: () async {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return const CheckoutBasket();
                    }));
                  },
                  child: const Text(
                    'MAKE AN ORDER',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          const SizedBox(
            height: 20,
            child: Center(),
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

  Future<List<BasketFile>?> getBasketFileItems() async {
    var items = await _dbHelper.getBasketFilesAll();
    return items;
  }

  Future removeBasketItem(Basket item) async {
    await _dbHelper.removeBasket(item.id);

    setState(() {
      basketItems?.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item deleted!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
