import { FieldValue } from 'firebase-admin/firestore';
import {db} from '../index.js'

export const getTopProduct = async (req, res) => {
  try {
    const snapshot = await db.collection("product")
        .where("orderCounts", ">" ,0)
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

export const increaseProductOrderCounts = async (req, res) => {
  try {
    console.log("------ handshake from flutter increase order ------");
    
    // Cloud Functions usually receive data in req.body for POST requests
    const { productId } = req.body;

    if (!productId) {
      console.log("Missing Product Id");
      return res.status(400).json({ message: "Product ID is required" });
    }

    const productRef = db.collection('product').doc(productId);

    // Atomic increment
    await productRef.update({
      orderCounts: FieldValue.increment(1)
    });

    console.log(`Increased product ${productId} orderCounts.`);
    res.status(200).json({
      success: true, 
      message: `${productId} orderCounts successfully increased` 
    });
    
  } catch (error) {
    console.error("Firestore Update/Increase Error:", error);
    res.status(500).json({ error: error.message });
  }
};

// Cloud Function: Decrease Order Count
export const decreaseProductOrderCounts = async (req, res) => {
  try {
    const { productId } = req.body; 
    console.log(`------ handshake from flutter decrease order: ${productId} ------`);

    if (!productId) {
      return res.status(400).json({ message: "Product ID is required" });
    }

    const productRef = db.collection('product').doc(productId);

    // Atomic decrement (increment by -1)
    await productRef.update({
      orderCounts: FieldValue.increment(-1)
    });

    console.log(`Decreased product ${productId} orderCounts.`);
    res.status(200).json({
      success: true, 
      message: `${productId} orderCounts successfully decreased` 
    });
    
  } catch (error) {
    console.error("Firestore Update/Decrease Error:", error);
    res.status(500).json({ error: error.message });
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
