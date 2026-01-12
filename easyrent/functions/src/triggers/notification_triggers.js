const admin = require("firebase-admin");
const db = admin.firestore();
const fcm = admin.messaging();

// Helper: Send Push & Save to Firestore
async function notifyUser(userId, title, body, type, referenceId) {
  try {
    // A. Get User's FCM Token
    const userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) return;
    const token = userDoc.data().fcmToken;

    // B. Save to Database (For the Notification Page)
    await db.collection("notifications").add({
      userId: userId,
      title: title,
      body: body,
      type: type, // 'booking' or 'chat'
      referenceId: referenceId,
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // C. Send Phone Notification
    if (token) {
      await fcm.send({
        token: token,
        notification: { title, body },
        data: { type, referenceId } // For click handling
      });
      console.log(`Notification sent to ${userId}`);
    }
  } catch (error) {
    console.error("Notification Error:", error);
  }
}

// --- TRIGGER 1: Booking Created (Notify Owner) ---
exports.onBookingCreated = async (event) => {
  const data = event.data.data();
  // Ensure we have an ownerId and itemTitle
  if (!data.ownerId) return;
  const itemName = data.itemTitle || "an item";
  
  await notifyUser(
    data.ownerId,
    "New Booking Request 🔔",
    `Someone wants to rent your ${itemName}.`,
    "booking",
    event.data.id
  );
};

// --- TRIGGER 2: Booking Status Changed (Notify Rentee) ---
exports.onBookingUpdated = async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();

  // Only run if status changed
  if (before.status === after.status) return;

  const renteeId = after.renteeId;
  const itemName = after.itemTitle || "Item";

  if (after.status === 'approved') {
    await notifyUser(
      renteeId,
      "Booking Approved! ✅",
      `Your request for ${itemName} is approved.`,
      "booking",
      event.data.after.id
    );
  } else if (after.status === 'rejected') {
    await notifyUser(
      renteeId,
      "Booking Declined ❌",
      `Your request for ${itemName} was declined.`,
      "booking",
      event.data.after.id
    );
  }
};

// --- TRIGGER 3: New Message (Notify Recipient) ---
// Watches: chats/{chatId}/messages/{msgId}
exports.onMessageCreated = async (event) => {
  const msgData = event.data.data();
  const chatId = event.params.chatId;
  const senderId = msgData.senderId;
  const text = msgData.type === 'product' ? 'Shared a product' : (msgData.text || 'Sent a message');

  // 1. Get Chat Participants
  const chatDoc = await db.collection("chats").doc(chatId).get();
  const participants = chatDoc.data().participants || [];

  // 2. Find the "Other" person
  const receiverId = participants.find(uid => uid !== senderId);

  if (receiverId) {
    await notifyUser(
      receiverId,
      "New Message 💬",
      text,
      "chat",
      chatId
    );
  }
};