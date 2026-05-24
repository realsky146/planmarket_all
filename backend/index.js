import express from "express";
import cors from "cors";
import path from "path";
import { fileURLToPath } from "url";
import { initDb } from "./db/initDb.js";
import { seedDatabase } from "./db/seed.js";

import authRoutes from "./routes/authRoutes.js";
import marketRoutes from "./routes/marketRoutes.js";
import bookingRoutes from "./routes/bookingRoutes.js";
import userRoutes from "./routes/userRoutes.js";
import favoriteRoutes from "./routes/favoriteRoutes.js";
import zonesRouter from './routes/zonesRoutes.js';
import uploadRoutes from './routes/upload.js'; // ⭐ เพิ่มบรรทัดนี้

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

// ⭐ เปิดให้เข้าถึงโฟลเดอร์ uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.use("/auth", authRoutes);
app.use("/markets", marketRoutes);
app.use("/bookings", bookingRoutes);
app.use("/users", userRoutes);
app.use("/favorites", favoriteRoutes);
app.use("/zones", zonesRouter);
app.use("/api", uploadRoutes); // ⭐ เพิ่มบรรทัดนี้

app.get("/", (req, res) => {
  res.json({ message: "Plan Market API is running" });
});

const startServer = async () => {
  try {
    await initDb();
    await seedDatabase();
    app.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error("❌ Failed to start server:", error);
    process.exit(1);
  }
};

startServer();