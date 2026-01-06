const mongoose = require("mongoose");

const productSchema = new mongoose.Schema({
  name: { type: String, required: true, lowercase: true },
  category: { type: String, enum: ["food", "drink", "other"], required: true },
  price: { type: Number, required: true, max: 1000 },
  inStock: { type: Boolean, default: true },
  stockQuantity: { type: Number, default: 0, min: 0 },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Product", productSchema);
