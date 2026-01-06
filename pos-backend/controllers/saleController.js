const Sale = require("../models/Sale");
const Product = require("../models/Product");
const User = require("../models/User");


exports.createSale = async (req, res) => {
  try {
    const { products, cashier, total, isParked, ticketName } = req.body;


    const cashierUser = await User.findById(cashier);
    if (!cashierUser) return res.status(404).json({ error: "Cashier not found" });
    if (!isParked) {
      for (let item of products) {
        const product = await Product.findById(item.product);
        if (!product) return res.status(404).json({ error: `Product ${item.product} not found` });
        if (item.quantity > product.stockQuantity) {
          return res.status(400).json({ error: `Not enough stock for product ${product.name}` });
        }
      }


      for (let item of products) {
        await Product.findByIdAndUpdate(item.product, {
          $inc: { stockQuantity: -item.quantity },
        });
      }
    }

    const sale = new Sale({ products, cashier, total, isParked, ticketName });
    await sale.save();

    const populatedSale = await Sale.findById(sale._id)
      .populate("products.product")
      .populate("cashier");

    res.status(201).json(populatedSale);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.getSales = async (req, res) => {
  try {
    const { isParked, cashier } = req.query;
    const filter = {};
    if (isParked !== undefined) {
      filter.isParked = (isParked === 'true' || isParked === true);
    }
    if (cashier) filter.cashier = cashier;

    const sales = await Sale.find(filter)
      .populate("products.product")
      .populate("cashier");
    res.json(sales);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getSaleById = async (req, res) => {
  try {
    const sale = await Sale.findById(req.params.id)
      .populate("products.product")
      .populate("cashier");
    if (!sale) return res.status(404).json({ error: "Sale not found" });
    res.json(sale);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.updateSale = async (req, res) => {
  try {
    const oldSale = await Sale.findById(req.params.id);
    if (!oldSale) return res.status(404).json({ error: "Sale not found" });
    const wasParked = oldSale.isParked || oldSale.status === 'parked';
    const becomingCharged = req.body.isParked === false || req.body.status === 'completed';

    if (wasParked && becomingCharged) {
      for (let item of req.body.products || oldSale.products) {
        const product = await Product.findById(item.product);
        if (!product) return res.status(404).json({ error: `Product ${item.product} not found` });
        if (item.quantity > product.stockQuantity) {
          return res.status(400).json({ error: `Not enough stock for product ${product.name}` });
        }
      }
      for (let item of req.body.products || oldSale.products) {
        await Product.findByIdAndUpdate(item.product, {
          $inc: { stockQuantity: -item.quantity },
        });
      }
    }
    if (req.body.isParked === false) {
      req.body.status = 'completed';
    } else if (req.body.isParked === true) {
      req.body.status = 'parked';
    }

    const sale = await Sale.findByIdAndUpdate(req.params.id, req.body, { new: true })
      .populate("products.product")
      .populate("cashier");
    res.json(sale);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.deleteSale = async (req, res) => {
  try {
    const sale = await Sale.findByIdAndDelete(req.params.id);
    if (!sale) return res.status(404).json({ error: "Sale not found" });

    for (let item of sale.products) {
      await Product.findByIdAndUpdate(item.product, { $inc: { stockQuantity: item.quantity } });
    }

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
