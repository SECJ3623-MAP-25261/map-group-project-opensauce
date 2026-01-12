const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("../../admin");
const db = admin.firestore();

exports.onBookingCreated = onDocumentCreated("bookings/{bookingId}", async (event) => {
  const booking = event.data.data();
  const bookingId = event.params.bookingId;

  if (!booking || !booking.itemId) {
    console.log(`No itemId found in booking ${bookingId}`);
    return;
  }

  try {
    const itemRef = db.collection("items").doc(booking.itemId);

    // Atomic Increment: Safe even if 100 people book at once
    await itemRef.update({
      rentCount: admin.firestore.FieldValue.increment(1)
    });

    console.log(`Incremented rentCount for item: ${booking.itemId}`);
  } catch (error) {
    console.error("Failed to update rent count:", error);
  }
});