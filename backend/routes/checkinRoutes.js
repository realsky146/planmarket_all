const express = require('express');
const router = express.Router();
const Booking = require('../models/Booking');
const Stall = require('../models/Stall');
const Notification = require('../models/Notification');
const { protect, authorizeRoles } = require('../middleware/authMiddleware');

// ── POST /api/checkin ──────────────────────────────────
// เจ้าหน้าที่สแกน QR → เปิดร้าน
router.post('/', protect, async (req, res) => {
    try {
        const { checkinToken } = req.body;
        const booking = await Booking.findOne({ checkinToken });

        if (!booking) {
            return res.status(404).json({
                success: false,
                message: 'QR Code ไม่ถูกต้อง'
            });
        }

        // ✅ เช็คช่วงวันที่
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        if (today < booking.startDate || today > booking.endDate) {
            return res.status(400).json({
                success: false,
                message: 'ไม่อยู่ในช่วงวันที่เปิดร้าน',
            });
        }

        // ✅ อัปเดต checkedIn + isOpen
        booking.checkedIn = true;
        booking.checkedInAt = new Date();
        booking.isOpen = true;
        await booking.save();

        // ✅ อัปเดต Stall → ลูกค้าเห็น
        await Stall.updateMany(
            { marketId: booking.marketId, stallCode: { $in: booking.stallIds } },
            { isOccupied: true, occupiedBy: booking.vendorId }
        );

        // 🔔 แจ้ง vendor
        await Notification.create({
            userId: booking.vendorId,
            title: 'เช็คอินสำเร็จ! 🟢',
            body: 'ร้านของคุณเปิดแล้ว ขอให้ขายดีนะครับ',
            type: 'checkin',
        });

        res.json({
            success: true,
            message: 'เช็คอินสำเร็จ',
            data: { isOpen: true, checkedInAt: booking.checkedInAt },
        });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
});

// ── POST /api/checkout ─────────────────────────────────
// vendor กดปิดร้าน
router.post('/checkout', protect, async (req, res) => {
    try {
        const { checkinToken } = req.body;
        const booking = await Booking.findOne({ checkinToken });

        if (!booking) {
            return res.status(404).json({
                success: false,
                message: 'ไม่พบการจอง'
            });
        }

        booking.isOpen = false;
        await booking.save();

        // ✅ Stall กลับเป็นว่าง
        await Stall.updateMany(
            { marketId: booking.marketId, stallCode: { $in: booking.stallIds } },
            { isOccupied: false, occupiedBy: null }
        );

        res.json({ success: true, message: 'ปิดร้านเรียบร้อย' });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
});

module.exports = router;