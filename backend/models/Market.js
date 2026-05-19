const mongoose = require('mongoose');

const marketSchema = new mongoose.Schema({
    name: { type: String, required: true },
    ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    description: { type: String },
    location: { type: String },
    image: { type: String },
    status: {
        type: String,
        enum: ['pending', 'approved', 'rejected'],
        default: 'pending',
    },
    openTime: { type: String },  // '16:00 - 22:00'
    totalStalls: { type: Number, default: 0 },
    availableStalls: { type: Number, default: 0 },
    pricePerDay: { type: Number, default: 0 },
    rating: { type: Number, default: 0 },
    isOpen: { type: Boolean, default: false },
    createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Market', marketSchema);