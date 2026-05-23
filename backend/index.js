import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import db from "./db/database.js";
import { initDb } from "./db/initDb.js";
import authRoutes from "./routes/authRoutes.js";
import bookingRoutes from "./routes/bookingRoutes.js";
import marketRoutes from "./routes/marketRoutes.js";
import userRoutes from "./routes/userRoutes.js";
import favoriteRoutes from "./routes/favoriteRoutes.js";

dotenv.config();

const app = express();

app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PATCH", "PUT", "DELETE"],
  allowedHeaders: ["Content-Type", "Authorization"],
}));
app.use(express.json());

app.get("/", (req, res) => {
  res.json({ message: "Planmarket API is running" });
});

app.use("/auth", authRoutes);
app.use("/markets", marketRoutes);
app.use("/bookings", bookingRoutes);
app.use("/users", userRoutes);
app.use("/favorites", favoriteRoutes);

initDb();

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});