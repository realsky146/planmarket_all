const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    phone: { type: String },
    role: {
        type: String,
        enum: ['customer', 'vendor', 'market_owner', 'super_admin'],
        default: 'customer',
    },
    status: {
        type: String,
        enum: ['pending', 'approved', 'rejected', 'active'],
        default: 'active',
    },
    // เฉพาะ vendor
    shopName: { type: String },
    shopCategory: { type: String },
    profileImage: { type: String },
    // เฉพาะ market_owner
    marketName: { type: String },
    createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('User', userSchema);