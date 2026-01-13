const express = require("express");
const dashboardController = require("../controllers/dashboard_controller");

const router = express.Router();

// GET /renter-stats?userId=...
router.get("/renter-stats", dashboardController.getRenterStats);

module.exports = router;