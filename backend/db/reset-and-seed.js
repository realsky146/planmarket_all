import sqlite3 from "sqlite3";
import bcrypt from "bcryptjs";

const db = new sqlite3.Database("./planmarket.db");
const hashPassword = (password) => bcrypt.hashSync(password, 10);

console.log("🗑️  Dropping all tables...");

db.serialize(() => {
    db.run("DROP TABLE IF EXISTS favorites");
    db.run("DROP TABLE IF EXISTS bookings");
    db.run("DROP TABLE IF EXISTS stalls");
    db.run("DROP TABLE IF EXISTS markets");
    db.run("DROP TABLE IF EXISTS users");

    console.log("✅ Tables dropped");

    db.run(`
    CREATE TABLE users (
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

    db.run(`
    CREATE TABLE markets (
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

    db.run(`
    CREATE TABLE stalls (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      market_id INTEGER NOT NULL,
      stall_number TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'available',
      price REAL DEFAULT 0,
      FOREIGN KEY (market_id) REFERENCES markets(id)
    )
  `);

    db.run(`
    CREATE TABLE bookings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      stall_id INTEGER NOT NULL,
      seller_id INTEGER NOT NULL,
      shop_name TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'pending',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (stall_id) REFERENCES stalls(id),
      FOREIGN KEY (seller_id) REFERENCES users(id)
    )
  `);

    db.run(`
    CREATE TABLE favorites (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      seller_id INTEGER NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(user_id, seller_id),
      FOREIGN KEY (user_id) REFERENCES users(id),
      FOREIGN KEY (seller_id) REFERENCES users(id)
    )
  `);

    console.log("✅ Tables created");

    // INSERT USERS
    const userStmt = db.prepare(`INSERT INTO users (id, name, email, password, phone, role, status) VALUES (?, ?, ?, ?, ?, ?, ?)`);

    userStmt.run(1, "Super Admin", "admin@planmarket.com", hashPassword("admin1234"), "000-000-0000", "super_admin", "active");
    userStmt.run(10, "นายสมชาย ใจดี", "customer1@test.com", hashPassword("123456"), "081-111-1111", "customer", "active");
    userStmt.run(11, "นางสาวมาลี รักช้อป", "customer2@test.com", hashPassword("123456"), "081-222-2222", "customer", "active");
    userStmt.run(12, "นายประยุทธ์ นักกิน", "customer3@test.com", hashPassword("123456"), "081-333-3333", "customer", "active");
    userStmt.run(20, "ร้านส้มตำแม่นิด", "vendor1@test.com", hashPassword("123456"), "082-111-1111", "seller", "approved");
    userStmt.run(21, "ร้านก๋วยเตี๋ยวลุงเชาว์", "vendor2@test.com", hashPassword("123456"), "082-222-2222", "seller", "approved");
    userStmt.run(22, "ร้านเสื้อผ้าแฟชั่น", "vendor3@test.com", hashPassword("123456"), "082-333-3333", "seller", "approved");
    userStmt.run(23, "ร้านของเล่นเด็ก", "vendor4@test.com", hashPassword("123456"), "082-444-4444", "seller", "approved");
    userStmt.run(24, "ร้านขนมหวาน", "vendor5@test.com", hashPassword("123456"), "082-555-5555", "seller", "approved");
    userStmt.run(30, "นายมานะ ตลาดดี", "market1@test.com", hashPassword("123456"), "083-111-1111", "market", "approved");
    userStmt.run(31, "นางสมศรี ตลาดนัด", "market2@test.com", hashPassword("123456"), "083-222-2222", "market", "approved");
    userStmt.run(32, "นายใหม่ ตลาดใหม่", "market3@test.com", hashPassword("123456"), "083-333-3333", "market", "pending");
    userStmt.finalize();
    console.log("✅ Users inserted");

    // INSERT MARKETS
    const marketStmt = db.prepare(`INSERT INTO markets (id, name, description, owner_id, location, open_time, close_time, rating) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`);
    marketStmt.run(1, "ตลาดนัดจตุจักร", "ตลาดนัดสุดสัปดาห์ที่ใหญ่ที่สุด", 30, "จตุจักร, กรุงเทพฯ", "09:00", "18:00", 4.8);
    marketStmt.run(2, "ตลาดนัดรถไฟรัชดา", "ตลาดกลางคืนชื่อดัง", 30, "รัชดาภิเษก, กรุงเทพฯ", "17:00", "01:00", 4.5);
    marketStmt.run(3, "ตลาดนัดหลังมอ", "ตลาดนัดราคาถูก", 31, "รามคำแหง, กรุงเทพฯ", "16:00", "22:00", 4.2);
    marketStmt.run(4, "ตลาดนัดใหม่เอี่ยม", "ตลาดเปิดใหม่ รอการอนุมัติ", 32, "ลาดพร้าว, กรุงเทพฯ", "10:00", "20:00", 0);
    marketStmt.finalize();
    console.log("✅ Markets inserted");

    // INSERT STALLS
    const stallStmt = db.prepare(`INSERT INTO stalls (id, market_id, stall_number, status) VALUES (?, ?, ?, ?)`);
    for (let i = 0; i < 20; i++) {
        const status = i < 5 ? "booked" : i < 8 ? "pending" : "available";
        stallStmt.run(100 + i, 1, `A${String(i + 1).padStart(2, "0")}`, status);
    }
    for (let i = 0; i < 15; i++) {
        const status = i < 3 ? "booked" : i < 5 ? "pending" : "available";
        stallStmt.run(200 + i, 2, `B${String(i + 1).padStart(2, "0")}`, status);
    }
    for (let i = 0; i < 12; i++) {
        const status = i < 2 ? "booked" : i < 4 ? "pending" : "available";
        stallStmt.run(300 + i, 3, `C${String(i + 1).padStart(2, "0")}`, status);
    }
    for (let i = 0; i < 10; i++) {
        stallStmt.run(400 + i, 4, `D${String(i + 1).padStart(2, "0")}`, "available");
    }
    stallStmt.finalize();
    console.log("✅ Stalls inserted");

    // INSERT BOOKINGS
    const bookingStmt = db.prepare(`INSERT INTO bookings (id, stall_id, seller_id, shop_name, status) VALUES (?, ?, ?, ?, ?)`);
    bookingStmt.run(1, 100, 20, "ส้มตำแม่นิด สาขาจตุจักร", "approved");
    bookingStmt.run(2, 203, 20, "ส้มตำแม่นิด สาขารัชดา", "pending");
    bookingStmt.run(3, 101, 21, "ก๋วยเตี๋ยวลุงเชาว์", "approved");
    bookingStmt.run(4, 304, 21, "ก๋วยเตี๋ยวลุงเชาว์ สาขา 2", "rejected");
    bookingStmt.run(5, 102, 22, "Fashion Hub", "approved");
    bookingStmt.run(6, 200, 22, "Fashion Hub Night", "approved");
    bookingStmt.run(7, 103, 23, "Toy Kingdom", "approved");
    bookingStmt.run(8, 302, 23, "Toy Kingdom Express", "pending");
    bookingStmt.run(9, 210, 23, "Toy Kingdom Plus", "rejected");
    bookingStmt.run(10, 201, 24, "Sweet Dreams", "approved");
    bookingStmt.run(11, 300, 24, "Sweet Dreams Mini", "approved");
    bookingStmt.run(12, 105, 24, "Sweet Dreams Premium", "pending");
    bookingStmt.finalize();
    console.log("✅ Bookings inserted");

    // INSERT FAVORITES
    const favoriteStmt = db.prepare(`INSERT INTO favorites (user_id, seller_id) VALUES (?, ?)`);
    favoriteStmt.run(10, 20);
    favoriteStmt.run(10, 21);
    favoriteStmt.run(10, 24);
    favoriteStmt.run(11, 22);
    favoriteStmt.run(11, 24);
    favoriteStmt.run(12, 20);
    favoriteStmt.run(12, 23);
    favoriteStmt.run(12, 24);
    favoriteStmt.finalize();
    console.log("✅ Favorites inserted");

    // VERIFY
    setTimeout(() => {
        db.get("SELECT COUNT(*) as count FROM users", (err, row) => {
            console.log(`📊 Users: ${row.count}`);
        });
        db.get("SELECT COUNT(*) as count FROM markets", (err, row) => {
            console.log(`📊 Markets: ${row.count}`);
        });
        db.get("SELECT COUNT(*) as count FROM stalls", (err, row) => {
            console.log(`📊 Stalls: ${row.count}`);
        });
        db.get("SELECT COUNT(*) as count FROM bookings", (err, row) => {
            console.log(`📊 Bookings: ${row.count}`);
        });
        db.get("SELECT COUNT(*) as count FROM favorites", (err, row) => {
            console.log(`📊 Favorites: ${row.count}`);
            console.log("\n🎉 Done!");
            console.log("\n📋 Test Accounts:");
            console.log("================");
            console.log("Admin:     admin@planmarket.com / admin1234");
            console.log("Customer:  customer1@test.com / 123456");
            console.log("Vendor:    vendor1@test.com / 123456");
            console.log("Market:    market1@test.com / 123456");
            db.close();
        });
    }, 500);
});