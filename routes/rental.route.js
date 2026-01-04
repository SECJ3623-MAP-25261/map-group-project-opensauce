import express from 'express'
import { analyzeRentalData } from '../controllers/rental.controller.js'

const rentalRoute = express.Router()

rentalRoute.get('/analyze-rental-data',analyzeRentalData)

export default rentalRoute