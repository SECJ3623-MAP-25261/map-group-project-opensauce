const { onRequest } = require("firebase-functions/v2/https");
const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore"); 
const express = require("express");
const cors = require("cors");

// Imports
const authTriggers = require("./src/auth_triggers");
const renterApi = require("./src/renter_api");
const bookingTriggers = require("./src/triggers/booking_triggers");
const itemRoutes = require("./src/routes/item_routes");
const dashboardRoutes = require("./src/routes/dashboard_routes"); 
const notificationTriggers = require("./src/triggers/notification_triggers");

const app = express();
app.use(cors({ origin: true }));

// Routess
app.use("/items", itemRoutes);
app.use("/dashboard", dashboardRoutes); 

// --- EXPORTS ---
exports.beforeCreate = authTriggers.beforeCreate;
exports.enableRenterMode = renterApi.enableRenterMode;
exports.onBookingCreated = bookingTriggers.onBookingCreated;
exports.notifyBookingCreated = onDocumentCreated("bookings/{docId}", notificationTriggers.onBookingCreated);
exports.notifyBookingUpdated = onDocumentUpdated("bookings/{docId}", notificationTriggers.onBookingUpdated);
exports.notifyMessageCreated = onDocumentCreated("chats/{chatId}/messages/{msgId}", notificationTriggers.onMessageCreated);

exports.api = onRequest(app);