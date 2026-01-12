const admin = require("../../admin");
const db = admin.firestore();

// 1. GET /most-rented
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
        ...data, // Spread original data first
        
        // --- CRITICAL FIX: Ensure ownerId exists ---
        ownerId: data.ownerId || data.userId || "", 
        title: data.title || data.name || "No Name",
        rentCount: data.rentCount || 0 
      });
    });

    return res.status(200).json(items);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: "Failed to fetch most rented items." });
  }
};

// 2. GET /new-arrivals
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
                ...data, // Spread original data first

                // --- CRITICAL FIX: Added this block to New Items too ---
                ownerId: data.ownerId || data.userId || "", 
                title: data.title || data.name || "No Name",
                // ------------------------------------------------------
            });
        });

        return res.status(200).json(items);
    } catch (error) {
        console.error(error);
        return res.status(500).json({ error: "Failed to fetch new items." });
    }
};

// 3. ADMIN: Recalculate Counts (Keeping this for your admin tools)
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

    return res.status(200).json({ message: "Rent counts updated successfully" });
  } catch (error) {
    console.error("Recalculate Error:", error);
    return res.status(500).json({ error: "Failed to recalculate." });
  }
};