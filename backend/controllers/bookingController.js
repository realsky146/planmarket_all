import db from "../db/database.js";

export const createBooking = (req, res) => {
  const { stall_id, seller_id, shop_name } = req.body;

  if (!stall_id || !seller_id || !shop_name) {
    return res.status(400).json({ message: "Missing required fields" });
  }

  db.get(`SELECT * FROM stalls WHERE id = ?`, [stall_id], (err, stall) => {
    if (err) {
      return res.status(500).json({ message: err.message });
    }

    if (!stall) {
      return res.status(404).json({ message: "Stall not found" });
    }

    if (stall.status !== "available") {
      return res.status(400).json({ message: "Stall is not available" });
    }

    const insertSql = `
      INSERT INTO bookings (stall_id, seller_id, shop_name, status)
      VALUES (?, ?, ?, 'pending')
    `;

    db.run(insertSql, [stall_id, seller_id, shop_name], function (insertErr) {
      if (insertErr) {
        return res.status(500).json({ message: insertErr.message });
      }

      const bookingId = this.lastID;

      db.run(
        `UPDATE stalls SET status = 'pending' WHERE id = ?`,
        [stall_id],
        (updateErr) => {
          if (updateErr) {
            return res.status(500).json({ message: updateErr.message });
          }

          return res.status(201).json({
            message: "Booking created successfully",
            bookingId
          });
        }
      );
    });
  });
};

export const approveBooking = (req, res) => {
  const bookingId = req.params.id;

  db.get(`SELECT * FROM bookings WHERE id = ?`, [bookingId], (err, booking) => {
    if (err) {
      return res.status(500).json({ message: err.message });
    }

    if (!booking) {
      return res.status(404).json({ message: "Booking not found" });
    }

    db.run(`UPDATE bookings SET status = 'approved' WHERE id = ?`, [bookingId], (bookingErr) => {
      if (bookingErr) {
        return res.status(500).json({ message: bookingErr.message });
      }

      db.run(`UPDATE stalls SET status = 'booked' WHERE id = ?`, [booking.stall_id], (stallErr) => {
        if (stallErr) {
          return res.status(500).json({ message: stallErr.message });
        }

        return res.json({ message: "Booking approved" });
      });
    });
  });
};

export const rejectBooking = (req, res) => {
  const bookingId = req.params.id;

  db.get(`SELECT * FROM bookings WHERE id = ?`, [bookingId], (err, booking) => {
    if (err) {
      return res.status(500).json({ message: err.message });
    }

    if (!booking) {
      return res.status(404).json({ message: "Booking not found" });
    }

    db.run(`UPDATE bookings SET status = 'rejected' WHERE id = ?`, [bookingId], (bookingErr) => {
      if (bookingErr) {
        return res.status(500).json({ message: bookingErr.message });
      }

      db.run(`UPDATE stalls SET status = 'available' WHERE id = ?`, [booking.stall_id], (stallErr) => {
        if (stallErr) {
          return res.status(500).json({ message: stallErr.message });
        }

        return res.json({ message: "Booking rejected" });
      });
    });
  });
};