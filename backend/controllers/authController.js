import db from "../db/database.js";
import bcrypt from "bcryptjs";

// ══════════════════════════════════════════════════════════
// Register - สมัครสมาชิก
// ══════════════════════════════════════════════════════════
export const register = (req, res) => {
  const { name, email, password, phone, role, image_url } = req.body;

  // ✅ Validate required fields
  if (!name || !email || !password || !role) {
    return res.status(400).json({
      success: false,
      message: "กรุณากรอกข้อมูลให้ครบถ้วน",
    });
  }

  // ✅ Validate role
  const validRoles = ['customer', 'vendor', 'market', 'market_owner'];
  if (!validRoles.includes(role)) {
    return res.status(400).json({
      success: false,
      message: "ประเภทผู้ใช้ไม่ถูกต้อง",
    });
  }

  // ✅ Validate email format
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({
      success: false,
      message: "รูปแบบอีเมลไม่ถูกต้อง",
    });
  }

  // ✅ Validate password length
  if (password.length < 6) {
    return res.status(400).json({
      success: false,
      message: "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร",
    });
  }

  // ✅ Check if email already exists
  const checkSql = `SELECT id FROM users WHERE email = ?`;
  db.get(checkSql, [email], (err, existingUser) => {
    if (err) {
      console.error("Check email error:", err.message);
      return res.status(500).json({
        success: false,
        message: "เกิดข้อผิดพลาดในระบบ",
      });
    }

    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: "อีเมลนี้ถูกใช้งานแล้ว",
      });
    }

    // ✅ Hash password before storing
    const hashedPassword = bcrypt.hashSync(password, 10);

    // ✅ Determine initial status based on role
    let status = "active";
    if (role === "market" || role === "market_owner") {
      status = "pending"; // ตลาดต้องรอ admin อนุมัติ
    }

    const sql = `
      INSERT INTO users (name, email, password, phone, role, status, image_url, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'))
    `;

    db.run(
      sql,
      [name, email, hashedPassword, phone || null, role, status, image_url || null],
      function (err) {
        if (err) {
          console.error("Register error:", err.message);
          return res.status(500).json({
            success: false,
            message: "ไม่สามารถสร้างบัญชีได้",
          });
        }

        return res.status(201).json({
          success: true,
          message: "สมัครสมาชิกสำเร็จ",
          userId: this.lastID.toString(),
          role: role,
          status: status,
        });
      }
    );
  });
};

