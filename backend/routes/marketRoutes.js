import express from "express";
import {
  getMarkets,
  getMarketById,
  getMarketStalls,
  getMarketBookings,
  getOwnerMarkets,
  createMarket,
  addStalls,
  getVendorBookings,
} from "../controllers/marketController.js";

const router = express.Router();

// owner routes ต้องอยู่ก่อน /:id เพื่อกัน "owner" ถูก parse เป็น id
router.get("/owner/:ownerId/bookings", getMarketBookings);
router.get("/owner/:ownerId", getOwnerMarkets);

router.get("/", getMarkets);
router.post("/", createMarket);

router.get("/:id/stalls", getMarketStalls);
router.post("/:id/stalls", addStalls);
router.get("/:id", getMarketById);

export default router;
