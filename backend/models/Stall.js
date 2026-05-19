const mongoose = require('mongoose');

const stallSchema = new mongoose.Schema({
    marketId: { type: mongoose.Schema.Types.ObjectId, ref: 'Market', required: true },
    stallCode: { type: String, required: true },  // 'A3', 'B5'
    zone: { type: String },
    size: { type: String },
    // ✅ สถานะที่ลูกค้าเห็น
    isOccupied: { type: Boolean, default: false },
    occupiedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
});

module.exports = mongoose.model('Stall', stallSchema);