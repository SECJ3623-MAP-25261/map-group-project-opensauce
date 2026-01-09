import express from "express";
import {decreaseProductOrderCounts, getTopProduct, increaseProductOrderCounts} from "../controllers/product.controller.js";

const productRouter = express.Router();

productRouter.get("/top-product", getTopProduct);
productRouter.post('/increase-orderCounts',increaseProductOrderCounts)
productRouter.post('/decrease-orderCounts',decreaseProductOrderCounts)
productRouter.get("/sample-product", getTopProduct);

export default productRouter;
