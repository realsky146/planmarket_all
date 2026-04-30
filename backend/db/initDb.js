import db from "./database.js";

export const initDb = () => {
  db.serialize(() => {
    db.run(`
      CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      role TEXT NOT NULL CHECK(role IN ('seller', 'market')),
      status TEXT NOT NULL DEFAULT 'approved' CHECK(status IN ('pending', 'approved', 'rejected')),
      image_url TEXT
    )
    `);

    db.run(`
      CREATE TABLE IF NOT EXISTS markets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        owner_id INTEGER NOT NULL,
        image_url TEXT,
        FOREIGN KEY (owner_id) REFERENCES users(id)
      )
    `);

    db.run(`
      CREATE TABLE IF NOT EXISTS stalls (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        market_id INTEGER NOT NULL,
        stall_number TEXT NOT NULL,
        status TEXT NOT NULL CHECK(status IN ('available', 'pending', 'booked')) DEFAULT 'available',
        FOREIGN KEY (market_id) REFERENCES markets(id)
      )
    `);

    db.run(`
      CREATE TABLE IF NOT EXISTS bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stall_id INTEGER NOT NULL,
        seller_id INTEGER NOT NULL,
        shop_name TEXT NOT NULL,
        status TEXT NOT NULL CHECK(status IN ('pending', 'approved', 'rejected')) DEFAULT 'pending',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (stall_id) REFERENCES stalls(id),
        FOREIGN KEY (seller_id) REFERENCES users(id)
      )
    `);

    console.log("Tables initialized");
  });
};