class DashboardStats {
  final int totalSales;
  final double totalRevenue;
  final int lowStockCount;
  final List<dynamic> recentTransactions;
  final List<String> chartLabels;
  final List<int> dailySalesData;
  final List<double> dailyRevenueData;

  DashboardStats({
    required this.totalSales,
    required this.totalRevenue,
    required this.lowStockCount,
    required this.recentTransactions,
    required this.chartLabels,
    required this.dailySalesData,
    required this.dailyRevenueData,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalSales: json['totalSales'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      lowStockCount: json['lowStockCount'] ?? 0,
      recentTransactions: json['recentTransactions'] ?? [],
      chartLabels: List<String>.from(json['chartLabels'] ?? []),
      dailySalesData: List<int>.from(
        (json['dailySalesData'] ?? []).map((e) => (e as num).toInt()),
      ),
      dailyRevenueData: List<double>.from(
        (json['dailyRevenueData'] ?? []).map((e) => (e as num).toDouble()),
      ),
    );
  }
}
