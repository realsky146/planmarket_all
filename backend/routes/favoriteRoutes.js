// routes/favoriteRoutes.js
import express from 'express';
import {
    getUserFavorites,
    addFavorite,
    removeFavorite,
    checkFavorite
} from '../controllers/favoriteController.js';

const router = express.Router();

// GET favorites ของ user
router.get('/:userId', getUserFavorites);

// เช็คว่าเป็น favorite หรือไม่
router.get('/:userId/check/:sellerId', checkFavorite);

// เพิ่ม favorite
router.post('/:userId', addFavorite);

// ลบ favorite
router.delete('/:userId/:sellerId', removeFavorite);

export default router;