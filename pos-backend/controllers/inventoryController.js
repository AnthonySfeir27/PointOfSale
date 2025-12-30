const Inventory = require("../models/Inventory");


exports.getAllInventory = async (req, res) => {
  try {
    const { productId, userId, type, startDate, endDate } = req.query;
    const filter = {};

    if (productId) filter.product = productId;
    if (userId) filter.user = userId;
    if (type) filter.type = type;
    if (startDate || endDate) filter.date = {};
    if (startDate) filter.date.$gte = new Date(startDate);
    if (endDate) filter.date.$lte = new Date(endDate);

    const inventory = await Inventory.find(filter)
      .populate("product")
      .populate("user")
      .populate("transaction");

    res.json(inventory);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getInventoryById = async (req, res) => {
  try {
    const inventory = await Inventory.findById(req.params.id)
      .populate("product")
      .populate("user")
      .populate("transaction");

    if (!inventory) return res.status(404).json({ error: "Inventory log not found" });
    res.json(inventory);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.createInventory = async (req, res) => {
  try {
    const inventory = new Inventory(req.body);
    await inventory.save();
    res.status(201).json(inventory);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.updateInventory = async (req, res) => {
  try {
    const inventory = await Inventory.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!inventory) return res.status(404).json({ error: "Inventory log not found" });
    res.json(inventory);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.deleteInventory = async (req, res) => {
  try {
    const inventory = await Inventory.findByIdAndDelete(req.params.id);
    if (!inventory) return res.status(404).json({ error: "Inventory log not found" });
    res.json({ message: "Inventory log deleted successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
