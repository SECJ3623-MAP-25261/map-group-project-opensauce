import express from 'express'
import { getSampleProduct } from '../controllers/product.controller.js'

const productRouter = express.Router()

productRouter.get('/sample-product',getSampleProduct)

export default productRouter