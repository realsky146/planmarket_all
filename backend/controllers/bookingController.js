// controllers/bookingController.js
import db from '../db/database.js';

// 1. ดึง bookings ทั้งหมด (เปลี่ยนจากดึง zone เป็นดึงชื่อตลาดแทน)
export const getAllBookings = (req, res) => {
  const query = `
        SELECT b.*, s.stall_number, m.name as market_name, u.name as seller_name, u.phone as seller_phone
        FROM bookings b
        LEFT JOIN stalls s ON b.stall_id = s.id
        LEFT JOIN markets m ON s.market_id = m.id
        LEFT JOIN users u ON b.seller_id = u.id
        ORDER BY b.created_at DESC
    `;

  db.all(query, [], (err, rows) => {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    res.json({ success: true, data: rows });
  });
};

// 2. ดึงรายละเอียด booking ชิ้นเดียวด้วย ID 
export const getBookingById = (req, res) => {
  const query = `
        SELECT b.*, s.stall_number, m.name as market_name, u.name as seller_name
        FROM bookings b
        LEFT JOIN stalls s ON b.stall_id = s.id
        LEFT JOIN markets m ON s.market_id = m.id
        LEFT JOIN users u ON b.seller_id = u.id
        WHERE b.id = ?
    `;

  db.get(query, [req.params.id], (err, row) => {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    if (!row) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }
    res.json({ success: true, data: row });
  });
};

// 3. ดึง bookings ทั้งหมดของพ่อค้า/แม่ค้า (ใช้ seller_id)
export const getUserBookings = (req, res) => {
  const { userId } = req.params;

  const query = `
        SELECT b.*, s.stall_number, m.name as market_name
        FROM bookings b
        LEFT JOIN stalls s ON b.stall_id = s.id
        LEFT JOIN markets m ON s.market_id = m.id
        WHERE b.seller_id = ?
        ORDER BY b.created_at DESC
    `;

  db.all(query, [userId], (err, rows) => {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    res.json({ success: true, data: rows });
  });
};

// 4. สร้างรายการจองแผงใหม่
export const createBooking = (req, res) => {
  const { stall_id, seller_id, shop_name, start_date, end_date, booking_type, total_price, reason } = req.body;

  if (!stall_id || !seller_id) {
    return res.status(400).json({ success: false, message: 'stall_id and seller_id are required' });
  }

  const query = `
        INSERT INTO bookings (stall_id, seller_id, shop_name, start_date, end_date, booking_type, total_price, reason, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'pending')
    `;

  db.run(query, [stall_id, seller_id, shop_name, start_date, end_date, booking_type || 'daily', total_price, reason || null], function (err) {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    res.status(201).json({
      success: true,
      message: 'Booking created',
      data: { id: this.lastID }
    });
  });
};

// 5. ✅ อัปเดตสถานะการจองแบบทั่วไป
export const updateBookingStatus = (req, res) => {
  const { id } = req.params;
  const { status, reason } = req.body;

  const query = `UPDATE bookings SET status = ?, reason = ? WHERE id = ?`;
  db.run(query, [status, reason || null, id], function (err) {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    if (this.changes === 0) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }

    if (status === 'approved') {
      db.run(`UPDATE stalls SET status = 'occupied' WHERE id = (SELECT stall_id FROM bookings WHERE id = ?)`, [id]);
    }

    res.json({ success: true, message: `Booking ${status}` });
  });
};

// 6. ✅ PATCH: กด Approve โดยตรง
export const approveBooking = (req, res) => {
  const query = `UPDATE bookings SET status = 'approved' WHERE id = ?`;

  db.run(query, [req.params.id], function (err) {
    if (err) return res.status(500).json({ success: false, message: err.message });
    if (this.changes === 0) return res.status(404).json({ success: false, message: 'Booking not found' });

    db.run(`UPDATE stalls SET status = 'occupied' WHERE id = (SELECT stall_id FROM bookings WHERE id = ?)`, [req.params.id]);
    res.json({ success: true, message: 'Booking approved' });
  });
};

// 7. ✅ PATCH: กด Reject บันทึกเหตุผล
export const rejectBooking = (req, res) => {
  const { reason } = req.body;
  const query = `UPDATE bookings SET status = 'rejected', reason = ? WHERE id = ?`;

  db.run(query, [reason || 'Rejected by admin', req.params.id], function (err) {
    if (err) return res.status(500).json({ success: false, message: err.message });
    if (this.changes === 0) return res.status(404).json({ success: false, message: 'Booking not found' });
    res.json({ success: true, message: 'Booking rejected' });
  });
};

// 8. ลบรายการจอง (DELETE)
export const deleteBooking = (req, res) => {
  db.run('DELETE FROM bookings WHERE id = ?', [req.params.id], function (err) {
    if (err) return res.status(500).json({ success: false, message: err.message });
    if (this.changes === 0) return res.status(404).json({ success: false, message: 'Booking not found' });
    res.json({ success: true, message: 'Booking deleted' });
  });
};

// 9. ดึงรายชื่อตลาดแนะนำ (แก้ตัวนับแผงว่างให้อิงจาก market_id ของ stalls โดยตรง)
export const getRecommendedMarkets = (req, res) => {
  const { excludeMarketId } = req.params;
  const { location } = req.query;

  let query = `
        SELECT m.*, 
               (SELECT COUNT(*) FROM stalls s WHERE s.market_id = m.id AND s.status = 'available') as available_stalls
        FROM markets m
        WHERE m.id != ? 
        AND m.rating >= 4.0
    `;
  const params = [excludeMarketId];

  if (location) {
    query += ` AND m.location LIKE ?`;
    params.push(`%${location}%`);
  }

  query += ` ORDER BY available_stalls DESC LIMIT 3`;

  db.all(query, params, (err, rows) => {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    res.json({ success: true, data: rows });
  });
};

// 10. ดึงรายการจองที่ถูกปฏิเสธของร้านค้า
export const getRejectedBookings = (req, res) => {
  const { userId } = req.params;

  const query = `
        SELECT b.*, s.stall_number, m.name as market_name
        FROM bookings b
        LEFT JOIN stalls s ON b.stall_id = s.id
        LEFT JOIN markets m ON s.market_id = m.id
        WHERE b.seller_id = ? AND b.status = 'rejected' AND b.notified = 0
        ORDER BY b.id DESC
    `;

  db.all(query, [userId], (err, rows) => {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    res.json({ success: true, data: rows });
  });
};

// 11. อัปเดตเครื่องหมายรับรู้การแจ้งเตือน
export const markAsNotified = (req, res) => {
  const { id } = req.params;
  const query = `UPDATE bookings SET notified = 1 WHERE id = ?`;

  db.run(query, [id], function (err) {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    res.json({ success: true, message: 'Marked as notified' });
  });
};