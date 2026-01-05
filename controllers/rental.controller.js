export const analyzeRentalData = async (req, res) => {
  try {
    const { productId } = req.params;

    const db = req.db;
    
    console.log(`--- ANALYZING FOR ID: ${productId} ---`); // spy 1

    // 1. CHANGE COLLECTION: Look inside 'orders' instead of 'rentals'
    const ordersSnapshot = await db.collection('orders')
      .where('productId', '==', productId)
      .get();

    console.log(`FOUND ${ordersSnapshot.size} ORDERS`); // spy 2

    let totalEarnings = 0;
    let totalOrders = 0;
    let totalDuration = 0;

    // 2. LOOP & CALCULATE
    ordersSnapshot.forEach(doc => {
      const data = doc.data();
      console.log("Reading Doc:", data); // spy 3: See exactly what is inside

      // Logic: Count the number of times this product appears
      totalOrders += 1;

      // Logic: Sum the 'renteeFee' for earnings
      // (We use || 0 to be safe in case the field is missing)
      totalEarnings += (data.renteeFee || 0);

      // Logic: Sum the 'duration' for total duration
      totalDuration += (data.duration || 0);
    });

    console.log(`RESULTS: Orders=${totalOrders}, Money=${totalEarnings}`); // spy 4

    // 3. SEND RESPONSE (Structure stays the same!)
    res.status(200).json({
      totalEarnings,
      totalOrders,
      totalDuration
    });

  } catch (error) {
    console.error("Error analyzing order data:", error);
    res.status(500).json({ message: "Failed to analyze data" });
  }
};