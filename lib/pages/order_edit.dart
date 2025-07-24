import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../database/db_helper.dart';
import '../models/customer.dart';
import '../models/customeruser.dart';
import '../models/saleorder.dart';
import '../models/saleorderdocument.dart';
import '../models/saleorderrow.dart';
import '../models/saleordertype.dart';

class OrderEditPage extends StatefulWidget {
  final String orderUid;

  const OrderEditPage({super.key, required this.orderUid});

  @override
  State<OrderEditPage> createState() => _OrderEditPageState();
}

class _OrderEditPageState extends State<OrderEditPage> {
  final DbHelper _dbHelper = DbHelper.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  SaleOrder? _currentOrder;
  List<SaleOrderRow> _currentOrderItems = [];

  Customer? _selectedCustomer;
  CustomerUser? _selectedCustomerUser;
  SaleOrderType? _selectedOrderType;

  final TextEditingController _customerDisplayController =
      TextEditingController();
  final TextEditingController _userDisplayController = TextEditingController();
  final TextEditingController _orderTypeDisplayController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Customer> _allCustomers = [];
  List<CustomerUser> _allCustomerUsers = [];
  List<SaleOrderType> _allOrderTypes = [];
  List<Customer> _filteredCustomers = [];
  List<CustomerUser> _filteredCustomerUsersForSelection = [];

  bool _isLoading = true;
  bool _isSaving = false;

  final List<XFile> _newlyPickedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      _currentOrder = await _dbHelper.getOrder(widget.orderUid);
      if (_currentOrder == null) {
        throw Exception("Sipariş bulunamadı.");
      }

