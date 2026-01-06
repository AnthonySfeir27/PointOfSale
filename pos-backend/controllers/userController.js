const User = require("../models/User");
const bcrypt = require("bcrypt");

//creates a user,required to define the username and password and role,the rest is not
//its on create  /users/
exports.createUser = async (req, res) => {
  try {
    console.log("Creating user:", req.body);
    const user = await User.create(req.body);
    res.status(201).json(user);
  } catch (err) {
    console.error("Error in createUser:", err);
    res.status(400).json({ error: err.message });
  }
};

//returns all users, its on get /users/
exports.getUsers = async (req, res) => {
  try {
    const { role, username } = req.query;
    const filter = {};
    if (role) filter.role = role;
    if (username) filter.username = { $regex: username, $options: "i" };

    const users = await User.find(filter);
    res.json(users);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
// only one user by id, and its on get /users/copypaste id here
exports.getUserById = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ error: "User not found" });
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

//only one user by name,get /users/username/the username here
exports.getUserByUsername = async (req, res) => {
  try {
    const user = await User.findOne({ username: req.params.username });
    if (!user) return res.status(404).json({ error: "User not found" });
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

//requires the username and pass then it hashes the password and compares it with the stored
//pass, if they match you get login succesful,on post /users/login
exports.login = async (req, res) => {
  try {
    const { username, password } = req.body;
    const user = await User.findOne({ username });
    if (!user) return res.status(404).json({ error: "User not found" });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).json({ error: "Invalid credentials" });

    res.json({ message: "Login successful", user });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

//add the values u want to change probably gonna modify this cause its not robust enough
//its on put /users/id here
exports.updateUser = async (req, res) => {
  try {
    if (req.body.password) {
      const salt = await bcrypt.genSalt(10);
      req.body.password = await bcrypt.hash(req.body.password, salt);
    }

    const user = await User.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!user) return res.status(404).json({ error: "User not found" });
    res.json(user);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

//delete a data sample , on delete /users/id here
exports.deleteUser = async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) return res.status(404).json({ error: "User not found" });
    res.json({ message: "User deleted" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Verify admin secret for role assignment
exports.verifyAdminSecret = async (req, res) => {
  try {
    const { secret } = req.body;
    const adminSecret = process.env.ADMIN_SECRET || "123456";

    if (secret === adminSecret) {
      res.json({ success: true, message: "Admin secret verified" });
    } else {
      res.status(401).json({ success: false, message: "Invalid admin secret" });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};