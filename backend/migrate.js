import sqlite3 from 'sqlite3';

const db = new sqlite3.Database('./planmarket.db');

db.run("ALTER TABLE users ADD COLUMN status TEXT DEFAULT 'approved'", (err) => {
  if (err) {
    if (err.message.includes('duplicate column')) {
      console.log('⚠️ column status มีอยู่แล้ว ไม่ต้องทำอะไร');
    } else {
      console.error('❌ error:', err.message);
    }
  } else {
    console.log('✅ เพิ่ม column status สำเร็จ');
  }
  db.close();
});