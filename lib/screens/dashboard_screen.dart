import 'package:flutter/material.dart';
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
                  const Text(
                    'Overview',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildStatGrid(stats),
                  const SizedBox(height: 20),
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildRecentTransactions(stats),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatGrid(DashboardStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Revenue',
          '\$${stats.totalRevenue.toStringAsFixed(2)}',
          Colors.green,
        ),
        _buildStatCard('Total Sales', '${stats.totalSales}', Colors.blue),
        _buildStatCard(
          'Low Stock Items',
          '${stats.lowStockCount}',
          stats.lowStockCount > 0 ? Colors.red : Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
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

        // Handle cashier population safely
        String cashierName = 'Unknown';
        if (sale['cashier'] != null) {
          if (sale['cashier'] is Map) {
            cashierName = sale['cashier']['name'] ?? 'Unknown';
          } else {
            cashierName = 'User ID: ${sale['cashier']}';
          }
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.deepPurple),
            title: Text('Sale: \$${total.toStringAsFixed(2)}'),
            subtitle: Text('Cashier: $cashierName\n$formattedDate'),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
