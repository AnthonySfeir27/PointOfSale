import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import '../services/analytics_service.dart';
import '../models/dashboard_stats.dart';
import '../models/user_model.dart';
import 'app_drawer.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  final AnalyticsService analyticsService;
  final User user;

  const DashboardScreen({
    super.key,
    required this.analyticsService,
    required this.user,
  });

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _refreshStats();
  }

  void _refreshStats() {
    setState(() {
      _statsFuture = widget.analyticsService.fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshStats),
        ],
      ),
      drawer: AppDrawer(user: widget.user),
      body: FutureBuilder<DashboardStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final stats = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refreshStats(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary row with key metrics
                  _buildSummaryRow(stats),
                  const SizedBox(height: 24),

                  // Sales Chart
                  const Text(
                    'Daily Sales (Last 7 Days)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildSalesChart(stats),
                  const SizedBox(height: 24),

                  // Revenue Chart
                  const Text(
                    'Daily Revenue (Last 7 Days)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildRevenueChart(stats),
                  const SizedBox(height: 24),

                  // Recent Transactions
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildRecentTransactions(stats),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(DashboardStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            Icons.attach_money,
            '\$${stats.totalRevenue.toStringAsFixed(2)}',
            'Total Revenue',
          ),
          _buildSummaryItem(
            Icons.receipt_long,
            '${stats.totalSales}',
            'Total Sales',
          ),
          _buildSummaryItem(
            Icons.warning_amber,
            '${stats.lowStockCount}',
            'Low Stock',
            isWarning: stats.lowStockCount > 0,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    IconData icon,
    String value,
    String label, {
    bool isWarning = false,
  }) {
    return Column(
      children: [
        Icon(icon, color: isWarning ? Colors.amber : Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isWarning ? Colors.amber : Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildSalesChart(DashboardStats stats) {
    if (stats.chartLabels.isEmpty || stats.dailySalesData.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No sales data available')),
      );
    }

    // Prepare data for the chart
    final List<Map<String, dynamic>> chartData = [];
    for (int i = 0; i < stats.chartLabels.length; i++) {
      chartData.add({
        'day': stats.chartLabels[i],
        'sales': stats.dailySalesData[i],
      });
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final chartBgColor = isDarkMode ? const Color(0xFF1B1A23) : Colors.white;
    final shadowColor = isDarkMode
        ? Colors.black45
        : Colors.grey.withOpacity(0.15);
    final axisLabelStyle = LabelStyle(
      textStyle: TextStyle(
        color: isDarkMode ? Colors.white70 : Colors.black87,
        fontSize: 10,
      ),
    );

    return Container(
      height: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: chartBgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Chart(
        data: chartData,
        variables: {
          'day': Variable(accessor: (Map map) => map['day'] as String),
          'sales': Variable(accessor: (Map map) => map['sales'] as num),
        },
        marks: [
          IntervalMark(
            color: ColorEncode(value: Colors.blue),
            size: SizeEncode(value: 20),
          ),
        ],
        axes: [
          Defaults.horizontalAxis..label = axisLabelStyle,
          Defaults.verticalAxis..label = axisLabelStyle,
        ],
      ),
    );
  }

  Widget _buildRevenueChart(DashboardStats stats) {
    if (stats.chartLabels.isEmpty || stats.dailyRevenueData.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No revenue data available')),
      );
    }

    // Prepare data for the chart
    final List<Map<String, dynamic>> chartData = [];
    for (int i = 0; i < stats.chartLabels.length; i++) {
      chartData.add({
        'day': stats.chartLabels[i],
        'revenue': stats.dailyRevenueData[i],
      });
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final chartBgColor = isDarkMode ? const Color(0xFF1B1A23) : Colors.white;
    final shadowColor = isDarkMode
        ? Colors.black45
        : Colors.grey.withOpacity(0.15);
    final axisLabelStyle = LabelStyle(
      textStyle: TextStyle(
        color: isDarkMode ? Colors.white70 : Colors.black87,
        fontSize: 10,
      ),
    );

    return Container(
      height: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: chartBgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Chart(
        data: chartData,
        variables: {
          'day': Variable(accessor: (Map map) => map['day'] as String),
          'revenue': Variable(accessor: (Map map) => map['revenue'] as num),
        },
        marks: [
          LineMark(
            color: ColorEncode(value: Colors.green),
            size: SizeEncode(value: 2),
          ),
          PointMark(
            color: ColorEncode(value: Colors.green),
            size: SizeEncode(value: 6),
          ),
        ],
        axes: [
          Defaults.horizontalAxis..label = axisLabelStyle,
          Defaults.verticalAxis..label = axisLabelStyle,
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(DashboardStats stats) {
    if (stats.recentTransactions.isEmpty) {
      return const Text("No recent transactions.");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.recentTransactions.length,
      itemBuilder: (context, index) {
        final sale = stats.recentTransactions[index];
        final total = sale['total'] ?? 0;
        final date = DateTime.parse(sale['date']);
        final formattedDate = DateFormat('MMM dd, hh:mm a').format(date);

        // Handle cashier population safely - works for both admin and cashier roles
        String cashierName = 'Unknown';
        if (sale['cashier'] != null) {
          if (sale['cashier'] is Map) {
            // Try username first (correct field), fall back to name for compatibility
            cashierName =
                sale['cashier']['username'] ??
                sale['cashier']['name'] ??
                'Unknown';
          } else if (sale['cashier'] is String) {
            cashierName = 'User ID: ${sale['cashier']}';
          }
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade100,
              child: const Icon(Icons.receipt_long, color: Colors.deepPurple),
            ),
            title: Text(
              '\$${total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('$cashierName • $formattedDate'),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ),
        );
      },
    );
  }
}
