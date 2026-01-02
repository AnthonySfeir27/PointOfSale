const router = require("express").Router();
const c = require("../controllers/saleController");

// CRUD
// Aggregate example
router.get("/aggregate/products", c.salesByProduct);

// CRUD
router.post("/", c.createSale);
router.get("/", c.getSales);
router.get("/:id", c.getSaleById);
router.put("/:id", c.updateSale);
router.delete("/:id", c.deleteSale);

module.exports = router;
