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

exports.processCheckout = async (req, res) => {
  // 1. Destructure the data from the request body
  const { items, paymentMethod, selectedLocations, depositPerItem, userId } = req.body;

  // Basic Validation
  if (!items || !userId || !paymentMethod) {
    return res.status(400).json({ error: "Missing required checkout data." });
  }

  try {
    const batch = db.batch();

    // 2. Iterate through items to build the batch
    items.forEach((item) => {
      // Create a new reference for the booking
      const bookingRef = db.collection('bookings').doc();
      
      // Reference to the specific cart item to delete it
      const cartRef = db
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(item.cartDocId);

      const rentalTotal = item.totalRentalPrice;
      const grandTotal = rentalTotal + depositPerItem;
      const location = selectedLocations[item.cartDocId] || "Contact Owner";

      // 3. Add 'Set' operation for Booking
      batch.set(bookingRef, {
        bookingId: bookingRef.id,
        itemId: item.itemId,
        ownerId: item.ownerId,
        renteeId: userId,
        // Convert ISO strings back to Timestamps if they were sent as strings
        startDate: admin.firestore.Timestamp.fromDate(new Date(item.startDate)),
        endDate: admin.firestore.Timestamp.fromDate(new Date(item.endDate)),
        totalDays: item.days,
        rentalPrice: rentalTotal,
        depositAmount: depositPerItem,
        totalPrice: grandTotal,
        status: 'pending',
        pickupLocation: location,
        itemTitle: item.title,
        itemImage: item.image,
        paymentMethod: paymentMethod,
        isDepositHeldByAdmin: false,
        isDepositRefunded: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 4. Add 'Delete' operation for Cart Item
      batch.delete(cartRef);
    });

    // 5. Commit all operations together
    await batch.commit();

    return res.status(200).json({ 
      success: true, 
      message: "Checkout processed successfully and cart cleared." 
    });

  } catch (error) {
    console.error("Error in processCheckout:", error);
    return res.status(500).json({ error: "Failed to process checkout." });
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

exports.decreaseOrderCount = async (req, res) => {
  const { itemId } = req.body;
  if (!itemId) {
    return res.status(400).json({ error: "Missing itemId." });
  }
  try {
    const itemRef = db.collection("items").doc(itemId);
    await itemRef.update({
      rentCount: admin.firestore.FieldValue.increment(-1),
    });
    return res.status(200).json({ message: "Rent count decreased." });
  } catch (error) {
    console.error("Error decreasing rent count:", error);
    return res.status(500).json({ error: "Failed to decrease rent count." });
  } 
}