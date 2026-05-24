// controllers/userController.js
import db from './../db/database.js';

// ดึงผู้ใช้ทั้งหมด
export const getAllUsers = (req, res) => {
  const query = `SELECT * FROM users ORDER BY created_at DESC`;

  db.all(query, [], (err, rows) => {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    res.json({ success: true, data: rows });
  });
};

// ดึงผู้ใช้ตาม ID
export const getUserById = (req, res) => {
  const { id } = req.params;

  db.get(`SELECT * FROM users WHERE id = ?`, [id], (err, row) => {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    if (!row) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    res.json({ success: true, data: row });
  });
};

// ดึงผู้ขายทั้งหมด
export const getSellers = (req, res) => {
  const query = `SELECT * FROM users WHERE role = 'seller' ORDER BY created_at DESC`;

  db.all(query, [], (err, rows) => {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    res.json({ success: true, data: rows });
  });
};

// ดึงลูกค้าทั้งหมด
export const getCustomers = (req, res) => {
  const query = `SELECT * FROM users WHERE role = 'customer' ORDER BY created_at DESC`;

  db.all(query, [], (err, rows) => {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    res.json({ success: true, data: rows });
  });
};

// ✅ เพิ่ม getPendingMarkets
export const getPendingMarkets = (req, res) => {
  const query = `
        SELECT m.*, u.name as owner_name, u.email as owner_email
        FROM markets m
        LEFT JOIN users u ON m.owner_id = u.id
        WHERE m.status = 'pending'
        ORDER BY m.created_at DESC
    `;

  db.all(query, [], (err, rows) => {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    res.json({ success: true, data: rows });
  });
};

// สร้างผู้ใช้ใหม่
export const createUser = (req, res) => {
  const { name, email, password, phone, role } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({
      success: false,
      message: 'Name, email and password are required'
    });
  }

  const query = `
        INSERT INTO users (name, email, password, phone, role, status)
        VALUES (?, ?, ?, ?, ?, 'active')
    `;

  db.run(query, [name, email, password, phone || '', role || 'customer'], function (err) {
    if (err) {
      if (err.message.includes('UNIQUE constraint failed')) {
        return res.status(400).json({ success: false, message: 'Email already exists' });
      }
      return res.status(500).json({ success: false, message: err.message });
    }
    res.status(201).json({
      success: true,
      message: 'User created successfully',
      data: { id: this.lastID }
    });
  });
};

// อัพเดทผู้ใช้
export const updateUser = (req, res) => {
  const { id } = req.params;
  const { name, email, phone, role, status } = req.body;

  const query = `
        UPDATE users 
        SET name = COALESCE(?, name),
            email = COALESCE(?, email),
            phone = COALESCE(?, phone),
            role = COALESCE(?, role),
            status = COALESCE(?, status)
        WHERE id = ?
    `;

  db.run(query, [name, email, phone, role, status, id], function (err) {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    if (this.changes === 0) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    res.json({ success: true, message: 'User updated successfully' });
  });
};

// ลบผู้ใช้
export const deleteUser = (req, res) => {
  const { id } = req.params;

  db.run(`DELETE FROM users WHERE id = ?`, [id], function (err) {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    if (this.changes === 0) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    res.json({ success: true, message: 'User deleted successfully' });
  });
};
