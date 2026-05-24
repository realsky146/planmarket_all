// force-patch.js
import db from './db/database.js'; // ชี้ไปที่ฐานข้อมูลหลักตัวจริง

console.log("⚡ กำลังบังคับเพิ่มคอลัมน์ที่ขาดหายเข้าฐานข้อมูลตัวจริง...");

// บังคับเพิ่มคอลัมน์ reason
db.run(`ALTER TABLE bookings ADD COLUMN reason TEXT`, (err) => {
    if (err) {
        console.log("❌ คอลัมน์ reason เพิ่มไม่สำเร็จ (อาจจะมีอยู่แล้ว):", err.message);
    } else {
        console.log("✅ [1/2] บังคับเพิ่มคอลัมน์ reason เข้าตาราง bookings สำเร็จ!");
    }

    // บังคับเพิ่มคอลัมน์ notified ต่อทันที
    db.run(`ALTER TABLE bookings ADD COLUMN notified INTEGER DEFAULT 0`, (err2) => {
        if (err2) {
            console.log("❌ คอลัมน์ notified เพิ่มไม่สำเร็จ (อาจจะมีอยู่แล้ว):", err2.message);
        } else {
            console.log("✅ [2/2] บังคับเพิ่มคอลัมน์ notified เข้าตาราง bookings สำเร็จ!");
        }

        console.log("\n🚀 เสร็จสิ้น! ปิดการทำงานโครงสร้างเบสอัปเดตแล้ว");
        process.exit(0);
    });
});