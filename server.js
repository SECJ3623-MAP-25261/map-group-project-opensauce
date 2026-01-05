import admin from 'firebase-admin';
import express, { json } from 'express';
import serviceAccount from './serviceAccountKey.json' with { type: 'json' };
import cors from 'cors'
import productRouter from './routes/product.route.js';
import rentalRoute from './routes/rental.route.js';

// 1. Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://opensource-88def-default-rtdb.asia-southeast1.firebasedatabase.app"
});

export const db = admin.firestore();
const app = express();
app.use(json());
app.use(cors());

app.use((req, res, next) => {
  req.db = db;
  next();
});

// 2. Define an API Endpoint
app.use('/api/product',productRouter)
app.use('/api/rental',rentalRoute)


const PORT = 3000;
app.listen(PORT,() => console.log(`Server running on port ${PORT}`));