import express from "express";
import { getFavorites, addFavorite, removeFavorite } from "../controllers/favoriteController.js";

const router = express.Router();

router.get("/:userId", getFavorites);
router.post("/", addFavorite);
router.delete("/:userId/:sellerId", removeFavorite);

export default router;
