const mongoose = require("mongoose");

const saleSchema = new mongoose.Schema({
  products: [{
    product: { type: mongoose.Schema.Types.ObjectId, ref: "Product", required: true },
    quantity: { type: Number, required: true, max: 50 }
  }],
  cashier: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  total: { type: Number, required: true, max: 10000 },
  isParked: { type: Boolean, default: false },
  status: { type: String, enum: ["completed", "parked"], default: "completed" },
  ticketName: { type: String },
  date: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Sale", saleSchema);
