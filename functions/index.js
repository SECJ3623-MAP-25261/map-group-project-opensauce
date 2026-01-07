import admin from "firebase-admin";
import express, {json} from "express";
import cors from "cors";
import {onRequest} from "firebase-functions/v2/https";
import productRouter from "./routes/product.route.js";
import rentalRoute from "./routes/rental.route.js";
import { getFirestore } from "firebase-admin/firestore";

//* firebase emulators:start

// 1. Initialize Firebase Admin first
// This returns the Firebase App instance
const firebaseApp = admin.initializeApp(); 

// 2. Initialize Firestore using the Firebase App
export const db = getFirestore(firebaseApp);

// 3. Initialize Express
const app = express();

app.use(json());
app.use(cors({origin: true})); 

// 4. Routes
app.use("/product", productRouter); 
app.use("/rental", rentalRoute);

// 5. Export the Cloud Function
export const api = onRequest(app);