import express from "express";
import { createBooking, approveBooking, rejectBooking } from "../controllers/bookingController.js";
import { getVendorBookings } from "../controllers/marketController.js";

const router = express.Router();

router.get("/seller/:sellerId", getVendorBookings);
router.post("/", createBooking);
router.patch("/:id/approve", approveBooking);
router.patch("/:id/reject", rejectBooking);

export default router;