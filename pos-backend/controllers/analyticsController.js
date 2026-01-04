const Sale = require("../models/Sale");
const Product = require("../models/Product");

exports.getDashboardStats = async (req, res) => {
  try {
    // 1. Total Sales Count
    const totalSales = await Sale.countDocuments();

    // 2. Total Revenue (Sum of 'total' field)
    const revenueAgg = await Sale.aggregate([
      { $group: { _id: null, totalRevenue: { $sum: "$total" } } }
    ]);
    const totalRevenue = revenueAgg.length > 0 ? revenueAgg[0].totalRevenue : 0;

    // 3. Low Stock Items (stockQuantity < 5)
    // Assuming 'stockQuantity' is the field name in Product model
    const lowStockCount = await Product.countDocuments({ stockQuantity: { $lt: 5 } });

    // 4. Recent Transactions (Limit 5, sort by date desc)
    const recentTransactions = await Sale.find()
      .sort({ date: -1 })
      .limit(5)
      .populate("cashier", "name email"); // Populate cashier info if available

    res.json({
      totalSales,
      totalRevenue,
      lowStockCount,
      recentTransactions
    });
  } catch (error) {
    console.error("Dashboard Stats Error:", error);
    res.status(500).json({ message: "Server Error fetching stats" });
  }
};
