const admin = require("../../admin");
const db = admin.firestore();

// 1. GET /most-rented
// Fetches items with the highest rentCount
exports.getMostRentedItems = async (req, res) => {
  try {
    const snapshot = await db.collection("items")
      .orderBy("rentCount", "desc")
      .limit(10)
      .get();

    const items = [];
    snapshot.forEach((doc) => {
      const data = doc.data();
      items.push({
        id: doc.id,
        ...data,
        
        // Safety Checks for Booking Logic
        ownerId: data.ownerId || data.userId || "", 
        title: data.title || data.name || "No Name",
        rentCount: data.rentCount || 0,
        category: data.category || "Others" // Preserving category as requested
      });
    });

    return res.status(200).json(items);
  } catch (error) {
    console.error("Error fetching most rented:", error);
    return res.status(500).json({ error: "Failed to fetch most rented items." });
  }
};

// 2. GET /new-arrivals
// Fetches the most recently created items
exports.getNewItems = async (req, res) => {
    try {
        const snapshot = await db.collection("items")
            .orderBy("createdAt", "desc")
            .limit(10)
            .get();

        const items = [];
        snapshot.forEach((doc) => {
            const data = doc.data();
            items.push({ 
                id: doc.id, 
                ...data, // <--- CRITICAL: Spreads ALL fields
                
                // Safety Checks
                ownerId: data.ownerId || data.userId || "", 
                title: data.title || data.name || "No Name",
                category: data.category || "Others"
            });
        });

        return res.status(200).json(items);
    } catch (error) {
        console.error("Error fetching new items:", error);
        return res.status(500).json({ error: "Failed to fetch new items." });
    }
};

exports.declineOrder = async (req, res) => {
  // Expecting bookingId and itemId from the request body
  const { bookingId, itemId } = req.body;

  if (!bookingId || !itemId) {
    return res.status(400).json({ error: "Missing bookingId or itemId." });
  }

  try {
    await db.runTransaction(async (transaction) => {
      const bookingRef = db.collection("bookings").doc(bookingId);
      const itemRef = db.collection("items").doc(itemId);

      // 1. Update Booking Status
      transaction.update(bookingRef, {
        status: "declined",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 2. Decrement rentCount on the Item
      transaction.update(itemRef, {
        rentCount: admin.firestore.FieldValue.increment(-1),
      });
    });

    return res.status(200).json({ message: "Order declined and rent count updated." });
  } catch (error) {
    console.error("Error declining order:", error);
    return res.status(500).json({ error: "Failed to decline order." });
  }
};

// 3. ADMIN: Recalculate Counts
// (Run this manually via Postman if rent counts seem wrong)
exports.recalculateRentCounts = async (req, res) => {
  try {
    // A. Reset all items to 0
    const itemsSnapshot = await db.collection("items").get();
    const batch = db.batch(); 
    
    itemsSnapshot.docs.forEach(doc => {
      batch.update(doc.ref, { rentCount: 0 });
    });
    await batch.commit();

    // B. Count all bookings
    const bookingsSnapshot = await db.collection("bookings").get();
    const counts = {};

    bookingsSnapshot.forEach(doc => {
      const itemId = doc.data().itemId;
      if (itemId) {
        counts[itemId] = (counts[itemId] || 0) + 1;
      }
    });

    // C. Update items with real counts
    const updateBatch = db.batch();
    for (const [itemId, count] of Object.entries(counts)) {
      const itemRef = db.collection("items").doc(itemId);
      updateBatch.update(itemRef, { rentCount: count });
    }
    await updateBatch.commit();

    return res.status(200).json({ message: "Rent counts recalculated successfully" });
  } catch (error) {
    console.error("Recalculate Error:", error);
    return res.status(500).json({ error: "Failed to recalculate." });
  }
};