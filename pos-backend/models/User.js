const mongoose = require("mongoose");
const bcrypt = require("bcrypt");

const userSchema = new mongoose.Schema({
  username: { type: String, required: true,unique:true, lowercase: true },
  role: { type: String, enum: ["admin","cashier","customer"], required: true },
  password: { type: String, required: true, minlength: 6 },
  createdAt: { type: Date, default: Date.now },

  preferences: { type: [String], default: [] },
  permissions: { type: mongoose.Schema.Types.Mixed },
  activityLog: { type: [mongoose.Schema.Types.Mixed], default: [] }
});

userSchema.pre("save", async function() {
  if (!this.isModified("password")) return;
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

module.exports = mongoose.model("User", userSchema);
