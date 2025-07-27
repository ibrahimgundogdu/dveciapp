import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/customer.dart';
import '../models/customeruser.dart';
import '../models/saleorder.dart';
import '../models/saleordertype.dart';
import 'orderdetail.dart';

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

  // Filtrelenmiş listeler (bottom sheet için)
  List<Customer> _filteredCustomersForSelection = [];
  List<CustomerUser> _filteredCustomerUsersForSelection = [];

  bool _isLoading = true;
  bool _isSaving = false;

  // OrderDetail sayfanızdaki renkler (Örnek, kendi renklerinizi kullanın)
  static const Color primaryColor = Color(0xFFB79C91); // Ana renk
  static const Color accentColor = Color(0xFF8F7A70); // Vurgu rengi
  static const Color backgroundColor = Colors.white; // Arka plan
  static const Color cardBackgroundColor = Color(0xFFF9F5F3); // Kart arka planı
  static const Color textColor = Colors.black87;
  static const Color hintColor = Colors.grey;

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

      _allCustomers = await _dbHelper.getCustomers();
      _allCustomerUsers =
          await _dbHelper.getCustomerUsers(); // Tüm kullanıcıları yükle
      _allOrderTypes = await _dbHelper.getSaleOrderType();

      _filteredCustomersForSelection =
          _allCustomers; // Başlangıçta tüm müşteriler

      if (_currentOrder != null) {
        _selectedCustomer = _allCustomers
            .firstWhere((c) => c.accountCode == _currentOrder!.accountCode);
        _customerDisplayController.text = _selectedCustomer != null
            ? "${_selectedCustomer!.accountCode} - ${_selectedCustomer!.customerName ?? ''}"
            : "Müşteri Seçilmedi";

        // Müşteri seçiliyse, o müşteriye ait kullanıcıları filtrele
        if (_selectedCustomer != null) {
          _filteredCustomerUsersForSelection = _allCustomerUsers
              .where(
                  (user) => user.accountCode == _selectedCustomer!.accountCode)
              .toList();
          // Mevcut Kullanıcıyı Seç
          if (_currentOrder!.customerUserId != null &&
              _currentOrder!.customerUserId != 0) {
            _selectedCustomerUser = _filteredCustomerUsersForSelection
                .firstWhere((u) => u.id == _currentOrder!.customerUserId);
          }
        }
        _userDisplayController.text = _selectedCustomerUser != null
            ? "${_selectedCustomerUser!.id} - ${_selectedCustomerUser!.contactName}"
            : "Yetkili Seç (Opsiyonel)";

        // Mevcut Sipariş Tipini Seç
        _selectedOrderType = _allOrderTypes
            .firstWhere((type) => type.id == _currentOrder!.orderTypeId);
        _orderTypeDisplayController.text = _selectedOrderType != null
            ? _selectedOrderType!.typeName
            : "Sipariş Tipi Seçilmedi";

        _descriptionController.text = _currentOrder!.description;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Sipariş yüklenirken hata: $e',
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.redAccent),
        );
        Navigator.of(context).pop(); // Hata durumunda sayfadan çık
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateOrderHeader() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen bir müşteri seçin.',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.orangeAccent),
      );
      return;
    }
    if (_selectedOrderType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen bir sipariş tipi seçin.',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // DbHelper'ınızda bu isimde bir metodunuz olduğundan emin olun
      await _dbHelper.updateOrder(
        widget.orderUid,
        _selectedCustomer!.accountCode,
        _selectedCustomerUser?.id.toString() ?? "0",
        _selectedOrderType!.id.toString(),
        _descriptionController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('The order was successfully updated!'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return OrderDetail(uid: widget.orderUid);
        }));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error during the update: $e',
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showItemSelectionSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> allItems,
    required List<T> filteredItems,
    required String Function(T item) displayItem,
    required String Function(T item)? subtitleItem,
    required void Function(T item) onItemSelected,
    required void Function(String query, StateSetter setModalState) filterLogic,
    required String searchHint,
  }) {
    TextEditingController searchController = TextEditingController();

    List<T> localFilteredItems = List.from(filteredItems);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext modalContext, StateSetter setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (_, scrollController) => Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: searchHint,
                      hintStyle:
                          TextStyle(color: hintColor.withValues(alpha: 0.7)),
                      prefixIcon: Icon(Icons.search,
                          color: primaryColor.withValues(alpha: 0.7)),
                      filled: true,
                      fillColor: cardBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: primaryColor, width: 1.5),
                      ),
                    ),
                    onChanged: (value) {
                      // Dışarıdan gelen filtreleme mantığını çağır ve modal'in state'ini güncelle
                      filterLogic(value, setModalState);
                      // Bu kısım önemli: _showItemSelectionSheet'e gönderilen filteredItems listesi
                      // ana widget'ın state'inde güncellenmeli ve buraya yansıtılmalı.
                      // Veya `localFilteredItems` doğrudan burada filtrelenebilir.
                      // Şimdilik ana widget'taki filtrelemenin yansıdığını varsayıyoruz.
                      // Doğrudan local filtreleme için:
                      setModalState(() {
                        if (value.isEmpty) {
                          localFilteredItems = List.from(allItems);
                        } else {
                          if (T == Customer) {
                            localFilteredItems =
                                (allItems as List<Customer>).where((item) {
                              final c = item;
                              return (c.accountCode
                                      .toLowerCase()
                                      .contains(value.toLowerCase()) ||
                                  (c.customerName?.toLowerCase() ?? '')
                                      .contains(value.toLowerCase()));
                            }).toList() as List<T>;
                          } else if (T == CustomerUser) {
                            localFilteredItems =
                                (allItems as List<CustomerUser>).where((item) {
                              final u = item;
                              return (u.contactName
                                      .toLowerCase()
                                      .contains(value.toLowerCase()) ||
                                  u.id.toString().contains(value));
                            }).toList() as List<T>;
                          }
                          // SaleOrderType için gerekirse eklenebilir
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: localFilteredItems
                            .isEmpty // localFilteredItems'ı kontrol et
                        ? const Center(
                            child: Text("Sonuç bulunamadı.",
                                style: TextStyle(color: hintColor)))
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: localFilteredItems.length,
                            // localFilteredItems'ı kullan
                            itemBuilder: (context, index) {
                              final item = localFilteredItems[
                                  index]; // localFilteredItems'ı kullan
                              return Card(
                                elevation: 1,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                color: cardBackgroundColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                child: ListTile(
                                  title: Text(displayItem(item),
                                      style: const TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.w500)),
                                  subtitle: subtitleItem != null
                                      ? Text(subtitleItem(item),
                                          style: TextStyle(
                                              color: textColor.withValues(
                                                  alpha: 0.7)))
                                      : null,
                                  onTap: () {
                                    onItemSelected(item);
                                    Navigator.pop(ctx);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                  // "Seçme" veya "Temizle" butonu (opsiyonel)
                  if (title.contains("Yetkili")) // Sadece yetkili için "Seçme"
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            if (T == CustomerUser) {
                              onItemSelected(null as T); // null gönder
                            }
                            Navigator.pop(ctx);
                          },
                          child: const Text("Yetkiliyi Temizle",
                              style: TextStyle(color: primaryColor)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      // Modal kapandığında ana sayfadaki filtre listelerini sıfırla
      if (T == Customer) {
        setState(() {
          _filteredCustomersForSelection = _allCustomers;
        });
      } else if (T == CustomerUser && _selectedCustomer != null) {
        setState(() {
          _filteredCustomerUsersForSelection = _allCustomerUsers
              .where(
                  (user) => user.accountCode == _selectedCustomer!.accountCode)
              .toList();
        });
      }
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    bool isRequired = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    int? maxLines = 1, // Yeni parametre: Varsayılan olarak 1 satır
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: onTap != null,
        // Eğer onTap varsa, sadece okunabilir yap
        decoration: InputDecoration(
          labelText: '$labelText${isRequired ? " *" : ""}',
          labelStyle: const TextStyle(color: accentColor),
          hintText: hintText,
          hintStyle: TextStyle(color: hintColor.withValues(alpha: 0.7)),
          filled: true,
          fillColor: cardBackgroundColor,
          prefixIcon: Icon(icon, color: primaryColor.withValues(alpha: 0.8)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
        ),
        onTap: onTap,
        validator: validator,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textInputAction: textInputAction ??
            (maxLines != null && maxLines > 1
                ? TextInputAction.newline
                : TextInputAction.done),
        style: const TextStyle(color: textColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "EDIT ORDER",
          style: TextStyle(
              color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundColor,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildTextField(
                      controller: _customerDisplayController,
                      labelText: "Customer",
                      hintText: "Select Customer",
                      icon: Icons.business_outlined,
                      isRequired: true,
                      onTap: () {
                        _showItemSelectionSheet<Customer>(
                          context: context,
                          title: "Select Customer",
                          allItems: _allCustomers,
                          filteredItems: _filteredCustomersForSelection,
                          // Başlangıçta tüm müşteriler
                          displayItem: (c) =>
                              "${c.accountCode} - ${c.customerName ?? ''}",
                          subtitleItem: (c) => c.taxNumber ?? "Tax Id: Unknown",
                          onItemSelected: (selected) {
                            setState(() {
                              _selectedCustomer = selected;
                              _customerDisplayController.text =
                                  "${selected.accountCode} - ${selected.customerName ?? ''}";
                              _selectedCustomerUser = null;
                              _userDisplayController.text =
                                  "Select Customer User (Optional)";
                              _filteredCustomerUsersForSelection =
                                  _allCustomerUsers
                                      .where((user) =>
                                          user.accountCode ==
                                          selected.accountCode)
                                      .toList();
                            });
                          },
                          filterLogic: (query, setModalState) {
                            // Modal içindeki anlık filtreleme için
                            setModalState(() {
                              // Modal'in kendi state'ini güncelle
                              _filteredCustomersForSelection = query.isEmpty
                                  ? _allCustomers
                                  : _allCustomers
                                      .where((c) =>
                                          c.accountCode
                                              .toLowerCase()
                                              .contains(query.toLowerCase()) ||
                                          (c.customerName?.toLowerCase() ?? '')
                                              .contains(query.toLowerCase()))
                                      .toList();
                            });
                          },
                          searchHint: "Search by account code or name...",
                        );
                      },
                      validator: (value) => (_selectedCustomer == null)
                          ? 'Customer selection is compulsory.'
                          : null,
                    ),

                    // Yetkili Seçimi (Sadece müşteri seçiliyse görünür ve aktif)
                    if (_selectedCustomer != null)
                      _buildTextField(
                        controller: _userDisplayController,
                        labelText: "Customer User",
                        hintText: "Select Customer User (Optional)",
                        icon: Icons.person_outline,
                        onTap: () {
                          // Müşteriye ait kullanıcı listesini hazırla
                          final usersForSelectedCustomer = _allCustomerUsers
                              .where((user) =>
                                  user.accountCode ==
                                  _selectedCustomer!.accountCode)
                              .toList();
                          setState(() {
                            // Ana state'i güncelle, modal bu listeyi alacak
                            _filteredCustomerUsersForSelection =
                                usersForSelectedCustomer;
                          });

                          _showItemSelectionSheet<CustomerUser>(
                            context: context,
                            title: "Select Customer User",
                            allItems: usersForSelectedCustomer,
                            // Sadece ilgili müşterinin kullanıcıları
                            filteredItems: _filteredCustomerUsersForSelection,
                            // Başlangıçta o müşterinin kullanıcıları
                            displayItem: (u) => "${u.id} - ${u.contactName}",
                            subtitleItem: (u) => u.departmentName,
                            onItemSelected: (selected) {
                              setState(() {
                                _selectedCustomerUser = selected;
                                _userDisplayController.text =
                                    "${selected.id} - ${selected.contactName}";
                              });
                            },
                            filterLogic: (query, setModalState) {
                              setModalState(() {
                                _filteredCustomerUsersForSelection = query
                                        .isEmpty
                                    ? usersForSelectedCustomer // Temel liste
                                    : usersForSelectedCustomer
                                        .where((user) =>
                                            user.contactName
                                                .toLowerCase()
                                                .contains(
                                                    query.toLowerCase()) ||
                                            user.id.toString().contains(query))
                                        .toList();
                              });
                            },
                            searchHint: "Search Custumer User ...",
                          );
                        },
                      ),
                    if (_selectedCustomer == null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: "Customer User",
                            labelStyle: const TextStyle(color: hintColor),
                            hintText: "Select Customer First",
                            hintStyle: TextStyle(
                                color: hintColor.withValues(alpha: 0.7)),
                            filled: true,
                            fillColor:
                                cardBackgroundColor.withValues(alpha: 0.5),
                            prefixIcon: Icon(Icons.person_outline,
                                color: hintColor.withValues(alpha: 0.5)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),

                    _buildTextField(
                      controller: _orderTypeDisplayController,
                      labelText: "Order Type",
                      hintText: "Select Order Type",
                      icon: Icons.list_alt_outlined,
                      isRequired: true,
                      onTap: () {
                        _showItemSelectionSheet<SaleOrderType>(
                          context: context,
                          title: "Select Order Type",
                          allItems: _allOrderTypes,
                          filteredItems: _allOrderTypes,
                          displayItem: (st) => st.typeName,
                          subtitleItem: (st) => "ID: ${st.id}",
                          onItemSelected: (selected) {
                            setState(() {
                              _selectedOrderType = selected;
                              _orderTypeDisplayController.text =
                                  selected.typeName;
                            });
                          },
                          filterLogic: (query, setModalState) {
                            setModalState(() {
                              _allOrderTypes;
                            });
                          },
                          searchHint: "Search Order Type...",
                        );
                      },
                      validator: (value) => (_selectedOrderType == null)
                          ? 'Order Type selection is compulsory.'
                          : null,
                    ),
                    _buildTextField(
                      controller: _descriptionController,
                      labelText: "Description",
                      hintText: "Description of Order (optional)",
                      icon: Icons.description_outlined,
                      maxLines: 8,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.0))
                          : const Icon(Icons.check_outlined,
                              color: Colors.white),
                      label: Text(
                        _isSaving ? 'SAVING...' : 'UPDATE ORDER',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      onPressed: _isSaving ? null : _updateOrderHeader,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
