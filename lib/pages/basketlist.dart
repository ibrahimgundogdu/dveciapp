import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/basketfile.dart';
import '../pages/checkoutbasket.dart';
import '../database/db_helper.dart';
import '../models/basket.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';
import 'addbasketitem.dart';
import 'detailbasketitem.dart';

class BasketList extends StatefulWidget {
  const BasketList({super.key});

  @override
  State<BasketList> createState() => _BasketListState();
}

class _BasketListState extends State<BasketList> {
  final DbHelper _dbHelper = DbHelper.instance;
  late Future<Map<String, List<dynamic>>> _basketDataFuture;

  List<Basket> _allBasketItems = [];
  List<BasketFile> _allBasketItemFiles = [];
  List<Basket> _filteredBasketItems = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _basketDataFuture = _loadBasketData();
    _searchController.addListener(_filterBasketItems);
  }

  Future<Map<String, List<dynamic>>> _loadBasketData() async {
    final items = await _dbHelper.getBasket();
    final files = await _dbHelper
        .getBasketFilesAll(); // Nullable olabileceğini varsayıyorum
    setState(() {
      _allBasketItems = items;
      _allBasketItemFiles = files ?? []; // Null ise boş liste ata
      _filteredBasketItems = items; // Başlangıçta tüm sepet öğelerini göster
    });
    return {'items': items, 'files': files ?? []};
  }

  Future<void> _refreshBasketData() async {
    _searchController.clear();
    setState(() {
      _basketDataFuture = _loadBasketData();
    });
    await _basketDataFuture;
  }

  void _filterBasketItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBasketItems = _allBasketItems;
      } else {
        _filteredBasketItems = _allBasketItems.where((item) {
          final qrCodeLower = item.qrCode.toLowerCase();
          final descriptionLower = (item.description).toLowerCase();
          final recordDateString = DateFormat('yyyy-MM-dd HH:mm')
              .format(item.recordDate!)
              .toLowerCase();

          return qrCodeLower.contains(query) ||
              descriptionLower.contains(query) ||
              recordDateString.contains(query) ||
              item.id.toString().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterBasketItems);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showDeleteConfirmationDialog(
      {Basket? item, bool deleteAll = false}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Text(
            deleteAll ? 'Delete All Items' : 'Delete Item',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(deleteAll
                    ? 'Are you sure you want to delete the whole basket list?'
                    : 'Are you sure you want to delete this item?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red[700])),
              onPressed: () {
                Navigator.of(context).pop();
                if (deleteAll) {
                  _removeAllBasketItems();
                } else if (item != null) {
                  _removeBasketItem(item);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeAllBasketItems() async {
    await _dbHelper.removeAllBasket();
    _refreshBasketData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All items deleted!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _removeBasketItem(Basket item) async {
    await _dbHelper.removeBasket(item.id);
    _refreshBasketData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item Deleted!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      drawer: drawerMenu(context, "D-Veci"),
      bottomNavigationBar: bottomWidget(context, 3),
      appBar: AppBar(
        title: const Text(
          "BASKET LIST",
          style: TextStyle(
              color: Color(0xFFB79C91),
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFFB79C91)),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add_outlined,
                color: Color(0xFFB79C91), size: 28),
            tooltip: 'Add New Item',
            onPressed: () async {
              final result = await Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) {
                return const AddBasketItem();
              }));
              if (result == true) {
                _refreshBasketData();
              }
            },
          ),
          if (_allBasketItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined,
                  color: Colors.red[600], size: 24),
              tooltip: 'Delete All Basket',
              onPressed: () {
                _showDeleteConfirmationDialog(deleteAll: true);
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBasketData,
        child: Column(
          children: <Widget>[
            _buildSearchField(),
            Expanded(
              child: FutureBuilder<Map<String, List<dynamic>>>(
                future: _basketDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      _allBasketItems.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              'Error while loading a basket: ${snapshot.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshBasketData,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildBasketItemsList();
                },
              ),
            ),
            if (_filteredBasketItems.isNotEmpty) _buildCheckoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search Basket Items...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
        ),
      ),
    );
  }

  Widget _buildBasketItemsList() {
    if (_filteredBasketItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _searchController.text.isNotEmpty
                ? 'The basket element that matched your search was not found..'
                : 'Your basket is empty.\nUse the (+) button to add the item or Scan QR',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      itemCount: _filteredBasketItems.length,
      itemBuilder: (context, index) {
        final basketItem = _filteredBasketItems[index];
        BasketFile? foundItemFile = _allBasketItemFiles
            .firstWhereOrNull((file) => file.basketId == basketItem.id);

        return Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red[600],
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            // Kartla aynı margin
            child:
                const Icon(Icons.delete_forever, color: Colors.white, size: 28),
          ),
          confirmDismiss: (direction) async {
            final bool? confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Delete the item?'),
                  content: Text(
                      '"${basketItem.qrCode}" - Are you sure you want to delete your item?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('DELETE',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                );
              },
            );
            return confirmed ?? false;
          },
          onDismissed: (direction) {
            _removeBasketItem(basketItem);
          },
          child: _buildBasketItemCard(basketItem, foundItemFile),
        );
      },
    );
  }

  Widget _buildBasketItemCard(Basket basketItem, BasketFile? basketFile) {
    return Card(
      elevation: 0.2,
      margin: const EdgeInsets.symmetric(vertical: 6.0), // Kartlar arası boşluk
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DetailBasketItem(
              itemId: basketItem.id,
            ),
          ));
          if (result == true) {
            // DetailBasketItem'dan bir değişiklik olduğunu belirtirse
            _refreshBasketData();
          }
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${basketItem.id}',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      basketItem.qrCode,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm')
                          .format(basketItem.recordDate!),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (basketItem.description.isNotEmpty)
                          Icon(
                            Icons.speaker_notes_rounded,
                            size: 20,
                            color: Colors.orange[700],
                          ),
                        const SizedBox(width: 10),
                        if (basketItem.description.isNotEmpty &&
                            basketFile != null)
                          const SizedBox(height: 8),
                        if (basketFile != null)
                          Icon(
                            Icons.insert_photo_outlined,
                            size: 20,
                            color: Colors.blue[700],
                          ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      basketItem.quantity.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 10.0),
      // Alt boşluğu artırıldı
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.folder_special_outlined, color: Colors.white),
          label: const Text(
            'CREATE A LOCAL ORDER',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(30.0), // Daha yuvarlak kenarlar
            ),
            elevation: 1,
          ).copyWith(elevation: ButtonStyleButton.allOrNull(2.0)),
          onPressed: () async {
            final result = await Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) {
              return const CheckoutBasket();
            }));
            if (result == true) {
              _refreshBasketData();
            }
          },
        ),
      ),
    );
  }
}
