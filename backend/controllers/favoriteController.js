import db from "../db/database.js";

// GET /favorites/:userId — รายการร้านที่ถูกใจของลูกค้า
export const getFavorites = (req, res) => {
  const userId = req.params.userId;

  const sql = `
    SELECT
      f.id AS favorite_id,
      u.id AS seller_id,
      COALESCE(b.shop_name, u.name) AS shop_name,
      u.name,
      u.image_url,
      MAX(m.name) AS market_name,
      CASE WHEN COUNT(b.id) > 0 THEN 1 ELSE 0 END AS is_open
    FROM favorites f
    JOIN users u ON f.seller_id = u.id
    LEFT JOIN bookings b ON b.seller_id = f.seller_id AND b.status = 'approved'
    LEFT JOIN stalls s ON b.stall_id = s.id
    LEFT JOIN markets m ON s.market_id = m.id
    WHERE f.user_id = ?
    GROUP BY f.id
    ORDER BY f.created_at DESC
  `;

  db.all(sql, [userId], (err, rows) => {
    if (err) return res.status(500).json({ message: err.message });
    return res.json(rows);
  });
};

// POST /favorites — เพิ่มร้านที่ถูกใจ { user_id, seller_id }
export const addFavorite = (req, res) => {
  const { user_id, seller_id } = req.body;
  if (!user_id || !seller_id) {
    return res.status(400).json({ message: "Missing user_id or seller_id" });
  }

  const sql = `INSERT OR IGNORE INTO favorites (user_id, seller_id) VALUES (?, ?)`;
  db.run(sql, [user_id, seller_id], function (err) {
    if (err) return res.status(500).json({ message: err.message });
    return res.status(201).json({ message: "Added to favorites", id: this.lastID });
  });
};

// DELETE /favorites/:userId/:sellerId — ลบออกจากถูกใจ
export const removeFavorite = (req, res) => {
  const { userId, sellerId } = req.params;

  const sql = `DELETE FROM favorites WHERE user_id = ? AND seller_id = ?`;
  db.run(sql, [userId, sellerId], function (err) {
    if (err) return res.status(500).json({ message: err.message });
    return res.json({ message: "Removed from favorites", changes: this.changes });
  });
};
