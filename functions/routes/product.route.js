import express from "express";
import {getTopProduct} from "../controllers/product.controller.js";

const productRouter = express.Router();

productRouter.get("/top-product", getTopProduct);
productRouter.get("/sample-product", getTopProduct);

export default productRouter;
