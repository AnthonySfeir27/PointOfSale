require("dotenv").config(); 
console.log("Mongo URL:", process.env.MONGO_URL);

const express = require("express");
const cors = require("cors");
const mongoose = require('mongoose');

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Test route
app.get("/", (req, res) => {
  res.send("POS backend is running");
});

// MongoDB connection and server start
mongoose.connect(process.env.MONGO_URL)
  .then(() => {
    console.log('MongoDB Atlas connected ✅');

    const PORT = process.env.PORT || 5000;
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  })
  .catch(err => console.log('Connection error:', err));
