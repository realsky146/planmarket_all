// db/initDb.js
import db from "./database.js";

export const initDb = () => {
  return new Promise((resolve, reject) => {
    db.serialize(() => {
      // 1. Users Table
      db.run(`
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          phone TEXT,
          role TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'active',
          image_url TEXT,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          updated_at DATETIME
        )
      `);

      // 2. Markets Table
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
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (owner_id) REFERENCES users(id)
        )
      `);

      // 3. Stalls Table
      db.run(`
        CREATE TABLE IF NOT EXISTS stalls (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          market_id INTEGER NOT NULL,
          stall_number TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'available',
          price REAL DEFAULT 0,
          FOREIGN KEY (market_id) REFERENCES markets(id)
        )
      `);

      // 4. Bookings Table (ปรับ Schema ให้รองรับฟีเจอร์จองรายวัน/รายเดือน และปุ่ม Approve/Reject)
      db.run(`
        CREATE TABLE IF NOT EXISTS bookings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          stall_id INTEGER NOT NULL,
          seller_id INTEGER NOT NULL,
          shop_name TEXT NOT NULL,
          start_date DATE,
          end_date DATE,
          booking_type TEXT DEFAULT 'daily',
          total_price REAL,
          status TEXT NOT NULL DEFAULT 'pending',
          reason TEXT,                  -- ✅ เก็บเหตุผลการปฏิเสธ
          notified INTEGER DEFAULT 0,   -- ✅ สถานะการแจ้งเตือน Popup
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (stall_id) REFERENCES stalls(id),
          FOREIGN KEY (seller_id) REFERENCES users(id)
        )
      `);

      // 5. Favorites Table
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
      `, (err) => {
        if (err) {
          console.error("❌ Error creating tables:", err);
          return reject(err);
        }

        console.log("✅ Database tables initialized");

        // 🔥 [SPECIAL PATCH] บังคับตรวจสอบและอัปเดตคอลัมน์กรณีที่ระบบเคยสร้างตารางเก่าค้างไว้แล้ว
        db.serialize(() => {
          db.run(`ALTER TABLE bookings ADD COLUMN reason TEXT`, () => { });
          db.run(`ALTER TABLE bookings ADD COLUMN notified INTEGER DEFAULT 0`, () => { });
          db.run(`ALTER TABLE bookings ADD COLUMN start_date DATE`, () => { });
          db.run(`ALTER TABLE bookings ADD COLUMN end_date DATE`, () => { });
          db.run(`ALTER TABLE bookings ADD COLUMN booking_type TEXT DEFAULT 'daily'`, () => { });
          db.run(`ALTER TABLE bookings ADD COLUMN total_price REAL`, () => { });

          console.log("🛠️ [Patch Check] คอลัมน์เสริมสำหรับ Bookings ถูกตรวจสอบและพร้อมใช้งานแล้ว!");
          resolve();
        });
      });
    });
  });
};