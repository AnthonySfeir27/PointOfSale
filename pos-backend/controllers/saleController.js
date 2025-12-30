const Sale = require("../models/Sale");
const Inventory = require("../models/Inventory");
const Product = require("../models/Product");
const Transaction = require("../models/Transaction");


exports.createSale = async (req, res) => {
  try {
    const { products, cashier, customer, total, createTransaction } = req.body;

   
    const sale = new Sale({ products, cashier, customer, total });
    await sale.save();


    const inventoryLogs = [];
    for (let item of products) {
      const product = await Product.findById(item.product);
      if (!product) continue;

      const log = await Inventory.create({
        product: product._id,
        quantity: item.quantity,
        type: "OUT"
      });
      inventoryLogs.push(log._id);
    }
    sale.inventoryLogs = inventoryLogs;
    await sale.save();

    
    if (createTransaction) {
      const transaction = await Transaction.create({
        sale: sale._id,
        user: cashier,
        method: createTransaction.method,
        amount: total,
        inventoryLogs
      });
      sale.transaction = transaction._id;
      await sale.save();
    }

    const populatedSale = await Sale.findById(sale._id)
      .populate("products.product")
      .populate("cashier")
      .populate("customer")
      .populate("inventoryLogs")
      .populate("transaction");

    res.status(201).json(populatedSale);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.getSales = async (req, res) => {
  try {
    const sales = await Sale.find()
      .populate("products.product")
      .populate("cashier")
      .populate("customer")
      .populate("inventoryLogs")
      .populate("transaction");
    res.json(sales);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getSaleById = async (req, res) => {
  try {
    const sale = await Sale.findById(req.params.id)
      .populate("products.product")
      .populate("cashier")
      .populate("customer")
      .populate("inventoryLogs")
      .populate("transaction");
    if (!sale) return res.status(404).json({ error: "Sale not found" });
    res.json(sale);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.updateSale = async (req, res) => {
  try {
    const sale = await Sale.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!sale) return res.status(404).json({ error: "Sale not found" });
    res.json(sale);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.deleteSale = async (req, res) => {
  try {
    const sale = await Sale.findByIdAndDelete(req.params.id);
    if (!sale) return res.status(404).json({ error: "Sale not found" });
    res.json({ message: "Sale deleted successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.salesByProduct = async (req, res) => {
  try {
    const result = await Sale.aggregate([
      { $unwind: "$products" },
      { $group: { _id: "$products.product", totalSold: { $sum: "$products.quantity" } } },
      { $lookup: { from: "products", localField: "_id", foreignField: "_id", as: "product" } },
      { $unwind: "$product" }
    ]);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
