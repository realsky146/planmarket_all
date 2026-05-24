// routes/upload.js
import express from 'express';
import multer from 'multer';
import path from 'path';
import { fileURLToPath } from 'url';
import Database from 'better-sqlite3';

const router = express.Router();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const db = new Database('./planmarket.db');

// ⭐ เพิ่ม BASE_URL
const BASE_URL = 'http://localhost:3001';

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/images/');
    },
    filename: (req, file, cb) => {
        const uniqueName = Date.now() + '-' + Math.round(Math.random() * 1E9) + path.extname(file.originalname);
        cb(null, uniqueName);
    }
});

const fileFilter = (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif|webp/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    if (extname && mimetype) {
        cb(null, true);
    } else {
        cb(new Error('รองรับเฉพาะไฟล์รูปภาพเท่านั้น!'), false);
    }
};

const upload = multer({
    storage: storage,
    limits: { fileSize: 5 * 1024 * 1024 },
    fileFilter: fileFilter
});

// API อัพโหลดรูป Vendor
router.post('/upload-vendor-image/:userId', upload.single('image'), (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ success: false, error: 'ไม่พบไฟล์รูปภาพ' });
        }

        // ⭐ เปลี่ยนเป็น Full URL
        const imageUrl = `${BASE_URL}/uploads/images/${req.file.filename}`;
        const userId = req.params.userId;

        const stmt = db.prepare('UPDATE users SET image_url = ? WHERE id = ? AND role = ?');
        const result = stmt.run(imageUrl, userId, 'seller');

        if (result.changes === 0) {
            return res.status(404).json({ success: false, error: 'ไม่พบ Seller ID นี้' });
        }

        res.json({
            success: true,
            imageUrl: imageUrl,
            message: 'อัพโหลดรูปภาพสำเร็จ'
        });
    } catch (error) {
        console.error('เกิดข้อผิดพลาด:', error);
        res.status(500).json({ success: false, error: 'อัพโหลดไม่สำเร็จ' });
    }
});

// API อัพโหลดรูปตลาด
router.post('/upload-market-image/:userId', upload.single('image'), (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ success: false, error: 'ไม่พบไฟล์รูปภาพ' });
        }

        // ⭐ เปลี่ยนเป็น Full URL
        const imageUrl = `${BASE_URL}/uploads/images/${req.file.filename}`;
        const userId = req.params.userId;

        const stmt = db.prepare('UPDATE users SET image_url = ? WHERE id = ? AND role = ?');
        const result = stmt.run(imageUrl, userId, 'market');

        if (result.changes === 0) {
            return res.status(404).json({ success: false, error: 'ไม่พบ Market ID นี้' });
        }

        res.json({
            success: true,
            imageUrl: imageUrl,
            message: 'อัพโหลดรูปตลาดสำเร็จ'
        });
    } catch (error) {
        console.error('เกิดข้อผิดพลาด:', error);
        res.status(500).json({ success: false, error: 'อัพโหลดไม่สำเร็จ' });
    }
});

export default router;