const {onCall, HttpsError} = require("firebase-functions/v2/https");
const admin = require("../admin");
const db = admin.firestore();

exports.enableRenterMode = onCall(async (request) => {
  // 1. Auth Check
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be logged in.");
  }

  const uid = request.auth.uid;

  try {
    // 2. Update Role
    await db.collection("users").doc(uid).update({
      role: "renter",
      isRenter: true,
      renterSince: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, message: "You are now a Renter!" };
  } catch (error) {
    console.error("Renter upgrade failed:", error);
    throw new HttpsError("internal", "Could not upgrade user role.");
  }
});