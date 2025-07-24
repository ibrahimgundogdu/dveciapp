import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../database/db_helper.dart';
import '../models/customer.dart';
import '../models/customeruser.dart';
import '../models/saleorderdocument.dart';
import '../models/saleordertype.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';
import 'orderdetail.dart';

class CheckoutBasket extends StatefulWidget {
  const CheckoutBasket({super.key});

  @override
  State<CheckoutBasket> createState() => _CheckoutBasketState();
}

class _CheckoutBasketState extends State<CheckoutBasket> {
  final DbHelper _dbHelper = DbHelper.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Uuid _uuid = const Uuid();
  final ImagePicker _picker = ImagePicker(); // ImagePicker instance

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

  final List<XFile> _pickedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      _allCustomers = await _dbHelper.getCustomers();
      _allCustomerUsers = await _dbHelper.getCustomerUsers();
      _allOrderTypes = await _dbHelper.getSaleOrderType();

      _filteredCustomers = _allCustomers;

      if (_allOrderTypes.isNotEmpty) {
        _selectedOrderType = _allOrderTypes.firstWhere((type) => type.id == 1,
            orElse: () => _allOrderTypes.first);
        _orderTypeDisplayController.text =
            "${_selectedOrderType!.id} - ${_selectedOrderType!.typeName}";
      }
      _customerDisplayController.text = "Select Customer";
      _userDisplayController.text = "Select User (Optional)";
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred when loading the data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? imageFile = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (imageFile != null) {
        setState(() {
          if (!_pickedFiles.any((file) => file.path == imageFile.path)) {
            _pickedFiles.add(imageFile);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('The file could not be selected: $e')),
        );
      }
    }
  }

  void _removeFile(XFile fileToRemove) {
    setState(() {
      _pickedFiles.removeWhere((file) => file.path == fileToRemove.path);
    });
  }

  void _filterCustomersForSelection(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = _allCustomers;
      } else {
        _filteredCustomers = _allCustomers
            .where((customer) =>
                customer.accountCode
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                customer.customerName!
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _filterCustomerUsersForSelection(String query) {
    final baseList = _selectedCustomer != null
        ? _allCustomerUsers
            .where((user) => user.accountCode == _selectedCustomer!.accountCode)
            .toList()
        : <CustomerUser>[];

    setState(() {
      if (query.isEmpty) {
        _filteredCustomerUsersForSelection = baseList;
      } else {
        _filteredCustomerUsersForSelection = baseList
            .where((user) =>
                user.contactName.toLowerCase().contains(query.toLowerCase()) ||
                user.id.toString().contains(query))
            .toList();
      }
    });
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a customer.')),
      );
      return;
    }
    if (_selectedOrderType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an order type.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    String orderUid = _uuid.v4();

    try {
      // 1. Sipariş Başlığını Kaydet
      await _dbHelper.addOrder(
        orderUid,
        _selectedCustomer?.accountCode ?? "120.00.000",
        _selectedCustomerUser?.id.toString() ?? "0",
        _selectedOrderType?.id.toString() ?? "1",
        _descriptionController.text,
      );

      // 2. Seçilen Dosyaları Kaydet (eğer varsa)
      if (_pickedFiles.isNotEmpty) {
        for (XFile pickedFile in _pickedFiles) {
          SaleOrderDocument newDoc = SaleOrderDocument(
            id: 0,
            saleOrderUid: orderUid,
            saleOrderRowUid: null,
            pathName: pickedFile.path,
            documentName: pickedFile.name,
          );

          await _dbHelper.addOrderXFile(newDoc);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The order was created successfully!')),
        );

        //await _dbHelper.removeAllBasket();

        if (!mounted) return;
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => OrderDetail(uid: orderUid),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error while recording order: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: drawerMenu(context, "D-Veci"),
      bottomNavigationBar: bottomWidget(context, 3),
      appBar: AppBar(
        title: const Text(
          "CREATE ORDER",
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildFormContent(),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // ... (_buildSelectionField ve _buildDescriptionField aynı kalacak) ...
          _buildSelectionField(
            label: "CUSTOMER (*)",
            controller: _customerDisplayController,
            onTap: () => _showCustomerSelectionSheet(context),
            validator: (value) {
              if (_selectedCustomer == null) {
                return 'Customer selection required.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildSelectionField(
            label: "CUSTOMER USER (Optional)",
            controller: _userDisplayController,
            onTap: () {
              if (_selectedCustomer == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please select a customer first.')),
                );
                return;
              }
              _showUserSelectionSheet(context);
            },
          ),
          const SizedBox(height: 16),
          _buildSelectionField(
            label: "ORDER TYPE (*)",
            controller: _orderTypeDisplayController,
            onTap: () => _showOrderTypeSelectionSheet(context),
            validator: (value) {
              if (_selectedOrderType == null) {
                return 'Order Type Selection is required.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          _buildSectionTitle("ORDER DOCUMENTS (Optional)",
              icon: Icons.attach_file_rounded),
          _buildFileAttachmentSection(),
          const SizedBox(height: 24),

          _buildDescriptionField(),
          const SizedBox(height: 32),
          _buildSaveButton(),
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
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark),
          ),
        ],
      ),
    );
  }

  Widget _buildFileAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_pickedFiles.isNotEmpty)
          Container(
            height: 110,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300)),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _pickedFiles.length,
              itemBuilder: (context, index) {
                final file = _pickedFiles[index];
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
                            .withValues(alpha: 0.7)),
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

  Widget _buildSelectionField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText:
                controller.text.isEmpty ? "Seçim Yapınız" : controller.text,
            hintStyle: TextStyle(color: Colors.grey[600]),
            suffixIcon:
                const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "DESCRIPTION (Optional)".toUpperCase(),
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Order Notes...",
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: _isSaving
            ? Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(2.0),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Icon(Icons.check_circle_outline_rounded),
        label: Text(_isSaving ? 'SAVING...' : 'CREATE ORDER'),
        onPressed: _isSaving ? null : _saveOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  void _showCustomerSelectionSheet(BuildContext context) {
    _filteredCustomers = _allCustomers;
    final searchController = TextEditingController();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        // Farklı bir context adı
        return StatefulBuilder(
          // BottomSheet içinde arama için
          builder: (BuildContext context, StateSetter modalSetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              // Başlangıç boyutu
              minChildSize: 0.3,
              maxChildSize: 0.8,
              // Maksimum boyut
              expand: false,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 16.0, left: 16, right: 16, bottom: 8),
                      child: Text('SELECT CUSTOMER',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 16),
                        ),
                        onChanged: (value) {
                          modalSetState(() {
                            // modalSetState kullanarak BottomSheet'i güncelle
                            _filterCustomersForSelection(value);
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _filteredCustomers.isEmpty
                          ? const Center(child: Text("Customer not found."))
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: _filteredCustomers.length,
                              itemBuilder: (context, index) {
                                final customer = _filteredCustomers[index];
                                return ListTile(
                                  title: Text(customer.customerName ?? ""),
                                  subtitle: Text(customer.accountCode),
                                  onTap: () {
                                    setState(() {
                                      _selectedCustomer = customer;
                                      _customerDisplayController.text =
                                          "${customer.accountCode} - ${customer.customerName}";
                                      _selectedCustomerUser = null;
                                      _userDisplayController.text =
                                          "SELECT USER (Optional)";
                                      _filteredCustomerUsersForSelection =
                                          _allCustomerUsers
                                              .where((user) =>
                                                  user.accountCode ==
                                                  customer.accountCode)
                                              .toList();
                                    });
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showUserSelectionSheet(BuildContext context) {
    _filteredCustomerUsersForSelection = _allCustomerUsers
        .where((user) => user.accountCode == _selectedCustomer!.accountCode)
        .toList();
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.6,
              expand: false,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 16.0, left: 16, right: 16, bottom: 8),
                      child: Text('Select User',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 16),
                        ),
                        onChanged: (value) {
                          modalSetState(() {
                            _filterCustomerUsersForSelection(value);
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _filteredCustomerUsersForSelection.isEmpty
                          ? const Center(
                              child: Text("User of this customer not found."))
                          : ListView.builder(
                              controller: scrollController,
                              itemCount:
                                  _filteredCustomerUsersForSelection.length,
                              itemBuilder: (context, index) {
                                final user =
                                    _filteredCustomerUsersForSelection[index];
                                return ListTile(
                                  title: Text(user.contactName),
                                  subtitle: Text("ID: ${user.id}"),
                                  onTap: () {
                                    setState(() {
                                      _selectedCustomerUser = user;
                                      _userDisplayController.text =
                                          "#${user.id} - ${user.contactName}";
                                    });
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                    ),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCustomerUser = null;
                            _userDisplayController.text =
                                "Select User (Optional)";
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text("Select User",
                            style: TextStyle(color: Colors.blueAccent))),
                    const SizedBox(
                      height: 8,
                    )
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showOrderTypeSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.5,
            expand: false,
            builder: (_, scrollController) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0, left: 16, right: 16, bottom: 8),
                    child: Text('Select Order Type',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: _allOrderTypes.isEmpty
                        ? const Center(child: Text("Order Type not found."))
                        : ListView.builder(
                            controller: scrollController,
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
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            });
      },
    );
  }
}
