import 'package:collection/collection.dart';
import 'package:dveci_app/models/saleordertype.dart';
import 'package:dveci_app/pages/order_row_detail.dart';
import 'package:dveci_app/pages/syncronize.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/db_helper.dart';
import '../models/userauthentication.dart';
import '../models/saleorder.dart';
import '../services/sharedpreferences.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';
import 'basketlist.dart';
import 'customerlist.dart';
import 'orderlist.dart';
import 'orderdetail.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<Map<String, dynamic>> _dataFuture;
  final DbHelper _dbHelper = DbHelper.instance;
  late List<SaleOrderType?> _saleOrderTypes = [];

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<Map<String, dynamic>> _loadData() async {
    final employee = await getEmployee();
    final orderCount = await _dbHelper.getOrderCount();
    final basketCount = await _dbHelper.getBasketCount();
    final customerCount = await _dbHelper.getCustomerCount();
    final recentOrders = await _dbHelper.getRecentOrders(limit: 10);
    _saleOrderTypes = await _dbHelper.getSaleOrderType();

    return {
      'employee': employee,
      'orderCount': orderCount,
      'basketCount': basketCount,
      'customerCount': customerCount,
      'recentOrders': recentOrders,
    };
  }

  Future<UserAuthentication?> getEmployee() async {
    final token = await ServiceSharedPreferences.getSharedString("token");
    if (token != null) {
      return await _dbHelper.getUserAuthentication(token);
    }
    return null;
  }

  Future<void> _refreshData() async {
    setState(() {
      _dataFuture = _loadData();
    });
    await _dataFuture;
  }

  Color _getStatusColor(int? orderStatusId) {
    switch (orderStatusId) {
      case 0:
        return Colors.blueGrey;
      case -1:
        return Colors.red;
      case 1:
        return Colors.purple;
      default:
        return Colors.black;
    }
  }

  IconData _getStatusIcon(int? statusId) {
    switch (statusId) {
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
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      drawer: drawerMenu(context, "D-Veci"),
      bottomNavigationBar: bottomWidget(context, 0),
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final employee =
                  snapshot.data!['employee'] as UserAuthentication?;
              return Text(
                employee?.employeeName ?? "Home",
                style: GoogleFonts.openSans(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.primary), // Drawer icon rengi
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color:
            Theme.of(context).colorScheme.primary, // Yenileme indicator rengi
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return _buildErrorView(snapshot.error);
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              final basketCount = data['basketCount'] as int;
              final orderCount = data['orderCount'] as int;
              final customerCount = data['customerCount'] as int;
              final recentOrders = data['recentOrders'] as List<SaleOrder>;

              return _buildDashboardContent(
                basketCount,
                orderCount,
                customerCount,
                8,
                recentOrders,
              );
            }
            return _buildNoDataView();
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    int basketCount,
    int orderCount,
    int customerCount,
    int fourthCardCount, // 4. kart için sayı
    List<SaleOrder> recentOrders,
  ) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverGrid.count(
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            children: <Widget>[
              _buildDashboardCard(
                count: basketCount,
                title: "Basket Items",
                icon: Icons.shopping_bag_outlined,
                iconColor: Colors.orange.shade700,
                onTap: () {
                  Navigator.of(context).push<String>(MaterialPageRoute(
                    builder: (context) => const BasketList(),
                  ));
                },
              ),
              _buildDashboardCard(
                count: orderCount,
                title: "Orders",
                icon: Icons.folder_copy_outlined,
                iconColor: Colors.purple.shade700,
                onTap: () {
                  Navigator.of(context).push<String>(MaterialPageRoute(
                    builder: (context) => const OrderList(),
                  ));
                },
              ),
              _buildDashboardCard(
                count: customerCount,
                title: "Customers",
                icon: Icons.corporate_fare_outlined,
                iconColor: Colors.blue.shade700,
                onTap: () {
                  Navigator.of(context).push<String>(MaterialPageRoute(
                    builder: (context) => const CustomerList(),
                  ));
                },
              ),
              _buildDashboardCard(
                count: fourthCardCount,
                title: "Synchronise",
                icon: Icons.cloud_download_outlined,
                iconColor: Colors.red.shade700,
                onTap: () {
                  Navigator.of(context).push<String>(MaterialPageRoute(
                    builder: (context) => const Syncronize(),
                  ));
                },
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Center(
              child: Text(
                "Recent Orders",
                style: GoogleFonts.openSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ),
        if (recentOrders.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off_rounded,
                      size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "No order has been created yet.",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final order = recentOrders[index];
                return _buildRecentOrderItem(order);
              },
              childCount: recentOrders.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildRecentOrderItem(SaleOrder order) {
    var orderTypeName = _saleOrderTypes.firstWhereOrNull(
      (type) => type?.id == (order.orderTypeId!),
    );

    final statusColor = _getStatusColor(order.orderStatusId);
    final statusIcon = _getStatusIcon(order.orderStatusId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 0.4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => OrderDetail(uid: order.uid),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber,
                      style: GoogleFonts.openSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      orderTypeName?.typeName ?? "",
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      // Uzun metinler için taşma kontrolü
                      maxLines: 1,
                      // Tek satırda kalmasını sağla
                      text: TextSpan(
                        // Varsayılan stil (eğer tüm span'ler aynı stildeyse burada tanımlanabilir)
                        // style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13, color: Colors.grey.shade600),
                        children: <TextSpan>[
                          TextSpan(
                            text: order.accountCode,
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight
                                    .w500), // İsterseniz stili biraz farklılaştırabilirsiniz
                          ),
                          TextSpan(
                            text: ' - ', // İki metin arasına ayırıcı
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey
                                    .shade500), // Ayırıcı için farklı bir stil
                          ),
                          TextSpan(
                            text: order.orderDate != null
                                ? "${order.orderDate!.day.toString().padLeft(2, '0')}.${order.orderDate!.month.toString().padLeft(2, '0')}.${order.orderDate!.year} ${order.orderDate!.hour.toString().padLeft(2, '0')}:${order.orderDate!.minute.toString().padLeft(2, '0')}"
                                : "",
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.grey.shade400, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required int count,
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          15.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // İçerik ortalandı
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.0),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 32.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.black.withValues(alpha: 0.65),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Text(
                "$count",
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: Colors.black.withValues(alpha: 0.85),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                color: Colors.red.shade400, size: 60),
            const SizedBox(height: 16),
            Text(
              'Error Accured!',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later and check Internet connection.\nDetail: ${error.toString()}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied_outlined,
                color: Colors.grey.shade400, size: 60),
            const SizedBox(height: 16),
            const Text(
              "Data not found.",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Please try again later.",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}
