const Sale = require("../models/Sale");
const Product = require("../models/Product");

exports.getDashboardStats = async (req, res) => {
  try {
    const totalSales = await Sale.countDocuments();
    const revenueAgg = await Sale.aggregate([
      { $group: { _id: null, totalRevenue: { $sum: "$total" } } }
    ]);
    const totalRevenue = revenueAgg.length > 0 ? revenueAgg[0].totalRevenue : 0;
    const lowStockCount = await Product.countDocuments({ stockQuantity: { $lt: 5 } });
    const recentTransactions = await Sale.find()
      .sort({ date: -1 })
      .limit(5)
      .populate("cashier", "username role");
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 6);
    sevenDaysAgo.setHours(0, 0, 0, 0);

    const dailyData = await Sale.aggregate([
      {
        $match: {
          date: { $gte: sevenDaysAgo }
        }
      },
      {
        $group: {
          _id: {
            year: { $year: "$date" },
            month: { $month: "$date" },
            day: { $dayOfMonth: "$date" }
          },
          salesCount: { $sum: 1 },
          revenue: { $sum: "$total" }
        }
      },
      {
        $sort: { "_id.year": 1, "_id.month": 1, "_id.day": 1 }
      }
    ]);
    const chartLabels = [];
    const dailySalesData = [];
    const dailyRevenueData = [];

    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      const year = date.getFullYear();
      const month = date.getMonth() + 1;
      const day = date.getDate();

      const dayLabel = date.toLocaleDateString('en-US', { weekday: 'short' });
      chartLabels.push(dayLabel);

      const found = dailyData.find(
        d => d._id.year === year && d._id.month === month && d._id.day === day
      );

      dailySalesData.push(found ? found.salesCount : 0);
      dailyRevenueData.push(found ? found.revenue : 0);
    }

    res.json({
      totalSales,
      totalRevenue,
      lowStockCount,
      recentTransactions,
      chartLabels,
      dailySalesData,
      dailyRevenueData
    });
  } catch (error) {
    console.error("Dashboard Stats Error:", error);
    res.status(500).json({ message: "Server Error fetching stats" });
  }
};
