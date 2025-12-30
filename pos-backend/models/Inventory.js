const mongoose = require("mongoose");

const inventorySchema = new mongoose.Schema({
  product: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Product",
    required: true
  },
  transaction: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Transaction",
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",      
    required: true
  },
  quantity: {
    type: Number,
    required: true
  },
  type: {
    type: String,
    enum: ["IN", "OUT"],
    required: true
  },
  date: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model("Inventory", inventorySchema);
