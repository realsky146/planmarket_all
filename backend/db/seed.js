// db/seed.js
import db from "./database.js";
import bcrypt from "bcryptjs";

const hashPassword = (password) => bcrypt.hashSync(password, 10);

export const seedDatabase = () => {
    return new Promise((resolve, reject) => {
        console.log("🌱 Starting database seed...");

        db.serialize(() => {
            // ══════════════════════════════════════════════════════════
            // 1. USERS
            // ══════════════════════════════════════════════════════════
            const users = [
                { id: 1, name: "Super Admin", email: "admin@planmarket.com", password: hashPassword("admin1234"), phone: "000-000-0000", role: "super_admin", status: "active" },
                { id: 10, name: "นายสมชาย ใจดี", email: "customer1@test.com", password: hashPassword("123456"), phone: "081-111-1111", role: "customer", status: "active" },
                { id: 11, name: "นางสาวมาลี รักช้อป", email: "customer2@test.com", password: hashPassword("123456"), phone: "081-222-2222", role: "customer", status: "active" },
                { id: 12, name: "นายประยุทธ์ นักกิน", email: "customer3@test.com", password: hashPassword("123456"), phone: "081-333-3333", role: "customer", status: "active" },
                { id: 20, name: "ร้านส้มตำแม่นิด", email: "vendor1@test.com", password: hashPassword("123456"), phone: "082-111-1111", role: "seller", status: "approved" },
                { id: 21, name: "ร้านก๋วยเตี๋ยวลุงเชาว์", email: "vendor2@test.com", password: hashPassword("123456"), phone: "082-222-2222", role: "seller", status: "approved" },
                { id: 22, name: "ร้านเสื้อผ้าแฟชั่น", email: "vendor3@test.com", password: hashPassword("123456"), phone: "082-333-3333", role: "seller", status: "approved" },
                { id: 23, name: "ร้านของเล่นเด็ก", email: "vendor4@test.com", password: hashPassword("123456"), phone: "082-444-4444", role: "seller", status: "approved" },
                { id: 24, name: "ร้านขนมหวาน", email: "vendor5@test.com", password: hashPassword("123456"), phone: "082-555-5555", role: "seller", status: "approved" },
                { id: 30, name: "นายมานะ ตลาดดี", email: "market1@test.com", password: hashPassword("123456"), phone: "083-111-1111", role: "market", status: "approved" },
                { id: 31, name: "นางสมศรี ตลาดนัด", email: "market2@test.com", password: hashPassword("123456"), phone: "083-222-2222", role: "market", status: "approved" },
                { id: 32, name: "นายใหม่ ตลาดใหม่", email: "market3@test.com", password: hashPassword("123456"), phone: "083-333-3333", role: "market", status: "pending" },
            ];

            const userSql = `INSERT OR REPLACE INTO users (id, name, email, password, phone, role, status) VALUES (?, ?, ?, ?, ?, ?, ?)`;
            users.forEach((u) => {
                db.run(userSql, [u.id, u.name, u.email, u.password, u.phone, u.role, u.status]);
            });
            console.log("✅ Users seeded");

            // ══════════════════════════════════════════════════════════
            // 2. MARKETS ✅ เพิ่ม has_parking, has_aircon, open_weekend, price_per_day
            // ══════════════════════════════════════════════════════════
            const markets = [
                {
                    id: 1, name: "ตลาดนัดจตุจักร",
                    description: "ตลาดนัดสุดสัปดาห์ที่ใหญ่ที่สุด",
                    owner_id: 30, location: "จตุจักร, กรุงเทพฯ",
                    open_time: "09:00", close_time: "18:00", rating: 4.8,
                    price_per_day: 300,   // ราคาถูก ✅
                    has_parking: 1,       // มีที่จอดรถ ✅
                    has_aircon: 0,
                    open_weekend: 1,      // เปิดวันหยุด ✅
                },
                {
                    id: 2, name: "ตลาดนัดรถไฟรัชดา",
                    description: "ตลาดกลางคืนชื่อดัง",
                    owner_id: 30, location: "รัชดาภิเษก, กรุงเทพฯ",
                    open_time: "17:00", close_time: "01:00", rating: 4.5,
                    price_per_day: 350,   // ราคาถูก ✅
                    has_parking: 1,       // มีที่จอดรถ ✅
                    has_aircon: 0,
                    open_weekend: 1,      // เปิดวันหยุด ✅
                },
                {
                    id: 3, name: "ตลาดนัดหลังมอ",
                    description: "ตลาดนัดราคาถูก",
                    owner_id: 31, location: "รามคำแหง, กรุงเทพฯ",
                    open_time: "16:00", close_time: "22:00", rating: 4.2,
                    price_per_day: 200,   // ราคาถูกมาก ✅
                    has_parking: 0,
                    has_aircon: 0,
                    open_weekend: 1,      // เปิดวันหยุด ✅
                },
                {
                    id: 4, name: "ตลาดนัดใหม่เอี่ยม",
                    description: "ตลาดเปิดใหม่ รอการอนุมัติ",
                    owner_id: 32, location: "ลาดพร้าว, กรุงเทพฯ",
                    open_time: "10:00", close_time: "20:00", rating: 4.5,
                    price_per_day: 500,
                    has_parking: 0,
                    has_aircon: 0,
                    open_weekend: 0,
                },
                // ── ตลาดเพิ่มเติม เพื่อให้ครอบคลุม preference ทุกแบบ ──
                {
                    id: 5, name: "อินดอร์มาร์เก็ต แอร์เย็น",
                    description: "ตลาดในร่ม มีแอร์เย็นสบาย",
                    owner_id: 30, location: "สุขุมวิท, กรุงเทพฯ",
                    open_time: "10:00", close_time: "21:00", rating: 4.3,
                    price_per_day: 800,
                    has_parking: 1,       // มีที่จอดรถ ✅
                    has_aircon: 1,        // มีแอร์ ✅
                    open_weekend: 1,      // เปิดวันหยุด ✅
                },
                {
                    id: 6, name: "ตลาดของกินราคาถูก",
                    description: "ตลาดอาหารราคาประหยัด",
                    owner_id: 31, location: "มีนบุรี, กรุงเทพฯ",
                    open_time: "08:00", close_time: "14:00", rating: 4.0,
                    price_per_day: 150,   // ราคาถูกมาก ✅
                    has_parking: 0,
                    has_aircon: 0,
                    open_weekend: 0,
                },
                {
                    id: 7, name: "ตลาดอีเว้นท์สเตชั่น",
                    description: "ตลาดอีเว้นท์ทันสมัย",
                    owner_id: 30, location: "พระราม 9, กรุงเทพฯ",
                    open_time: "12:00", close_time: "22:00", rating: 4.6,
                    price_per_day: 1200,
                    has_parking: 1,       // มีที่จอดรถ ✅
                    has_aircon: 1,        // มีแอร์ ✅
                    open_weekend: 1,      // เปิดวันหยุด ✅
                },
                {
                    id: 8, name: "ตลาดโต้รุ่ง คนเมือง",
                    description: "ตลาดดึกสำหรับคนชอบกลางคืน",
                    owner_id: 31, location: "สีลม, กรุงเทพฯ",
                    open_time: "20:00", close_time: "04:00", rating: 4.1,
                    price_per_day: 400,
                    has_parking: 0,
                    has_aircon: 0,
                    open_weekend: 1,      // เปิดวันหยุด ✅
                },
            ];

            // ✅ เพิ่ม has_parking, has_aircon, open_weekend, price_per_day ใน SQL
            const marketSql = `
        INSERT OR REPLACE INTO markets 
          (id, name, description, owner_id, location, 
           open_time, close_time, rating,
           price_per_day, has_parking, has_aircon, open_weekend)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `;

            markets.forEach((m) => {
                db.run(marketSql, [
                    m.id, m.name, m.description, m.owner_id, m.location,
                    m.open_time, m.close_time, m.rating,
                    m.price_per_day, m.has_parking, m.has_aircon, m.open_weekend,
                ]);
            });
            console.log("✅ Markets seeded");

            // ══════════════════════════════════════════════════════════
            // 3. STALLS
            // ══════════════════════════════════════════════════════════
            const stallSql = `INSERT OR REPLACE INTO stalls (id, market_id, stall_number, status) VALUES (?, ?, ?, ?)`;

            // ตลาด 1: 20 แผง
            for (let i = 0; i < 20; i++) {
                const status = i < 5 ? "booked" : i < 8 ? "pending" : "available";
                db.run(stallSql, [100 + i, 1, `A${String(i + 1).padStart(2, "0")}`, status]);
            }
            // ตลาด 2: 15 แผง
            for (let i = 0; i < 15; i++) {
                const status = i < 3 ? "booked" : i < 5 ? "pending" : "available";
                db.run(stallSql, [200 + i, 2, `B${String(i + 1).padStart(2, "0")}`, status]);
            }
            // ตลาด 3: 12 แผง
            for (let i = 0; i < 12; i++) {
                const status = i < 2 ? "booked" : i < 4 ? "pending" : "available";
                db.run(stallSql, [300 + i, 3, `C${String(i + 1).padStart(2, "0")}`, status]);
            }
            // ตลาด 4: 10 แผง
            for (let i = 0; i < 10; i++) {
                db.run(stallSql, [400 + i, 4, `D${String(i + 1).padStart(2, "0")}`, "available"]);
            }
            // ✅ ตลาด 5-8: เพิ่มใหม่
            for (let i = 0; i < 12; i++) {
                const status = i < 3 ? "booked" : i < 5 ? "pending" : "available";
                db.run(stallSql, [500 + i, 5, `E${String(i + 1).padStart(2, "0")}`, status]);
            }
            for (let i = 0; i < 8; i++) {
                db.run(stallSql, [600 + i, 6, `F${String(i + 1).padStart(2, "0")}`, "available"]);
            }
            for (let i = 0; i < 15; i++) {
                const status = i < 4 ? "booked" : i < 6 ? "pending" : "available";
                db.run(stallSql, [700 + i, 7, `G${String(i + 1).padStart(2, "0")}`, status]);
            }
            for (let i = 0; i < 10; i++) {
                const status = i < 2 ? "booked" : "available";
                db.run(stallSql, [800 + i, 8, `H${String(i + 1).padStart(2, "0")}`, status]);
            }
            console.log("✅ Stalls seeded");

            // ══════════════════════════════════════════════════════════
            // 4. BOOKINGS
            // ══════════════════════════════════════════════════════════
            const bookings = [
                { id: 1, stall_id: 100, seller_id: 20, shop_name: "ส้มตำแม่นิด สาขาจตุจักร", status: "approved" },
                { id: 2, stall_id: 203, seller_id: 20, shop_name: "ส้มตำแม่นิด สาขารัชดา", status: "pending" },
                { id: 3, stall_id: 101, seller_id: 21, shop_name: "ก๋วยเตี๋ยวลุงเชาว์", status: "approved" },
                { id: 4, stall_id: 304, seller_id: 21, shop_name: "ก๋วยเตี๋ยวลุงเชาว์ สาขา 2", status: "rejected" },
                { id: 5, stall_id: 102, seller_id: 22, shop_name: "Fashion Hub", status: "approved" },
                { id: 6, stall_id: 200, seller_id: 22, shop_name: "Fashion Hub Night", status: "approved" },
                { id: 7, stall_id: 103, seller_id: 23, shop_name: "Toy Kingdom", status: "approved" },
                { id: 8, stall_id: 302, seller_id: 23, shop_name: "Toy Kingdom Express", status: "pending" },
                { id: 9, stall_id: 210, seller_id: 23, shop_name: "Toy Kingdom Plus", status: "rejected" },
                { id: 10, stall_id: 201, seller_id: 24, shop_name: "Sweet Dreams", status: "approved" },
                { id: 11, stall_id: 300, seller_id: 24, shop_name: "Sweet Dreams Mini", status: "approved" },
                { id: 12, stall_id: 105, seller_id: 24, shop_name: "Sweet Dreams Premium", status: "pending" },
            ];

            const bookingSql = `INSERT OR REPLACE INTO bookings (id, stall_id, seller_id, shop_name, status) VALUES (?, ?, ?, ?, ?)`;
            bookings.forEach((b) => {
                db.run(bookingSql, [b.id, b.stall_id, b.seller_id, b.shop_name, b.status]);
            });
            console.log("✅ Bookings seeded");

            // ══════════════════════════════════════════════════════════
            // 5. FAVORITES
            // ══════════════════════════════════════════════════════════
            const favorites = [
                { user_id: 10, seller_id: 20 },
                { user_id: 10, seller_id: 21 },
                { user_id: 10, seller_id: 24 },
                { user_id: 11, seller_id: 22 },
                { user_id: 11, seller_id: 24 },
                { user_id: 12, seller_id: 20 },
                { user_id: 12, seller_id: 23 },
                { user_id: 12, seller_id: 24 },
            ];

            const favoriteSql = `INSERT OR IGNORE INTO favorites (user_id, seller_id) VALUES (?, ?)`;
            favorites.forEach((f, index) => {
                db.run(favoriteSql, [f.user_id, f.seller_id], (err) => {
                    if (index === favorites.length - 1) {
                        console.log("✅ Favorites seeded");
                        console.log("🎉 Database seeding completed!");
                        resolve();
                    }
                });
            });
        });
    });
};