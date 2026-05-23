import db from "../db/database.js";

export const getUsers = (req, res) => {
  const sql = `SELECT id, name, email, role, status FROM users ORDER BY id ASC`;
  db.all(sql, [], (err, rows) => {
    if (err) return res.status(500).json({ message: err.message });
    return res.json(rows);
  });
};

export const approveUser = (req, res) => {
  const userId = req.params.id;
  db.run(`UPDATE users SET status = 'approved' WHERE id = ?`, [userId], function (err) {
    if (err) return res.status(500).json({ message: err.message });
    if (this.changes === 0) return res.status(404).json({ message: "User not found" });
    return res.json({ message: "User approved" });
  });
};

export const rejectUser = (req, res) => {
  const userId = req.params.id;
  db.run(`UPDATE users SET status = 'rejected' WHERE id = ?`, [userId], function (err) {
    if (err) return res.status(500).json({ message: err.message });
    if (this.changes === 0) return res.status(404).json({ message: "User not found" });
    return res.json({ message: "User rejected" });
  });
};

// GET /users/sellers — ดึงรายชื่อผู้ค้าที่มี booking อนุมัติแล้ว
export const getSellers = (req, res) => {
  const sql = `
    SELECT
      u.id,
      COALESCE(b.shop_name, u.name) AS shop_name,
      u.name,
      u.image_url,
      MAX(m.name) AS market_name,
      CASE WHEN COUNT(b.id) > 0 THEN 1 ELSE 0 END AS is_open
    FROM users u
    LEFT JOIN bookings b ON b.seller_id = u.id AND b.status = 'approved'
    LEFT JOIN stalls s ON b.stall_id = s.id
    LEFT JOIN markets m ON s.market_id = m.id
    WHERE u.role = 'seller' AND u.status = 'approved'
    GROUP BY u.id
    ORDER BY is_open DESC, u.id ASC
  `;
  db.all(sql, [], (err, rows) => {
    if (err) return res.status(500).json({ message: err.message });
    return res.json(rows);
  });
};
