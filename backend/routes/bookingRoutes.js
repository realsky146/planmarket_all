// routes/bookings.js
import express from 'express';
import {
    getAllBookings,
    getBookingById,
    getUserBookings,
    getRejectedBookings,
    getRecommendedMarkets,
    createBooking,
    approveBooking,
    rejectBooking,
    updateBookingStatus,
    markAsNotified,
    deleteBooking
} from '../controllers/bookingController.js';

const router = express.Router();

// === GET Routes ===
router.get('/', getAllBookings); // ดูการจองทั้งหมด (ดึงข้อมูลโซน/ผู้ขายพ่วงด้วย)
router.get('/:id', getBookingById); // ดูรายละเอียดการจองรายชิ้นด้วย ID
router.get('/user/:userId', getUserBookings); // ดูการจองของ user คนนั้นๆ
router.get('/user/:userId/rejected', getRejectedBookings); // ดูรายการที่ถูกปฏิเสธของ user
router.get('/recommended/:excludeMarketId', getRecommendedMarkets); // ตลาดแนะนำที่ไม่รวม ID นี้

// === POST Routes ===
router.post('/', createBooking); // สร้างรายการจองใหม่
router.post('/:id/notified', markAsNotified); // ทำเครื่องหมายว่ารับทราบแจ้งเตือนแล้ว

// === PUT / PATCH Routes ===
router.put('/:id/status', updateBookingStatus); // อัปเดตสถานะ (รวม)
router.patch('/:id/approve', approveBooking); // อนุมัติการจอง + เปลี่ยนแผงเป็น occupied
router.patch('/:id/reject', rejectBooking); // ปฏิเสธการจอง + ใส่เหตุผล

// === DELETE Routes ===
router.delete('/:id', deleteBooking); // ลบรายการจอง

export default router;