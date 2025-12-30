const router = require("express").Router();
const c = require("../controllers/userController");


router.post("/", c.createUser);
    

router.post("/login", c.login);


router.get("/username/:username", c.getUserByUsername);


router.get("/", c.getUsers);
router.get("/:id", c.getUserById);
router.put("/:id", c.updateUser);
router.delete("/:id", c.deleteUser);

module.exports = router;
