const jwt = require('jsonwebtoken');
const crypto = require('crypto');

// ✅ สร้าง JWT Token
const generateJWT = (userId) => {
    return jwt.sign(
        { id: userId },
        process.env.JWT_SECRET,
        { expiresIn: '7d' }
    );
};

// ✅ สร้าง QR Checkin Token แบบ unique
const generateCheckinToken = (bookingId, vendorId) => {
    return crypto
        .createHash('sha256')
        .update(`${bookingId}-${vendorId}-${Date.now()}`)
        .digest('hex')
        .toUpperCase();
};

module.exports = { generateJWT, generateCheckinToken };