// ══════════════════════════════════════════════════════════
// Login - เข้าสู่ระบบ
// ══════════════════════════════════════════════════════════
export const login = (req, res) => {
  const { email, password, role } = req.body;

  // ✅ Validate required fields
  if (!email || !password) {
    return res.status(400).json({
      success: false,
      message: "กรุณากรอกอีเมลและรหัสผ่าน",
    });
  }

  // ✅ Build query based on role
  let sql = `
    SELECT id, name, email, password, phone, role, status, image_url
    FROM users
    WHERE email = ?
  `;
  const params = [email];

  if (role) {
    // Map role aliases (จากหน้าบ้านส่ง seller มาให้แมปเข้ากับ vendor ใน DB)
    let roleToCheck = role;
    if (role === 'seller') roleToCheck = 'vendor';

    sql += ` AND role = ?`;
    params.push(roleToCheck);
  }

  db.get(sql, params, (err, user) => {
    if (err) {
      console.error("Login error:", err.message);
      return res.status(500).json({
        success: false,
        message: "เกิดข้อผิดพลาดในระบบ",
      });
    }

    if (!user) {
      return res.status(401).json({
        success: false,
        message: role
          ? "ไม่พบบัญชีผู้ใช้ในประเภทนี้"
          : "อีเมลหรือรหัสผ่านไม่ถูกต้อง",
      });
    }

    // ✅ Compare hashed password
    const isValidPassword = bcrypt.compareSync(password, user.password);
    if (!isValidPassword) {
      return res.status(401).json({
        success: false,
        message: "อีเมลหรือรหัสผ่านไม่ถูกต้อง",
      });
    }

    // ✅ 1. ถ้าโดนแบนถาวร (banned) -> บล็อกไม่ให้เข้าสู่ระบบเลยตั้งแต่นาทีแรก
    if (user.status === "banned") {
      return res.status(403).json({
        success: false,
        message: "บัญชีของคุณถูกระงับการใช้งาน",
      });
    }

    // ✅ 2. ถ้าถูกปฏิเสธ (rejected) -> ปล่อยให้ผ่านไปก่อน เพื่อส่ง Object และเหตุผลกลับไปให้ Flutter
    if (user.status === "rejected") {
      const { password: _, ...userWithoutPassword } = user;
      return res.json({
        success: true, // เปลี่ยนเป็น true เพื่อให้แอปผ่านหน้าล็อกอินสำเร็จ
        message: "เข้าสู่ระบบสำเร็จ (ถูกปฏิเสธสิทธิ์)",
        userId: user.id.toString(),
        role: user.role,
        status: user.status,
        user: userWithoutPassword, // ตัวแอปจะเอาไปดึง reject_reason มาโชว์ต่อเอง
      });
    }

    // ✅ Check if market owner is pending
    if ((user.role === "market" || user.role === "market_owner") && user.status === "pending") {
      return res.json({
        success: true,
        message: "บัญชีของคุณรอการอนุมัติ",
        userId: user.id.toString(),
        role: user.role,
        status: user.status,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          role: user.role,
          status: user.status,
          image_url: user.image_url,
        },
      });
    }

    // ✅ Remove password from response
    const { password: _, ...userWithoutPassword } = user;

    return res.json({
      success: true,
      message: "เข้าสู่ระบบสำเร็จ",
      userId: user.id.toString(),
      role: user.role,
      status: user.status,
      user: userWithoutPassword,
    });
  });
};

// ══════════════════════════════════════════════════════════
// Get Sellers - ดึงข้อมูลผู้ค้า (Vendors)
// ══════════════════════════════════════════════════════════
export const getSellers = (req, res) => {
  // แก้ไขจาก role = 'seller' เป็น 'vendor' ให้ตรงกับตอน Register
  const sql = `
    SELECT 
      u.id,
      u.name,
      u.email,
      u.phone,
      u.image_url,
      u.status,
      COALESCE(b.shop_name, u.name) as shop_name,
      m.name as market_name,
      m.id as market_id,
      CASE WHEN b.status = 'approved' THEN 1 ELSE 0 END as is_open
    FROM users u
    LEFT JOIN bookings b ON b.seller_id = u.id AND b.status = 'approved'
    LEFT JOIN stalls s ON b.stall_id = s.id
    LEFT JOIN markets m ON s.market_id = m.id
    WHERE u.role = 'vendor'
    GROUP BY u.id
    ORDER BY is_open DESC, u.name
  `;

  db.all(sql, [], (err, rows) => {
    if (err) {
      console.error("getSellers error:", err);
      return res.status(500).json({ success: false, message: "เกิดข้อผิดพลาดในการดึงข้อมูลผู้ค้า" });
    }
    res.json(rows);
  });
};

// ══════════════════════════════════════════════════════════
// Get Pending Markets - ดึงรายชื่อตลาดที่รออนุมัติ
// ══════════════════════════════════════════════════════════
export const getPendingMarkets = (req, res) => {
  const sql = `
    SELECT id, name, email, phone, status, created_at 
    FROM users 
    WHERE (role = 'market' OR role = 'market_owner') AND status = 'pending'
  `;

  db.all(sql, [], (err, rows) => {
    if (err) {
      console.error("getPendingMarkets error:", err);
      return res.status(500).json({ success: false, message: "เกิดข้อผิดพลาดในการดึงข้อมูล" });
    }
    res.json(rows);
  });
};

// Approve user
export const approveUser = (req, res) => {
  const { id } = req.params;

  db.run("UPDATE users SET status = 'approved' WHERE id = ?", [id], function (err) {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    if (this.changes === 0) {
      return res.status(404).json({ success: false, message: "ไม่พบผู้ใช้" });
    }
    res.json({ success: true, message: "อนุมัติแล้ว" });
  });
};

