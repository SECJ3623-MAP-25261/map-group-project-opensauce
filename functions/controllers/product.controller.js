import {db} from '../index.js'
export const getTopProduct = async (req, res) => {
  try {
    const snapshot = await db.collection("product")
        .orderBy("orderCounts", "desc")
        .get();

    if (snapshot.empty) {
      return res.status(404).json({message: "No products found"});
    }

    const topProducts = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.status(200).json(topProducts);
  } catch (error) {
    res.status(500).json({error: error.message});
  }
};
export const testConnection = async (req, res) => {
  try {
    res.status(200).json("----- Hi From NodeJs--------");
  } catch (error) {
    console.error("Firestore Top Product Fetch Error:", error);
    res.status(500).json({error: error.message});
  }
};
