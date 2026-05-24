// routes/zonesRoutes.js
import express from 'express';
import db from '../db/database.js'; // ✅ แก้พาร์ทให้ตรงกับในโฟลเดอร์ db/database.js ของคุณ

const router = express.Router();

// GET all zones
router.get('/', (req, res) => {
    const sql = `
        SELECT z.*, m.name as market_name,
            (SELECT COUNT(*) FROM stalls WHERE zone_id = z.id) as total_stalls,
            (SELECT COUNT(*) FROM stalls WHERE zone_id = z.id AND status = 'available') as available_stalls
        FROM zones z
        LEFT JOIN markets m ON z.market_id = m.id
    `;

    db.all(sql, [], (err, rows) => {
        if (err) {
            return res.status(500).json({ success: false, message: err.message });
        }
        res.json({ success: true, data: rows });
    });
});

// GET zone by ID with stalls
router.get('/:id', (req, res) => {
    const zoneSql = 'SELECT * FROM zones WHERE id = ?';
    const stallsSql = 'SELECT * FROM stalls WHERE zone_id = ?';

    db.get(zoneSql, [req.params.id], (err, zone) => {
        if (err) {
            return res.status(500).json({ success: false, message: err.message });
        }
        if (!zone) {
            return res.status(404).json({ success: false, message: 'Zone not found' });
        }

        db.all(stallsSql, [req.params.id], (err, stalls) => {
            if (err) {
                return res.status(500).json({ success: false, message: err.message });
            }
            res.json({ success: true, data: { ...zone, stalls } });
        });
    });
});

// ✅ เปลี่ยนมาใช้ตัวส่งออกระบบใหม่แทน module.exports เพื่อแก้ SyntaxError
export default router;