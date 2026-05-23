import db from "./database.js";

export const initDb = () => {
  db.serialize(() => {
    db.run(`
      CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      role TEXT NOT NULL CHECK(role IN ('seller', 'market', 'customer')),
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
        location TEXT DEFAULT '',
        open_time TEXT DEFAULT '08:00',
        close_time TEXT DEFAULT '20:00',
        rating REAL DEFAULT 4.0,
        FOREIGN KEY (owner_id) REFERENCES users(id)
      )
    `);

    // Migrate: add columns if they don't exist yet (safe to run multiple times)
    const silentRun = (sql) => db.run(sql, () => {});
    silentRun(`ALTER TABLE markets ADD COLUMN location TEXT DEFAULT ''`);
    silentRun(`ALTER TABLE markets ADD COLUMN open_time TEXT DEFAULT '08:00'`);
    silentRun(`ALTER TABLE markets ADD COLUMN close_time TEXT DEFAULT '20:00'`);
    silentRun(`ALTER TABLE markets ADD COLUMN rating REAL DEFAULT 4.0`);

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

    db.run(`
      CREATE TABLE IF NOT EXISTS favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        seller_id INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id, seller_id),
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (seller_id) REFERENCES users(id)
      )
    `);

    console.log("Tables initialized");
  });
};