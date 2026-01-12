const admin = require("../../admin");
const db = admin.firestore();

exports.getRenterStats = async (req, res) => {
  try {
    const userId = req.query.userId;
    if (!userId) return res.status(400).json({ error: "Missing userId" });

    const bookingsSnapshot = await db.collection("bookings")
      .where("ownerId", "==", userId)
      .get();

    let totalEarnings = 0;
    let activeCount = 0;
    let pendingCount = 0;
    let completedCount = 0;
    const earningsMap = {}; 

    bookingsSnapshot.forEach((doc) => {
      const data = doc.data();
      const status = data.status || '';

      // --- THE FIX ---
      // We grab rentalPrice (Pure Income) directly.
      // We do NOT subtract deposit here, assuming rentalPrice excludes it.
      const income = parseFloat(data.rentalPrice) || 0; 

      // --- COUNTERS ---
      if (status === 'pending') pendingCount++;
      if (status === 'ongoing' || status === 'active') activeCount++;
      if (status === 'completed') completedCount++;

      // --- SUMMING LOGIC ---
      // Include 'approved' to ensure we count upcoming confirmed money
      if (['ongoing', 'active', 'completed', 'approved'].includes(status)) {
        
        totalEarnings += income;

        if (data.startDate) {
          const dateObj = data.startDate.toDate(); 
          const dateKey = dateObj.toISOString().split('T')[0];
          earningsMap[dateKey] = (earningsMap[dateKey] || 0) + income;
        }
      }
    });

    const chartData = Object.keys(earningsMap).sort().map(dateKey => ({
      date: dateKey,
      amount: earningsMap[dateKey]
    }));

    return res.status(200).json({
      totalEarnings,
      activeCount,
      pendingCount,
      completedCount,
      chartData
    });

  } catch (error) {
    console.error("Dashboard Error:", error);
    return res.status(500).json({ error: "Calculation failed" });
  }
};