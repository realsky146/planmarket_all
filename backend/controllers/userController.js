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
