import {db} from '../index.js'

export const analyzeRentalData = async (req, res) => {
  try {
    // 1. Get productId from query string or body
    // In Cloud Functions, params aren't parsed like Express 'routes' 
    // unless you use a middleware. Usually passed via URL query: ?productId=123
    const { productId } = req.params;

    if (!productId) {
      res.status(400).json({ message: "Missing productId" });
      return;
    }
    
    console.log(`--- ANALYZING FOR ID: ${productId} ---`);

    // 2. Fetch Orders
    const ordersSnapshot = await db.collection('orders')
      .where('productId', '==', productId)
      .get();

    console.log(`FOUND ${ordersSnapshot.size} ORDERS`);

    let totalEarnings = 0;
    let totalOrders = 0;
    let totalDuration = 0;

    // 3. Loop & Calculate
    ordersSnapshot.forEach(doc => {
      const data = doc.data();
      
      totalOrders += 1;
      totalEarnings += (data.renteeFee || 0);
      totalDuration += (data.duration || 0);
    });

    console.log(`RESULTS: Orders=${totalOrders}, Money=${totalEarnings}`);

    // 4. Send Response
    res.status(200).json({
      totalEarnings,
      totalOrders,
      totalDuration
    });

  } catch (error) {
    console.error("Error analyzing order data:", error);
    res.status(500).json({ message: "Internal Server Error" });
  }
};