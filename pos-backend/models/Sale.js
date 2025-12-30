const mongoose = require("mongoose");

const saleSchema = new mongoose.Schema({
  products: [{
    product: { type: mongoose.Schema.Types.ObjectId, ref: "Product", required: true },
    quantity: { type: Number, required: true, max: 50 }
  }],
  cashier: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  customer: { type: mongoose.Schema.Types.ObjectId, ref: "User" }, // optional customer
  total: { type: Number, required: true, max: 10000 },
  inventoryLogs: [{ type: mongoose.Schema.Types.ObjectId, ref: "Inventory" }],
  transaction: { type: mongoose.Schema.Types.ObjectId, ref: "Transaction" },
  date: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Sale", saleSchema);
