// controllers/favoriteController.js
import db from '../db/database.js';

// ดึง favorites ของ user
export const getUserFavorites = (req, res) => {
  const { userId } = req.params;
  const query = `
    SELECT f.id, f.user_id, f.seller_id, f.created_at,
           u.name as shop_name, u.image_url, u.email, u.status
    FROM favorites f
    LEFT JOIN users u ON f.seller_id = u.id
    WHERE f.user_id = ?
    ORDER BY f.created_at DESC
  `;
  db.all(query, [userId], (err, rows) => {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    res.json({ success: true, data: rows });
  });
};

// เพิ่ม favorite
export const addFavorite = (req, res) => {
  const { userId } = req.params;
  const { seller_id } = req.body;
  if (!seller_id) {
    return res.status(400).json({ success: false, message: 'seller_id is required' });
  }
  const query = `INSERT INTO favorites (user_id, seller_id) VALUES (?, ?)`;
  db.run(query, [userId, seller_id], function (err) {
    if (err) {
      if (err.message.includes('UNIQUE constraint failed')) {
        return res.status(400).json({ success: false, message: 'Already in favorites' });
      }
      return res.status(500).json({ success: false, message: err.message });
    }
    res.status(201).json({
      success: true,
      message: 'Added to favorites',
      data: { id: this.lastID }
    });
  });
};

// ลบ favorite
export const removeFavorite = (req, res) => {
  const { userId, sellerId } = req.params;
  const query = `DELETE FROM favorites WHERE user_id = ? AND seller_id = ?`;
  db.run(query, [userId, sellerId], function (err) {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    if (this.changes === 0) {
      return res.status(404).json({ success: false, message: 'Favorite not found' });
    }
    res.json({ success: true, message: 'Removed from favorites' });
  });
};

// เช็คว่าเป็น favorite หรือไม่
export const checkFavorite = (req, res) => {
  const { userId, sellerId } = req.params;
  const query = `SELECT * FROM favorites WHERE user_id = ? AND seller_id = ?`;
  db.get(query, [userId, sellerId], (err, row) => {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    res.json({ success: true, isFavorite: !!row });
  });
};