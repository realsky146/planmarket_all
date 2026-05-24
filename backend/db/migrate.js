// database/migrate.js
import db from '../db/database.js'; // เปลี่ยนมาชี้ให้ตรงกับฐานข้อมูลหลักในระบบปัจจุบัน

const migrations = [
    // 1. สั่งลบตาราง bookings เก่าทิ้งไปเลย เพื่อเคลียร์โครงสร้างใหม่ให้หมดจด
    `DROP TABLE IF EXISTS bookings`,

    // 2. สร้างตาราง Zones
    `CREATE TABLE IF NOT EXISTS zones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        market_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (market_id) REFERENCES markets(id)
    )`,

    // 3. สร้างตาราง Stalls
    `CREATE TABLE IF NOT EXISTS stalls (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        zone_id INTEGER NOT NULL,
        stall_number TEXT NOT NULL,
        size TEXT DEFAULT 'medium',
        price_daily REAL,
        price_monthly REAL,
        status TEXT DEFAULT 'available',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (zone_id) REFERENCES zones(id)
    )`,

    // 4. สร้างตาราง Bookings ใหม่ -> มัดรวมคอลัมน์ที่ต้องใช้จริงทั้งหมดไว้ที่นี่เลย!
    `CREATE TABLE IF NOT EXISTS bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stall_id INTEGER NOT NULL,
        seller_id INTEGER NOT NULL,
        shop_name TEXT,
        start_date DATE,
        end_date DATE,
        status TEXT DEFAULT 'pending',
        booking_type TEXT DEFAULT 'daily',
        total_price REAL,
        reason TEXT,          -- ✅ คอลัมน์เก็บเหตุผลในการปฏิเสธ (มีอยู่จริงแน่นอนแล้ว)
        notified INTEGER DEFAULT 0, -- ✅ คอลัมน์สำหรับตรวจสอบการเปิด/ปิด Popup แจ้งเตือน
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (stall_id) REFERENCES stalls(id),
        FOREIGN KEY (seller_id) REFERENCES users(id)
    )`
];

// ข้อมูลทดสอบ
const seedData = [
    // Zones
    `INSERT OR IGNORE INTO zones (id, market_id, name, description) VALUES 
        (1, 1, 'โซน A', 'โซนอาหารสด'),
        (2, 1, 'โซน B', 'โซนเสื้อผ้า'),
        (3, 1, 'โซน C', 'โซนของใช้ทั่วไป')`,

    // Stalls
    `INSERT OR IGNORE INTO stalls (id, zone_id, stall_number, size, price_daily, price_monthly, status) VALUES 
        (1, 1, 'A-001', 'small', 100, 2000, 'available'),
        (2, 1, 'A-002', 'medium', 150, 3000, 'available'),
        (3, 2, 'B-001', 'large', 200, 4000, 'available'),
        (4, 2, 'B-002', 'medium', 150, 3000, 'occupied'),
        (5, 3, 'C-001', 'small', 100, 2000, 'available')`,

    // แถม: สร้างข้อมูลจองแบบ pending ไว้ให้ Admin ทดลองกด Approve / Reject เล่น 1 รายการ
    `INSERT OR IGNORE INTO bookings (id, stall_id, seller_id, shop_name, start_date, end_date, status, booking_type, total_price) VALUES
        (1, 1, 1, 'ร้านข้าวมันไก่ตอน', '2026-06-01', '2026-06-07', 'pending', 'daily', 700)`
];

async function migrate() {
    console.log('🚀 Starting database migration with clean schema...\n');

    // Run migrations
    for (const sql of migrations) {
        try {
            await new Promise((resolve, reject) => {
                db.run(sql, (err) => {
                    if (err) reject(err);
                    else resolve();
                });
            });
            console.log('✅ Migration executed');
        } catch (err) {
            console.log('⚠️ Migration skipped or failed:', err.message);
        }
    }

    // Run seed data
    console.log('\n📦 Seeding data...\n');
    for (const sql of seedData) {
        try {
            await new Promise((resolve, reject) => {
                db.run(sql, (err) => {
                    if (err) reject(err);
                    else resolve();
                });
            });
            console.log('✅ Seed executed');
        } catch (err) {
            console.log('⚠️ Seed skipped:', err.message);
        }
    }

    console.log('\n✨ Migration completed successfully!');
    // วางแทรกโค้ดนี้ลงไปในท่อนท้ายของไฟล์ เพื่อบังคับสั่งอัปเดตตาราง bookings ปัจจุบัน
    db.run(`ALTER TABLE bookings ADD COLUMN reason TEXT`, (err) => {
        if (err) console.log("⚠️ หมายเหตุ: คอลัมน์ reason อาจจะมีอยู่แล้ว");
        else console.log("✅ เพิ่มคอลัมน์ reason เข้าตาราง bookings สำเร็จ!");
    });

    db.run(`ALTER TABLE bookings ADD COLUMN notified INTEGER DEFAULT 0`, (err) => {
        if (err) console.log("⚠️ หมายเหตุ: คอลัมน์ notified อาจจะมีอยู่แล้ว");
        else console.log("✅ เพิ่มคอลัมน์ notified เข้าตาราง bookings สำเร็จ!");
    });
    process.exit(0);
}

migrate();