import db from "../db/database.js";

export const getMarkets = (req, res) => {
  const sql = `
    SELECT id, name, description, owner_id, image_url
    FROM markets
    ORDER BY id ASC
  `;

  db.all(sql, [], (err, rows) => {
    if (err) {
      return res.status(500).json({ message: err.message });
    }

    return res.json(rows);
  });
};

export const getMarketStalls = (req, res) => {
  const marketId = req.params.id;

  const sql = `
    SELECT
      s.id,
      s.market_id,
      s.stall_number,
      s.status,
      b.shop_name
    FROM stalls s
    LEFT JOIN bookings b
      ON s.id = b.stall_id
      AND b.status = 'approved'
    WHERE s.market_id = ?
    ORDER BY s.stall_number ASC
  `;

  db.all(sql, [marketId], (err, rows) => {
    if (err) {
      return res.status(500).json({ message: err.message });
    }

    return res.json(rows);
  });
};

export const getMarketBookings = (req, res) => {
  const ownerId = req.params.ownerId;

  const sql = `
    SELECT
      b.id,
      b.shop_name,
      b.status,
      b.created_at,
      s.stall_number,
      m.name AS market_name,
      u.name AS seller_name
    FROM bookings b
    JOIN stalls s ON b.stall_id = s.id
    JOIN markets m ON s.market_id = m.id
    JOIN users u ON b.seller_id = u.id
    WHERE m.owner_id = ?
    ORDER BY b.created_at DESC
  `;

  db.all(sql, [ownerId], (err, rows) => {
    if (err) {
      return res.status(500).json({ message: err.message });
    }

    return res.json(rows);
  });
};

export const getVendorBookings = (req, res) => {
  const sellerId = req.params.sellerId;

  const sql = `
    SELECT
      b.id,
      b.shop_name,
      b.status,
      b.created_at,
      s.stall_number,
      m.id AS market_id,
      m.name AS market_name
    FROM bookings b
    JOIN stalls s ON b.stall_id = s.id
    JOIN markets m ON s.market_id = m.id
    WHERE b.seller_id = ?
    ORDER BY b.created_at DESC
  `;

  db.all(sql, [sellerId], (err, rows) => {
    if (err) return res.status(500).json({ message: err.message });
    return res.json(rows);
  });
};