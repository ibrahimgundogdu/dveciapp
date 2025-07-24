import 'dart:io';

import 'package:dveci_app/pages/order_edit.dart';
import 'package:image_picker/image_picker.dart';

import '../models/saleorderrow.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/db_helper.dart';
import '../models/customer.dart';
import '../models/customeruser.dart';
import '../models/saleorder.dart';
import '../models/saleorderdocument.dart';
import '../models/saleordertype.dart';
import '../repositories/apirepository.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';

class OrderDetail extends StatefulWidget {
  final String uid;

  const OrderDetail({super.key, required this.uid});

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  final DbHelper _dbHelper = DbHelper.instance;
  late Apirepository _repository;

  late Future<Map<String, dynamic>> _detailDataFuture;
  SaleOrder? _order;
  Customer? _customer;
  CustomerUser? _customerUser;
  SaleOrderType? _saleOrderType;

  final ImagePicker _picker = ImagePicker();
  List<SaleOrderRow> _orderRows = [];
  List<SaleOrderDocument> _orderDocuments = [];
  final List<XFile> pickedFiles = [];

  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _repository = Apirepository();
    _detailDataFuture = _loadAllDetails();
  }

  Future<Map<String, dynamic>> _loadAllDetails() async {
    try {
      final order = await _dbHelper.getOrder(widget.uid);
      if (order == null) {
        throw Exception("Order not found.");
      }

      final customer = await _dbHelper.getCustomer(order.accountCode);
      final customerUser =
          await _dbHelper.getCustomerUser(order.customerUserId);
      final saleOrderType =
          await _dbHelper.getSaleOrderTypeById(order.orderTypeId!);
      final orderRows = await _dbHelper.getOrderRows(widget.uid);
      final orderDocuments = await _dbHelper.getOrderDocuments(widget.uid);

      setState(() {
        _order = order;
        _customer = customer;
        _customerUser = customerUser;
        _saleOrderType = saleOrderType;
        _orderRows = orderRows;
        _orderDocuments = orderDocuments!;
      });

      if (orderDocuments != null) {
        for (var orderFile in orderDocuments) {
          if (orderFile.pathName != null) {
            try {
              final xfile = XFile(orderFile.pathName!);
              if (!pickedFiles.any((file) => file.path == xfile.path)) {
                pickedFiles.add(xfile);
              }
            } catch (e) {
              // Hata durumunda yapılacak işlemler
            }
          }
        }
      }

      return {
        'order': order,
        'customer': customer,
        'customerUser': customerUser,
        'saleOrderType': saleOrderType,
        'orderRows': orderRows,
        'orderDocuments': orderDocuments,
      };
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<void> _refreshDetails() async {
    setState(() {
      _detailDataFuture = _loadAllDetails();
    });
    await _detailDataFuture;
  }

  Future<void> _sendToCloud() async {
    if (_isSyncing) return;
    setState(() {
      _isSyncing = true;
    });

    try {
      var message = await _repository.sendAppOrder(widget.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      _refreshDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Synchronization error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  Future<void> _sendToEdit() async {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return OrderEditPage(orderUid: widget.uid);
    }));
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? imageFile =
          await _picker.pickImage(source: source, imageQuality: 85);
      if (imageFile != null) {
        setState(() {
          if (!pickedFiles.any((file) => file.path == imageFile.path) &&
              !_orderDocuments
                  .any((doc) => doc.documentName == imageFile.name)) {
            pickedFiles.add(imageFile);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Bu dosya zaten ekli veya aynı isimde mevcut bir dosya var.')),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Dosya seçilemedi: $e')));
      }
    }
  }

  Future removeBasketXFileItem(XFile item) async {
    await _dbHelper.removeOrderXFile(widget.uid, item);
    if (!mounted) return;

    setState(() {
      pickedFiles.removeWhere((file) => file.path == item.path);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Item removed!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeFile(XFile fileToRemove) async {
    await removeBasketXFileItem(fileToRemove);

    setState(() {
      pickedFiles.removeWhere((file) => file.path == fileToRemove.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: drawerMenu(context, "D-Veci"),
      bottomNavigationBar: bottomWidget(context, 4),
      appBar: AppBar(
        title: Text(
          _order?.orderNumber ?? "ORDER DETAILS",
          style: const TextStyle(
              color: Color(0xFFB79C91),
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFFB79C91)),
        actions: [
          // Eğer düzenleme modu varsa, bir kaydet butonu eklenebilir
          // if (_isEditMode)
          //   IconButton(
          //     icon: Icon(Icons.save_outlined, color: Color(0xFFB79C91)),
          //     onPressed: _updateOrderDetails,
          //     tooltip: 'Değişiklikleri Kaydet',
          //   ),
          IconButton(
            icon: _isSyncing
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.blue[700]))
                : Icon(Icons.cloud_sync_outlined,
                    color: Colors.blue[700], size: 28),
            onPressed: _isSyncing ? null : _sendToCloud,
            tooltip: 'SEND ORDER',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFB79C91)),
            onPressed: _refreshDetails,
            tooltip: 'REFRESH',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _order == null) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Details could not be loaded: ${snapshot.error}',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      onPressed: _refreshDetails,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),
            );
          } else if (_order == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Order details could not be loaded.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go Back'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            );
          }

          return _buildOrderDetailContent();
        },
      ),
    );
  }

  Widget _buildOrderDetailContent() {
    return Form(
      child: ListView(
        // SingleChildScrollView yerine ListView, section'lar için daha iyi
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Card(
            color: Theme.of(context).cardColor.withValues(alpha: 0.8),
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsetsGeometry.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("ORDER INFO",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB79C91))),
                          if (_order!.orderStatusId == 0)
                            SizedBox(
                              height: 30,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrange,
                                  shadowColor: Colors.white,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.edit),
                                label: const Text('EDIT ORDER'),
                                onPressed: _isSyncing ? null : _sendToEdit,
                              ),
                            ),
                        ],
                      )),
                  _buildInfoCard([
                    _buildInfoRow("Order Number:", _order!.orderNumber,
                        isHighlighted: true),
                    _buildInfoRow("Status:", _order!.statusName,
                        statusColor: _getStatusColor(_order!.orderStatusId),
                        isHighlighted: true),
                    _buildInfoRow("Order Type:",
                        _saleOrderType?.typeName ?? "Bilinmiyor"),
                    _buildInfoRow(
                        "Order Date:",
                        DateFormat('dd.MM.yyyy HH:mm')
                            .format(_order!.orderDate!)),
                    if (_order!.orderSyncDate != null &&
                        _order!.orderSyncDate != _order!.orderDate)
                      _buildInfoRow(
                          "Sync Date:",
                          DateFormat('dd.MM.yyyy HH:mm')
                              .format(_order!.orderSyncDate!)),
                  ]),
                  const SizedBox(
                      height: 20,
                      child: Divider(
                          height: 16,
                          thickness: 0.5,
                          indent: 16,
                          endIndent: 16)),
                  _buildInfoCard([
                    _buildInfoLine(_customer?.accountCode ?? ""),
                    _buildInfoLine(_customer?.customerName ?? "",
                        maxLines: 2, isHighlighted: true),
                    if (_customerUser != null) ...[
                      const Divider(height: 16, thickness: 0.5),
                      _buildInfoRow(
                          "#${_customerUser!.id} ", _customerUser!.contactName),
                    ]
                  ]),
                  const SizedBox(
                      height: 20,
                      child: Divider(
                          height: 16,
                          thickness: 0.5,
                          indent: 16,
                          endIndent: 16)),
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      color: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(_order!.description,
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                                height: 1.4)),
                      ),
                    ),
                  ),
                  const SizedBox(
                      height: 20,
                      child: Divider(
                          height: 16,
                          thickness: 0.5,
                          indent: 16,
                          endIndent: 16)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildFileAttachmentSection(),
          const SizedBox(height: 20),
          _buildSectionTitle("ORDER ITEMS (${_orderRows.length})",
              icon: Icons.list_alt_rounded),
          _buildOrderRowsSection(),
          const SizedBox(height: 20),
          if (_order!.orderStatusId == 0)
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('EDIT TEMP ORDER'),
              onPressed: _isSyncing ? null : _sendToEdit,
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Theme.of(context).primaryColor, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            title.toUpperCase(),
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      color: Colors.pinkAccent.withValues(alpha: 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isHighlighted = false, int maxLines = 1, Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Etiket genişliği
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      isHighlighted ? FontWeight.bold : FontWeight.normal,
                  color: statusColor ?? Colors.black87),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLine(String value,
      {bool isHighlighted = false, int maxLines = 1, Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        value,
        style: TextStyle(
            fontSize: 15,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: statusColor ?? Colors.black87),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Color _getStatusColor(int? orderStatusId) {
    switch (orderStatusId) {
      case 0:
        return Colors.orange.shade700; // Beklemede
      case -1:
        return Colors.red.shade700; // İptal
      case 1:
        return Colors.green.shade700; // Tamamlandı
      // Diğer durumlar için renkler eklenebilir
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _buildOrderRowsSection() {
    if (_orderRows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(
            child: Text("Bu siparişte henüz kalem yok.",
                style: TextStyle(color: Colors.grey))),
      );
    }
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        // ListView içinde ListView için
        physics: const NeverScrollableScrollPhysics(),
        // Ana ListView kaydırsın
        itemCount: _orderRows.length,
        itemBuilder: (context, index) {
          final row = _orderRows[index];
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColorLight,
              child: Text(
                row.quantity!.toStringAsFixed(0),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorDark),
              ),
            ),
            title: Text(row.itemCode,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
                "Birim Fiyat: ${NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(row.unitPrice)}\n"
                "Toplam: 0",
                style: TextStyle(color: Colors.grey[700], height: 1.3)),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Colors.grey[400]),
            onTap: () {
              // Kalem detayına git veya düzenle
              // Navigator.push(context, MaterialPageRoute(builder: (context) => OrderRowDetailPage(rowId: row.id)));
            },
          );
        },
        separatorBuilder: (context, index) =>
            const Divider(height: 0.5, indent: 16, endIndent: 16),
      ),
    );
  }

  Widget _buildFileAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pickedFiles.isNotEmpty)
          Container(
            height: 110,
            margin: const EdgeInsets.only(bottom: 10, top: 0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300)),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: pickedFiles.length,
              itemBuilder: (context, index) {
                final file = pickedFiles[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.grey.shade400, width: 0.5)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            File(file.path),
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                    width: 90,
                                    height: 90,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.broken_image_outlined,
                                        color: Colors.grey[400])),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _removeFile(file),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 18),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt_outlined, size: 20),
                label: const Text("Kamera"),
                onPressed: () => _pickImage(ImageSource.camera),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.7)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(fontSize: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.photo_library_outlined, size: 20),
                label: const Text("Galeri"),
                onPressed: () => _pickImage(ImageSource.gallery),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepOrange,
                    side: BorderSide(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(fontSize: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
