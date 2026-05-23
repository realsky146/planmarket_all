/**
 * migrate2.js — เพิ่ม columns ใหม่และอัปเดต markets ที่มีอยู่แล้ว
 * รัน: node migrate2.js
 */
import sqlite3 from 'sqlite3';
const db = new sqlite3.Database('./planmarket.db');

db.serialize(() => {
  // 1. เพิ่ม columns ถ้ายังไม่มี (safe to run multiple times)
  const addCol = (sql) =>
    db.run(sql, (err) => {
      if (err && !err.message.includes('duplicate column')) {
        console.error('❌ AddCol error:', err.message);
      }
    });

  addCol(`ALTER TABLE markets ADD COLUMN location TEXT DEFAULT ''`);
  addCol(`ALTER TABLE markets ADD COLUMN open_time TEXT DEFAULT '08:00'`);
  addCol(`ALTER TABLE markets ADD COLUMN close_time TEXT DEFAULT '20:00'`);
  addCol(`ALTER TABLE markets ADD COLUMN rating REAL DEFAULT 4.0`);

  // 2. สร้าง favorites table ถ้ายังไม่มี
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
    if (err) console.error('❌ Create favorites error:', err.message);
    else console.log('✅ favorites table ready');
  });

  // 3. อัปเดต markets ที่ location ว่าง ให้ใส่ข้อมูล (อัปเดตตาม name)
  const marketUpdates = [
    { name: 'ตลาดจตุจักร', location: 'จตุจักร กรุงเทพฯ', open_time: '17:00', close_time: '23:00', rating: 4.8 },
    { name: 'ตลาดนัดรถไฟ', location: 'รามอินทรา กรุงเทพฯ', open_time: '18:00', close_time: '23:00', rating: 4.5 },
    { name: 'ตลาดสวนลุม', location: 'พระราม 4 กรุงเทพฯ', open_time: '17:00', close_time: '22:00', rating: 4.3 },
    { name: 'ตลาดนัดสวนลุม', location: 'พระราม 4 กรุงเทพฯ', open_time: '17:00', close_time: '22:00', rating: 4.3 },
    { name: 'ตลาดเซฟวันโก', location: 'สวนหลวง กรุงเทพฯ', open_time: '17:00', close_time: '23:00', rating: 4.2 },
  ];

  // อัปเดตทุก market ที่ location ว่างโดยใช้ชื่อ (ถ้าตรงกัน)
  marketUpdates.forEach(({ name, location, open_time, close_time, rating }) => {
    db.run(
      `UPDATE markets SET location = ?, open_time = ?, close_time = ?, rating = ?
       WHERE name LIKE ? AND (location IS NULL OR location = '')`,
      [location, open_time, close_time, rating, `%${name}%`],
      function (err) {
        if (err) console.error(`❌ Update market "${name}":`, err.message);
        else if (this.changes > 0) console.log(`✅ อัปเดต "${name}" สำเร็จ (${this.changes} rows)`);
      }
    );
  });

  // 4. อัปเดต market ที่เหลือ (ที่ไม่ตรงชื่อข้างบน) ให้มีค่า default
  db.run(
    `UPDATE markets SET location = 'กรุงเทพมหานคร', open_time = '08:00', close_time = '20:00', rating = 4.0
     WHERE location IS NULL OR location = ''`,
    (err) => {
      if (err) console.error('❌ Update remaining markets:', err.message);
      else console.log('✅ อัปเดต markets ที่เหลือแล้ว');
    }
  );

  // 5. แสดงผลสรุป
  db.all(`SELECT id, name, location, open_time, close_time, rating FROM markets`, [], (err, rows) => {
    if (err) { console.error('❌', err.message); return; }
    console.log('\n📋 Markets ในระบบ:');
    rows.forEach(r => {
      console.log(`  [${r.id}] ${r.name} | ${r.location} | ${r.open_time}-${r.close_time} | ★${r.rating}`);
    });
    db.close(() => console.log('\n✅ Migration เสร็จสิ้น'));
  });
});
