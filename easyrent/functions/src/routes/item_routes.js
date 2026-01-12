const express = require("express");
const itemController = require("../controllers/item_controllers");

const router = express.Router();

router.get("/most-rented", itemController.getMostRentedItems);
router.get("/new-arrivals", itemController.getNewItems);

// Admin Tool: Fix the counts
// router.post("/recalculate-counts", itemController.recalculateRentCounts);

module.exports = router;