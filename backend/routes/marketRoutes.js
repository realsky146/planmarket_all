import express from "express";
import { getMarkets, getMarketStalls, getMarketBookings, getVendorBookings } from "../controllers/marketController.js";

const router = express.Router();

router.get("/owner/:ownerId/bookings", getMarketBookings);
router.get("/", getMarkets);
router.get("/:id/stalls", getMarketStalls);

export default router;