      if (_currentOrder!.orderStatusId != 0) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Bu sipariş onaylandığı için düzenlenemez.')),
        );
        Navigator.of(context).pop();
        return;
      }

      _currentOrderItems = await _dbHelper.getOrderRows(widget.orderUid);

      _allCustomers = await _dbHelper.getCustomers();
      _allCustomerUsers = await _dbHelper.getCustomerUsers();
      _allOrderTypes = await _dbHelper.getSaleOrderType();
      _filteredCustomers = _allCustomers;

      if (_currentOrder != null) {
        try {
          _selectedCustomer = _allCustomers.firstWhere(
            (c) => c.accountCode == _currentOrder!.accountCode,
          );
        } catch (e) {
          _selectedCustomer = null;
        }

        if (_selectedCustomer != null) {
          _customerDisplayController.text =
              "${_selectedCustomer!.accountCode} - ${_selectedCustomer!.customerName ?? ''}";
          _filteredCustomerUsersForSelection = _allCustomerUsers
              .where(
                  (user) => user.accountCode == _selectedCustomer!.accountCode)
              .toList();

          if (_currentOrder!.customerUserId != null &&
              _currentOrder!.customerUserId != 0) {
            _selectedCustomerUser = _allCustomerUsers.firstWhere((u) =>
                u.id == _currentOrder!.customerUserId &&
                u.accountCode == _selectedCustomer!.accountCode);

            if (_selectedCustomerUser != null) {
              _userDisplayController.text =
                  "${_selectedCustomerUser!.id} - ${_selectedCustomerUser!.contactName}";
            } else {
              _userDisplayController.text = "Yetkili Seç (Opsiyonel)";
            }
          } else {
            _userDisplayController.text = "Yetkili Seç (Opsiyonel)";
          }
        } else {
          _customerDisplayController.text = "Müşteri Seçin";
        }

        _selectedOrderType = _allOrderTypes.firstWhere(
          (type) => type.id == _currentOrder!.orderTypeId,
        );
        if (_selectedOrderType != null) {
          _orderTypeDisplayController.text =
              "${_selectedOrderType!.id} - ${_selectedOrderType!.typeName}";
        } else {
          _orderTypeDisplayController.text = "Sipariş Tipi Seçin";
        }
        _descriptionController.text = _currentOrder!.description;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sipariş yüklenirken hata: $e')),
        );
        // Navigator.of(context).pop(); // Hata durumunda sayfadan çık
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterCustomersForSelection(String query) {
    setState(() {
      _filteredCustomers = query.isEmpty
          ? _allCustomers
          : _allCustomers
              .where((c) =>
                  c.accountCode.toLowerCase().contains(query.toLowerCase()) ||
                  (c.customerName?.toLowerCase() ?? '')
                      .contains(query.toLowerCase()))
              .toList();
    });
  }

  void _filterCustomerUsersForSelection(String query) {
    final baseList = _selectedCustomer != null
        ? _allCustomerUsers
            .where((user) => user.accountCode == _selectedCustomer!.accountCode)
            .toList()
        : <CustomerUser>[];
    setState(() {
      _filteredCustomerUsersForSelection = query.isEmpty
          ? baseList
          : baseList
              .where((user) =>
                  user.contactName
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  user.id.toString().contains(query))
              .toList();
    });
  }

  Future<void> _updateOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen bir müşteri seçin.')));
      return;
    }
    if (_selectedOrderType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen bir sipariş tipi seçin.')));
      return;
    }

    // Sipariş satırı kontrolü (opsiyonel, düzenleme ayrı olacağı için belki burada gerekmez)
    // if (_currentOrderItems.isEmpty) { /* ... uyarı ... */ }

    setState(() => _isSaving = true);

    try {
      await _dbHelper.updateOrder(
        widget.orderUid,
        _selectedCustomer!.accountCode,
        _selectedCustomerUser?.id.toString() ?? "0",
        _selectedOrderType!.id.toString(),
        _descriptionController.text,
      );

      // for (SaleOrderDocument docToRemove in _filesToRemove) {
      //   await _dbHelper.removeOrderDocumentById(docToRemove.id);
      // }

      for (XFile pickedFile in _newlyPickedFiles) {
        SaleOrderDocument newDoc = SaleOrderDocument(
          id: 0,
          saleOrderUid: widget.orderUid,
          saleOrderRowUid: null,
          pathName: pickedFile.path,
          documentName: pickedFile.name,
        );
        await _dbHelper.addOrderXFile(newDoc);
      }

      // Sipariş satırları için: Bu aşamada satır güncelleme/ekleme/silme işlemleri
      // ayrı bir mekanizma (örn: bottom sheet'ten sonra) ile yönetilecek.
      // Bu yüzden _updateOrder içinde satırlara dokunmuyoruz.

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Sipariş başlığı başarıyla güncellendi!')),
        );
        Navigator.of(context).pop(true); // Başarı ile dön
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sipariş güncellenirken hata: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showCustomerSelectionSheet(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder: (_, controller) => Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Müşteri Seç',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                        hintText: 'Müşteri Kodu veya Adı Ara...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onChanged: (value) {
                      _filterCustomersForSelection(value);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _filteredCustomers.isEmpty
                        ? const Center(child: Text("Müşteri bulunamadı"))
                        : ListView.builder(
                            controller: controller,
                            itemCount: _filteredCustomers.length,
                            itemBuilder: (context, index) {
                              final customer = _filteredCustomers[index];
                              return ListTile(
                                title: Text(
                                    "${customer.accountCode} - ${customer.customerName ?? ''}"),
                                subtitle:
                                    Text(customer.taxNumber ?? 'Vergi No Yok'),
                                onTap: () {
                                  setState(() {
                                    _selectedCustomer = customer;
                                    _customerDisplayController.text =
                                        "${customer.accountCode} - ${customer.customerName ?? ''}";
                                    _selectedCustomerUser = null;
                                    _userDisplayController.text =
                                        "Yetkili Seç (Opsiyonel)";
                                    _filteredCustomerUsersForSelection =
                                        _allCustomerUsers
                                            .where((user) =>
                                                user.accountCode ==
                                                _selectedCustomer!.accountCode)
                                            .toList();
                                    _filterCustomerUsersForSelection('');
                                  });
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).whenComplete(() => _filterCustomersForSelection(''));
  }

  void _showUserSelectionSheet(BuildContext context) {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen önce bir müşteri seçin.')));
      return;
    }
    TextEditingController searchUserController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext modalContext, StateSetter setModalState) {
          List<CustomerUser> usersToList = _filteredCustomerUsersForSelection;
          return DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.8,
            expand: false,
            builder: (_, controller) => Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Yetkili Seç (Opsiyonel)',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchUserController,
                    decoration: InputDecoration(
                        hintText: 'Yetkili Adı veya ID Ara...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onChanged: (value) {
                      _filterCustomerUsersForSelection(value);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 10),
                  if (usersToList.isEmpty && _selectedCustomer != null)
                    ListTile(
                      title: const Text("Bu müşteriye ait yetkili yok"),
                      leading: const Icon(Icons.person_off_outlined),
                      onTap: () {
                        setState(() {
                          _selectedCustomerUser = null;
                          _userDisplayController.text =
                              "Yetkili Seç (Opsiyonel)";
                        });
                        Navigator.pop(ctx);
                      },
                    ),
                  Expanded(
                    child: usersToList.isEmpty
                        ? const SizedBox.shrink()
                        : ListView.builder(
                            controller: controller,
                            itemCount: usersToList.length,
                            itemBuilder: (context, index) {
                              final user = usersToList[index];
                              return ListTile(
                                title: Text(user.contactName),
                                subtitle: Text(
                                    "ID: ${user.id} ${user.departmentName.isNotEmpty ? '- ${user.departmentName}' : ''}"),
                                onTap: () {
                                  setState(() {
                                    _selectedCustomerUser = user;
                                    _userDisplayController.text =
                                        "${user.id} - ${user.contactName}";
                                  });
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCustomerUser = null;
                          _userDisplayController.text =
                              "Yetkili Seç (Opsiyonel)";
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text("Yetkili Seçme"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).whenComplete(() => _filterCustomerUsersForSelection(''));
  }

  void _showOrderTypeSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Sipariş Tipi Seç',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Expanded(
              child: _allOrderTypes.isEmpty
                  ? const Center(child: Text("Sipariş tipi bulunamadı"))
                  : ListView.builder(
                      itemCount: _allOrderTypes.length,
                      itemBuilder: (context, index) {
                        final type = _allOrderTypes[index];
                        return ListTile(
                          title: Text(type.typeName),
                          subtitle: Text("ID: ${type.id}"),
                          onTap: () {
                            setState(() {
                              _selectedOrderType = type;
                              _orderTypeDisplayController.text =
                                  "${type.id} - ${type.typeName}";
                            });
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Sipariş Satırlarını Yönetmek için placeholder bir fonksiyon.
  // Bu fonksiyon, satırları listeleyen ve düzenleme/ekleme için
  // yeni bir bottom sheet/sayfa açacak bir butonu tetikleyebilir.
  void _manageOrderItems() {
    // Örneğin, yeni bir sayfaya yönlendirme:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => OrderItemsManagementPage(
    //       orderUid: widget.orderUid,
    //       currentItems: _currentOrderItems, // Mevcut satırları gönder
    //       // Geri dönüşte güncellenmiş satırları almak için callback
    //       onItemsUpdated: (updatedItems) {
    //         setState(() {
    //           _currentOrderItems = updatedItems;
    //         });
    //       },
    //     ),
    //   ),
    // );

    // Veya bir BottomSheet gösterme:
    // showModalBottomSheet(context: context, builder: (ctx) => OrderItemsBottomSheet(...));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Sipariş satırı yönetimi (ekleme/düzenleme/silme) daha sonra eklenecek.')),
    );
  }

  Widget _buildEditFormContent() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
        // FAB için altta boşluk
        children: <Widget>[
          _buildSectionTitle('Müşteri Bilgileri'),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(children: [
                TextFormField(
                  controller: _customerDisplayController,
                  readOnly: true,
                  decoration: InputDecoration(
                      labelText: 'Müşteri *',
                      hintText: 'Müşteri Seçin',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.business_outlined)),
                  onTap: () => _showCustomerSelectionSheet(context),
                  validator: (v) =>
                      (v == null || v.isEmpty || _selectedCustomer == null)
                          ? 'Müşteri seçimi zorunludur.'
                          : null,
                ),
                if (_selectedCustomer != null) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _userDisplayController,
                    readOnly: true,
                    decoration: InputDecoration(
                        labelText: 'Yetkili (Opsiyonel)',
                        hintText: 'Yetkili Seçin',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.person_outline)),
                    onTap: () => _showUserSelectionSheet(context),
                  ),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionTitle('Sipariş Detayları'),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(children: [
                TextFormField(
                  controller: _orderTypeDisplayController,
                  readOnly: true,
                  decoration: InputDecoration(
                      labelText: 'Sipariş Tipi *',
                      hintText: 'Sipariş Tipi Seçin',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.list_alt_outlined)),
                  onTap: () => _showOrderTypeSelectionSheet(context),
                  validator: (v) =>
                      (v == null || v.isEmpty || _selectedOrderType == null)
                          ? 'Sipariş tipi seçimi zorunludur.'
                          : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                      labelText: 'Açıklama',
                      hintText: 'Sipariş için açıklama (opsiyonel)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.description_outlined)),
                  maxLines: 3,
                ),
              ]),
            ),
          ),
          const SizedBox(height: 20),

          // Sipariş Satırları Bölümü (Yönetim Butonu ile)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle(
                  'Sipariş Kalemleri (${_currentOrderItems.length})'),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit_note),
                label: const Text('Kalemleri Yönet'),
                onPressed: _manageOrderItems,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8)),
              )
            ],
          ),
          // Sadece mevcut satırların bir özetini göster (düzenleme burada değil)
          _currentOrderItems.isEmpty
              ? Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                        child: Text(
                            'Siparişte hiç ürün yok.\nKalemleri Yönet butonu ile ekleyebilirsiniz.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey))),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _currentOrderItems.length,
                  itemBuilder: (context, index) {
                    final item = _currentOrderItems[index];
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        leading: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .primaryColorLight
                                .withValues(alpha: 0.5),
                            child: Text('${index + 1}',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).primaryColorDark))),
                        title: Text(item.itemCode,
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text('Miktar: ${item.quantity} ${item.unit}'),
                        // Trailing'de düzenle/sil butonları yok, _manageOrderItems'a yönlendiriyoruz.
                      ),
                    );
                  },
                ),
          const SizedBox(height: 20),

          const SizedBox(height: 30),
          // FloatingActionButton için ek boşluk
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorDark),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("SİPARİŞ DÜZENLE",
            style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColorDark),
        actions: [
          if (_currentOrder != null && _currentOrder!.orderStatusId == 0)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Icon(Icons.cloud_upload_outlined,
                    color: Theme.of(context).primaryColor),
                onPressed: () {
                  // _sendOrderToApi(_currentOrder!.uid);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('API\'ye gönderme özelliği eklenecek.')));
                },
                tooltip: 'Siparişi Onaya Gönder',
              ),
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildEditFormContent(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: double.infinity,
          child: FloatingActionButton.extended(
            onPressed: _isSaving ? null : _updateOrder,
            backgroundColor: Theme.of(context).primaryColor,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.0))
                : const Icon(Icons.save_alt_outlined, color: Colors.white),
            label: Text(
              _isSaving ? 'KAYDEDİLİYOR...' : 'GÜNCELLEMELERİ KAYDET',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
