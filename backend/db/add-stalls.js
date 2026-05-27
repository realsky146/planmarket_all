// db/add-stalls.js
import db from "./database.js";

console.log("🔧 Adding stalls for markets 9-14...");

db.serialize(() => {
    const stallStmt = db.prepare(`
    INSERT OR IGNORE INTO stalls (id, market_id, stall_number, status)
    VALUES (?, ?, ?, ?)
  `);

    const configs = [
        { marketId: 9, start: 900, prefix: "I", count: 10, booked: 2, pending: 1 },
        { marketId: 10, start: 1000, prefix: "J", count: 15, booked: 3, pending: 2 },
        { marketId: 11, start: 1100, prefix: "K", count: 12, booked: 4, pending: 2 },
        { marketId: 12, start: 1200, prefix: "L", count: 20, booked: 5, pending: 3 },
        { marketId: 13, start: 1300, prefix: "M", count: 18, booked: 6, pending: 2 },
        { marketId: 14, start: 1400, prefix: "N", count: 8, booked: 1, pending: 1 },
    ];

    for (const cfg of configs) {
        for (let i = 0; i < cfg.count; i++) {
            const status =
                i < cfg.booked ? "booked" :
                    i < cfg.booked + cfg.pending ? "pending" :
                        "available";
            stallStmt.run(
                cfg.start + i,
                cfg.marketId,
                `${cfg.prefix}${String(i + 1).padStart(2, "0")}`,
                status
            );
        }
        console.log(`✅ Market ${cfg.marketId}: ${cfg.count} stalls added`);
    }

    stallStmt.finalize();

    // Verify
    setTimeout(() => {
        db.all(`
      SELECT
        m.id,
        m.name,
        m.price_per_day,
        m.has_parking,
        m.has_aircon,
        m.open_weekend,
        COUNT(s.id) as total_stalls,
        SUM(CASE WHEN s.status = 'available' THEN 1 ELSE 0 END) as available_stalls
      FROM markets m
      LEFT JOIN stalls s ON s.market_id = m.id
      GROUP BY m.id
      ORDER BY m.id
    `, (err, rows) => {
            if (err) { console.error(err); return; }

            console.log("\n📊 ตลาดทั้งหมดหลัง update:");
            console.log("=".repeat(90));
            console.log(
                "id".padEnd(4),
                "ชื่อ".padEnd(28),
                "ราคา".padEnd(6),
                "จอด".padEnd(5),
                "แอร์".padEnd(5),
                "หยุด".padEnd(5),
                "แผงทั้งหมด".padEnd(12),
                "ว่าง"
            );
            console.log("-".repeat(90));

            for (const r of rows) {
                console.log(
                    String(r.id).padEnd(4),
                    r.name.substring(0, 26).padEnd(28),
                    String(r.price_per_day).padEnd(6),
                    (r.has_parking ? "✅" : "❌").padEnd(5),
                    (r.has_aircon ? "✅" : "❌").padEnd(5),
                    (r.open_weekend ? "✅" : "❌").padEnd(5),
                    String(r.total_stalls).padEnd(12),
                    r.available_stalls
                );
            }
            console.log("=".repeat(90));
            console.log("\n🎉 Done!");
            db.close();
        });
    }, 500);
});