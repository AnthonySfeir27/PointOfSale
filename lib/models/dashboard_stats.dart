class DashboardStats {
  final int totalSales;
  final double totalRevenue;
  final int lowStockCount;
  final List<dynamic> recentTransactions;

  DashboardStats({
    required this.totalSales,
    required this.totalRevenue,
    required this.lowStockCount,
    required this.recentTransactions,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalSales: json['totalSales'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(), // Ensure double
      lowStockCount: json['lowStockCount'] ?? 0,
      recentTransactions: json['recentTransactions'] ?? [],
    );
  }
}
