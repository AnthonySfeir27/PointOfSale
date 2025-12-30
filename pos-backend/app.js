require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();

//middleman
app.use(cors());
app.use(express.json());

//testing route
app.get("/", (req, res) => {
  res.send("POS Backend is running ✅");
});

//API Routes
app.use("/products", require("./routes/productRoutes"));
app.use("/users", require("./routes/userRoutes"));
app.use("/sales", require("./routes/saleRoutes"));

//Connection and Server Start
mongoose.connect(process.env.MONGO_URL)
  .then(() => {
    console.log("MongoDB connected ✅");

    app.listen(5000, () => {
      console.log("Server running on port 5000");
    });
  })
  .catch((err) => {
    console.error("MongoDB connection failed ❌", err);
  });
