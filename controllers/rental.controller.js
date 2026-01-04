import admin from 'firebase-admin';

export const analyzeRentalData = async (req, res) => {
    try {
        // --- THE TRICK ---
        // We get the DB instance right now, inside the function.
        // This prevents the "Circular Dependency" crash because we aren't importing from server.js
        const db = admin.firestore(); 
        // -----------------

        const { productId } = req.params;

        // Run your query as normal
        const rentalsSnapshot = await db.collection('rentals')
            .where('productId', '==', productId)
            .get();

        let totalEarnings = 0;
        let totalOrders = 0;
        let totalDuration = 0;

        if (rentalsSnapshot.empty) {
             return res.status(200).json({ totalEarnings: 0, totalOrders: 0, totalDuration: 0 });
        }

        rentalsSnapshot.forEach(doc => {
            const data = doc.data();
            totalOrders += 1;
            totalEarnings += (data.totalPrice || 0);
            totalDuration += (data.rentingDuration || 0);
        });

        res.status(200).json({
            totalEarnings,
            totalOrders,
            totalDuration
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Error", error: error.message });
    }
};