// Reject user
export const rejectUser = (req, res) => {
  const { id } = req.params;

  db.run("UPDATE users SET status = 'rejected' WHERE id = ?", [id], function (err) {
    if (err) {
      return res.status(500).json({ success: false, message: err.message });
    }
    if (this.changes === 0) {
      return res.status(404).json({ success: false, message: "ไม่พบผู้ใช้" });
    }
    res.json({ success: true, message: "ปฏิเสธแล้ว" });
  });
};

// Get Current User
export const getCurrentUser = (req, res) => {
  const { userId } = req.params;

  if (!userId) {
    return res.status(400).json({
      success: false,
      message: "กรุณาระบุ userId",
    });
  }

  const sql = `
    SELECT id, name, email, phone, role, status, image_url, created_at
    FROM users
    WHERE id = ?
  `;

  db.get(sql, [userId], (err, user) => {
    if (err) {
      return res.status(500).json({
        success: false,
        message: "เกิดข้อผิดพลาดในระบบ",
      });
    }

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "ไม่พบผู้ใช้",
      });
    }

    return res.json({
      success: true,
      user: user,
    });
  });
};

// Update Profile
export const updateProfile = (req, res) => {
  const { userId } = req.params;
  const { name, phone, image_url } = req.body;

  if (!userId) {
    return res.status(400).json({
      success: false,
      message: "กรุณาระบุ userId",
    });
  }

  // ป้องกันกรณีที่ Frontend ส่งสตริงว่างมาเคลียร์ค่า (ยกเว้น image_url กับ phone ที่ยอมให้ว่างได้)
  const finalName = name === "" ? undefined : name;

  const sql = `
    UPDATE users
    SET name = COALESCE(?, name),
        phone = COALESCE(?, phone),
        image_url = COALESCE(?, image_url),
        updated_at = datetime('now')
    WHERE id = ?
  `;

  db.run(sql, [finalName, phone, image_url, userId], function (err) {
    if (err) {
      return res.status(500).json({
        success: false,
        message: "ไม่สามารถอัปเดตข้อมูลได้",
      });
    }

    if (this.changes === 0) {
      return res.status(404).json({
        success: false,
        message: "ไม่พบผู้ใช้",
      });
    }

    return res.json({
      success: true,
      message: "อัปเดตข้อมูลสำเร็จ",
    });
  });
};

// Change Password
export const changePassword = (req, res) => {
  const { userId } = req.params;
  const { currentPassword, newPassword } = req.body;

  if (!userId || !currentPassword || !newPassword) {
    return res.status(400).json({
      success: false,
      message: "กรุณากรอกข้อมูลให้ครบถ้วน",
    });
  }

  if (newPassword.length < 6) {
    return res.status(400).json({
      success: false,
      message: "รหัสผ่านใหม่ต้องมีอย่างน้อย 6 ตัวอักษร",
    });
  }

  const getSql = `SELECT password FROM users WHERE id = ?`;
  db.get(getSql, [userId], (err, user) => {
    if (err || !user) {
      return res.status(404).json({
        success: false,
        message: "ไม่พบผู้ใช้",
      });
    }

    const isValid = bcrypt.compareSync(currentPassword, user.password);
    if (!isValid) {
      return res.status(401).json({
        success: false,
        message: "รหัสผ่านปัจจุบันไม่ถูกต้อง",
      });
    }

    const hashedPassword = bcrypt.hashSync(newPassword, 10);

    const updateSql = `
      UPDATE users SET password = ?, updated_at = datetime('now')
      WHERE id = ?
    `;

    db.run(updateSql, [hashedPassword, userId], function (err) {
      if (err) {
        return res.status(500).json({
          success: false,
          message: "ไม่สามารถเปลี่ยนรหัสผ่านได้",
        });
      }

      return res.json({
        success: true,
        message: "เปลี่ยนรหัสผ่านสำเร็จ",
      });
    });
  });
};
