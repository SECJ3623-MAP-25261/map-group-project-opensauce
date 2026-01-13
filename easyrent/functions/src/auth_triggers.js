const {beforeUserCreated} = require("firebase-functions/v2/identity");
const admin = require("../admin"); 
const db = admin.firestore();

exports.beforeCreate = beforeUserCreated(async (event) => {
  const user = event.data;

  try {
    // Basic profile creation
    await db.collection("users").doc(user.uid).set({
      uid: user.uid,
      email: user.email || "",
      displayName: user.displayName || "New User",
      role: "rentee", // Default role
      joinedDate: admin.firestore.FieldValue.serverTimestamp(),
      fcmToken: "",
      phoneNumber: user.phoneNumber || "",
    });
    console.log(`User profile created for: ${user.uid}`);
  } catch (error) {
    console.error("Error creating user profile:", error);
  }
});