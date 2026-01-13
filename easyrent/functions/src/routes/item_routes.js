const express = require("express");
const itemController = require("../controllers/item_controllers");

const router = express.Router();

// Define the endpoints
router.get("/most-rented", itemController.getMostRentedItems);
router.get("/new-arrivals", itemController.getNewItems);

// Admin route (optional, keep commented out if you want to protect it)
// router.post("/recalculate-counts", itemController.recalculateRentCounts);

module.exports = router;