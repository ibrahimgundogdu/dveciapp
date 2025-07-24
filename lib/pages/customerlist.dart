import '../models/customer.dart';
import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';

class CustomerList extends StatefulWidget {
  const CustomerList({super.key});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  final DbHelper _dbHelper = DbHelper.instance;
  late Future<List<Customer>> _customersFuture;
  List<Customer> _filteredCustomers = [];
  List<Customer> _originalCustomers = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _customersFuture = _fetchCustomers();
    _searchController.addListener(_filterCustomers);
  }

  Future<List<Customer>> _fetchCustomers() async {
    final customers = await _dbHelper.getCustomers();
    setState(() {
      _originalCustomers = customers;
      _filteredCustomers = customers;
    });
    return customers;
  }

  Future<void> _refreshCustomers() async {
    _searchController.clear();
    setState(() {
      _customersFuture = _fetchCustomers();
    });
    await _customersFuture;
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = _originalCustomers;
      } else {
        _filteredCustomers = _originalCustomers.where((customer) {
          final customerNameLower = (customer.customerName ?? "").toLowerCase();
          final accountCodeLower = (customer.accountCode).toLowerCase();
          final addressLower = (customer.address ?? "").toLowerCase();
          final taxOfficeLower = (customer.taxOffice ?? "").toLowerCase();

          return customerNameLower.contains(query) ||
              accountCodeLower.contains(query) ||
              addressLower.contains(query) ||
              taxOfficeLower.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCustomers);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      drawer: drawerMenu(context, "D-Veci"),
      bottomNavigationBar: bottomWidget(context,1),
      appBar: AppBar(
        title: const Text(
          "CUSTOMERS",
          style: TextStyle(
            color: Color(0xFFB79C91),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFFB79C91)), // Drawer icon rengi
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCustomers,
        child: Column(
          children: <Widget>[
            _buildSearchField(),
            Expanded(
              child: FutureBuilder<List<Customer>>(
                future: _customersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && _originalCustomers.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error occurred while customers loading: ${snapshot.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshCustomers,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (_originalCustomers.isEmpty && _searchController.text.isEmpty && !snapshot.hasData) {

                  }

                  return _buildCustomerList();
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
          hintText: 'Search Customers',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _searchController.clear();
              // _filterCustomers listener tarafından otomatik çağrılacak
            },
          )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0), // Daha yuvarlak kenarlar
            borderSide: BorderSide.none, // Kenarlık yok
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.deepOrange.shade100, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerList() {
    if (_filteredCustomers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _searchController.text.isNotEmpty
                ? 'Customer Matching With Your Call Not Found.'
                : 'Your customer list is empty.\nSlide down to renew.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      itemCount: _filteredCustomers.length,
      itemBuilder: (context, index) {
        return _buildCustomerCard(_filteredCustomers[index]);
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: 8);
      },
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return Card(
      elevation: 1.0,
      margin: const EdgeInsets.symmetric(vertical: 4.0), // Kartın dikeyde hafif boşluğu
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell( // Kartı tıklanabilir yapmak için
        onTap: () {

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${customer.customerName ?? "Customer"} selected.')),
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                customer.customerName ?? "",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.label_outline_rounded, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    customer.accountCode,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (customer.taxOffice != null && customer.taxOffice!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.business, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "${customer.taxOffice ?? ""} - ${customer.taxNumber ?? ""}",
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (customer.address != null && customer.address!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          customer.address ?? "",
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