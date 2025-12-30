const Transaction = require("../models/Transaction");


exports.getAllTransactions = async (req, res) => {
  try {
    const { method, startDate, endDate } = req.query;
    const filter = {};

    if (method) filter.method = method;
    if (startDate || endDate) filter.date = {};
    if (startDate) filter.date.$gte = new Date(startDate);
    if (endDate) filter.date.$lte = new Date(endDate);

    const transactions = await Transaction.find(filter)
      .populate({
        path: "sale",
        populate: [
          { path: "products.product" },  
          { path: "cashier" },          
          { path: "customer" }           
        ]
      })
      .populate("inventoryLogs");       
    res.json(transactions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


exports.getTransactionById = async (req, res) => {
  try {
    const transaction = await Transaction.findById(req.params.id)
      .populate({
        path: "sale",
        populate: [
          { path: "products.product" },
          { path: "cashier" },
          { path: "customer" }
        ]
      })
      .populate("inventoryLogs");

    if (!transaction) return res.status(404).json({ error: "Transaction not found" });
    res.json(transaction);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


exports.createTransaction = async (req, res) => {
  try {
    const transaction = new Transaction(req.body);
    await transaction.save();
    res.status(201).json(transaction);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};


exports.updateTransaction = async (req, res) => {
  try {
    const transaction = await Transaction.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    if (!transaction) return res.status(404).json({ error: "Transaction not found" });
    res.json(transaction);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};


exports.deleteTransaction = async (req, res) => {
  try {
    const transaction = await Transaction.findByIdAndDelete(req.params.id);
    if (!transaction) return res.status(404).json({ error: "Transaction not found" });
    res.json({ message: "Transaction deleted successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.aggregateByMethod = async (req, res) => {
  try {
    const result = await Transaction.aggregate([
      { $group: { _id: "$method", totalAmount: { $sum: "$amount" } } }
    ]);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
