// db/update-markets.js
import db from "./database.js";

console.log("🔧 Updating market data...");

// ข้อมูลจริงสำหรับแต่ละตลาด
// อ้างอิงจากชื่อใน description
const updates = [
    // id 1-8 ที่ seed ไปแล้ว (ครบแล้ว ไม่ต้องแก้)

    // id 9: ตลาดอินดี้ ชวนชิม — "ของกินสตรีทฟู้ดราคาถูก มีที่จอดรถสะดวกสบาย"
    { id: 9, price_per_day: 250, has_parking: 1, has_aircon: 0, open_weekend: 1 },

    // id 10: นภา พลาซ่าคลองถม — "ตลาดนัดติดแอร์ มีของเล่นและอีเว้นท์"
    { id: 10, price_per_day: 600, has_parking: 0, has_aircon: 1, open_weekend: 1 },

    // id 11: ตลาดนัดท้ายรถ เปิดท้าย — "เปิดเฉพาะวันหยุด เสาร์-อาทิตย์"
    { id: 11, price_per_day: 180, has_parking: 1, has_aircon: 0, open_weekend: 1 },

    // id 12: ตลาดค้าส่งราคาส่ง — "ราคาถูกที่สุดในย่าน"
    { id: 12, price_per_day: 100, has_parking: 1, has_aircon: 0, open_weekend: 0 },

    // id 13: ตลาดโต้รุ่ง คนเมือง — "มีที่จอดรถรองรับทัวร์ลง"
    { id: 13, price_per_day: 350, has_parking: 1, has_aircon: 0, open_weekend: 1 },

    // id 14: ถนนคนเดิน สุภาพร — "เปิดเฉพาะค่ำวันหยุด"
    { id: 14, price_per_day: 200, has_parking: 0, has_aircon: 0, open_weekend: 1 },
];

db.serialize(() => {
    const stmt = db.prepare(`
    UPDATE markets
    SET
      price_per_day = ?,
      has_parking   = ?,
      has_aircon    = ?,
      open_weekend  = ?
    WHERE id = ?
  `);

    for (const m of updates) {
        stmt.run(
            m.price_per_day,
            m.has_parking,
            m.has_aircon,
            m.open_weekend,
            m.id,
            (err) => {
                if (err) {
                    console.error(`❌ Error updating market ${m.id}:`, err.message);
                }
            }
        );
        console.log(`✅ Updated market id=${m.id}`);
    }

    stmt.finalize();

    // ── Verify ────────────────────────────────────────────
    setTimeout(() => {
        db.all(`
      SELECT id, name, price_per_day, has_parking, has_aircon, open_weekend
      FROM markets
      ORDER BY id
    `, (err, rows) => {
            if (err) {
                console.error("❌ Error:", err.message);
                return;
            }

            console.log("\n📊 ข้อมูลตลาดทั้งหมดใน DB:");
            console.log("=".repeat(80));
            console.log(
                "id".padEnd(4),
                "ชื่อ".padEnd(30),
                "ราคา".padEnd(8),
                "จอดรถ".padEnd(8),
                "แอร์".padEnd(6),
                "หยุด"
            );
            console.log("-".repeat(80));

            for (const r of rows) {
                console.log(
                    String(r.id).padEnd(4),
                    r.name.padEnd(30),
                    String(r.price_per_day).padEnd(8),
                    (r.has_parking ? "✅" : "❌").padEnd(8),
                    (r.has_aircon ? "✅" : "❌").padEnd(6),
                    r.open_weekend ? "✅" : "❌"
                );
            }
            console.log("=".repeat(80));
            console.log("\n Done!");
            db.close();
        });
    }, 300);
});