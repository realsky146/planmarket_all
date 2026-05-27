// routes/marketFavoriteRoutes.js
import express from "express";
import db from "../db/database.js";

const router = express.Router();

// ─────────────────────────────────────────────────────
// GET /market-favorites?userId=1
// ดึงรายการตลาดที่ vendor ถูกใจ
// ─────────────────────────────────────────────────────
router.get("/", (req, res) => {
    const { userId } = req.query;

    if (!userId) {
        return res.status(400).json({ error: "userId is required" });
    }

    const sql = `
    SELECT
      mf.market_id,
      m.name,
      m.image_url,
      m.location
    FROM market_favorites mf
    JOIN markets m ON m.id = mf.market_id
    WHERE mf.user_id = ?
    ORDER BY mf.created_at DESC
  `;

    db.all(sql, [userId], (err, rows) => {
        if (err) {
            console.error("❌ GET market-favorites error:", err.message);
            return res.status(500).json({ error: err.message });
        }
        console.log(
            `✅ GET market-favorites: userId=${userId}, found=${rows.length}`
        );
        res.json(rows);
    });
});

// ─────────────────────────────────────────────────────
// POST /market-favorites
// เพิ่มตลาดในรายการถูกใจ
// Body: { userId: 1, marketId: 2 }
// ─────────────────────────────────────────────────────
router.post("/", (req, res) => {
    const { userId, marketId } = req.body;

    if (!userId || !marketId) {
        return res
            .status(400)
            .json({ error: "userId and marketId are required" });
    }

    const sql = `
    INSERT OR IGNORE INTO market_favorites (user_id, market_id)
    VALUES (?, ?)
  `;

    db.run(sql, [userId, marketId], function (err) {
        if (err) {
            console.error("❌ POST market-favorites error:", err.message);
            return res.status(500).json({ error: err.message });
        }

        // this.changes === 0 หมายความว่ามีอยู่แล้ว (IGNORE)
        if (this.changes === 0) {
            console.log(
                `ℹ️ market-favorites already exists: userId=${userId}, marketId=${marketId}`
            );
            return res
                .status(200)
                .json({ success: true, message: "มีในรายการอยู่แล้ว" });
        }

        console.log(
            `✅ POST market-favorites: userId=${userId}, marketId=${marketId}`
        );
        res.status(201).json({ success: true, message: "เพิ่มตลาดถูกใจแล้ว" });
    });
});

// ─────────────────────────────────────────────────────
// DELETE /market-favorites/:marketId?userId=1
// ลบตลาดออกจากรายการถูกใจ
// ─────────────────────────────────────────────────────
router.delete("/:marketId", (req, res) => {
    const { userId } = req.query;
    const { marketId } = req.params;

    if (!userId) {
        return res.status(400).json({ error: "userId is required" });
    }

    const sql = `
    DELETE FROM market_favorites
    WHERE user_id = ? AND market_id = ?
  `;

    db.run(sql, [userId, marketId], function (err) {
        if (err) {
            console.error("❌ DELETE market-favorites error:", err.message);
            return res.status(500).json({ error: err.message });
        }

        if (this.changes === 0) {
            return res.status(404).json({ error: "ไม่พบรายการนี้" });
        }

        console.log(
            `✅ DELETE market-favorites: userId=${userId}, marketId=${marketId}`
        );
        res.json({ success: true, message: "นำตลาดออกจากถูกใจแล้ว" });
    });
});

export default router;