import sqlite3 from "sqlite3";

sqlite3.verbose();

const db = new sqlite3.Database("./planmarket.db", (err) => {
  if (err) {
    console.error("Database connection error:", err.message);
  } else {
    console.log("Connected to SQLite database");
  }
});

export default db;