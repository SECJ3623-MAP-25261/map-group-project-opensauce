export const analyzeRentalData = async (req, res) => {
  try {
    const { productId } = req.params;

    const db = req.db;
    
    console.log(`--- ANALYZING FOR ID: ${productId} ---`); // spy 1

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

      totalOrders += 1;

      totalEarnings += (data.renteeFee || 0);

      totalDuration += (data.duration || 0);
    });

    console.log(`RESULTS: Orders=${totalOrders}, Money=${totalEarnings}`); // spy 4

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