import db from "./db/database.js"; // แก้ path ตรงนี้ให้ตรงกับในโปรเจกต์ของคุณ

console.log("กำลังอัปเดตฐานข้อมูล...");

// เพิ่มคอลัมน์ notified
db.run("ALTER TABLE bookings ADD COLUMN notified INTEGER DEFAULT 0;", (err) => {
    if (err) {
        console.log("⚠️ แจ้งเตือน (notified):", err.message);
    } else {
        console.log("✅ เพิ่มคอลัมน์ 'notified' สำเร็จ!");
    }
});

// เพิ่มคอลัมน์ reject_reason
db.run("ALTER TABLE bookings ADD COLUMN reject_reason TEXT;", (err) => {
    if (err) {
        console.log("⚠️ แจ้งเตือน (reject_reason):", err.message);
    } else {
        console.log("✅ เพิ่มคอลัมน์ 'reject_reason' สำเร็จ!");
    }
});