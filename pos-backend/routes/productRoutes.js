const router = require("express").Router();
const c = require("../controllers/productController");

// CRUD
router.post("/", c.createProduct);
router.get("/", c.getAllProducts);
router.get("/filter", c.filterProducts);
router.get("/:id", c.getProductById);
router.put("/:id", c.updateProduct);
router.delete("/:id", c.deleteProduct);

// Aggregate
router.get("/aggregate/stock-value", c.aggregateStockValue);

module.exports = router;
