const router = require("express").Router();
const c = require("../controllers/saleController");

// CRUD
router.post("/", c.createSale);
router.get("/", c.getSales);
router.get("/:id", c.getSaleById);
router.put("/:id", c.updateSale);
router.delete("/:id", c.deleteSale);

// Aggregate example
router.get("/aggregate/products", c.salesByProduct);

module.exports = router;
