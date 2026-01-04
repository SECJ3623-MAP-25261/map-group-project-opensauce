import { db } from "../server.js";

export const getSampleProduct = async (req, res) => {
  try {
    // 1. Reference the collection
    const productCollection = db.collection('product');
    
    // 2. Get the snapshot (the raw data from Firebase)
    const snapshot = await productCollection.get();

    // 3. Check if the collection is empty
    if (snapshot.empty) {
      return res.status(404).json({ message: "No products found" });
    }

    // 4. Map the documents into a clean JavaScript array
    const products = snapshot.docs.map(doc => ({
      id: doc.id,       // The auto-generated Firestore ID
      ...doc.data()     // The actual fields (name, price, etc.)
    }));

    // 5. Send the array back to Flutter as JSON
    res.status(200).json(products);
    
  } catch (error) {
    console.error("Firestore Fetch Error:", error);
    res.status(500).json({ error: error.message });
  }
};