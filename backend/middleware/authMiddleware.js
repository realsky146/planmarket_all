const jwt = require('jsonwebtoken');
const User = require('../models/User');

// ✅ ตรวจสอบ JWT Token
const protect = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                success: false,
                message: 'ไม่มี Token กรุณาเข้าสู่ระบบ'
            });
        }

        const token = authHeader.split(' ');
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = await User.findById(decoded.id).select('-password');
        next();

    } catch (err) {
        res.status(401).json({
            success: false,
            message: 'Token ไม่ถูกต้องหรือหมดอายุ'
        });
    }
};

// ✅ เช็ค Role
const authorizeRoles = (...roles) => {
    return (req, res, next) => {
        if (!roles.includes(req.user.role)) {
            return res.status(403).json({
                success: false,
                message: 'ไม่มีสิทธิ์เข้าถึง'
            });
        }
        next();
    };
};

module.exports = { protect, authorizeRoles };