import db from "../db/database.js";

export const register = (req, res) => {
  const { name, email, password, role, image_url } = req.body;

  if (!name || !email || !password || !role) {
    return res.status(400).json({ message: "Missing required fields" });
  }

  const sql = `
    INSERT INTO users (name, email, password, role, image_url)
    VALUES (?, ?, ?, ?, ?)
  `;

  db.run(sql, [name, email, password, role, image_url || null], function (err) {
    if (err) {
      return res.status(400).json({ message: err.message });
    }

    return res.status(201).json({
      message: "User registered successfully",
      userId: this.lastID
    });
  });
};

export const login = (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: "Email and password are required" });
  }

  const sql = `
  SELECT id, name, email, role, status, image_url
  FROM users
  WHERE email = ? AND password = ?
  `;

  db.get(sql, [email, password], (err, user) => {
    if (err) {
      return res.status(500).json({ message: err.message });
    }

    if (!user) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    return res.json({
      message: "Login successful",
      user
    });
  });
};