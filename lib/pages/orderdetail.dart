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
import 'full_screen_image_page.dart';
import 'order_row_detail.dart';

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
  List<SaleOrderDocument> _orderRowDocuments = [];
  final List<XFile> pickedFiles = [];

  bool _isSyncing = false;
  final bool _isLoading = false;

  static const Color primaryColor = Color(0xFFB79C91);
  static const Color accentColor = Color(0xFF8F7A70);
  static const Color cardBackgroundColor = Color(0xFFF9F5F3);
  static const Color textColor = Colors.black87;

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
      final orderRowDocuments =
          await _dbHelper.getOrderRowAllDocuments(widget.uid);

      setState(() {
        _order = order;
        _customer = customer;
        _customerUser = customerUser;
        _saleOrderType = saleOrderType;
        _orderRows = orderRows;
        _orderDocuments = orderDocuments!;
        _orderRowDocuments = orderRowDocuments!;
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
        await _saveImageToDocuments(imageFile);

        setState(() {
          if (!pickedFiles.any((file) => file.path == imageFile.path) &&
              !_orderDocuments
                  .any((doc) => doc.documentName == imageFile.name)) {
            pickedFiles.add(imageFile);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'This file is already attached or an existing file with the same name..')),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('The file could not be selected: $e')));
      }
    }
  }

  Future<void> _saveImageToDocuments(XFile imageFile) async {
    try {
      await _dbHelper.addOrderXFileuid(widget.uid, imageFile);
    } catch (e) {
      //
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
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.deepOrange),
            onPressed: _isSyncing ? null : _sendToEdit,
            tooltip: 'EDIT ORDER',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever_outlined, color: Colors.red),
            onPressed: _isSyncing ? null : _sendToEdit,
            tooltip: 'EDIT ORDER',
          ),
          IconButton(
            icon: _isSyncing
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.blue[700]))
                : Icon(Icons.cloud_upload_outlined,
                    color: Colors.blue[700], size: 28),
            onPressed: _isSyncing ? null : _sendToCloud,
            tooltip: 'SEND ORDER',
          ),
          if (_order != null && _order!.orderStatusId == 1)
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
                padding: const EdgeInsets.all(10.0),
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
                padding: const EdgeInsets.all(10.0),
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
        padding: const EdgeInsets.all(4.0),
        children: <Widget>[
          Card(
            color: Colors.grey.withAlpha(20),
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildFileAttachmentSection(),
          _buildOrderRowsSection(),
          const SizedBox(height: 20),
          if (_order!.orderStatusId == 0)
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent.shade100,
                  foregroundColor: Colors.blue[900],
                ),
                icon: Icon(
                  Icons.cloud_upload_outlined,
                  size: 24,
                  color: Colors.blue[900],
                ),
                label: const Text('  SEND ORDER TO THE CLOUD',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                onPressed: _isSyncing ? null : _sendToCloud,
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      color: const Color(0x00ffdfdf).withAlpha(100),
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
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: primaryColor));
    }
    if (_orderRows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: Text(
            "This order has not yet been added to the product.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final bool canEditOrderItems = _order?.orderStatusId == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Center(
            child: Text(
              "ORDER ITEMS (${_orderRows.length})",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _orderRows.length,
          itemBuilder: (context, index) {
            final row = _orderRows[index];

            final bool rowHasDescription = row.description.isNotEmpty;
            final bool rowHasPhotos =
                _orderRowDocuments.any((doc) => doc.saleOrderRowUid == row.uid);

            return Card(
              elevation: 1,
              margin:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              color: cardBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                leading: Text(
                  '#${index + 1}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey),
                ),
                title: Text(
                  row.qrCode,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textColor), // textColor'ınızı kullanın
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (row.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          row.description,
                          // Modelden gelen ürün açıklaması
                          style: TextStyle(
                              fontSize: 13,
                              color: textColor.withValues(alpha: 0.7)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "${row.quantity} x ${row.unitPrice} ${row.currency}",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.withValues(alpha: 0.9)),
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (rowHasDescription)
                      Icon(Icons.notes_outlined,
                          color: accentColor.withValues(alpha: 0.7), size: 20),
                    if (rowHasDescription && rowHasPhotos)
                      const SizedBox(width: 6),
                    if (rowHasPhotos)
                      Icon(Icons.image_outlined,
                          color: accentColor.withValues(alpha: 0.7), size: 20),
                    if (canEditOrderItems)
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Colors.redAccent.withAlpha(200), size: 24),
                        tooltip: 'Delete the Item',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          final confirmDelete = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete the Item'),
                                content: Text(
                                    'Are you sure you want to delete the "${row.qrCode}" coded product from order?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('CANCEL'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('DELETE',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmDelete == true && mounted) {
                            try {
                              await _dbHelper.removeOrderRow(row.uid);
                              _orderRows
                                  .removeWhere((item) => item.uid == row.uid);
                              await _refreshDetails();

                              if (!context.mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('"${row.qrCode}" deleted.'),
                                    backgroundColor: Colors.orange),
                              );
                              // setState(() {}); // _refreshOrderTotalsAndCounts veya _refreshDetails zaten setState içerir
                            } catch (e) {
                              if (!context.mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Error while the item is deleted: $e',
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    backgroundColor: Colors.redAccent),
                              );
                              await _refreshDetails();
                            }
                          }
                        },
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailRowEditPage(
                        orderUid: widget.uid,
                        orderRowUid: row.uid,
                      ),
                    ),
                  ).then((result) {
                    if (result == true && mounted) {
                      _refreshDetails();
                    }
                  });
                },
              ),
            );
          },
        ),
      ],
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
                final String imagePath = file.path;
                final String uniqueHeroTag = 'imageHero_$imagePath';

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImagePage(
                                filePath: imagePath,
                                heroTag: uniqueHeroTag,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.grey.shade400, width: 0.5)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Hero(
                              tag: uniqueHeroTag,
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
                label: const Text("Camera"),
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
                label: const Text("Gallery"),
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
