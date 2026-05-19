const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
    vendorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    marketId: { type: mongoose.Schema.Types.ObjectId, ref: 'Market', required: true },
    stallIds: { type: [String], required: true },
    zone: { type: String },
    stallSize: { type: String },
    startDate: { type: Date, required: true },
    endDate: { type: Date, required: true },
    totalDays: { type: Number, required: true },
    totalPrice: { type: Number, required: true },
    rentalRate: { type: Number, required: true },

    // ── สถานะการจอง ──────────────────────────────────────
    status: {
        type: String,
        enum: ['pending', 'approved', 'rejected', 'completed'],
        default: 'pending',
    },

    // ── การชำระเงิน ───────────────────────────────────────
    paymentStatus: {
        type: String,
        enum: ['unpaid', 'paid'],
        default: 'unpaid',
    },
    paidAt: { type: Date, default: null },

    // ── QR Token ──────────────────────────────────────────
    checkinToken: { type: String, default: null, unique: true, sparse: true },
    checkedIn: { type: Boolean, default: false },
    checkedInAt: { type: Date, default: null },

    // ── สถานะเปิด/ปิดร้าน ────────────────────────────────
    isOpen: { type: Boolean, default: false },

    note: { type: String, default: '' },
    createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Booking', bookingSchema);

// 19/05/69