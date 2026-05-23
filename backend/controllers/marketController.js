import db from "../db/database.js";

export const getMarkets = (req, res) => {
  const sql = `
    SELECT m.id, m.name, m.description, m.owner_id, m.image_url,
           m.location, m.open_time, m.close_time, m.rating,
           COUNT(s.id) AS total_stalls,
           SUM(CASE WHEN s.status = 'available' THEN 1 ELSE 0 END) AS available_stalls
    FROM markets m
    LEFT JOIN stalls s ON s.market_id = m.id
    GROUP BY m.id
    ORDER BY m.id ASC
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

export const createMarket = (req, res) => {
  const { name, description, owner_id, image_url, location, open_time, close_time, rating } = req.body;
  if (!name || !owner_id) {
    return res.status(400).json({ message: "Missing required fields" });
  }
  const sql = `INSERT INTO markets (name, description, owner_id, image_url, location, open_time, close_time, rating)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?)`;
  db.run(sql, [
    name, description || null, owner_id, image_url || null,
    location || '', open_time || '08:00', close_time || '20:00', rating || 4.0
  ], function (err) {
    if (err) return res.status(500).json({ message: err.message });
    return res.status(201).json({ message: "Market created", marketId: this.lastID });
  });
};

export const getMarketById = (req, res) => {
  const marketId = req.params.id;
  const sql = `SELECT id, name, description, owner_id, image_url FROM markets WHERE id = ?`;
  db.get(sql, [marketId], (err, row) => {
    if (err) return res.status(500).json({ message: err.message });
    if (!row) return res.status(404).json({ message: "Market not found" });
    return res.json(row);
  });
};

export const getOwnerMarkets = (req, res) => {
  const ownerId = req.params.ownerId;
  const sql = `
    SELECT m.id, m.name, m.description, m.owner_id, m.image_url,
           COUNT(s.id) AS total_stalls,
           SUM(CASE WHEN s.status = 'available' THEN 1 ELSE 0 END) AS available_stalls
    FROM markets m
    LEFT JOIN stalls s ON s.market_id = m.id
    WHERE m.owner_id = ?
    GROUP BY m.id
    ORDER BY m.id ASC
  `;
  db.all(sql, [ownerId], (err, rows) => {
    if (err) return res.status(500).json({ message: err.message });
    return res.json(rows);
  });
};

export const addStalls = (req, res) => {
  const marketId = req.params.id;
  const { stalls } = req.body;

  if (!stalls || !Array.isArray(stalls) || stalls.length === 0) {
    return res.status(400).json({ message: "stalls must be a non-empty array of stall numbers" });
  }

  const sql = `INSERT INTO stalls (market_id, stall_number, status) VALUES (?, ?, 'available')`;
  let completed = 0;
  const errors = [];

  stalls.forEach((stallNumber) => {
    db.run(sql, [marketId, stallNumber], function (err) {
      if (err) errors.push({ stallNumber, error: err.message });
      completed++;
      if (completed === stalls.length) {
        if (errors.length > 0) {
          return res.status(207).json({ message: "Some stalls failed", errors });
        }
        return res.status(201).json({ message: "Stalls added", count: stalls.length });
      }
    });
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