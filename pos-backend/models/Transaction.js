const mongoose = require("mongoose");

const transactionSchema = new mongoose.Schema({
  sale: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Sale",
    required: true
  },
  user: { 
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  method: {
    type: String,
    enum: ["cash", "card", "mobile"],
    required: true
  },
  amount: {
    type: Number,
    required: true,
    min: 0
  },
  inventoryLogs: [{ 
    type: mongoose.Schema.Types.ObjectId,
    ref: "Inventory"
  }],
  date: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model("Transaction", transactionSchema);
