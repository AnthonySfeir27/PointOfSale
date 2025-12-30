const express = require("express");
const router = express.Router();
const c = require("../controllers/transactionController");

// CRUD endpoints
router.get("/", c.getAllTransactions);
router.get("/:id", c.getTransactionById);
router.post("/", c.createTransaction);
router.put("/:id", c.updateTransaction);
router.delete("/:id", c.deleteTransaction);

// Aggregate example
router.get("/aggregate/method", c.aggregateByMethod);

module.exports = router;
