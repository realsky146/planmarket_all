// routes/bookings.js

const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const Booking = require('../models/Booking');
const { sendNotification } = require('../utils/notification');

// ── POST /api/bookings/:id/approve ─────────────────────
// เจ้าของตลาดกด "อนุมัติ"
router.post('/:id/approve', async (req, res) => {
    try {
        const booking = await Booking.findByIdAndUpdate(
            req.params.id,
            { status: 'approved' },
            { new: true }
        );

        if (!booking) {
            return res.status(404).json({
                success: false,
                message: 'ไม่พบการจอง'
            });
        }

        // 🔔 แจ้ง vendor ให้ชำระเงิน
        await sendNotification(booking.vendorId, {
            title: 'การจองได้รับการอนุมัติ ✅',
            body: 'กรุณาชำระเงินภายใน 24 ชั่วโมงเพื่อยืนยันการจอง',
            type: 'approved',
        });

        res.json({ success: true, data: booking });

    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
});