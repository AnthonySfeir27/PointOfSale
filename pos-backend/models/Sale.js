const mongoose = require("mongoose");

const saleSchema = new mongoose.Schema({
  products: [{
    product: { type: mongoose.Schema.Types.ObjectId, ref: "Product", required: true },
    quantity: { type: Number, required: true, max: 50 }
  }],
  cashier: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  customer: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
  total: { type: Number, required: true, max: 10000 },
  date: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Sale", saleSchema);
