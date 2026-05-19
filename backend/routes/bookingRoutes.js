// index.js
import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import mongoose from "mongoose";
import db from "./db/database.js";
import { initDb } from "./db/initDb.js";
import authRoutes from "./routes/authRoutes.js";
import bookingRoutes from "./routes/bookingRoutes.js";
import marketRoutes from "./routes/marketRoutes.js";
import checkinRoutes from "./routes/checkinRoutes.js";
import notificationRoutes from "./routes/notificationRoutes.js";

dotenv.config();

const app = express();

// ── Middleware ─────────────────────────────────────────
app.use(cors({
    origin: "*",
    methods: ["GET", "POST", "PATCH", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"],
}));
app.use(express.json());

// ── Connect MongoDB ────────────────────────────────────
mongoose.connect(process.env.MONGO_URI)
    .then(() => console.log("✅ MongoDB Connected"))
    .catch((err) => console.error("❌ MongoDB Error:", err));

// ── Health Check ───────────────────────────────────────
app.get("/", (req, res) => {
    res.json({ message: "Planmarket API is running" });
});

// ── Routes ─────────────────────────────────────────────
app.use("/auth", authRoutes);
app.use("/markets", marketRoutes);
app.use("/bookings", bookingRoutes);
app.use("/checkin", checkinRoutes);       // ✅ เพิ่มใหม่
app.use("/notifications", notificationRoutes);  // ✅ เพิ่มใหม่

// ── Init SQLite DB (ถ้ายังใช้อยู่) ────────────────────
initDb();

// ── Start Server ───────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
});