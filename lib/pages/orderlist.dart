import '../models/saleordertype.dart';
import '../pages/orderdetail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../database/db_helper.dart';
import '../models/saleorder.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';

class OrderList extends StatefulWidget {
  const OrderList({super.key});

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  final DbHelper _dbHelper = DbHelper.instance;
  late Future<Map<String, List<dynamic>>> _orderDataFuture;

  List<SaleOrder> _allSaleOrders = [];
  List<SaleOrderType> _allSaleOrderTypes = [];
  List<SaleOrder> _filteredSaleOrders = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _orderDataFuture = _loadOrderData();
    _searchController.addListener(_filterSaleOrders);
  }

  Future<Map<String, List<dynamic>>> _loadOrderData() async {
    final orders = await _dbHelper.getOrders();
    final types = await _dbHelper.getSaleOrderType();
    setState(() {
      _allSaleOrders = orders;
      _allSaleOrderTypes = types;
      _filteredSaleOrders = orders; // Başlangıçta tüm siparişleri göster
    });
    return {'orders': orders, 'types': types};
  }

  Future<void> _refreshOrderData() async {
    _searchController.clear();
    setState(() {
      _orderDataFuture = _loadOrderData();
    });
    await _orderDataFuture;
  }

  void _filterSaleOrders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSaleOrders = _allSaleOrders;
      } else {
        _filteredSaleOrders = _allSaleOrders.where((order) {
          final orderNumberLower = order.orderNumber.toLowerCase();
          final accountCodeLower = order.accountCode.toLowerCase();
          final statusNameLower = order.statusName.toLowerCase();
          final orderTypeNameLower =
          getSaleOrderTypeName(order.orderTypeId!, _allSaleOrderTypes)
              .toLowerCase();
          final orderDateString =
          DateFormat('yyyy-MM-dd HH:mm').format(order.orderDate!).toLowerCase();

          return orderNumberLower.contains(query) ||
              accountCodeLower.contains(query) ||
              statusNameLower.contains(query) ||
              orderTypeNameLower.contains(query) ||
              orderDateString.contains(query) ||
              order.id.toString().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSaleOrders);
    _searchController.dispose();
    super.dispose();
  }

  String getSaleOrderTypeName(
      int targetId, List<SaleOrderType> saleOrderTypes) {
    if (saleOrderTypes.isEmpty) {
      return "Tip Yok";
    }
    SaleOrderType? foundType = saleOrderTypes.firstWhereOrNull(
          (type) => type.id == targetId,
    );
    return foundType?.typeName ?? "Bilinmeyen Tip";
  }

  Future<bool?> _showDeleteConfirmationDialog(SaleOrder order) async { // Dönüş tipini Future<bool?> yapın
    return showDialog<bool>( // showDialog'un generic tipini bool yapın
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Text('Siparişi Sil', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    '"${order.orderNumber}" numaralı siparişi silmek istediğinizden emin misiniz?'),
                const Text('Bu işlem geri alınamaz.', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop(false); // İptal durumunda false döndür
              },
            ),
            TextButton(
              child: Text('Sil', style: TextStyle(color: Colors.red[700])),
              onPressed: () {
                // Burada doğrudan silme işlemi yapmayın, sadece true döndürün.
                // Silme işlemi onDismissed içinde veya confirmDismiss'ten sonra yapılmalı.
                // Ancak mevcut yapınızda silme işlemi onPressed içinde kalabilir,
                // yine de true döndürmeniz confirmDismiss için gereklidir.
                Navigator.of(context).pop(true); // Silme onaylanırsa true döndür
              },
            ),
          ],
        );
      },
    );
  }
  Color _getStatusColor(int? orderStatusId) {
    switch (orderStatusId) {
      case 0: // Örnek: Beklemede
        return Colors.deepOrange;
      case -1: // Örnek: İptal
        return Colors.grey;
      case 1: // Örnek: Tamamlandı
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  IconData _getStatusIcon(int? orderStatusId) {
    switch (orderStatusId) {
      case 0:
        return Icons.hourglass_empty_rounded;
      case -1:
        return Icons.cancel_outlined;
      case 1:
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: false,
      drawer: drawerMenu(context, "D-Veci"),
      bottomNavigationBar: bottomWidget(context,4),
      appBar: AppBar(
        title: const Text(
          "ORDER LIST",
          style: TextStyle(
              color: Color(0xFFB79C91),
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFFB79C91)),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrderData,
        child: Column(
          children: <Widget>[
            _buildSearchField(),
            Expanded(
              child: FutureBuilder<Map<String, List<dynamic>>>(
                future: _orderDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && _allSaleOrders.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Siparişler yüklenirken hata: ${snapshot.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshOrderData,
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    );
                  }
                  return _buildOrderList();
                },
              ),
            ),
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
          hintText: 'Sipariş Ara (No, Müşteri Kodu, Durum...)',
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

  Widget _buildOrderList() {
    if (_filteredSaleOrders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _searchController.text.isNotEmpty
                ? 'Aramanızla eşleşen sipariş bulunamadı.'
                : 'Henüz sipariş yok.\nYenilemek için aşağı kaydırın.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      itemCount: _filteredSaleOrders.length,
      itemBuilder: (context, index) {
        final order = _filteredSaleOrders[index];
        // Sadece orderStatusId == 0 (örneğin "Beklemede") olanlar silinebilir.
        // Diğer statülerdeki siparişlerin silinmesi iş mantığınıza göre engellenebilir.
        // Bu örnekte, sadece orderStatusId == 0 olanlar için Dismissible aktif olacak.
        if (order.orderStatusId == 0) {
          return Dismissible(
            key: ValueKey(order.uid),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red[600],
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: const Icon(Icons.delete_forever, color: Colors.white, size: 28),
            ),
            confirmDismiss: (direction) async {
              // Silmeden önce onay iste
              return await _showDeleteConfirmationDialog(order);
            },
            onDismissed: (direction) {

            },
            child: _buildOrderCard(order),
          );
        } else {
          // Silinemeyen siparişler için normal kart
          return _buildOrderCard(order);
        }
      },
    );
  }

  Widget _buildOrderCard(SaleOrder order) {
    final statusColor = _getStatusColor(order.orderStatusId);
    final statusIcon = _getStatusIcon(order.orderStatusId);
    final orderTypeName = getSaleOrderTypeName(order.orderTypeId!, _allSaleOrderTypes);

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: statusColor.withValues(alpha: 0.5), width: 1), // Duruma göre kenarlık
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => OrderDetail(uid: order.uid),
          ));
          if (result == true) { // OrderDetail'dan bir değişiklik olduğunu belirtirse
            _refreshOrderData();
          }
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${order.id} - ${order.orderNumber}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          order.statusName,
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    order.accountCode,
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.category_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    orderTypeName,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(order.orderDate!),
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              if (order.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.notes_rounded, size: 16, color: Colors.orange[700]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.description,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}